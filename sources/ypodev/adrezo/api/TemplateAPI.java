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
import org.apache.logging.log4j.*;
import ypodev.adrezo.beans.IpDispoBean;
import ypodev.adrezo.util.IPFmt;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;

@Path("/template")
@Secured({Role.API})
public class TemplateAPI {
	
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = LogManager.getLogger(TemplateAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiTplSiteList {
		private List<ApiTplSite> site_list = new ArrayList<ApiTplSite>();
	}
	private class ApiTplSite {
		private Integer id;
		private String name;
		private Integer mask;
		private Integer nbvlan;
		private Integer nbsubnet;
	}
	private class TplApiSubnetList {
		private List<TplApiSubnet> subnet_list = new ArrayList<TplApiSubnet>();
	}
	private class TplApiSubnet {
		private Integer id;
		private String name;
		private Integer mask;
		private String ip;
		private String gw;
		private String bc;
		private Integer vlan;
		private Integer template;
		private String surnets;
	}
	private class TplApiVlanList {
		private List<TplApiVlan> vlan_list = new ArrayList<TplApiVlan>();
	}
	private class TplApiVlan {
		private Integer id;
		private String name;
		private Integer vid;
		private Integer template;
	}
		
	@GET
	@Secured
	@Path("/sites")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplsitelistRESTService() {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
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
				rs = stmt.executeQuery("select id,name,mask,nbvlan,nbsubnet from tpl_site_display");
				if (rs.isBeforeFirst()) {
					ApiTplSiteList mylist = new ApiTplSiteList();
					while (rs.next()) {
						ApiTplSite mysite = new ApiTplSite();
						mysite.id = rs.getInt("id");
  	  			mysite.name = rs.getString("name");
			    	mysite.mask = rs.getInt("mask");
    				mysite.nbvlan = rs.getInt("nbvlan");
    				mysite.nbsubnet = rs.getInt("nbsubnet");
    				mylist.site_list.add(mysite);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Site list empty";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplSiteList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplSiteList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplSiteList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplSiteList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/site/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplsiteinfoRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("TplSiteInfo/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select id,name,mask,nbvlan,nbsubnet from tpl_site_display where id="+site);
				if (rs.next()) {
					ApiTplSite mysite = new ApiTplSite();
					mysite.id = rs.getInt("id");
  	  		mysite.name = rs.getString("name");
			    mysite.mask = rs.getInt("mask");
    			mysite.nbvlan = rs.getInt("nbvlan");
    			mysite.nbsubnet = rs.getInt("nbsubnet");
    			Gson gson = new Gson();
					result = gson.toJson(mysite);
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplSiteInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplSiteInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplSiteInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplSiteInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/vlan/{vlan}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplvlaninfoRESTService(@PathParam("vlan") String vlan) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(vlan); } catch (NumberFormatException e) { printLog("TplVlanInfo/Check: Vlan not a number",null); }
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
				rs = stmt.executeQuery("select * from tpl_vlan where id="+vlan);
				if (rs.next()) {
					TplApiVlan myvlan = new TplApiVlan();
						myvlan.id = rs.getInt("id");
    				myvlan.name = rs.getString("def");
		    		myvlan.vid = rs.getInt("vid");
    				myvlan.template = rs.getInt("tpl");
						Gson gson = new Gson();
						result = gson.toJson(myvlan);
				} else {
					errcode=404;
					result="Vlan not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplVlanInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplVlanInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplVlanInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplVlanInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
		
	@GET
	@Secured
	@Path("/vlan/list/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplvlanlistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("TplVlanList/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select * from tpl_vlan where tpl="+site);
				if (rs.isBeforeFirst()) {
					TplApiVlanList mylist = new TplApiVlanList();
					while (rs.next()) {
						TplApiVlan myvlan = new TplApiVlan();
						myvlan.id = rs.getInt("id");
    				myvlan.name = rs.getString("def");
		    		myvlan.vid = rs.getInt("vid");
    				myvlan.template = rs.getInt("tpl");
						mylist.vlan_list.add(myvlan);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Vlan list empty or site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplVlanList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplVlanList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplVlanList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplVlanList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/subnet/{subnet}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplsubnetinfoRESTService(@PathParam("subnet") String subnet) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("TplSubnetInfo/Check: Subnet not a number",null); }
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
				rs = stmt.executeQuery("select * from tpl_subnet where id="+subnet);
				if (rs.next()) {
					TplApiSubnet mysub = new TplApiSubnet();
						mysub.id = rs.getInt("id");
    				mysub.name = rs.getString("def");
    				mysub.mask = rs.getInt("mask");
    				mysub.ip = rs.getString("ip");
    				mysub.gw = rs.getString("gw");
    				mysub.bc = rs.getString("bc");
		    		mysub.vlan = rs.getInt("vlan");
		    		mysub.surnets = rs.getString("surnet");
    				mysub.template = rs.getInt("tpl");
						Gson gson = new Gson();
						result = gson.toJson(mysub);
				} else {
					errcode=404;
					result="Subnet not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplSubnetInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplSubnetInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplSubnetInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplSubnetInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
		
	@GET
	@Secured
	@Path("/subnet/list/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response tplsubnetlistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("TplSubnetList/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select * from tpl_subnet where tpl="+site);
				if (rs.isBeforeFirst()) {
					TplApiSubnetList mylist = new TplApiSubnetList();
					while (rs.next()) {
						TplApiSubnet mysub = new TplApiSubnet();
						mysub.id = rs.getInt("id");
    				mysub.name = rs.getString("def");
    				mysub.mask = rs.getInt("mask");
    				mysub.ip = rs.getString("ip");
    				mysub.gw = rs.getString("gw");
    				mysub.bc = rs.getString("bc");
		    		mysub.vlan = rs.getInt("vlan");
		    		mysub.surnets = rs.getString("surnet");
    				mysub.template = rs.getInt("tpl");
    				mylist.subnet_list.add(mysub);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Subnet list empty or site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("TplSubnetList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("TplSubnetList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("TplSubnetList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("TplSubnetList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
}
