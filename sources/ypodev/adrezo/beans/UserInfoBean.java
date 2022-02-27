package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.*;
import javax.naming.*;
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.directory.api.ldap.model.cursor.*;
import org.apache.directory.api.ldap.model.entry.*;
import org.apache.directory.api.ldap.model.message.*;
import org.apache.directory.api.ldap.model.exception.*;
import org.apache.directory.api.ldap.model.name.*;
import org.apache.directory.ldap.client.api.*;
import org.apache.logging.log4j.*;
import org.jasypt.util.password.*;
import org.jasypt.util.text.*;
import ypodev.adrezo.util.DbFunc;

public class UserInfoBean implements Serializable {
	// Properties
	private String login;
	private String pwd;
	private String mail;
	private Integer idrole;
	private String idannu;
	private String errLog = "";
	private String ctx;
	private String lang;
	private String userdn = "";
	private boolean erreur = false;
	private boolean bAuth = false;
	private boolean bLocal = false;
	private Hashtable<String,Integer> roles = new Hashtable<String,Integer>();
	private Integer role = 0;
	private transient ResourceBundle prop;
	private String url;
	private String macsearch;
	private String slidetime;
	private static Logger mylog = LogManager.getLogger(UserInfoBean.class);
	private static Map session;

	//Private functions
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg;
	}
	private void ClearAll() {
		errLog = "";
		erreur = false;
	}
	private Hashtable<String,Integer> MergeRoles(Hashtable<String,Integer> ha,Hashtable<String,Integer> hb) {
		Hashtable<String,Integer> result = new Hashtable<String,Integer>();
		
		Enumeration actx = ha.keys();
		Enumeration bctx = hb.keys();
    while(actx.hasMoreElements()) {
    	String contexte = (String) actx.nextElement();
    	Integer arights = ha.get(contexte);
    	Integer brights = hb.get(contexte);
    	Integer mrights = (arights | brights);
    	result.put(contexte,mrights);
    }
		
		return result;
	}
	private Hashtable<String,Integer> FillRoles(Hashtable<String,Integer> in) {
		Hashtable<String,Integer> result = new Hashtable<String,Integer>();
		
		Enumeration actx = in.keys();
    while(actx.hasMoreElements()) {
    	String contexte = (String) actx.nextElement();
    	Integer arights = in.get(contexte);
    	result.put(contexte,arights);
    }
		
		return result;
	}
	private void Authentication() {
		Connection conn = null;
		Statement stmt = null;
		Statement stmt2 = null;
		ResultSet rslang = null;
		ResultSet rslocal = null;
		ResultSet rsext = null;
		ResultSet rs = null;
		ResultSet rscookie = null;
		ResultSet res = null;
		ResultSet rstemp = null;
		String exppref = null;
		String expsuff = null;
		
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			stmt2 = conn.createStatement();
			rslang = stmt.executeQuery("select lang from usercookie where login = 'admin'");
			if (rslang.next()) {this.lang = rslang.getString("lang");} else {this.lang="en";}
			rslang = stmt.executeQuery("select * from settings");
			if (rslang.next()) {
				exppref = rslang.getString("exppref");
				expsuff = rslang.getString("expsuff");
			}
			rslang.close();rslang = null;
			Locale locale = new Locale(this.lang);
			this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			// Authent local
			rslocal = stmt.executeQuery("select pwd,mail,role from auth_users where auth=0 and login='"+login+"'");
			if (rslocal.next()) {
				String mypwd = rslocal.getString("pwd");
				BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
				if (passwordEncryptor.checkPassword(this.pwd, mypwd)) {
					this.bAuth = true;
					this.mail = rslocal.getString("mail");
					this.idrole = rslocal.getInt("role");
					this.bLocal = true;
				}
			}
			rslocal.close();rslocal = null;
			if (!bAuth) {
				//Authent Externe
				rsext = stmt.executeQuery("select id,type from auth_annu where type > 0 order by ordre");
				while (!bAuth && rsext.next()) {
					String annutype = String.valueOf(rsext.getInt("type"));
					String annuid = String.valueOf(rsext.getInt("id"));
					if (annutype.equals("1")) { //LDAP
						res = stmt2.executeQuery("select * from auth_ldap where id = "+annuid);
						if (res.next()) {
							String basedn = res.getString("basedn");
							String[] usrdn = res.getString("usrdn").split(";");
							String usrfilter = res.getString("usrfilter");
							if (usrfilter==null) { usrfilter=""; }
							String usrnameattr = res.getString("usrnameattr");
							String usrclass = res.getString("usrclass");						
							LdapConnectionPool pool = null;
							if (session.containsKey("AdrezoLdapPool_"+annuid)) {
								pool = (LdapConnectionPool) session.get("AdrezoLdapPool_"+annuid);
							} else { printLog("Missing LDAP Pool",null); }
						 	if (pool!=null) {
						 		LdapConnection lconn = pool.getConnection();
								try {
									boolean bFound = false;
									for(int i=0;i<usrdn.length&&!bFound;i++) {
										SearchRequest sreq = new SearchRequestImpl();
  				  				sreq.setScope(SearchScope.SUBTREE);
								    sreq.addAttributes("*");
 										sreq.setTimeLimit(0);
 										sreq.setBase( new Dn(usrdn[i]+","+basedn) );
 										sreq.setFilter("(&(objectclass="+usrclass+")("+usrnameattr+"="+this.login+")"+usrfilter+")");
							    	SearchCursor searchCursor = lconn.search(sreq);
										while (searchCursor.next()) {
		    	    				bFound=true;
	  	  	    				Response response = searchCursor.get();
								      if (response instanceof SearchResultEntry) {
    	  	  	    			Entry resultEntry = ( (SearchResultEntry) response ).getEntry();
      	  	  	  			this.userdn = resultEntry.getDn().toString();
          			  			Attribute usrmail = resultEntry.get("mail");
          			  			if (usrmail != null) { this.mail = usrmail.getString(); }
          			  			else {
													if (exppref != null || expsuff != null) {
														String unacc = this.login;
														if (exppref !=null && !exppref.equals("") && unacc.startsWith(exppref)) { unacc = unacc.substring(exppref.length()); }
														if (expsuff !=null && !expsuff.equals("") && unacc.endsWith(expsuff)) { unacc = unacc.substring(0,unacc.indexOf(expsuff)-1); }
														SearchRequest mailreq = new SearchRequestImpl();
  				  								mailreq.setScope(SearchScope.SUBTREE);
								    				mailreq.addAttributes("*");
 														mailreq.setTimeLimit(0);
 														mailreq.setBase( new Dn(basedn) );
 														mailreq.setFilter("(&(objectclass="+usrclass+")("+usrnameattr+"="+unacc+")"+usrfilter+")");
							    					SearchCursor mailsc = lconn.search(mailreq);
														while (mailsc.next()) {
															Response mailrsp = mailsc.get();
								      				if (mailrsp instanceof SearchResultEntry) {
																Entry mailre = ( (SearchResultEntry) mailrsp ).getEntry();
																Attribute usraccmail =  mailre.get("mail");
          			  							if (usraccmail != null) { this.mail = usraccmail.getString(); }
															}
														}
													}
												}
											}
										}
										searchCursor.close();
									}
								} catch (Exception e) { printLog("LdapAuthentication: ",e); }
								if (!userdn.equals("")) {
									boolean bLdapAuth = false;
									try {
										lconn.bind(userdn,this.pwd);
							  	  bLdapAuth = true;
									} catch (LdapException e) {
										bLdapAuth = false;
									}
									this.bAuth=bLdapAuth;
									this.idannu=annuid;
								}
								pool.releaseConnection(lconn);
							}
						}
						res.close();res = null;
					}
				}
				rsext.close();rsext = null;
			}
			if (!bAuth) { printLog(prop.getString("user.err"),null); }
			else {
				// Start Roles : Role Read-only
				rs=stmt.executeQuery("select ctx,rights from auth_rights where role = 0");
				Hashtable<String,Integer> readonly = new Hashtable<String,Integer>();
				while(rs.next()) {
					readonly.put(String.valueOf(rs.getInt("ctx")),rs.getInt("rights"));
				}
				// Start Ctx : Role Read-Only
				rs=stmt.executeQuery("select pref_ctx from auth_roles where id = 0");
				if (rs.next()) {
					this.ctx = String.valueOf(rs.getInt("pref_ctx"));
				}
				if (bLocal) {
					//Authorize Local
					rs=stmt.executeQuery("select pref_ctx from auth_roles where id = "+String.valueOf((Integer)idrole));
					if (rs.next()) {
						this.ctx = String.valueOf(rs.getInt("PREF_CTX"));
					}
					rs=stmt.executeQuery("select ctx,rights from auth_rights where role = "+String.valueOf((Integer)idrole));
					Hashtable<String,Integer> localroles = new Hashtable<String,Integer>();
					while(rs.next()) {
						localroles.put(String.valueOf(rs.getInt("ctx")),rs.getInt("rights"));
					}
					this.roles = MergeRoles(readonly,localroles);
					this.role = this.roles.get(this.ctx);
				} else {
					//Authorize Externe
					this.roles = FillRoles(readonly);
					res = stmt2.executeQuery("select basedn,usrnameattr,grpmemberattr,usrclass,grpfilter from auth_ldap where id = "+this.idannu);
					String basedn = "";
					String grpmemberattr = "";
					String usrnameattr = "";
					String grpfilter = "";
					String usrclass = "";
					if (res.next()) {
						grpfilter = res.getString("grpfilter");
						basedn = res.getString("basedn");
						grpmemberattr = res.getString("grpmemberattr");
						usrclass = res.getString("usrclass");
						usrnameattr = res.getString("usrnameattr");
					}
					res.close();res = null;
					if (grpfilter==null) { grpfilter=""; }
					LdapConnectionPool pool = null;
					if (session.containsKey("AdrezoLdapPool_"+this.idannu)) {
						pool = (LdapConnectionPool) session.get("AdrezoLdapPool_"+this.idannu);
					} else { printLog("Missing LDAP Pool",null); }
					if (pool!=null) {
						LdapConnection lconn = pool.getConnection();
						if (grpmemberattr.equals("member")) {
							try {
								rs=stmt.executeQuery("select id,grp_dn,pref_ctx from auth_roles where annu="+idannu);
								while (rs.next()) {
									String myid = String.valueOf(rs.getInt("id"));
									String mydn = rs.getString("grp_dn");
									String myctx = String.valueOf(rs.getInt("pref_ctx"));
									Entry mygrp = lconn.lookup(mydn);
									Attribute members = mygrp.get(grpmemberattr);
									boolean bFound = false;
									if (members != null) {
										for (Iterator<Value<?>> i = members.iterator(); i.hasNext()&&!bFound;) {
											if (i.next().getString().equals(userdn)) {
												bFound = true;
												this.ctx = myctx;
												rstemp=stmt2.executeQuery("select ctx,rights from auth_rights where role = "+myid);
												Hashtable<String,Integer> temproles = new Hashtable<String,Integer>();
												while(rstemp.next()) {
													temproles.put(String.valueOf(rstemp.getInt("ctx")),rstemp.getInt("rights"));
												}
												this.roles = MergeRoles(this.roles,temproles);
												rstemp.close();rstemp = null;
											}
										}
									}
								}
							} catch (Exception e) { printLog("LdapAuthorization-member: ",e); }
						}
						if (grpmemberattr.equals("memberof") || grpmemberattr.equals("memberofnested")) {
							try {
								String strsearch = "";
								if (grpmemberattr.equals("memberof")) { strsearch = "memberOf="; }
								if (grpmemberattr.equals("memberofnested")) { strsearch = "memberOf:1.2.840.113556.1.4.1941:="; }
								rs=stmt.executeQuery("select id,grp_dn,pref_ctx from auth_roles where annu="+idannu);
								while (rs.next()) {
									String myid = String.valueOf(rs.getInt("id"));
									String mydn = rs.getString("grp_dn");
									String myctx = String.valueOf(rs.getInt("pref_ctx"));
									SearchRequest sreq = new SearchRequestImpl();
  					  		sreq.setScope(SearchScope.SUBTREE);
									sreq.addAttributes("*");
 									sreq.setTimeLimit(0);
 									sreq.setBase( new Dn(basedn) );
 									sreq.setFilter("(&(objectclass="+usrclass+")("+strsearch+mydn+")("+usrnameattr+"="+this.login+")"+grpfilter+")");
 									mylog.debug("(&(objectclass="+usrclass+")("+strsearch+mydn+")("+usrnameattr+"="+this.login+")"+grpfilter+")");
									SearchCursor searchCursor = lconn.search(sreq);
									boolean bFound = false;
									while (!bFound && searchCursor.next()) {
		  	  	    		Response response = searchCursor.get();
									  if (response instanceof SearchResultEntry) {
    		  	  	    	Entry resultEntry = ( (SearchResultEntry) response ).getEntry();
      		  	  	  	String myuserdn = resultEntry.getDn().toString();
      	  	  		  	if (myuserdn.equals(this.userdn)) {
												mylog.debug("found "+myuserdn);
												bFound=true;
												this.ctx = myctx;
												rstemp=stmt2.executeQuery("select ctx,rights from auth_rights where role = "+myid);
												Hashtable<String,Integer> temproles = new Hashtable<String,Integer>();
												while(rstemp.next()) {
													temproles.put(String.valueOf(rstemp.getInt("ctx")),rstemp.getInt("rights"));
												}
												this.roles = MergeRoles(this.roles,temproles);
												rstemp.close();rstemp = null;
											}
										}
									}
									searchCursor.close();
								}
							} catch (Exception e) { printLog("LdapAuthorization-memberOf: ",e); }
						}
						pool.releaseConnection(lconn);
						rs = stmt.executeQuery("select ctx,rights from auth_rights where role in (select role from auth_users where auth > 0 and login='"+this.login+"')");
						Hashtable<String,Integer> temproles = new Hashtable<String,Integer>(readonly);
						while(rs.next()) {
							temproles.put(String.valueOf(rs.getInt("ctx")),rs.getInt("rights"));
						}
						this.roles = MergeRoles(this.roles,temproles);
						this.role = this.roles.get(this.ctx);					
					}
				}
				rs.close();rs = null;
				if (!login.equals("admin")) {
					rscookie = stmt.executeQuery("select ctx,lang,url,slidetime,macsearch from usercookie where login = '"+login+"'");
					if (rscookie.next()) {
						this.ctx = String.valueOf(rscookie.getInt("ctx"));
						this.lang = rscookie.getString("lang");
						this.url = String.valueOf(rscookie.getInt("url"));
						this.macsearch = String.valueOf(rscookie.getInt("macsearch"));
						this.slidetime = String.valueOf(rscookie.getInt("slidetime"));
						stmt.executeUpdate("update usercookie set mail='"+this.mail+"',last = "+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS') where login = '"+login+"'");
					} else {
						stmt.executeUpdate("insert into usercookie (login,mail,ctx,lang,last) values ('"+login+"','"+this.mail+"',"+this.ctx+",'"+this.lang+"',"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS'))");
						this.url = "1";
						this.macsearch = "1";
						this.slidetime = "2000";
					}
					rscookie.close();rscookie = null;
				}
			}
			stmt.close();stmt = null;
			stmt2.close();stmt2 = null;
			conn.close();conn = null;
		} catch (Exception e) { printLog("AuthGlobal: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
			if (rsext != null) { try { rsext.close(); } catch (SQLException e) { ; } rsext = null; }
			if (rscookie != null) { try { rscookie.close(); } catch (SQLException e) { ; } rscookie = null; }
			if (rslocal != null) { try { rslocal.close(); } catch (SQLException e) { ; } rslocal = null; }
			if (rslang != null) { try { rslang.close(); } catch (SQLException e) { ; } rslang = null; }    	
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (res != null) { try { res.close(); } catch (SQLException e) { ; } res = null; }
			if (rstemp != null) { try { rstemp.close(); } catch (SQLException e) { ; } rstemp = null; }			
    	if (stmt2 != null) { try { stmt2.close(); } catch (SQLException e) { ; } stmt2 = null; }
    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}
	
	//Public getters
	public boolean getErreur() { return erreur; }
	public String getErrLog() {	return errLog; }
	public String getMail () { return (mail == null ? "" : mail); }
	public String getLogin() { return (login == null ? "" : login); }
	public String getCtx() { return (ctx == null ? "" : ctx); }
	public String getLang() { return (lang == null ? "" : lang); }
	public String getRole() { return String.valueOf((Integer)this.role); }
	public String getUrl() { return (url == null ? "" : url); }
	public String getSlidetime() { return (slidetime == null ? "" : slidetime); }
	public String getMacsearch() { return (macsearch == null ? "" : macsearch); }
	
	//Public setters
	public void setPwd(String pwd) {
		this.pwd = pwd;
		ClearAll();
		Authentication();
		this.session = null;
	}
	public void setSession(Map session) { this.session = session; }
	public void setLogin(String login) { this.login = login; }
	public void setUrl(String url) {this.url = url; }
	public void setMacsearch(String mac) {this.macsearch = mac; }
	public void setSlidetime(String st) {this.slidetime = st; }
	public void setCtx(String ctx) {
		this.ctx = ctx;
		if (this.roles.containsKey(this.ctx)) {
			this.role = this.roles.get(this.ctx);
		} else {
			this.role = 0;
		}
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
	//Public Testers on actual ctx
	public boolean isIp() {
		boolean isValid = false;
		if ((role & 1) == 1) { isValid = true; }
		return isValid;
	}
	public boolean isPhoto() {
		boolean isValid = false;
		if ((role & 2) == 2) { isValid = true; }
		return isValid;
	}
	public boolean isStock() {
		boolean isValid = false;
		if ((role & 4) == 4) { isValid = true; }
		return isValid;
	}
	public boolean isStockAdmin() {
		boolean isValid = false;
		if ((role & 8) == 8) { isValid = true; }
		return isValid;
	}
	public boolean isAdmin() {
		boolean isValid = false;
		if ((role & 16) == 16) { isValid = true; }
		return isValid;
	}
	public boolean isRezo() {
		boolean isValid = false;
		if ((role & 32) == 32) { isValid = true; }
		return isValid;
	}
	public boolean isApi() {
		boolean isValid = false;
		if ((role & 64) == 64) { isValid = true; }
		return isValid;
	}
	public boolean isTemplate() {
		boolean isValid = false;
		if ((role & 128) == 128) { isValid = true; }
		return isValid;
	}
	
	//Public Testers on specified ctx
	public boolean stockCtx(String myctx) {
		boolean isValid = false;
		Integer myrole = 0;
		if (this.roles.containsKey(myctx)) { myrole = this.roles.get(myctx); }
		if ((myrole & 4) == 4) { isValid = true; }
		return isValid;
	}
}
