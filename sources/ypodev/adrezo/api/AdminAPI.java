package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import javax.servlet.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.SecurityContext;
import org.quartz.*;
import org.quartz.ee.servlet.*;
import org.quartz.impl.*;
import org.quartz.impl.matchers.*;
import java.security.Principal;
import com.google.gson.*;
import org.apache.logging.log4j.*;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;
import ypodev.adrezo.util.IPFmt;

@Path("/admin")
@Secured({Role.API})
public class AdminAPI {
	
	@Context
	ServletContext servletContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = LogManager.getLogger(AdminAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}

	private class ApiSite {
		private Integer id;
		private String name;
		private String code;
		private Integer ctx;
	}
	private class ApiTplStdSite {
		private Integer id;
		private String name;
		private String code;
		private Integer ctx;
		private Integer tpl;
		private String ip;
		private Integer surnet;
	}
	private class ApiTplNonStdSite {
		private Integer id;
		private String name;
		private String code;
		private Integer ctx;
		private Integer tpl;
	}
	private class ApiCtx {
		private Integer id;
		private String name;
		private Integer site_main;
	}
	private class ApiCtxList {
		private List<ApiCtx> ctx_list = new ArrayList<ApiCtx>();
	}
	private class ApiSiteList {
		private List<ApiSite> site_list = new ArrayList<ApiSite>();
	}

	private String listAvailable(ArrayList<String> a,ArrayList<String> e) {
		for (int i=0;i<e.size();i++) { a.remove(e.get(i).toString()); }
		if (a.size()>0) {
			return a.get(0).toString();
		} else {
			return "";
		}
	}
  private String NSSearch(String templateid, String siteid, String sitectx, String sitecod, String sitename) {
  	HashMap<String,String> existing = new HashMap<String,String>();
		ArrayList<String> allnet = new ArrayList<String>();
		ArrayList<String> existnet = new ArrayList<String>();
		Connection conn = null;
		Statement stmt = null;
		Statement stmtres = null;
		ResultSet result = null;
		ResultSet resother = null;
		String myresult = "";
		try {
			javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			result = stmt.executeQuery("select id,vid,mask,def,gw,bc,surnet from tpl_subnet_display where tpl="+templateid);
			boolean bHadResults = false;
			boolean bContinue = true;
			while (bContinue && result.next()) {
				bHadResults = true;
				String myid = String.valueOf(result.getInt("id"));
				String mydef = result.getString("def");
				String mygw = result.getString("gw");
				String mybc = result.getString("bc");
				String surnets = result.getString("surnet");
				String myvid = String.valueOf(result.getInt("vid"));
				String mymask = String.valueOf(result.getInt("mask"));
				mydef = mydef.replaceAll("#CODE#",sitecod);
				mydef = mydef.replaceAll("#SITE#",sitename);
				stmtres = conn.createStatement();
				boolean bFound = false;
				for(String surnetid : surnets.split(",")) {
					if (!bFound) {
						String mainip = "";
						String mainmask = "";
						resother = stmtres.executeQuery("select ip,mask from surnets where id="+surnetid);
						while (resother.next()) {
							mainip = resother.getString("ip");
							mainmask = String.valueOf(resother.getInt("mask"));
						}
						resother.close();
						resother = stmtres.executeQuery("select ip,mask from surnets where parent="+surnetid);
						while (resother.next()) { existing.put(resother.getString("ip"),String.valueOf(resother.getInt("mask"))); }
						resother.close();
						resother = stmtres.executeQuery("select ip,mask from subnets where surnet="+surnetid);
						while (resother.next()) { existing.put(resother.getString("ip"),String.valueOf(resother.getInt("mask"))); }
						resother.close();
						for(Map.Entry<String,String> entry : existing.entrySet()) {
							Integer m = Integer.parseInt(entry.getValue());
							Integer n = Integer.parseInt(mymask);
							if (m<n) { existnet.addAll(IPFmt.SplitSubnet(entry.getKey(),entry.getValue(),mymask)); }
							if (m==n) { existnet.add(entry.getKey()); }
							if (m>n) { existnet.add(IPFmt.GetNetwork(entry.getKey(),mymask)); }
						}
						allnet.addAll(IPFmt.SplitSubnet(mainip,mainmask,mymask));
						String myip = listAvailable(allnet,existnet);
						if (!myip.equals("")) {
							bFound=true;
							String gw = IPFmt.addTwoIP(myip,mygw);
							String bc = IPFmt.addTwoIP(myip,mybc);
							String myvlan = "";
							resother = stmtres.executeQuery("select id from vlan where vid = " + myvid + " and site = " + siteid);
							while (resother.next()) { myvlan = String.valueOf(resother.getInt("id")); }
							resother.close();resother=null;
							stmtres.executeUpdate("insert into subnets (id,ctx,site,ip,mask,def,gw,bc,vlan) values (" + DbSeqNextval.dbSeqNextval("subnets_seq") + "," + sitectx + "," + siteid + ",'" + myip + "'," + mymask + ",'" + mydef + "','" + gw + "','" + bc + "'," + myvlan+")");
							myresult += "Subnet created. " + IPFmt.displayIP(myip) + "/" + mymask + ", " + mydef + "\n";
						}
						existing.clear();
						allnet.clear();
						existnet.clear();
					}
				}
				if (!bFound) {
					printLog("NSSearch: No subnet found for "+mydef+", /"+mymask,null);
					bContinue = false;
				}
				stmtres.close();stmtres = null;
			}
			result.close();result = null;
			if (!bHadResults) {
				printLog("NSSearch: No subnets defined",null);
			}
			stmt.close();stmt = null;
			conn.close();conn = null;
		} catch (Exception e) { printLog("NSSearch: ",e); }
		finally {    
			if (result != null) { try { result.close(); } catch (SQLException e) { ; } result = null; }
			if (resother != null) { try { resother.close(); } catch (SQLException e) { ; } resother = null; }
			if (stmtres != null) { try { stmtres.close(); } catch (SQLException e) { ; } stmtres = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
	    if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}

		return myresult;
  }
  private String NSJob() {
		String jobname = "NormAddSubnetJob";
		String myresult = "";
    try {
			StdSchedulerFactory stdSchedulerFactory = (StdSchedulerFactory) servletContext.getAttribute(QuartzInitializerListener.QUARTZ_FACTORY_KEY);
		  Scheduler scheduler = stdSchedulerFactory.getScheduler();
			for (String groupName : scheduler.getJobGroupNames()) {
				for (JobKey jobKey : scheduler.getJobKeys(GroupMatcher.jobGroupEquals(groupName))) {
					String jobName = jobKey.getName();
					String jobGroup = jobKey.getGroup();
					if (jobName.equals(jobname)) { scheduler.triggerJob(jobKey); }
				}
			}
			myresult = "Job NormAddSubnet launched\n";
		} catch (Exception e) { printLog("NSJob: ",e); }
		
		return myresult;
  }

	@GET
	@Secured
	@Path("/site/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response siteinfoRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("SiteInfo/Check: Site not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id,name,cod_site,ctx from sites where id="+site);
				if (rs.next()) {
					ApiSite mysite = new ApiSite();
						mysite.id = rs.getInt("id");
    				mysite.name = (rs.getString("name")==null)?"":rs.getString("name");
		    		mysite.code = rs.getString("cod_site");
    				mysite.ctx = rs.getInt("ctx");
						Gson gson = new Gson();
						result = gson.toJson(mysite);
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Path("/site/{site}")
	@Secured({Role.ADMIN})
	@Produces(MediaType.TEXT_PLAIN)
	public Response sitedelRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("SiteDelete/Check: Site not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from sites where id="+site);
				if (rs.next()) {
   				try {
						String myid=String.valueOf(rs.getInt("id"));
    				stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from sites where id="+myid);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("SiteDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SiteDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteDelete/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/site/")
	@Secured({Role.ADMIN})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response siteaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String incode="";
		String inctx="";
		try {
			Gson gson = new Gson();
			ApiSite obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiSite.class);
			inname = (obj.name==null)?"":obj.name;
			incode = obj.code;
 			inctx = String.valueOf(obj.ctx);
		} catch (Exception e) { printLog("SiteAdd/ReadJSON: ",e); }
		if (incode==null) { printLog("SiteAdd/Check: code must be not null",null); }
		else {
			if (incode.length()>8) { printLog("SiteAdd/Check: code too long",null); }
		}
		if (inname.length()>60) { printLog("SiteAdd/Check: name too long",null); }
		try { Integer.parseInt(inctx); } catch (NumberFormatException e) { printLog("SiteAdd/Check: ctx not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			ResultSet rsv = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from contextes where id="+inctx);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into sites (id,ctx,name,cod_site) values ("+DbSeqNextval.dbSeqNextval("sites_seq")+","+inctx+",'"+inname+"','"+incode+"')");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("sites_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Site "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Site created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.executeUpdate("insert into vlan (id,vid,def,site) values ("+DbSeqNextval.dbSeqNextval("vlan_seq")+",0,'No Vlan',"+DbSeqCurrval.dbSeqCurrval("sites_seq")+")");
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("SiteAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Context not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("SiteAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SiteAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/site/template/std/")
	@Secured({Role.ADMIN})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response siteaddstdtplRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String incode="";
		String inctx="";
		String intpl="";
		String inip="";
		String infip="";
		String insur="";
		try {
			Gson gson = new Gson();
			ApiTplStdSite obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiTplStdSite.class);
			inname = (obj.name==null)?"":obj.name;
			incode = obj.code;
 			inctx = String.valueOf(obj.ctx);
 			intpl = String.valueOf(obj.tpl);
 			infip = obj.ip;
 			inip = IPFmt.renderIP(infip);
 			insur = String.valueOf(obj.surnet);
		} catch (Exception e) { printLog("SiteTemplateAdd-Std/ReadJSON: ",e); }
		if (incode==null) { printLog("SiteTemplateAdd-Std/Check: code must be not null",null); }
		else {
			if (incode.length()>8) { printLog("SiteTemplateAdd-Std/Check: code too long",null); }
		}
		if (inname.length()>60) { printLog("SiteTemplateAdd-Std/Check: name too long",null); }
		try { Integer.parseInt(inctx); } catch (NumberFormatException e) { printLog("SiteTemplateAdd-Std/Check: ctx not a number",null); }
		try { Integer.parseInt(intpl); } catch (NumberFormatException e) { printLog("SiteTemplateAdd-Std/Check: tpl not a number",null); }
		try { Integer.parseInt(insur); } catch (NumberFormatException e) { printLog("SiteTemplateAdd-Std/Check: surnet not a number",null); }
		if (infip==null) { printLog("SiteTemplateAdd-Std/Check: IP must be not null",null); }
		else {
			if (!IPFmt.verifIP(infip)) { printLog("SiteTemplateAdd-Std/Check : IP not valid",null); }
		}
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			Statement stmtvlan = null;
			Statement stmtsubnet = null;
			ResultSet rs = null;
			ResultSet rsv = null;
			ResultSet rsvlan = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select name,mask from tpl_site where id="+intpl);					
				if (rs.next()) {
					Integer tplmask = rs.getInt("mask");
					String tplname = rs.getString("name");
					if (tplmask==0) {
						errcode=500;
						result="Template is non-standard, use appropriate endpoint";
					} else {
  					try {
	   					stmtup = conn.createStatement();
							stmtup.executeUpdate("insert into sites (id,ctx,name,cod_site) values ("+DbSeqNextval.dbSeqNextval("sites_seq")+","+inctx+",'"+inname+"','"+incode+"')");
							String myquery = "select "+DbSeqCurrval.dbSeqCurrval("sites_seq")+" as seq";
							if (db_type.equals("oracle")) { myquery += " from dual"; }
							rsv = stmtup.executeQuery(myquery);
							String mysite="";
							if (rsv.next()) {
								mysite=String.valueOf(rsv.getInt("seq"));
								result+="Site "+mysite+" created.\n";
							} else { result+="Site created, no id returned. Stopping\n"; }
							rsv.close();
							if (!mysite.equals("")) {
								rsv=stmtup.executeQuery("select * from tpl_vlan where tpl="+intpl);
								stmtvlan = conn.createStatement();
								while (rsv.next()) {
									String myvid = String.valueOf(rsv.getInt("vid"));
									String mydef = rsv.getString("def");
									String myvlanid = String.valueOf(rsv.getInt("id"));
									mydef = mydef.replaceAll("#CODE#",incode);
									mydef = mydef.replaceAll("#SITE#",inname);
									stmtvlan.executeUpdate("insert into vlan (id,vid,def,site) values ("+DbSeqNextval.dbSeqNextval("vlan_seq")+","+myvid+",'"+mydef+"',"+mysite+")");
									myquery = "select "+DbSeqCurrval.dbSeqCurrval("vlan_seq")+" as seq";
									if (db_type.equals("oracle")) { myquery += " from dual"; }
									rsvlan = stmtvlan.executeQuery(myquery);
									String myvlan="";
									if (rsvlan.next()) {
										myvlan=String.valueOf(rsvlan.getInt("seq"));
										result+="Vlan "+myvlan+" created.\n";
									} else { result+="Vlan created, no id returned. Stopping\n"; }
									rsvlan.close();
									if (!myvlan.equals("")) {
										rsvlan=stmtvlan.executeQuery("select * from tpl_subnet where tpl="+intpl+" and vlan="+myvlanid);
										while (rsvlan.next()) {
											String myip = rsvlan.getString("ip");
											String mymask = String.valueOf(rsvlan.getInt("mask"));
											String mysubdef = rsvlan.getString("def");
											mysubdef = mysubdef.replaceAll("#CODE#",incode);
											mysubdef = mysubdef.replaceAll("#SITE#",inname);
											String mygw = rsvlan.getString("gw");
											String mybc = rsvlan.getString("bc");
											stmtsubnet = conn.createStatement();
											String newip = IPFmt.addTwoIP(inip,myip);
											stmtsubnet.executeUpdate("insert into subnets (id,ctx,site,ip,mask,def,gw,bc,vlan) values ("+DbSeqNextval.dbSeqNextval("subnets_seq")+","+inctx+","+mysite+",'"+newip+"',"+mymask+",'"+mysubdef+"','"+IPFmt.addTwoIP(inip,mygw)+"','"+IPFmt.addTwoIP(inip,mybc)+"',"+myvlan+")");
											result+="Subnet "+IPFmt.displayIP(newip)+"/"+mymask+" created.\n";
											stmtsubnet.close();stmtsubnet=null;
										}
										rsvlan.close();rsvlan=null;
									}
								}
								rsv.close();rsv=null;
								stmtvlan.executeUpdate("insert into surnets (id,ip,mask,def,infos,parent,calc) values ("+DbSeqNextval.dbSeqNextval("surnets_seq")+",'"+inip+"',"+String.valueOf(tplmask)+",'"+inname+"','',"+insur+",1)");
								result+="Surnet created.\n";
								stmtvlan.close();stmtvlan=null;
								result+=NSJob();
							}
							stmtup.close();stmtup=null;
						} catch (Exception e) { printLog("SiteTemplateAdd-Std/Failed: ",e); }
					}
				} else {
					errcode=404;
					result="Template not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteTemplateAdd-Std/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close rsv",e); } rsv = null; }
				if (rsvlan != null) { try { rsvlan.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close rsvlan",e); } rsvlan = null; }				
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close stmtup",e); } stmtup = null; }
				if (stmtvlan != null) { try { stmtvlan.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close stmtvlan",e); } stmtvlan = null; }
				if (stmtsubnet != null) { try { stmtsubnet.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close stmtsubnet",e); } stmtsubnet = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-Std/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/site/template/nonstd/")
	@Secured({Role.ADMIN})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response siteaddnonstdtplRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String incode="";
		String inctx="";
		String intpl="";
		try {
			Gson gson = new Gson();
			ApiTplNonStdSite obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiTplNonStdSite.class);
			inname = (obj.name==null)?"":obj.name;
			incode = obj.code;
 			inctx = String.valueOf(obj.ctx);
 			intpl = String.valueOf(obj.tpl);
		} catch (Exception e) { printLog("SiteTemplateAdd-NonStd/ReadJSON: ",e); }
		if (incode==null) { printLog("SiteTemplateAdd-NonStd/Check: code must be not null",null); }
		else {
			if (incode.length()>8) { printLog("SiteTemplateAdd-NonStd/Check: code too long",null); }
		}
		if (inname.length()>60) { printLog("SiteTemplateAdd-NonStd/Check: name too long",null); }
		try { Integer.parseInt(inctx); } catch (NumberFormatException e) { printLog("SiteTemplateAdd-NonStd/Check: ctx not a number",null); }
		try { Integer.parseInt(intpl); } catch (NumberFormatException e) { printLog("SiteTemplateAdd-NonStd/Check: tpl not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			Statement stmtvlan = null;
			Statement stmtsubnet = null;
			ResultSet rs = null;
			ResultSet rsv = null;
			ResultSet rsvlan = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select name,mask from tpl_site where id="+intpl);					
				if (rs.next()) {
					Integer tplmask = rs.getInt("mask");
					String tplname = rs.getString("name");
					if (tplmask>0) {
						errcode=500;
						result="Template is standard, use appropriate endpoint";
					} else {
  					try {
	   					stmtup = conn.createStatement();
							stmtup.executeUpdate("insert into sites (id,ctx,name,cod_site) values ("+DbSeqNextval.dbSeqNextval("sites_seq")+","+inctx+",'"+inname+"','"+incode+"')");
							String myquery = "select "+DbSeqCurrval.dbSeqCurrval("sites_seq")+" as seq";
							if (db_type.equals("oracle")) { myquery += " from dual"; }
							rsv = stmtup.executeQuery(myquery);
							String mysite="";
							if (rsv.next()) {
								mysite=String.valueOf(rsv.getInt("seq"));
								result+="Site "+mysite+" created.\n";
							} else { result+="Site created, no id returned. Stopping\n"; }
							rsv.close();
							if (!mysite.equals("")) {
								rsv=stmtup.executeQuery("select * from tpl_vlan where tpl="+intpl);
								stmtvlan = conn.createStatement();
								while (rsv.next()) {
									String myvid = String.valueOf(rsv.getInt("vid"));
									String mydef = rsv.getString("def");
									String myvlanid = String.valueOf(rsv.getInt("id"));
									mydef = mydef.replaceAll("#CODE#",incode);
									mydef = mydef.replaceAll("#SITE#",inname);
									stmtvlan.executeUpdate("insert into vlan (id,vid,def,site) values ("+DbSeqNextval.dbSeqNextval("vlan_seq")+","+myvid+",'"+mydef+"',"+mysite+")");
									myquery = "select "+DbSeqCurrval.dbSeqCurrval("vlan_seq")+" as seq";
									if (db_type.equals("oracle")) { myquery += " from dual"; }
									rsvlan = stmtvlan.executeQuery(myquery);
									String myvlan="";
									if (rsvlan.next()) {
										myvlan=String.valueOf(rsvlan.getInt("seq"));
										result+="Vlan "+myvlan+" created.\n";
									} else { result+="Vlan created, no id returned.\n"; }
									rsvlan.close();
								}
								rsv.close();rsv=null;
								stmtvlan.close();stmtvlan=null;
								result+=NSSearch(intpl,mysite,inctx,incode,inname);
								result+=NSJob();
							}
							stmtup.close();stmtup=null;
						} catch (Exception e) { printLog("SiteTemplateAdd-NonStd/Failed: ",e); }
					}
				} else {
					errcode=404;
					result="Template not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteTemplateAdd-NonStd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close rsv",e); } rsv = null; }
				if (rsvlan != null) { try { rsvlan.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close rsvlan",e); } rsvlan = null; }				
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close stmtup",e); } stmtup = null; }
				if (stmtvlan != null) { try { stmtvlan.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close stmtvlan",e); } stmtvlan = null; }
				if (stmtsubnet != null) { try { stmtsubnet.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close stmtsubnet",e); } stmtsubnet = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteTemplateAdd-NonStd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
		
	@PATCH
	@Path("/site/{site}")
	@Secured({Role.ADMIN})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response sitepatchRESTService(@PathParam("site") String site,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String incode="";
		try {
			Gson gson = new Gson();
			ApiSite obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiSite.class);
			inname = obj.name;
			incode = obj.code;
		} catch (Exception e) { printLog("SiteMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>60) { printLog("SiteMod/Check: name too long",null); }
		if (incode!=null&&incode.length()>8) { printLog("SiteMod/Check: code too long",null); }
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("SiteMod/Check: site not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from sites where id="+site);					
				if (rs.next()) {
  				try {
						if (inname==null && incode==null) {
							errcode=200;
							result="Nothing to patch";
						} else {
	   					stmtup = conn.createStatement();
	   					String queryupdt = "update sites set ";
	   					if (inname!=null) { queryupdt = queryupdt + "name='"+inname+"'"; }
	   					if (inname!=null&&incode!=null) { queryupdt = queryupdt + ","; }
							if (incode!=null) { queryupdt = queryupdt + "cod_site='"+incode+"'"; }
							queryupdt = queryupdt + " where id=" + site;
							stmtup.executeUpdate(queryupdt);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("SiteMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SiteMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SiteMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SiteMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SiteMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SiteMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/context/{ctx}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ctxinfoRESTService(@PathParam("ctx") String ctx) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(ctx); } catch (NumberFormatException e) { printLog("CtxInfo/Check: Context not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id,name,site_main from contextes where id="+ctx);
				if (rs.next()) {
					ApiCtx myctx = new ApiCtx();
						myctx.id = rs.getInt("id");
    				myctx.name = rs.getString("name");
		    		myctx.site_main = rs.getInt("site_main");
						Gson gson = new Gson();
						result = gson.toJson(myctx);
				} else {
					errcode=404;
					result="Context not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("CtxInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("CtxInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("CtxInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("CtxInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/context/listsite/{ctx}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ctxlistsiteRESTService(@PathParam("ctx") String ctx) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(ctx); } catch (NumberFormatException e) { printLog("CtxListSite/Check: Context not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id,name,cod_site from sites where ctx="+ctx);
				if (rs.isBeforeFirst()) {
					ApiSiteList mylist = new ApiSiteList();
					while (rs.next()) {
						ApiSite mysite = new ApiSite();
						mysite.id = rs.getInt("id");
    				mysite.name = rs.getString("name");
		    		mysite.code = rs.getString("cod_site");
						mylist.site_list.add(mysite);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Site list empty or context not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("CtxListSite/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("CtxListSite/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("CtxListSite/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("CtxListSite/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/context/list")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ctxlistRESTService() {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select id,name,site_main from contextes");
			if (rs.isBeforeFirst()) {
				ApiCtxList mylist = new ApiCtxList();
				while (rs.next()) {
					ApiCtx myctx = new ApiCtx();
					myctx.id = rs.getInt("id");
    			myctx.name = rs.getString("name");
		   		myctx.site_main = rs.getInt("site_main");
					mylist.ctx_list.add(myctx);
				}
				Gson gson = new Gson();
				result = gson.toJson(mylist);
			} else {
				errcode=404;
				result="Context list empty";
			}
			rs.close();rs=null;				
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) { printLog("CtxList/Global: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("CtxList/Close rs",e); } rs = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("CtxList/Close stmt",e); } stmt = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("CtxList/Close conn",e); } conn = null; }				
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Path("/context/{ctx}")
	@Secured({Role.ADMIN})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response ctxpatchRESTService(@PathParam("ctx") String ctx,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		try {
			Gson gson = new Gson();
			ApiCtx obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiCtx.class);
			inname = obj.name;
		} catch (Exception e) { printLog("CtxMod/ReadJSON: ",e); }
		if (inname==null) { printLog("CtxMod/Check: name must be not null",null); }
		if (inname!=null&&inname.length()>30) { printLog("CtxMod/Check: name too long",null); }
		try { Integer.parseInt(ctx); } catch (NumberFormatException e) { printLog("CtxMod/Check: Context not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from contextes where id="+ctx);					
				if (rs.next()) {
  				try {
   					stmtup = conn.createStatement();
						stmtup.executeUpdate("update contextes set name='"+inname+"' where id="+ctx);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("CtxMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Context not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("CtxMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("CtxMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("CtxMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("CtxMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("CtxMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
}
