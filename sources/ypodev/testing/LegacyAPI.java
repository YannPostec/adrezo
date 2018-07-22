package ypodev.testing;

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
import com.google.gson.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.beans.IpDispoBean;
import ypodev.adrezo.util.IPFmt;
import ypodev.adrezo.util.DbSeqNextval;

public class LegacyAPI {
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(LegacyAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiIPDispo {
		private String ip;
		private Integer subnet;
		private ApiIPDispo(String ip, Integer subnet) {
			this.ip = ip;
			this.subnet = subnet;
		}
	}
	private class ApiIPAddress {
		private Integer id;
		private String ip;
		private Integer mask;
		private String name;
		private String desc;
		private Integer ctx;
		private Integer site;
		private Integer subnet;
	}
	private class ApiIPName {
		private String name;
		private ApiIPName(String name) {
			this.name = name;
		}
	}
	private class ApiIPData {
		private Integer id;
		private String ip;
		private Integer mask;
		private String name;
		private String desc;
	}
	private class ApiIPSubnet {
		private List<ApiIPData> ip = new ArrayList<ApiIPData>();
	}
	private class ApiIPPost {
		private String ip;
		private String name;
		private String desc;
		private String subnet;
	}
	private class ApiSubnetData {
		private Integer id;
	}
	private class ApiSubnetMy {
		private List<ApiSubnetData> subnet = new ArrayList<ApiSubnetData>();
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
	}
	
	@GET
	@Path("/ipdispo/{username}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipdispoRESTService(@PathParam("username") String username) {
		String[] arrsub;
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("IpDispo/Check: Username too long",null); }
		else {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					boolean bFound = false;
					arrsub = rs.getString("subnets").split(",",-1);
					for (String sub: arrsub) {
						if (!bFound) {
							IpDispoBean testdispo = new IpDispoBean();
							testdispo.setSubnet(sub);
							testdispo.setStartIP(null);
							testdispo.setNbIP(1);
							if (!testdispo.getErreur()) {
								if (testdispo.getIpFinal().length()>0) {
									bFound = true;
									ApiIPDispo myipdispo = new ApiIPDispo(testdispo.getIpFinal(),Integer.parseInt(sub));
									Gson gson = new Gson();
									result = gson.toJson(myipdispo);
								}
							} else {
								bFound=true;
								printLog("IpDispo/Bean:"+sub+": "+testdispo.getErrLog(),null);
							}
						}
					}
					if (!bFound) {
						errcode=204;
						result="IpDispo: No IP available\n";
					}
					rs.close();rs=null;
					stmt.close();stmt=null;
					conn.close();conn=null;
				} else {
					errcode=401;
					result="IpDispo: API user not registered\n";
				}
			} catch (Exception e) { printLog("IpDispo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
		
	@GET
	@Path("/ip/{username}/{ip}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipinfoRESTService(@PathParam("username") String username, @PathParam("ip") String ip) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("IpInfo/Check: Username too long",null); }
		if (!IPFmt.verifIP(ip)) { printLog("IpInfo/Check : IP not valid",null); }
		if (!erreur) {
			String myip = IPFmt.renderIP(ip);
			Connection conn = null;
			Statement stmt = null;
			Statement stmtip = null;
			ResultSet rs = null;
			ResultSet rsip = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					stmtip = conn.createStatement();
					rsip = stmtip.executeQuery("select id,ip,mask,name,def,ctx,site,subnet from adresses where ip='"+myip+"' and subnet in ("+rs.getString("subnets")+")" );
					if (rsip.next()) {
						ApiIPAddress myipaddress = new ApiIPAddress();
						myipaddress.id = rsip.getInt("id");
						myipaddress.ip = IPFmt.displayIP(rsip.getString("ip"));
						myipaddress.mask = rsip.getInt("mask");
			 			myipaddress.name = rsip.getString("name");
    				myipaddress.desc = (rsip.getString("def")==null)?"":rsip.getString("def");
    				myipaddress.ctx = rsip.getInt("ctx");
    				myipaddress.site = rsip.getInt("site");
    				myipaddress.subnet = rsip.getInt("subnet");
						Gson gson = new Gson();
						result = gson.toJson(myipaddress);
					} else {
						errcode=404;
						result="IpInfo: IP not found\n";
					}
					rsip.close();rsip=null;
					stmtip.close();stmtip=null;
				} else {
					errcode=401;
					result="IpInfo: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (rsip != null) { try { rsip.close(); } catch (SQLException e) { ; } rsip = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (stmtip != null) { try { stmtip.close(); } catch (SQLException e) { ; } stmtip = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Path("/ip/{username}/{ip}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response ipdelRESTService(@PathParam("username") String username, @PathParam("ip") String ip) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("IpDelete/Check: Username too long",null); }
		if (!IPFmt.verifIP(ip)) { printLog("IpDelete/Check : IP not valid",null); }
		if (!erreur) {
			String myip = IPFmt.renderIP(ip);
			Connection conn = null;
			Statement stmt = null;
			Statement stmtip = null;
			ResultSet rs = null;
			ResultSet rsip = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					stmtip = conn.createStatement();
					rsip = stmtip.executeQuery("select id from adresses where ip='"+myip+"' and subnet in ("+rs.getString("subnets")+")" );
					if (rsip.next()) {
    				try {
							String myid=String.valueOf(rsip.getInt("id"));
	    				Statement stmtup = conn.createStatement();
							stmtup.executeUpdate("delete from adresses where id="+myid);
							stmtup.close();
						} catch (Exception e) { printLog("IpDelete/Fail: ",e); }
					} else {
						errcode=404;
						result="IpDelete: IP not found\n"; }
					rsip.close();rsip=null;
					stmtip.close();stmtip=null;
				} else {
					errcode=401;
					result="IpDelete: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (rsip != null) { try { rsip.close(); } catch (SQLException e) { ; } rsip = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (stmtip != null) { try { stmtip.close(); } catch (SQLException e) { ; } stmtip = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Path("/ip/{username}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response ipaddRESTService(@PathParam("username") String username, InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String indef="";
		String inip="";
		String insubnet="";
		String infip="";
		if (username.length()>20) { printLog("IpAdd/Check: Username too long",null); }
		else {
			try {
				Gson gson = new Gson();
				ApiIPPost obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiIPPost.class);
 				inname = obj.name;
 				indef = obj.desc;
	 			infip = obj.ip;
 				inip = IPFmt.renderIP(infip);
 				insubnet = obj.subnet;
			} catch (Exception e) { printLog("IpAdd/ReadJSON: ",e); }
			if (inname.length()>20) { printLog("IpAdd/Check: name too long",null); }
			if (indef.length()>100) { printLog("IpAdd/Check: desc too long",null); }
			try { Integer.parseInt(insubnet); } catch (NumberFormatException e) { printLog("IpAdd/Check: subnet not a number",null); }
			if (!IPFmt.verifIP(infip)) { printLog("IpAdd/Check : IP not valid",null); }
			if (!erreur) {
				Connection conn = null;
				Statement stmt = null;
				Statement stmtsub = null;
				Statement stmtup = null;
				ResultSet rs = null;
				ResultSet rssub = null;
				try {
					Context env = (Context) new InitialContext().lookup("java:comp/env");
					String jdbc_jndi = (String) env.lookup("jdbc_jndi");
					javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
					conn = ds.getConnection();
					stmt = conn.createStatement();
					rs = stmt.executeQuery("select * from api where login='"+username+"'");
					if (rs.next()) {
						String[] arrsub = rs.getString("subnets").split(",",-1);
						boolean bFound = false;
						for (String sub: arrsub) {
							if (sub.equals(insubnet)) { bFound=true; }
						}
						if (bFound) {
							stmtsub = conn.createStatement();
							rssub = stmtsub.executeQuery("select ctx,site,mask from subnets where id="+insubnet);
							if (rssub.next()) {
    						try {
	    						stmtup = conn.createStatement();
									stmtup.executeUpdate("insert into adresses (id,ctx,site,name,def,ip,mask,subnet,usr_modif) values ("+DbSeqNextval.dbSeqNextval("adresses_seq")+","+rssub.getString("ctx")+","+rssub.getString("site")+",'"+inname+"','"+indef+"','"+inip+"',"+String.valueOf(rssub.getInt("mask"))+","+insubnet+",'"+username+"')");
									stmtup.close();stmtup=null;
								} catch (Exception e) { printLog("IpAdd/Failed: ",e); }
							} else {
								errcode=404;
								result="IpAdd: Subnet not found\n";
							}
							rssub.close();rssub=null;
							stmtsub.close();stmtsub=null;
						} else {
							errcode=400;
							result="IpAdd: Subnet not authorized\n";
						}
					} else {
						errcode=401;
						result="IpAdd: API user not registered\n";
					}
					rs.close();rs=null;
					stmt.close();stmt=null;
					conn.close();conn=null;
				} catch (Exception e) { printLog("IpAdd/Global: ",e); }
				finally {
					if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
					if (rssub != null) { try { rssub.close(); } catch (SQLException e) { ; } rssub = null; }
					if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
					if (stmtsub != null) { try { stmtsub.close(); } catch (SQLException e) { ; } stmtsub = null; }
					if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { ; } stmtup = null; }
					if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
				}
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/ipname/{username}/{myname}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response ipnameRESTService(@PathParam("username") String username, @PathParam("myname") String myname) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("IpName/Check: Username too long",null); }
		if (myname.length()>17) { printLog("IpName/Check: prefix name too long",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtn = null;
			ResultSet rs = null;
			ResultSet rsn = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					stmtn = conn.createStatement();
					rsn = stmtn.executeQuery("select LPAD(substr(lower(name),length('"+myname+"')+1),3,'0') as idx from adresses where lower(name) like lower('"+myname+"%') order by idx");
					boolean bFound = false;
					int cpt = 1;
					if (rsn.isBeforeFirst()) {
						while (!bFound && rsn.next()) {
							String idx = rsn.getString("idx");
							try {
								int myidx=Integer.parseInt(idx);
								if (cpt < myidx) { bFound = true; }
								else { cpt++; }
							} catch (NumberFormatException e) { }
						}
						ApiIPName myipname = new ApiIPName(myname+IPFmt.AddLZeroToInt(cpt));
						Gson gson = new Gson();
						result = gson.toJson(myipname);
					} else {
						ApiIPName myipname = new ApiIPName(myname+"001");
						Gson gson = new Gson();
						result = gson.toJson(myipname);
					}
					rsn.close();rsn=null;
					stmtn.close();stmtn=null;
				} else {
					errcode=401;
					result="IpName: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("IpName/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (rsn != null) { try { rsn.close(); } catch (SQLException e) { ; } rsn = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (stmtn != null) { try { stmtn.close(); } catch (SQLException e) { ; } stmtn = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/mysubnet/{username}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response mysubnetRESTService(@PathParam("username") String username) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("MySubnet/Check: Username too long",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;			
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					ApiSubnetMy mysub = new ApiSubnetMy();
					String[] arrsub = rs.getString("subnets").split(",",-1);
					for (String sub: arrsub) {
						ApiSubnetData data = new ApiSubnetData();
						data.id = Integer.parseInt(sub);
						mysub.subnet.add(data);
					}
					Gson gson = new Gson();
					result = gson.toJson(mysub);
				} else {
					errcode=401;
					result="MySubnet: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("MySubnet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/subnet/{username}/{subnet}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response subnetinfoRESTService(@PathParam("username") String username, @PathParam("subnet") String subnet) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("SubnetInfo/Check: Username too long",null); }
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("SubnetInfo/Check: Subnet not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmts = null;
			ResultSet rs = null;
			ResultSet rss = null;					
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					stmts = conn.createStatement();
					rss = stmts.executeQuery("select id,def,ip,mask,gw,bc,ctx,site,vlan from subnets where id="+subnet+" and id in ("+rs.getString("subnets")+")" );
					if (rss.next()) {
						ApiSubnet mysub = new ApiSubnet();
						mysub.id = rss.getInt("id");
    				mysub.desc = (rss.getString("def")==null)?"":rss.getString("def");
		    		mysub.ip = IPFmt.displayIP(rss.getString("ip"));
  		  		mysub.mask = rss.getInt("mask");
  		  		mysub.gateway = (rss.getString("gw")==null)?"":IPFmt.displayIP(rss.getString("gw"));
  		  		mysub.broadcast = IPFmt.displayIP(rss.getString("bc"));
    				mysub.ctx = rss.getInt("ctx");
    				mysub.site = rss.getInt("site");
    				mysub.vlan = rss.getInt("vlan");
						Gson gson = new Gson();
						result = gson.toJson(mysub);
					} else {
						errcode=404;
						result="SubnetInfo: Subnet not found\n";
					}
					rss.close();rss=null;
					stmts.close();stmts=null;
				} else {
					errcode=401;
					result="SubnetInfo: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SubnetInfo/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (rss != null) { try { rss.close(); } catch (SQLException e) { ; } rss = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (stmts != null) { try { stmts.close(); } catch (SQLException e) { ; } stmts = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/subnetip/{username}/{subnet}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response subnetipRESTService(@PathParam("username") String username, @PathParam("subnet") String subnet) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (username.length()>20) { printLog("SubnetIp/Check: Username too long",null); }
		try { Integer.parseInt(subnet); } catch (NumberFormatException e) { printLog("SubnetIp/Check: Subnet not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmts = null;
			ResultSet rs = null;
			ResultSet rss = null;			
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from api where login='"+username+"'");
				if (rs.next()) {
					stmts = conn.createStatement();
					rss = stmts.executeQuery("select id,ip,name,def,mask from adresses where subnet="+subnet+" and subnet in ("+rs.getString("subnets")+")" );
					if (rss.isBeforeFirst()) {
						ApiIPSubnet myipsub = new ApiIPSubnet();
						while (rss.next()) {
							ApiIPData mydata = new ApiIPData();
							mydata.id = rss.getInt("id");
							mydata.ip = IPFmt.displayIP(rss.getString("ip"));
							mydata.name = rss.getString("name");
							mydata.desc = (rss.getString("def")==null)?"":rss.getString("def");
							mydata.mask = rss.getInt("mask");
							myipsub.ip.add(mydata);
						}
						Gson gson = new Gson();
						result = gson.toJson(myipsub);
					} else {
						errcode=404;
						result="SubnetIp: Subnet not found or empty\n";
					}
					rss.close();rss=null;
					stmts.close();stmts=null;
				} else {
					errcode=401;
					result="SubnetIp: API user not registered\n";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("SubnetIp/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
				if (rss != null) { try { rss.close(); } catch (SQLException e) { ; } rss = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (stmts != null) { try { stmts.close(); } catch (SQLException e) { ; } stmts = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
}
