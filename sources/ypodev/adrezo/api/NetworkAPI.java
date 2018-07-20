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
import ypodev.adrezo.beans.IpDispoBean;
import ypodev.adrezo.util.IPFmt;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;

@Path("/network")
@Secured({Role.API})
public class NetworkAPI {
	
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(NetworkAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiSubnetList {
		private List<ApiSubnet> subnet_list = new ArrayList<ApiSubnet>();
	}
	private class ApiSubnet {
		private Integer id;
		private String ip;
		private Integer mask;
		private String desc;
		private String gateway;
		private String broadcast;
		private Integer ctx;
		private Integer site;
		private Integer vlan;
		private Integer surnet;
	}
	private class ApiVlanList {
		private List<ApiVlan> vlan_list = new ArrayList<ApiVlan>();
	}
	private class ApiVlan {
		private Integer id;
		private String name;
		private Integer vid;
		private Integer site;
	}
		
	@GET
	@Secured
	@Path("/subnet/my")
	@Produces(MediaType.APPLICATION_JSON)
	public Response subnetmyRESTService() {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
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
			rs = stmt.executeQuery("select * from api where login='"+username+"'");
			if (rs.next()) {
				ApiSubnetList mysub = new ApiSubnetList();
				String[] arrsub = rs.getString("subnets").split(",",-1);
				for (String sub: arrsub) {
					ApiSubnet data = new ApiSubnet();
					data.id = Integer.parseInt(sub);
					mysub.subnet_list.add(data);
				}
				Gson gson = new Gson();
				result = gson.toJson(mysub);
			} else {
				result="No subnet restrictions for user "+username;
			}
			rs.close();rs=null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) { printLog("SubnetMy/Global: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SubnetMy/Close rs",e); } rs = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SubnetMy/Close stmt",e); } stmt = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SubnetMy/Close conn",e); } conn = null; }				
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/subnet/{subnet}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response subnetinfoRESTService(@PathParam("subnet") String subnet) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("SubnetInfo/Check: Subnet not a number",null); }
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
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				String usersub = "all";
				if (rs.next()) { usersub = rs.getString("subnets"); }
				rs.close();rs=null;
				String querysub = "select id,def,ip,mask,gw,bc,ctx,site,vlan,surnet from subnets where id="+subnet;
				if (!usersub.equals("all")) { querysub = querysub + " and id in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);
				if (rs.next()) {
					ApiSubnet mysub = new ApiSubnet();
						mysub.id = rs.getInt("id");
    				mysub.desc = (rs.getString("def")==null)?"":rs.getString("def");
		    		mysub.ip = IPFmt.displayIP(rs.getString("ip"));
  		  		mysub.mask = rs.getInt("mask");
  		  		mysub.gateway = (rs.getString("gw")==null)?"":IPFmt.displayIP(rs.getString("gw"));
  		  		mysub.broadcast = IPFmt.displayIP(rs.getString("bc"));
    				mysub.ctx = rs.getInt("ctx");
    				mysub.site = rs.getInt("site");
    				mysub.vlan = rs.getInt("vlan");
    				mysub.surnet = rs.getInt("surnet");
						Gson gson = new Gson();
						result = gson.toJson(mysub);
				} else {
					errcode=404;
					result="Subnet not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SubnetInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SubnetInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SubnetInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SubnetInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Path("/subnet/{subnet}")
	@Secured({Role.NETWORK})
	@Produces(MediaType.TEXT_PLAIN)
	public Response subnetdelRESTService(@PathParam("subnet") String subnet) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("SubnetDelete/Check: Subnet not a number",null); }
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
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				String usersub = "all";
				if (rs.next()) { usersub = rs.getString("subnets"); }
				rs.close();rs=null;
				String querysub = "select id from subnets where id="+subnet;
				if (!usersub.equals("all")) { querysub = querysub + " and id in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);				
				if (rs.next()) {
   				try {
						String myid=String.valueOf(rs.getInt("id"));
    				stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from subnets where id="+myid);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("SubnetDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Subnet not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SubnetDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SubnetDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SubnetDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SubnetDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SubnetDelete/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/subnet/")
	@Secured({Role.NETWORK})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response subnetaddRESTService(InputStream incomingData) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inip="";
		String infip="";
		String inmask="";
		String indesc="";
		String infgw="";
		String ingw="";
		String infbc="";
		String inbc="";
		String inctx="";
		String insite="";
		String invlan="";
		try {
			Gson gson = new Gson();
			ApiSubnet obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiSubnet.class);
			infip = obj.ip;
			inip = IPFmt.renderIP(infip);
			inmask = String.valueOf(obj.mask);
			indesc = obj.desc;
			infgw = obj.gateway;
			ingw = (infgw==null)?"":IPFmt.renderIP(infgw);
			infbc = obj.broadcast;
			inbc = IPFmt.renderIP(infbc);
 			inctx = String.valueOf(obj.ctx);
 			insite = String.valueOf(obj.site);
 			invlan = String.valueOf(obj.vlan);
		} catch (Exception e) { printLog("SubnetAdd/ReadJSON: ",e); }
		if (!IPFmt.verifIP(infip)) { printLog("SubnetAdd/Check : IP not valid",null); }
		if (infgw!=null&&!IPFmt.verifIP(infgw)) { printLog("SubnetAdd/Check : Gateway not valid",null); }
		if (!IPFmt.verifIP(infbc)) { printLog("SubnetAdd/Check : Broadcast not valid",null); }
		if (indesc!=null&&indesc.length()>40) { printLog("SubnetAdd/Check: desc too long",null); }
		try {
			Integer mymask = Integer.parseInt(inmask);
			if (mymask<2 || mymask>32) { printLog("SubnetAdd/Check : 1 < mask < 32",null); }
		} catch (NumberFormatException e) { printLog("SubnetAdd/Check: mask not a number",null); }
		try { Integer.parseInt(inctx); } catch (NumberFormatException e) { printLog("SubnetAdd/Check: ctx not a number",null); }
		try { Integer.parseInt(insite); } catch (NumberFormatException e) { printLog("SubnetAdd/Check: site not a number",null); }
		try { Integer.parseInt(invlan); } catch (NumberFormatException e) { printLog("SubnetAdd/Check: vlan not a number",null); }
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
				rs = stmt.executeQuery("select id from vlan where id="+invlan+" and site="+insite+" and ctx="+inctx);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into subnets (id,ip,mask,def,gw,bc,ctx,site,vlan,surnet) values ("+DbSeqNextval.dbSeqNextval("subnets_seq")+",'"+inip+"',"+inmask+",'"+indesc+"','"+ingw+"','"+inbc+"',"+inctx+","+insite+","+invlan+",0)");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("subnets_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Subnet "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Subnet created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("SubnetAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Context,Site,Vlan not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SubnetAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SubnetAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("SubnetAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SubnetAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("SubnetAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SubnetAdd/Close conn",e); } conn = null; }				
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
	public Response subnetlistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("SubnetList/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select * from subnets where site="+site);
				if (rs.isBeforeFirst()) {
					ApiSubnetList mylist = new ApiSubnetList();
					while (rs.next()) {
						ApiSubnet mysubnet = new ApiSubnet();
						mysubnet.id = rs.getInt("id");
						mysubnet.ip = IPFmt.displayIP(rs.getString("ip"));
    				mysubnet.mask = rs.getInt("mask");
		    		mysubnet.desc = rs.getString("def");
		    		mysubnet.gateway = (rs.getString("gw")==null)?"":IPFmt.displayIP(rs.getString("gw"));
		    		mysubnet.broadcast = IPFmt.displayIP(rs.getString("bc"));
		    		mysubnet.vlan = rs.getInt("vlan");
		    		mysubnet.surnet = rs.getInt("surnet");
		    		mysubnet.ctx = rs.getInt("ctx");
		    		mysubnet.site = rs.getInt("site");
						mylist.subnet_list.add(mysubnet);
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
			} catch (Exception e) { printLog("SubnetList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("SubnetList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("SubnetList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("SubnetList/Close conn",e); } conn = null; }				
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
	public Response vlaninfoRESTService(@PathParam("vlan") String vlan) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(vlan); } catch (NumberFormatException e) { printLog("VlanInfo/Check: Vlan not a number",null); }
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
				rs = stmt.executeQuery("select id,def,vid,site from vlan where id="+vlan);
				if (rs.next()) {
					ApiVlan myvlan = new ApiVlan();
						myvlan.id = rs.getInt("id");
    				myvlan.name = rs.getString("def");
		    		myvlan.vid = rs.getInt("vid");
    				myvlan.site = rs.getInt("site");
						Gson gson = new Gson();
						result = gson.toJson(myvlan);
				} else {
					errcode=404;
					result="Vlan not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("VlanInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("VlanInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("VlanInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("VlanInfo/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Path("/vlan/{vlan}")
	@Secured({Role.NETWORK})
	@Produces(MediaType.TEXT_PLAIN)
	public Response vlandelRESTService(@PathParam("vlan") String vlan) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(vlan); } catch (NumberFormatException e) { printLog("VlanDelete/Check: Vlan not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			ResultSet rsv = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from vlan where id="+vlan);				
				if (rs.next()) {
   				try {
						String myid=String.valueOf(rs.getInt("id"));
						stmtup = conn.createStatement();
						rsv = stmtup.executeQuery("select id from vlan where vid=0 and site in (select site from vlan where id ="+myid+")");
						String myzeroid = null;
						if (rsv.next()) { myzeroid = String.valueOf(rsv.getInt("id")); }
						rsv.close();rsv=null;
    				if (myzeroid!=null) { stmtup.executeUpdate("update subnets set vlan="+myzeroid+" where vlan="+myid); }
						stmtup.executeUpdate("delete from vlan where id="+myid);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("VlanDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Vlan not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("VlanDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("VlanDelete/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("VlanDelete/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("VlanDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("VlanDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("VlanDelete/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/vlan/")
	@Secured({Role.NETWORK})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response vlanaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String invid="";
		String inname="";
		String insite="";
		try {
			Gson gson = new Gson();
			ApiVlan obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiVlan.class);
			invid = String.valueOf(obj.vid);
			inname = obj.name;
 			insite = String.valueOf(obj.site);
		} catch (Exception e) { printLog("VlanAdd/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>50) { printLog("VlanAdd/Check: name too long",null); }
		try { Integer.parseInt(insite); } catch (NumberFormatException e) { printLog("VlanAdd/Check: site not a number",null); }
		try { Integer.parseInt(invid); } catch (NumberFormatException e) { printLog("VlanAdd/Check: vid not a number",null); }
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
				rs = stmt.executeQuery("select id from sites where id="+insite);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into vlan (id,def,vid,site) values ("+DbSeqNextval.dbSeqNextval("vlan_seq")+",'"+inname+"',"+invid+","+insite+")");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("vlan_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Vlan "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Vlan created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("VlanAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("VlanAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("VlanAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("VlanAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("VlanAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("VlanAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("VlanAdd/Close conn",e); } conn = null; }				
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
	public Response vlanlistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("SubnetList/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select * from vlan where site="+site);
				if (rs.isBeforeFirst()) {
					ApiVlanList mylist = new ApiVlanList();
					while (rs.next()) {
						ApiVlan myvlan = new ApiVlan();
						myvlan.id = rs.getInt("id");
    				myvlan.name = rs.getString("def");
		    		myvlan.vid = rs.getInt("vid");
    				myvlan.site = rs.getInt("site");
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
			} catch (Exception e) { printLog("VlanList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("VlanList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("VlanList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("VlanList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
}
