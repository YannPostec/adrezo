package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import org.apache.logging.log4j.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.cxf.transport.http.HTTPConduit;

public class TestDHCPServerBean implements Serializable {
	private String errLog = "";
	private boolean erreur = false;
	private transient Connection conn;
	private transient ResourceBundle prop;
	private String lang;
	private String myid;
	private static Logger mylog = LogManager.getLogger(TestDHCPServerBean.class);
	private Integer dhcp_receive=5000;
	private Integer dhcp_cnx=3000;
	private String basePath = "dhcp";

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg;
	}
	private void ReadConf() {
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			dhcp_receive = cfg.getInt("dhcp.receive_timeout");
			dhcp_cnx = cfg.getInt("dhcp.cnx_timeout");
			basePath = cfg.getString("dhcp.basePath");
			mylog.debug("Read Configurations");
		}
		catch (Exception cex) { printLog("TestDHCPServer/ReadConf: ",cex); }
	}
	private void OpenDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			mylog.debug("Connected to DB");
		} catch (Exception e) { printLog("TestDHCPServer/OpenDB: ",e); }
	}
	private void CloseDB() {
		try {
			conn.close();conn=null;
			mylog.debug("Closed DB");
		} catch (Exception e) { printLog("TestDHCPServer/CloseDB: ",e); }
		finally {    
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("TestDHCPServer/CloseDB-conn",e); } conn = null; }
		}
	}
	private void TestServer() {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select * from dhcp_server where id="+myid);
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
				mylog.debug("Testing Server "+srv_method+"://"+srv_host+srv_httpport+",auth:"+String.valueOf(srv_bauth)+",login:"+srv_user+",pwd:"+srv_pwd);
				Response r = client.path(basePath+"/scopelist").type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
       	if (r.getStatus()==200) {
					mylog.debug("Server OK");
				} else {
					mylog.debug("Server Timeout");
					printLog(prop.getString("testdhcp.timeout"),null);
				}
			}
			rs.close();rs = null;
			stmt.close();stmt = null;
		} catch (Exception e) { printLog("TestDHCPServer/Test: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		}
	}
	
	public boolean getErreur() { return erreur; }
	public String getErrLog() { return errLog; }	
	public void setMyid(String myid) {
		this.myid = myid;
	}
	public void setLang(String lang) {
		try {
			Locale locale = new Locale(lang);
			this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			ReadConf();
			OpenDB();
			TestServer();
			CloseDB();
		} catch (Exception e) { printLog("TestDHCPServer/Main: ",e); }	
	}
}
