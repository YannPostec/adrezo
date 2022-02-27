package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import javax.ws.rs.*;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.SecurityContext;
import javax.ws.rs.container.ContainerRequestFilter;
import javax.ws.rs.container.ContainerRequestContext;
import javax.ws.rs.container.ResourceInfo;
import javax.ws.rs.ext.Provider;
import java.lang.annotation.*;
import java.lang.reflect.*;
import javax.annotation.Priority;
import java.security.Principal;
import org.apache.logging.log4j.*;

@Secured
@Provider
@Priority(Priorities.AUTHORIZATION)
public class AuthorizationFilter implements ContainerRequestFilter {
	private Logger mylog = LogManager.getLogger(AuthorizationFilter.class);
	private String login = null;
	private String msg = null;

	@Context
	private ResourceInfo resourceInfo;
	
	@Override
	public void filter(ContainerRequestContext requestContext) throws IOException {
		final SecurityContext sc = requestContext.getSecurityContext();
		Principal principal = sc.getUserPrincipal();
		this.login=principal.getName();
		// Get the resource class which matches with the requested URL and extract the roles declared by it
		Class<?> resourceClass = resourceInfo.getResourceClass();
		List<Role> classRoles = extractRoles(resourceClass);
		// Get the resource method which matches with the requested URL and extract the roles declared by it
		Method resourceMethod = resourceInfo.getResourceMethod();
		List<Role> methodRoles = extractRoles(resourceMethod);

		try {
			// Check if the user is allowed to execute the method
			// The method annotations overloads the class annotations
			if (!classRoles.isEmpty()) { checkPermissions(classRoles); }
			if (!methodRoles.isEmpty()) { checkPermissions(methodRoles); }
		} catch (Exception e) { requestContext.abortWith(Response.status(Response.Status.FORBIDDEN).entity(e.getMessage()).build()); }
	}

	// Extract the roles from the annotated element
	private List<Role> extractRoles(AnnotatedElement annotatedElement) {
		if (annotatedElement == null) {
			return new ArrayList<Role>();
		} else {
			Secured secured = annotatedElement.getAnnotation(Secured.class);
			if (secured == null) {
				return new ArrayList<Role>();
			} else {
				Role[] allowedRoles = secured.value();
				return Arrays.asList(allowedRoles);
			}
		}
	}

	private void checkPermissions(List<Role> allowedRoles) throws Exception {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		String msg = "Invalid Authorization";
		
		boolean bCorrect = true;
		try {
			javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select new_ctx from auth_roles where id = (select role as id from auth_users where auth=0 and login='"+this.login+"')");
			if (rs.next()) {
				Integer myrole = rs.getInt("new_ctx");
				ListIterator li = allowedRoles.listIterator();
				String missing = null;
				while (li.hasNext()) {
					Role r = (Role) li.next();
					if (Role.ADMIN.equals(r) && !isAdmin(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Admin"; } else { missing = "Admin"; } }
					if (Role.API.equals(r) && !isApi(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Api"; } else { missing = "Api"; } }
					if (Role.IP.equals(r) && !isIp(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Ip"; } else { missing = "Ip"; } }
					if (Role.NETWORK.equals(r) && !isNetwork(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Network"; } else { missing = "Network"; } }
					if (Role.PHOTO.equals(r) && !isPhoto(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Photo"; } else { missing = "Photo"; } }
					if (Role.STOCK.equals(r) && !isStock(myrole)) { bCorrect = false; if (missing!=null) { missing += ",Stock"; } else { missing = "Stock"; } }
					if (Role.STKADMIN.equals(r) && !isStockAdmin(myrole)) { bCorrect = false; if (missing!=null) { missing += ",StockAdmin"; } else { missing = "StockAdmin"; } }
				}
				if (!bCorrect) { msg = "Missing roles "+missing; }
			} else {
				bCorrect = false;
				mylog.debug("User "+this.login+" has no roles defined");
				msg = "Invalid authorization : no roles defined";
			}
			rs.close();rs = null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) {
			bCorrect = false;
			msg = "DB Error";
			mylog.error("DB Access: ",e);
		} finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("DB Close rs: ",e); } rs = null; }
   		if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("DB Close stmt: ",e); } stmt = null; }
   		if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("DB Close conn: ",e); } conn = null; }
   	}
   	if (!bCorrect) { throw new Exception(msg); }
	}
	
	private boolean isIp(Integer role) {
		boolean isValid = false;
		if ((role & 1) == 1) { isValid = true; }
		return isValid;
	}
	private boolean isPhoto(Integer role) {
		boolean isValid = false;
		if ((role & 2) == 2) { isValid = true; }
		return isValid;
	}
	private boolean isStock(Integer role) {
		boolean isValid = false;
		if ((role & 4) == 4) { isValid = true; }
		return isValid;
	}
	private boolean isStockAdmin(Integer role) {
		boolean isValid = false;
		if ((role & 8) == 8) { isValid = true; }
		return isValid;
	}	
	private boolean isAdmin(Integer role) {
		boolean isValid = false;
		if ((role & 16) == 16) { isValid = true; }
		return isValid;
	}
	private boolean isNetwork(Integer role) {
		boolean isValid = false;
		if ((role & 32) == 32) { isValid = true; }
		return isValid;
	}
	private boolean isApi(Integer role) {
		boolean isValid = false;
		if ((role & 64) == 64) { isValid = true; }
		return isValid;
	}
	
}
