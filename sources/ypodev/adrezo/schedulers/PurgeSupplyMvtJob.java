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

public class PurgeSupplyMvtJob implements Job {

	private Logger mylog = Logger.getLogger(PurgeSupplyMvtJob.class);

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
			rsg = stmtg.executeQuery("select * from schedulers where id=2");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 2 enabled");
					int days = 0-rsg.getInt("days");
					mylog.debug("days="+String.valueOf(days));
					stmt = conn.createStatement();
					rs = stmt.executeQuery("select count(*) as nb from stock_mvt where stamp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addDays(new java.util.Date(),days))+"','YYYY-MM-DD HH24:MI:SS')");
					while (rs.next()) {
						String nblines = rs.getString("nb");
						mylog.info("Deleted: "+nblines+" lines");
						stmtdel = conn.createStatement();
						stmtdel.executeUpdate("delete from stock_mvt where stamp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(DateUtils.addDays(new java.util.Date(),days))+"','YYYY-MM-DD HH24:MI:SS')");
						stmtdel.close();stmtdel=null;
					}
					rs.close();rs=null;
					stmt.close();stmt=null;
				} else mylog.debug("Job 2 disabled");
			}
			rsg.close();rsg=null;
			stmtg.close();stmtg=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("PurgeSupplyMvt/DB: "+e.getMessage()); }
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
