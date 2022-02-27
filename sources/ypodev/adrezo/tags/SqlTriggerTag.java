package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import java.sql.*;
import javax.naming.*;
import java.util.*;
import org.apache.logging.log4j.*;

public class SqlTriggerTag extends SimpleTagSupport {
	private Logger mylog = LogManager.getLogger(SqlTriggerTag.class);
	public void doTag() throws IOException {
		Connection conn = null;
		Statement stmt = null;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup(jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			StringWriter sw = new StringWriter();
			getJspBody().invoke(sw);
			stmt.execute(sw.toString());
			stmt.close();stmt = null;
			conn.close();conn = null;
		} catch (Exception e) { mylog.error("Error:",e); }
		finally {
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}
}
