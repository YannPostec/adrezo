package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import org.apache.log4j.Logger;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import org.apache.cxf.jaxrs.client.WebClient;
import org.apache.cxf.transport.http.HTTPConduit;
import org.apache.cxf.interceptor.InterceptorProvider;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import com.google.gson.*;

public class DHCPScopeServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;	
	private String id = "";
	private Logger mylog = Logger.getLogger(DHCPScopeServlet.class);
	private Integer dhcp_receive=5000;
	private Integer dhcp_cnx=3000;
	private String basePath = "adrezo/dhcp";
	private List<String> scopes = new ArrayList<String>();
	private List<String> exclus = new ArrayList<String>();

	private class Scope {
		private String ip;
	}
	private class ScopeList {
		private List<Scope> scopes = new ArrayList<Scope>();
	}

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		} else { mylog.error(msg,null); }
		this.errLog += msg + "<br />";
	}
	
	private void ReadConf() {
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			dhcp_receive = cfg.getInt("dhcp.receive_timeout");
			dhcp_cnx = cfg.getInt("dhcp.cnx_timeout");
			mylog.debug("Reading Configuration Properties");
		} catch (Exception cex) { mylog.error("DHCPScope/ReadConf: "+cex.getMessage(),cex); }
	}

  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		Connection conn = null;
		Statement stmt = null;
		ResultSet result = null;
		try {
			this.id = req.getParameter("id");
			mylog.debug("Receiving server id: "+id);
			if (!id.equals("")) {
				ReadConf();
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				result = stmt.executeQuery("select scope from dhcp_exclu where srv="+id);
				while(result.next()) {
					this.exclus.add(result.getString("scope"));
				}
				result = stmt.executeQuery("select * from dhcp_server where id="+id);
				if (result.next()) {
					String srv_host = result.getString("hostname");
					Integer srv_port = result.getInt("port");
					Integer srv_ssl = result.getInt("ssl");
					Integer srv_bauth = result.getInt("auth");
					String srv_user = "";
					String srv_pwd = "";
					if (srv_bauth==1) {
						srv_user = result.getString("login");
						srv_pwd = result.getString("pwd");
					}
					String srv_method = "http";
					if (srv_ssl==1) { srv_method = srv_method+"s"; }
					String srv_httpport = "";
					if ((srv_ssl==0 && srv_port!=80) || (srv_ssl==1 && srv_port!=443)) { srv_httpport = ":"+String.valueOf(srv_port); }
					WebClient client;
					if (srv_bauth==1) {
						client = WebClient.create(srv_method+"://"+srv_host+srv_httpport,srv_user,srv_pwd,null);
						mylog.debug(id+": Construct WebClient "+srv_method+"://"+srv_host+srv_httpport+", auth with "+srv_user+"/"+srv_pwd);
					} else {
						client = WebClient.create(srv_method+"://"+srv_host+srv_httpport);
						mylog.debug(id+": Construct WebClient "+srv_method+"://"+srv_host+srv_httpport+", no auth");
					}
        	HTTPConduit conduit = WebClient.getConfig(client).getHttpConduit();
        	conduit.getClient().setReceiveTimeout(dhcp_receive);
        	conduit.getClient().setConnectionTimeout(dhcp_cnx);
	        Response r = client.path(basePath+"/scopelist").type(MediaType.APPLICATION_JSON).accept(MediaType.APPLICATION_JSON).get();
        	if (r.getStatus()==200) {
						mylog.debug(id+": Accessing scopelist");
	        	try {
							Gson gson = new Gson();
							ScopeList obj = gson.fromJson(new InputStreamReader((InputStream)r.getEntity(), "UTF-8"),ScopeList.class);
							List<Scope> myscope = obj.scopes;
							ListIterator li = myscope.listIterator();
							while (li.hasNext()) {
								Scope s = (Scope) li.next();
								if (!this.exclus.contains(s.ip)) {
									this.scopes.add(s.ip);
									mylog.debug(id+": Scope "+s.ip);
								}
							}
						} catch (Exception e) { printLog("DHCPScope/ReadJSON: "+e.getMessage(),e); }
						finally { client.reset(); }
					} else {
						printLog("Timeout to access scopes from server "+srv_host,null);
					}
				}
				result.close();result = null;
				stmt.close();stmt = null;
				conn.close();conn = null;
			}
		} catch (Exception e) { printLog("DHCPScope/Global: ",e); }
		finally {
			if (result != null) { try { result.close(); } catch (SQLException e) { printLog("DHCPScope/Global-rs: ",e); } result = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("DHCPScope/Global-stmt: ",e); } stmt = null; }
    	if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("DHCPScope/Global-conn: ",e); } conn = null; }
		}
		res.setContentType("text/xml; charset=UTF-8");
	  res.setCharacterEncoding("UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			errLog = errLog.replaceAll("&","&amp;");
  		errLog = errLog.replaceAll("<","&lt;");
 	  	errLog = errLog.replaceAll(">","&gt;");
   		errLog = errLog.replaceAll("\"","&quot;");
   		errLog = errLog.replaceAll("'","&apos;");
			out.println("<err>true</err><msg>" + errLog + "</msg>");
		} else {
			out.println("<err>false</err><msg>OK</msg>");
		}
		for (String scope : this.scopes) {
			out.println("<scope>"+scope+"</scope>");
		}
		out.println("</reponse>");		
		out.flush();
		out.close();
		errLog = "";
		erreur = false;
		id = "";
		scopes.clear();
		exclus.clear();
  }
}
