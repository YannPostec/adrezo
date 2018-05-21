package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import java.sql.*;
import javax.naming.*;
import org.apache.log4j.Logger;
import org.jasypt.util.password.*;

public class UpdatePwdTag extends SimpleTagSupport {
	private String value;
	private Logger mylog = Logger.getLogger(UpdatePwdTag.class);
	
	public void setValue(String value) {
		this.value = value;
	}

	public void doTag() throws IOException {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select pwd from auth_users where auth=0 and login='admin'");
			if (rs.next()) {
				String mypwd = rs.getString("pwd");
				BasicPasswordEncryptor passwordEncryptor = new BasicPasswordEncryptor();
				if (passwordEncryptor.checkPassword(this.value, mypwd)) {
					getJspContext().getOut().print("password_ok");
				}
			}
			rs.close();rs=null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("ErrCompare",e); }
		finally {    
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("CloseRS:",e); } rs = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("CloseStmt:",e); } stmt = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("CloseConn:",e); } conn = null; }
		}
	}
}
