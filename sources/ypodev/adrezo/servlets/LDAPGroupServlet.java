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
import org.apache.directory.api.ldap.model.cursor.*;
import org.apache.directory.api.ldap.model.entry.*;
import org.apache.directory.api.ldap.model.message.*;
import org.apache.directory.api.ldap.model.message.controls.*;
import org.apache.directory.api.ldap.model.name.*;
import org.apache.directory.ldap.client.api.*;
import org.apache.logging.log4j.*;

public class LDAPGroupServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String roleid = "";
	private Hashtable<String,String> groups = new Hashtable<String,String>();
	private Logger mylog = LogManager.getLogger(LDAPGroupServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}

  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		Connection conn = null;
		Statement stmt = null;
		Statement stmt2 = null;
		ResultSet result = null;
		ResultSet rs = null;
		try {
			this.roleid = req.getParameter("id");
			if (!roleid.equals("")) {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				result = stmt.executeQuery("select id,type from auth_annu where id=(select annu from auth_roles where id="+roleid+")");
				if (result.next()) {
					String annutype = String.valueOf(result.getInt("type"));
					String annuid = String.valueOf(result.getInt("id"));
					stmt2 = conn.createStatement();
					if (annutype.equals("1")) { //LDAP
						rs = stmt2.executeQuery("select * from auth_ldap where id="+annuid);
						if (rs.next()) {
							String basedn = rs.getString("basedn");
							String[] grpdn = rs.getString("grpdn").split(";");
							String grpfilter = rs.getString("grpfilter");
							String grpnameattr = rs.getString("grpnameattr");
							String grpclass = rs.getString("grpclass");
							String mysearch = "";
							if (grpfilter != null) { mysearch += "(&"; }
							mysearch += "(objectclass="+grpclass+")";
							if (grpfilter != null) { mysearch += grpfilter+")"; }
							try {
								ServletContext ctx = req.getSession().getServletContext();
								LdapConnectionPool pool = (LdapConnectionPool) ctx.getAttribute("AdrezoLdapPool_"+annuid);
								LdapConnection lconn = pool.getConnection();
								byte[] cookie = null;
								int PageSize = 50;
								PagedResults myCtl = new PagedResultsImpl();
								myCtl.setSize(PageSize);
								myCtl.setCookie(cookie);
								myCtl.setCritical(false);
								for(int i=0;i<grpdn.length;i++) {
									do {
										SearchRequest sreq = new SearchRequestImpl();
  		  						sreq.setScope(SearchScope.SUBTREE);
								    sreq.addAttributes("*");
    								sreq.setTimeLimit(0);
    								sreq.setBase( new Dn(grpdn[i]+","+basedn) );
    								sreq.setFilter(mysearch);
    								sreq.addControl(myCtl);
								    SearchCursor searchCursor = lconn.search(sreq);
										while (searchCursor.next()) {
	    	    					Response response = searchCursor.get();
							        if (response instanceof SearchResultEntry) {
    	    	    				Entry resultEntry = ( (SearchResultEntry) response ).getEntry();
      	    	  				String groupdn = resultEntry.getDn().toString();
        	  	  				String groupname = null;
          		  				Attribute groupnameattr = resultEntry.get(grpnameattr);
          		  				if (groupnameattr != null) { groupname = groupnameattr.getString(); }
          	  					if (groupdn!=null && groupname !=null) { this.groups.put(groupdn,groupname); }
											}
										}
										SearchResultDone resultat = searchCursor.getSearchResultDone();
										searchCursor.close();
										myCtl = (PagedResults) resultat.getControl(PagedResults.OID);
										myCtl.setSize(PageSize);
										cookie = myCtl.getCookie();										
									} while (cookie != null);
								}
								pool.releaseConnection(lconn);
							} catch (Exception e) { printLog("LDAP: ",e); }
						}
						rs.close();rs = null;
					}
					stmt2.close();stmt2 = null;
				}
				result.close();result = null;
				stmt.close();stmt = null;
				conn.close();conn = null;
			}
		} catch (Exception e) { printLog("Global: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
			if (result != null) { try { result.close(); } catch (SQLException e) { ; } result = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
    	if (stmt2 != null) { try { stmt2.close(); } catch (SQLException e) { ; } stmt2 = null; }
    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
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
		TreeMap<String,String> sortgrp = new TreeMap<String,String>(groups);
		for(Map.Entry<String,String> entry : sortgrp.entrySet()) {
  		String dn = entry.getKey();
  		String cn = entry.getValue();
  		out.println("<group>");
			out.println("<cn>"+cn+"</cn><dn>"+dn+"</dn>");
	  	out.println("</group>");		
		}
		out.println("</reponse>");		
		out.flush();
		out.close();
		errLog = "";
		erreur = false;
		roleid = "";
		groups.clear();
  }
}
