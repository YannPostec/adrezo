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

@Path("/ip")
@Secured({Role.API})
public class IPAPI {
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = LogManager.getLogger(IPAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiIP {
		private Integer id;
		private String ip;
		private Integer mask;
		private String mac;
		private String name;
		private String desc;
		private Integer ctx;
		private Integer site;
		private Integer subnet;
	}
	private class ApiIPList {
		private List<ApiIP> ip_list = new ArrayList<ApiIP>();
	}
	
	@GET
	@Path("/dispo/{subnet}")
	@Secured({Role.IP})
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipdispoRESTService(@PathParam("subnet") String subnet) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("IpDispo/Check: Subnet not a number",null); }
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
				String querysub = "select id from subnets where id="+subnet;
				if (!usersub.equals("all")) { querysub = querysub + " and id in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);
				if (rs.next()) {
					boolean bFound = false;
					IpDispoBean testdispo = new IpDispoBean();
					testdispo.setSubnet(subnet);
					testdispo.setStartIP(null);
					testdispo.setNbIP(1);
					if (!testdispo.getErreur()) {
						if (testdispo.getIpFinal().length()>0) {
							bFound = true;
							ApiIP myipdispo = new ApiIP();
							myipdispo.ip = testdispo.getIpFinal();
							myipdispo.subnet = Integer.parseInt(subnet);
							Gson gson = new Gson();
							result = gson.toJson(myipdispo);
						}
					} else {
						bFound=true;
						printLog("IpDispo/Bean:"+subnet+": "+testdispo.getErrLog(),null);
					}
					if (!bFound) {
						errcode=404;
						result="No IP available";
					}
				} else {
					printLog("IpDispo: Subnet not found",null);
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpDispo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpDispo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpDispo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpDispo/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
		
	@GET
	@Path("/{ip}")
	@Secured
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipinfoRESTService(@PathParam("ip") String ip) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (!IPFmt.verifIP(ip)) { printLog("IpInfo/Check : IP not valid",null); }
		if (!erreur) {
			String myip = IPFmt.renderIP(ip);
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id,ip,mask,mac,name,def,ctx,site,subnet from adresses where ip='"+myip+"'" );
				if (rs.next()) {
					ApiIP myipaddress = new ApiIP();
					myipaddress.id = rs.getInt("id");
					myipaddress.ip = IPFmt.displayIP(rs.getString("ip"));
					myipaddress.mask = rs.getInt("mask");
					myipaddress.mac = (rs.getString("mac")==null)?"":rs.getString("mac");
			 		myipaddress.name = rs.getString("name");
    			myipaddress.desc = (rs.getString("def")==null)?"":rs.getString("def");
    			myipaddress.ctx = rs.getInt("ctx");
    			myipaddress.site = rs.getInt("site");
    			myipaddress.subnet = rs.getInt("subnet");
					Gson gson = new Gson();
					result = gson.toJson(myipaddress);
				} else {
					errcode=404;
					result="IP not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpInfo/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpInfo/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpInfo/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Path("/{ip}")
	@Secured({Role.IP})
	@Produces(MediaType.TEXT_PLAIN)
	public Response ipdelRESTService(@PathParam("ip") String ip) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (!IPFmt.verifIP(ip)) { printLog("IpDelete/Check : IP not valid",null); }
		if (!erreur) {
			String myip = IPFmt.renderIP(ip);
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
				String querysub = "select id from adresses where ip='"+myip+"'";
				if (!usersub.equals("all")) { querysub = querysub + " and subnet in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);
				if (rs.next()) {
    			try {
						String myid=String.valueOf(rs.getInt("id"));
	    			stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from adresses where id="+myid);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("IpDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="IP not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("IpDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpDelete/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/")
	@Secured({Role.IP})
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response ipaddRESTService(InputStream incomingData) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String indef="";
		String inip="";
		String insubnet="";
		String infip="";
		String inmac="";
		try {
			Gson gson = new Gson();
			ApiIP obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiIP.class);
			inname = obj.name;
			indef = obj.desc;
 			infip = obj.ip;
			inip = IPFmt.renderIP(infip);
			insubnet = String.valueOf(obj.subnet);
			inmac = (obj.mac==null)?"":obj.mac;
		} catch (Exception e) { printLog("IpAdd/ReadJSON: ",e); }
		if (inname.length()>20) { printLog("IpAdd/Check: name too long",null); }
		if (indef.length()>100) { printLog("IpAdd/Check: desc too long",null); }
		if (!inmac.equals("") && inmac.length()!=12) { printLog("IpAdd/Check : mac bad size",null); }
		try { Integer.parseInt(insubnet); } catch (NumberFormatException e) { printLog("IpAdd/Check: subnet not a number",null); }
		if (!IPFmt.verifIP(infip)) { printLog("IpAdd/Check : IP not valid",null); }
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
				String querysub = "select ctx,site,mask from subnets where id="+insubnet;
				if (!usersub.equals("all")) { querysub = querysub + " and id in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into adresses (id,ctx,site,name,def,ip,mask,subnet,usr_modif,mac) values ("+DbSeqNextval.dbSeqNextval("adresses_seq")+","+rs.getString("ctx")+","+rs.getString("site")+",'"+inname+"','"+indef+"','"+inip+"',"+String.valueOf(rs.getInt("mask"))+","+insubnet+",'"+username+"','"+inmac+"')");
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("IpAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Subnet not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpAdd/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("IpAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/name/{myname}")
	@Secured({Role.IP})
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipnameRESTService(@PathParam("myname") String myname) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (myname.length()>17) { printLog("IpName/Check: prefix name too long",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtn = null;
			ResultSet rs = null;
			ResultSet rsn = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				boolean bFound = false;
				int cpt = 1;
				rs = stmt.executeQuery("select LPAD(substr(lower(name),length('"+myname+"')+1),3,'0') as idx from adresses where lower(name) like lower('"+myname+"%') order by idx");
				if (rs.isBeforeFirst()) {
					while (!bFound && rs.next()) {
						String idx = rs.getString("idx");
						try {
							int myidx=Integer.parseInt(idx);
							if (cpt < myidx) { bFound = true; }
							else { cpt++; }
						} catch (NumberFormatException e) { }
					}
					ApiIP myipname = new ApiIP();
					myipname.name = myname+IPFmt.AddLZeroToInt(cpt);
					Gson gson = new Gson();
					result = gson.toJson(myipname);
				} else {
					ApiIP myipname = new ApiIP();
					myipname.name = myname+"001";
					Gson gson = new Gson();
					result = gson.toJson(myipname);
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpName/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpName/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpName/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpName/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/list/{subnet}")
	@Secured
	@Produces(MediaType.APPLICATION_JSON)
	public Response iplistsubnetRESTService(@PathParam("subnet") String subnet) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("IpList/Check: Subnet not a number",null); }
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
				String querysub = "select id,ip,name,def,mask from adresses where subnet="+subnet;
				if (!usersub.equals("all")) { querysub = querysub + " and subnet in ("+usersub+")"; }
				rs = stmt.executeQuery(querysub);		
				if (rs.isBeforeFirst()) {
					ApiIPList myipsub = new ApiIPList();
					while (rs.next()) {
						ApiIP mydata = new ApiIP();
						mydata.id = rs.getInt("id");
						mydata.ip = IPFmt.displayIP(rs.getString("ip"));
						mydata.name = rs.getString("name");
						mydata.desc = (rs.getString("def")==null)?"":rs.getString("def");
						mydata.mask = rs.getInt("mask");
						myipsub.ip_list.add(mydata);
					}
					Gson gson = new Gson();
					result = gson.toJson(myipsub);
				} else {
					errcode=404;
					result="Subnet not found or empty";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("IpList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("IpList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("IpList/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
}
