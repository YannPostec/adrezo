package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.SecurityContext;
import java.security.Principal;
import com.google.gson.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;

@Path("/admin")
@Secured({Role.API})
public class AdminAPI {
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(AdminAPI.class);
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


	@GET
	@Secured({Role.ADMIN})
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
	@Secured({Role.ADMIN})
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
	@Secured({Role.ADMIN})
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
	@Secured({Role.ADMIN})
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
