package ypodev.adrezo.listener;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.naming.*;
import org.apache.directory.ldap.client.api.*;
import org.apache.commons.pool.impl.*;
import org.jasypt.util.text.*;
import org.apache.log4j.Logger;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;

public class LdapPoolListener implements ServletContextListener {
	private ArrayList<String> ids = new ArrayList<String>();
	private Logger mylog = Logger.getLogger(LdapPoolListener.class);

	@Override
	public void contextInitialized(ServletContextEvent sce) {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		ServletContext ctx = sce.getServletContext();
		int maxactive = 8;
		int maxidle = 8;

		mylog.info("Ldap Pools Initialization...");
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			maxactive = cfg.getInt("ldap.maxactive");
			maxidle = cfg.getInt("ldap.maxidle");
			mylog.debug("Reading LDAP Configuration, maxWait: "+String.valueOf(maxactive)+", maxIdle: "+String.valueOf(maxidle));
		}
		catch (Exception cex) { mylog.error("LdapPoolConf: ",cex); }
		
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select * from auth_ldap");
			while (rs.next()) {
				String myid = String.valueOf(rs.getInt("id"));
				String mysrv = rs.getString("server");
				Integer myport = rs.getInt("port");
				Integer mymeth = rs.getInt("method");
				String basedn = rs.getString("basedn");
				String binddn = rs.getString("binddn");
				String mybindpwd = rs.getString("bindpwd");
				BasicTextEncryptor crypto = new BasicTextEncryptor();
				crypto.setPassword("ceciestlepasswordldap");
				String bindpwd = crypto.decrypt(mybindpwd);
				boolean useSSL = false;
				if (mymeth == 1) { useSSL = true; }
				try {
					LdapConnectionConfig lcfg = new LdapConnectionConfig();
					lcfg.setLdapHost(mysrv);
					lcfg.setLdapPort(myport);
					lcfg.setUseSsl(useSSL);
					lcfg.setName(binddn+","+basedn);
					lcfg.setCredentials(bindpwd);
					DefaultLdapConnectionFactory factory = new DefaultLdapConnectionFactory(lcfg);
					factory.setTimeOut(2000);
					GenericObjectPool.Config poolConfig = new GenericObjectPool.Config();
					poolConfig.lifo = true;
					poolConfig.maxActive = maxactive;
					poolConfig.maxIdle = maxidle;
					poolConfig.maxWait = -1L;
					poolConfig.minEvictableIdleTimeMillis = 1000L * 60L * 30L;
					poolConfig.minIdle = 0;
					poolConfig.numTestsPerEvictionRun = 3;
					poolConfig.softMinEvictableIdleTimeMillis = -1L;
					poolConfig.testOnBorrow = false;
					poolConfig.testOnReturn = false;
					poolConfig.testWhileIdle = false;
					poolConfig.timeBetweenEvictionRunsMillis = -1L;
					poolConfig.whenExhaustedAction = GenericObjectPool.WHEN_EXHAUSTED_BLOCK;

					LdapConnectionPool pool = new LdapConnectionPool(new ValidatingPoolableLdapConnectionFactory(factory),poolConfig);
					ctx.setAttribute("AdrezoLdapPool_"+myid, pool);
					ids.add(myid);
					mylog.info("Ldap Pool ID "+myid+" started");
				} catch (Exception e) { mylog.error("LDAP: ",e); }
			}
			rs.close();rs = null;
			stmt.close();stmt = null;
			conn.close();conn = null;
		} catch (Exception e) { mylog.error("Init: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}

	public void contextDestroyed(ServletContextEvent sce) {
		mylog.info("Destroying LDAP Service...");
		ServletContext ctx = sce.getServletContext();
		ListIterator li = ids.listIterator();
		while (li.hasNext()) {
			try {
				LdapConnectionPool pool = (LdapConnectionPool) ctx.getAttribute("AdrezoLdapPool_"+li.next());
				pool.close();
			} catch (Exception e) { mylog.error("Error in LDAP Service Shutdown",e); }
		}
		ids=null;
	}

}
