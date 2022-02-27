package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import javax.ws.rs.*;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.HttpHeaders;
import javax.ws.rs.core.SecurityContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.ext.Provider;
import java.lang.annotation.*;
import javax.annotation.Priority;
import java.security.Principal;
import org.apache.logging.log4j.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import org.apache.commons.lang3.time.DateUtils;

@Secured
@Provider
@Priority(Priorities.AUTHENTICATION)
public class AuthenticationFilter implements ContainerRequestFilter {
	private Logger mylog = LogManager.getLogger(AuthenticationFilter.class);
	private static final String REALM = "production";
	private static final String AUTHENTICATION_SCHEME = "Adrezo";
	private String username=null;
	private String db_type;

	@Override
	public void filter(ContainerRequestContext requestContext) throws IOException {
		this.username=null;
		String authorizationHeader = requestContext.getHeaderString(HttpHeaders.AUTHORIZATION);
		if (!isTokenBasedAuthentication(authorizationHeader)) {
			abortWithUnauthorized(requestContext,"Token required");
			return;
		}
		String token = authorizationHeader.substring(AUTHENTICATION_SCHEME.length()).trim();
		try {
			validateToken(token);
			if (this.username!=null) {
				final SecurityContext currentSecurityContext = requestContext.getSecurityContext();
				requestContext.setSecurityContext(new SecurityContext() {
			  	@Override
	        public Principal getUserPrincipal() { return () -> username; }
					@Override
    			public boolean isUserInRole(String role) { return true; }
		  	  @Override
    			public boolean isSecure() { return currentSecurityContext.isSecure(); }
			    @Override
  	  		public String getAuthenticationScheme() { return AUTHENTICATION_SCHEME; }
				});
			}
		} catch (Exception e) { abortWithUnauthorized(requestContext,e.getMessage()); }
	}
	
	private boolean isTokenBasedAuthentication(String authorizationHeader) {
		return authorizationHeader != null && authorizationHeader.toLowerCase().startsWith(AUTHENTICATION_SCHEME.toLowerCase() + " ");
	}

	private void abortWithUnauthorized(ContainerRequestContext requestContext, String msg) {
		requestContext.abortWith(Response.status(Response.Status.UNAUTHORIZED).header(HttpHeaders.WWW_AUTHENTICATE, AUTHENTICATION_SCHEME).entity(msg).build());
	}

	private void validateToken(String token) throws Exception {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		this.username = null;
		String resultat = "Invalid Token";
		Configurations cfgs = new Configurations();
		Integer timeout = 10;
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			timeout = cfg.getInteger("api.timeout",10);
		}
		catch (Exception e) { mylog.error("AuthFilter Conf: ",e); }
		
		boolean bCorrect = true;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			db_type = (String) env.lookup("db_type");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select login,expiration from api_token where token = '"+token+"'");
			if (rs.next()) {
				String myusr = rs.getString("login");
				String mydate = rs.getString("expiration");
				String myformat = "yyyy-MM-dd HH:mm:ss";
				if (db_type.equals("oracle")) { myformat += ".0"; }
				java.util.Date expdate = DateUtils.parseDate(mydate,myformat);
				java.util.Date now = new java.util.Date();
				if (expdate.getTime() < now.getTime()) {
					mylog.debug("User "+myusr+" has expired token");
					bCorrect=false;
					resultat = "Expired Token";
				} else {
					this.username = myusr;
				}
			} else {
				mylog.debug("Token: "+token+" not found");
				bCorrect=false;
			}
			rs.close();rs = null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) {
			bCorrect = false;
			mylog.error("DB Access: ",e);
		} finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("DB Close rs: ",e); } rs = null; }
   		if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("DB Close stmt: ",e); } stmt = null; }
   		if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("DB Close conn: ",e); } conn = null; }
   	}
   	if (!bCorrect) { throw new Exception(resultat); }
	}
}
