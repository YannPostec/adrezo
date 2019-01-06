package ypodev.adrezo.schedulers;

/*
 * @Author : Yann POSTEC
 */
 
import org.quartz.*;
import org.apache.log4j.Logger;
import java.util.*;
import java.text.*;
import java.sql.*;
import javax.naming.*;
import org.apache.commons.lang3.time.DateUtils;
import ypodev.adrezo.util.DbFunc;

public class PurgeUsersJob implements Job {

	private Logger mylog = Logger.getLogger(PurgeUsersJob.class);

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		Connection conn = null;
		Statement stmt = null;
		Statement stmtdel = null;
		Statement stmtg = null;
		ResultSet rsg = null;
		ResultSet rs = null;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmtg = conn.createStatement();
			rsg = stmtg.executeQuery("select * from schedulers where id=1");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 1 enabled");
					int days = 0-rsg.getInt("param");
					mylog.debug("param="+String.valueOf(days));
					stmt = conn.createStatement();
					rs = stmt.executeQuery("select login from usercookie where last<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addDays(new java.util.Date(),days))+"','YYYY-MM-DD HH24:MI:SS') and login <> 'admin'");
					mylog.debug("Executing SQL :"+"select login from usercookie where last<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addDays(new java.util.Date(),days))+"','YYYY-MM-DD HH24:MI:SS') and login <> 'admin'");
					Integer nbdel=0;
					while (rs.next()) {
						String dellogin = rs.getString("login");
						mylog.info("Deleted: "+dellogin);
						nbdel++;
						stmtdel = conn.createStatement();
						stmtdel.executeUpdate("delete from usercookie where login='"+dellogin+"'");
						stmtdel.close();stmtdel=null;
					}
					if (nbdel==0) { mylog.info("No login to delete"); }
					rs.close();rs=null;
					stmt.close();stmt=null;
				} else mylog.debug("Job 1 disabled");
			}
			rsg.close();rsg=null;
			stmtg.close();stmtg=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("PurgeUsers/DB: "+e.getMessage()); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { ; } rsg = null; }
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (stmtg != null) { try { stmtg.close(); } catch (SQLException e) { ; } stmtg = null; }
			if (stmtdel != null) { try { stmtdel.close(); } catch (SQLException e) { ; } stmtdel = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}		
	}
}
