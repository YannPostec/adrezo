package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import java.text.*;
import javax.naming.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import java.math.BigInteger;
import java.security.SecureRandom;
import com.google.gson.*;
import org.jasypt.util.password.*;
import org.apache.log4j.Logger;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import org.apache.commons.lang3.time.DateUtils;
import ypodev.adrezo.util.DbFunc;

@Path("/auth")
public class AuthAPI {
	private Logger mylog = Logger.getLogger(AuthAPI.class);
	private Connection conn = null;
	private Statement stmt = null;
	private ResultSet rslocal = null;
	private String db_type;

	private class APIToken {
		private String sessionKey;
		private APIToken(String t) {
			this.sessionKey = t;
		}
	}
	
	@POST
	@Produces(MediaType.APPLICATION_JSON)
	@Consumes(MediaType.APPLICATION_FORM_URLENCODED)
	public Response authenticateUser(@FormParam("username") String username,@FormParam("password") String password) {
		String result="";
		baseend();
		baseinit();
		
		Configurations cfgs = new Configurations();
		Integer apitimeout = 10;
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			apitimeout = cfg.getInteger("api.timeout",10);
		}
		catch (Exception e) { mylog.error("APIAuth Conf: ",e); }
		
		try {
			authenticate(username,password);
			String token = issueToken(username,apitimeout);
			APIToken mytoken = new APIToken(token);
			Gson gson = new Gson();
			result = gson.toJson(mytoken);
			return Response.ok(result).build();
		} catch (Exception e) {
			return Response.status(Response.Status.FORBIDDEN).entity(e.getMessage()).build();
		} finally { baseend(); }
	}

	private void baseend() {
		if (this.rslocal != null) { try { this.rslocal.close(); } catch (SQLException e) { mylog.error("DB Close rslocal: ",e); } this.rslocal = null; }
   	if (this.stmt != null) { try { this.stmt.close(); } catch (SQLException e) { mylog.error("DB Close stmt: ",e); } this.stmt = null; }
   	if (this.conn != null) { try { this.conn.close(); } catch (SQLException e) { mylog.error("DB Close conn: ",e); } this.conn = null; }
	}
	
	private void baseinit() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			db_type = (String) env.lookup("db_type");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			this.conn = ds.getConnection();
			this.stmt = conn.createStatement();
		} catch (Exception e) { mylog.error("DB Open: ",e); }
	}
	
	private void authenticate(String usr, String pwd) throws Exception {
		boolean bCorrect = true;
		try {
			rslocal = stmt.executeQuery("select pwd from auth_users where auth=0 and login='"+usr+"'");
			if (rslocal.next()) {
				String mypwd = rslocal.getString("pwd");
				BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
				if (!passwordEncryptor.checkPassword(pwd, mypwd)) {
					mylog.warn("Bad Password for API user "+usr);
					bCorrect = false;
				}
			} else {
				mylog.warn("User "+usr+" unknown");
				bCorrect = false;
			}
			rslocal.close();rslocal = null;
		} catch (Exception e) {
			bCorrect = false;
			mylog.error("DB Authenticate: ",e);
		} finally {
			if (this.rslocal != null) { try { this.rslocal.close(); } catch (SQLException e) { mylog.error("DB Close rslocal in authenticate: ",e); } this.rslocal = null; }
		}
		if (!bCorrect) { throw new Exception("Invalid User or Password"); }
	}
	
	private String issueToken(String usr,Integer timeout) {
		Random random = new SecureRandom();
		String token = new BigInteger(130, random).toString(32);
		String resultat = "Invalid token";
		try {
			rslocal = stmt.executeQuery("select token,expiration from api_token where login = '"+usr+"'");
			if (rslocal.next()) {
				String mytoken = rslocal.getString("token");
				String mydate = rslocal.getString("expiration");
				String myformat = "yyyy-MM-dd HH:mm:ss";
				if (db_type.equals("oracle")) { myformat += ".0"; }
				java.util.Date expdate = DateUtils.parseDate(mydate,myformat);
				java.util.Date now = new java.util.Date();
				if (expdate.getTime() > now.getTime()) {
					mylog.debug("User "+usr+" returns, token refreshed and reassigned");
					stmt.executeUpdate("update api_token set expiration = "+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addMinutes(new java.util.Date(),timeout))+"','YYYY-MM-DD HH24:MI:SS') where login = '"+usr+"'");					
					resultat = mytoken;
				} else {
					mylog.debug("User "+usr+" returns, token expired, new delivered");
					stmt.executeUpdate("update api_token set token = '"+token+"',expiration = "+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addMinutes(new java.util.Date(),timeout))+"','YYYY-MM-DD HH24:MI:SS') where login = '"+usr+"'");
					resultat = token;
				}
			} else {
				mylog.debug("New API user "+usr+" inserted");
				stmt.executeUpdate("insert into api_token (login,token,expiration) values ('"+usr+"','"+token+"',"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addMinutes(new java.util.Date(),timeout))+"','YYYY-MM-DD HH24:MI:SS'))");
				resultat = token;
			}
		} catch (Exception e) {
			mylog.error("DB issueToken: ",e);
		} finally {
			if (this.rslocal != null) { try { this.rslocal.close(); } catch (SQLException e) { mylog.error("DB Close rslocal in issueToken: ",e); } this.rslocal = null; }
		}
		return resultat;
	}
}
