package ypodev.adrezo.schedulers;

/*
 * @Author : Yann POSTEC
 */
 
import org.quartz.*;
import org.apache.log4j.Logger;
import java.io.*;
import java.util.*;
import java.text.*;
import java.sql.*;
import javax.naming.*;
import com.google.gson.*;
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.interceptor.InterceptorProvider;
import ypodev.adrezo.util.IPFmt;
import ypodev.adrezo.util.DbFunc;

public class DHCPJob implements Job {
	private Logger mylog = Logger.getLogger(DHCPJob.class);
	private Connection conn = null;
	private Statement stmt = null;
	private boolean erreur = false;
	private ResourceBundle prop;
	private class DHCPServer {
		private List<String> names = new ArrayList<String>();
		private DHCPServer(String n) {
			this.names.add(n);
		}
	}
	private Map<String,DHCPServer> scopes = new HashMap<String,DHCPServer>();
	private Map<String,WebClient> servers = new HashMap<String,WebClient>();
	private class Scope {
		private String ip;
	}
	private class ScopeList {
		private List<Scope> scopes = new ArrayList<Scope>();
	}
	private class ScopeRange {
		private String start;
		private String end;
	}
	private class ScopeExcludeRangeList {
		private List<ScopeRange> excluderanges = new ArrayList<ScopeRange>();
	}
	private class Lease {
		private String ip;
		private String mac;
		private String stamp;
		private String name;
		private String def;
		private Integer type;
	}
	private class ScopeLeaseList {
		private List<Lease> leases = new ArrayList<Lease>();
	}
	private String mailhost="";
	private String mailfrom="";
	private Integer mailport=25;
	private boolean mailssl=false;
	private String mailuser="";
	private String mailpwd="";
	private boolean mailauth=false;
	private Integer dhcp_receive=5000;
	private Integer dhcp_cnx=3000;
	private String basePath = "adrezo/dhcp";
	
	private void ReadConf() {
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			mailhost = cfg.getString("mail.host");
			mailfrom = cfg.getString("mail.from");
			mailport = cfg.getInt("mail.port");
			mailssl = cfg.getBoolean("mail.ssl");
			mailuser = cfg.getString("mail.user");
			mailpwd = cfg.getString("mail.pwd");
			mailauth = cfg.getBoolean("mail.auth");
			dhcp_receive = cfg.getInt("dhcp.receive_timeout");
			dhcp_cnx = cfg.getInt("dhcp.cnx_timeout");
		} catch (Exception cex) { mylog.error("DHCP/ReadConf: "+cex.getMessage(),cex); }
	}
	
	private void OpenDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			mylog.debug("Connected to DB");
		} catch (Exception e) { erreur=true;mylog.error("DHCP/OpenDB: "+e.getMessage(),e); }
	}

	private void CloseDB() {
		try {
			stmt.close();stmt=null;
			conn.close();conn=null;
			mylog.debug("Closed DB");
		} catch (Exception e) { mylog.error("DHCP/CloseDB: "+e.getMessage(),e); }
		finally {    
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("DHCP/CloseDB-stmt",e); } stmt = null; }
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("DHCP/CloseDB-conn",e); } conn = null; }
		}
	}

	private void sendMsg(String to, String subject, String message) {
		try {
			if (!mailhost.equals("")) {
				Email email = new SimpleEmail();
				email.setHostName(mailhost);
				email.setSmtpPort(mailport);
				email.setSSLOnConnect(mailssl);
				if (mailauth) {
					email.setAuthenticator(new DefaultAuthenticator(mailuser,mailpwd));
				}
				email.setFrom(mailfrom);
				email.setSubject(subject);
				email.setMsg(message);
				email.addTo(to);
				email.send();
			} else { mylog.info("MailHost : no host in configuration"); }
		}
		catch (EmailException e) { mylog.error("DHCP/Mail: "+e.getMessage(),e); }
	}	
	
	private void SendErrorMail() {
		ResultSet rsa = null;
		ResultSet rsm = null;
		Statement stmtm = null;
	
		try {
			String myto = "";
			rsa = stmt.executeQuery("select mail from auth_users where id=0");
			if (rsa.next()) {
				myto = rsa.getString("mail");
				stmtm = conn.createStatement();
				rsm = stmtm.executeQuery("select * from mail where id=8 and lang=(select lang from usercookie where login='admin')");
				if (rsm.next()) {
					if (!rsm.getString("destinataire").equals("USERDEF")) { myto = rsm.getString("destinataire"); }
					sendMsg(myto,rsm.getString("subject"),rsm.getString("message"));
				}
				rsm.close();rsm=null;
				stmtm.close();stmtm=null;
			}
			rsa.close();rsa=null;
		} catch (Exception e) { mylog.error("DHCP/SendErrorMail: "+e.getMessage(),e); }
		finally {
			if (rsa != null) { try { rsa.close(); } catch (SQLException e) { mylog.error("DHCP/SendErrorMail-rsa",e); } rsa = null; }
			if (rsm != null) { try { rsm.close(); } catch (SQLException e) { mylog.error("DHCP/SendErrorMail-rsm",e); } rsm = null; }
			if (stmtm != null) { try { stmtm.close(); } catch (SQLException e) { mylog.error("DHCP/SendErrorMail-stmtm",e); } stmtm = null; }
		}
	}
	
	private void GetServerList() {
		ResultSet rs = null;
		
		try {
			mylog.debug("Retrieving server list");
			rs = stmt.executeQuery("select * from dhcp_server");
			while (rs.next()) {
				String srv_host = rs.getString("hostname");
				Integer srv_port = rs.getInt("port");
				Integer srv_ssl = rs.getInt("ssl");
				Integer srv_bauth = rs.getInt("auth");
				String srv_user = rs.getString("login");
				String srv_pwd = rs.getString("pwd");
				String srv_method = "http";
				if (srv_ssl==1) { srv_method = srv_method+"s"; }
				String srv_httpport = "";
				if ((srv_ssl==0 && srv_port!=80) || (srv_ssl==1 && srv_port!=443)) { srv_httpport = ":"+String.valueOf(srv_port); }
				WebClient client;
				if (srv_bauth==1) {
					client = WebClient.create(srv_method+"://"+srv_host+srv_httpport,srv_user,srv_pwd,null);
				} else {
					client = WebClient.create(srv_method+"://"+srv_host+srv_httpport);
				}
        HTTPConduit conduit = WebClient.getConfig(client).getHttpConduit();
        conduit.getClient().setReceiveTimeout(dhcp_receive);
        conduit.getClient().setConnectionTimeout(dhcp_cnx);
				mylog.debug("Add server "+srv_method+"://"+srv_host+srv_httpport+",auth:"+String.valueOf(srv_bauth)+",login:"+srv_user+",pwd:"+srv_pwd);
				servers.put(srv_host,client);
			}
			rs.close();rs=null;
			mylog.info("Retrieving "+String.valueOf(servers.size())+" servers informations");
		} catch (Exception e) { mylog.error("DHCP/GetServerList: "+e.getMessage(),e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("DHCP/GetServerList-rs",e); } rs = null; }
		}
	}
		
	private boolean NotExcluded(String srv, String scope) {
		boolean res = true;
		ResultSet rs = null;
		
		try {
			rs = stmt.executeQuery("select id from dhcp_exclu where scope='"+scope+"' and srv in (select id from dhcp_server where hostname='"+srv+"')");
			if (rs.next()) { res = false; }
			rs.close();rs=null;
		} catch (Exception e) { mylog.error("DHCP/NotExcluded: "+e.getMessage(),e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("DHCP/NotExcluded-rs",e); } rs = null; }
		}
		return res;
	}
		
	private void GetScopeList() {
		Integer cpt = 0;
		
		mylog.debug("Accessing scope list for each server");
		for (String srv : servers.keySet()) {
			WebClient client = servers.get(srv);
			try {
				mylog.debug("Accessing scopes from server "+srv);
        Response r = client.path(basePath+"/scopelist").type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
        if (r.getStatus()==200) {
        	try {
						Gson gson = new Gson();
						ScopeList obj = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeList.class);
						List<Scope> myscope = obj.scopes;
						ListIterator li = myscope.listIterator();
						while (li.hasNext()) {
							Scope s = (Scope) li.next();
							if (NotExcluded(srv,s.ip)) {
								if (this.scopes.containsKey(s.ip)) {
									this.scopes.get(s.ip).names.add(srv);
								} else {
									this.scopes.put(s.ip,new DHCPServer(srv));
								}
							} else { mylog.debug("Exclusion of scope "+s.ip+" for server "+srv); }
						}
						mylog.debug("Add scopes from server "+srv);
					} catch (Exception e) { mylog.error("DHCP/GetScopeList/ReadJSON: "+e.getMessage(),e); }
					cpt++;
				} else {
					mylog.warn("Timeout to access scopes from server "+srv);
				}
			} catch (Exception e) { mylog.error("DHCP/GetScopeList: "+e.getMessage(),e); }
			finally { client.reset(); }
		}
		if (scopes.isEmpty()) {
			erreur = true;
			mylog.error("DHCP/GetScopeList: Scope List is empty");
		} else {
			mylog.info("Retrieving "+String.valueOf(scopes.size())+" scopes from "+String.valueOf(cpt)+" DHCP servers");
		}
	}
	
	private void DeleteDHCPInfos(String subnet) {
		try {
			stmt.executeUpdate("delete from adresses where type='dhcp' and subnet="+subnet);
			mylog.debug("Deleted DHCP entries for subnet "+subnet);
		}	catch (Exception e) {
			mylog.error("DHCP/DeleteDHCPInfos Subnet "+subnet+": "+e.getMessage(),e);
		}
	}

	private ScopeRange GetScopeRange(String srv,String scope) {
		mylog.debug(srv+"/"+scope+": Access Range");
		ScopeRange res = null;
		WebClient client = servers.get(srv);
   	try {
      Response r = client.path(basePath+"/range/"+scope).type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
   		if (r.getStatus()==200) {
				Gson gson = new Gson();
				res = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeRange.class);
			} else {
				mylog.warn("Timeout or Error to access ranges on scope "+scope+" from server "+srv);
			}
		} catch (Exception e) { mylog.error("DHCP/GetScopeRange: "+e.getMessage(),e); }
		finally { client.reset(); }
		if (res==null) { mylog.debug(srv+"/"+scope+": Range NULL"); }
		else { mylog.debug(srv+"/"+scope+": Range from "+res.start+" to "+res.end); }
		return res;
	}
	
	private ScopeExcludeRangeList GetScopeExclude(String srv,String scope) {
		mylog.debug(srv+"/"+scope+": Access Exclude Ranges");
		ScopeExcludeRangeList res = null;
		WebClient client = servers.get(srv);
   	try {
      Response r = client.path(basePath+"/exclude/"+scope).type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
   		if (r.getStatus()==200) {
				Gson gson = new Gson();
				res = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeExcludeRangeList.class);
			} else {
				mylog.warn("Timeout or Error to access exclude ranges on scope "+scope+" from server "+srv);
			}
		} catch (Exception e) { mylog.error("DHCP/GetScopeExclude: "+e.getMessage(),e); }
		finally { client.reset(); }
		if (res==null) { mylog.debug(srv+"/"+scope+": Exclude Ranges NULL"); }
		else {
			if (res.excluderanges.isEmpty()) { mylog.debug(srv+"/"+scope+": Exclude Ranges None"); }
			else {
				for (ScopeRange s : res.excluderanges) {
					mylog.debug(srv+"/"+scope+": Exclude Range from "+s.start+" to "+s.end);
				}
			}
		}
		return res;
	}

	private void GetScopeReserve(String srv,String scope,List<Lease> leaselist, List<String> iprange) {
		mylog.debug(srv+"/"+scope+": Access Reserve IP");
		Integer cpt=0;
		WebClient client = servers.get(srv);
   	try {
      Response r = client.path(basePath+"/reserve/"+scope).type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
   		if (r.getStatus()==200) {
				Gson gson = new Gson();
				ScopeLeaseList obj = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeLeaseList.class);
				List<Lease> mylist = obj.leases;
				ListIterator li = mylist.listIterator();
				while (li.hasNext()) {
					Lease l = (Lease) li.next();
					l.ip = IPFmt.renderIP(l.ip);
					if (l.name.length() > 20) { l.name = l.name.substring(0,20); }
					l.type = 2;
					l.def = prop.getString("dhcp.reserve");
					leaselist.add(l);
					iprange.remove(l.ip);
					cpt++;
				}
			} else {
				mylog.warn("Timeout or Error to access reserve ip on scope "+scope+" from server "+srv);
			}
		} catch (Exception e) { mylog.error("DHCP/GetScopeReserve: "+e.getMessage(),e); }
		finally { client.reset(); }
		mylog.debug(srv+"/"+scope+": Processed "+String.valueOf(cpt)+" reserve IP");
	}

	private void GetScopeLease(String srv,String scope,List<Lease> leaselist, List<String> iprange) {
		mylog.debug(srv+"/"+scope+": Access Lease IP");
		Integer cpt=0;
		WebClient client = servers.get(srv);
   	try {
      Response r = client.path(basePath+"/lease/"+scope).type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
   		if (r.getStatus()==200) {
				Gson gson = new Gson();
				ScopeLeaseList obj = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeLeaseList.class);
				List<Lease> mylist = obj.leases;
				ListIterator li = mylist.listIterator();
				while (li.hasNext()) {
					Lease l = (Lease) li.next();
					l.ip = IPFmt.renderIP(l.ip);
					if (l.name.length() > 20) { l.name = l.name.substring(0,20); }
					l.type = 1;
					l.def = prop.getString("dhcp.lease");
					leaselist.add(l);
					iprange.remove(l.ip);
					cpt++;
				}
			} else {
				mylog.warn("Timeout or Error to access lease ip on scope "+scope+" from server "+srv);
			}
		} catch (Exception e) { mylog.error("DHCP/GetScopeLease: "+e.getMessage(),e); }
		finally { client.reset(); }
		mylog.debug(srv+"/"+scope+": Processed "+String.valueOf(cpt)+" lease IP");
	}
	
	private List<String> ListIP(String start,String end) {
		List<String> res = new ArrayList<String>();
		while (start.compareTo(end) <=0) {
			res.add(start);
			start=IPFmt.incIP(start);
	 	}
	 	return res;
	}
	
	private void GetScopeInfos() {
		ResultSet rs = null;
		Integer globalcpt = 0;
		
		try {
			for (String key : scopes.keySet()) {
				mylog.debug("Processing scope "+key);
				String subnet=null;
				String mask="";
				String ctx="";
				String site="";
				rs = stmt.executeQuery("select id,mask,ctx,site from subnets where ip = '"+IPFmt.renderIP(key)+"'");
				while (rs.next()) {
					subnet = String.valueOf(rs.getInt("id"));
					mask = String.valueOf(rs.getInt("mask"));
					ctx = String.valueOf(rs.getInt("ctx"));
					site = String.valueOf(rs.getInt("site"));
					mylog.debug("Informations for scope "+key+": id="+subnet+",mask="+mask+",ctx="+ctx+",site="+site);
				}
				rs.close();rs=null;
				if (subnet!=null) {
					DeleteDHCPInfos(subnet);
					DHCPServer mysrv = scopes.get(key);
					ListIterator li = mysrv.names.listIterator();
					while (li.hasNext()) {
						String srv = (String) li.next();
						ScopeRange range = GetScopeRange(srv,key);
						ScopeExcludeRangeList exclude = GetScopeExclude(srv,key);
						if (range!=null && exclude!=null) {
							mylog.debug(srv+"/"+key+": Ranges are defined. Constructing IP list from "+range.start+" to "+range.end);
							List<String> iprange = ListIP(IPFmt.renderIP(range.start),IPFmt.renderIP(range.end));
							mylog.debug(srv+"/"+key+": IP list contains "+iprange.size()+" elements");
							ListIterator liex = exclude.excluderanges.listIterator();
							while (liex.hasNext()) {
								ScopeRange s = (ScopeRange) liex.next();
								iprange.subList(iprange.indexOf(IPFmt.renderIP(s.start)),iprange.indexOf(IPFmt.renderIP(s.end))+1).clear();
							}
							mylog.debug(srv+"/"+key+": IP list contains "+iprange.size()+" elements after applying exclusions");
							List<Lease> iplease = new ArrayList<Lease>();
							GetScopeReserve(srv,key,iplease,iprange);
							GetScopeLease(srv,key,iplease,iprange);
							Statement stmtu = conn.createStatement();
							try {
								String today = DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS')";
								for (String ip : iprange) {
									stmtu.executeUpdate("insert into adresses (id,ctx,site,name,def,ip,mask,subnet,type,usr_modif,date_modif) values (0,"+ctx+","+site+",'"+prop.getString("dhcp.blockname")+"','"+prop.getString("dhcp.blockdef")+"','"+ip+"',"+mask+","+subnet+",'dhcp','dhcp',"+today+")");
								}
								mylog.debug(srv+"/"+key+": SQL Processed IP list with "+iprange.size()+" inserts");
								globalcpt+=iprange.size();
								ListIterator lilea = iplease.listIterator();
								while (lilea.hasNext()) {
									Lease l = (Lease) lilea.next();
									if (l.type==1) {
										stmtu.executeUpdate("insert into adresses (id,ctx,site,name,def,ip,mask,mac,subnet,temp,date_temp,usr_temp,type,usr_modif,date_modif) values (0,"+ctx+","+site+",'"+l.name+"','"+l.def+"','"+l.ip+"',"+mask+",'"+l.mac+"',"+subnet+",1,"+DbFunc.ToDateStr()+"('"+l.stamp+"','YYYY-MM-DD HH24:MI:SS'),'dhcp','dhcp','dhcp',"+today+")");
									}
									if (l.type==2) {
										stmtu.executeUpdate("insert into adresses (id,ctx,site,name,def,ip,mask,mac,subnet,type,usr_modif,date_modif) values (0,"+ctx+","+site+",'"+l.name+"','"+l.def+"','"+l.ip+"',"+mask+",'"+l.mac+"',"+subnet+",'dhcp','dhcp',"+today+")");
									}
								}
								mylog.debug(srv+"/"+key+": SQL Processed Reserve and lease with "+iplease.size()+" inserts");
								globalcpt+=iplease.size();
								stmtu.close();stmtu=null;
							} catch (SQLException e) { erreur=true;mylog.warn("DHCP/GetScopeInfos-UpdateSQL: "+e.getMessage(),null); }
							finally {
								if (stmtu != null) { try { stmtu.close(); } catch (SQLException e) { mylog.error("DHCP/GetScopeInfos-stmtu",e); } stmtu = null; }
							}
							iprange=null;
							iplease=null;
						}
						range=null;
						exclude=null;
					}
				} else { mylog.warn("Scope "+key+": no match for subnet in database"); }
			}
			mylog.info("Processed "+String.valueOf(globalcpt)+" SQL inserts");
		} catch (Exception e) { erreur=true;mylog.error("DHCP/GetScopeInfos: "+e.getMessage(),e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("DHCP/GetScopeInfos-rs",e); } rs = null; }
		}
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ResultSet rsg = null;
		try {
			OpenDB();
			rsg = stmt.executeQuery("select lang from usercookie where login='admin'");
			if (rsg.next()) {
				Locale locale = new Locale(rsg.getString("lang"));
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			} else {
				Locale locale = new Locale("en");
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale); 
			}
			rsg = stmt.executeQuery("select * from schedulers where id=11");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 11 enabled");
					ReadConf();
					GetServerList();
					if (!servers.isEmpty()) {
						GetScopeList();
						if (!erreur) { GetScopeInfos(); }
						if (erreur) { SendErrorMail(); }
					}
				} else mylog.debug("Job 11 disabled");
			}
			rsg.close();rsg=null;
			CloseDB();
		} catch (Exception e) { mylog.error("DHCP/Global: "+e.getMessage(),e); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { mylog.error("DHCP/Global-CloseRSG",e); } rsg = null; }
		}		
	} 
}
