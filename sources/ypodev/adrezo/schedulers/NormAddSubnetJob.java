package ypodev.adrezo.schedulers;

/*
 * @Author : Yann POSTEC
 */
 
import org.quartz.*;
import org.apache.log4j.Logger;
import java.io.*;
import java.util.*;
import java.text.*;
import java.sql.*;
import javax.naming.*;
import ypodev.adrezo.util.IPFmt;

public class NormAddSubnetJob implements Job {
	private Logger mylog = Logger.getLogger(NormAddSubnetJob.class);
	private Connection conn = null;
	private Statement stmt = null;
	private Statement stmtsearch = null;
	private Statement stmtupdt = null;
	
	private void OpenDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			stmtsearch = conn.createStatement();
			stmtupdt = conn.createStatement();
		} catch (Exception e) { mylog.error("NormAS/OpenDB: "+e.getMessage(),e); }
	}
	
	private void CloseDB() {
		try {
			stmt.close();stmt=null;
			stmtsearch.close();stmtsearch=null;
			stmtupdt.close();stmtupdt=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("NormAS/CloseDB: "+e.getMessage(),e); }
		finally {    
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (stmtsearch != null) { try { stmtsearch.close(); } catch (SQLException e) { ; } stmtsearch = null; }
			if (stmtupdt != null) { try { stmtupdt.close(); } catch (SQLException e) { ; } stmtupdt = null; }
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}
	
	private Integer SearchSurnet(Integer myid, String myip, Integer mymask) {
		Integer res = 0;
		ResultSet rssearch = null;
		try {
			String strmask = String.valueOf(mymask);
			String ipsub = IPFmt.GetNetwork(myip,strmask);
			rssearch = stmtsearch.executeQuery("select id from surnets where ip='"+ipsub+"' and mask="+strmask);
			if (rssearch.next()) {
				res = rssearch.getInt("id");
			} else {
				if (mymask>2) {
					res = SearchSurnet(myid,myip,mymask-1);
				}
			}
			rssearch.close();rssearch=null;
			
		} catch (Exception e) { mylog.error("NormAS/SearchSubnet: "+e.getMessage(),e); }
		finally {
			if (rssearch != null) { try { rssearch.close(); } catch (SQLException e) { ; } rssearch = null; }
		}
		return res;
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ResultSet rsg = null;
		ResultSet rssub = null;
		try {
			OpenDB();
			mylog.debug("Connected to DB");
			rsg = stmt.executeQuery("select * from schedulers where id=6");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 6 enabled");
					Integer result = 0;
					rssub = stmt.executeQuery("select id,ip,mask from subnets where surnet=0");
					while (rssub.next()) {
						Integer mymask = rssub.getInt("mask");
						Integer myid = rssub.getInt("id");
						String myip = rssub.getString("ip");
						mylog.debug("Search surnet for subnet "+String.valueOf(myid)+" ("+IPFmt.displayIP(myip)+"/"+String.valueOf(mymask)+")");
						result = SearchSurnet(myid,myip,mymask);
						if (result>0) {
							stmtupdt.execute("update subnets set surnet = "+String.valueOf(result)+" where id = "+String.valueOf(myid));
							mylog.info("Found surnet "+String.valueOf(result)+" for subnet "+String.valueOf(myid)+" ("+IPFmt.displayIP(myip)+"/"+String.valueOf(mymask)+")");
						} else {
							mylog.warn("No surnet for subnet "+String.valueOf(myid)+" ("+IPFmt.displayIP(myip)+"/"+String.valueOf(mymask)+")");
						}
						result = 0;
					}
					rssub.close();rssub=null;
				} else mylog.debug("Job 6 disabled");
			}
			rsg.close();rsg=null;
			CloseDB();
			mylog.debug("DB closed");
		} catch (Exception e) { mylog.error("NormAS/Global: "+e.getMessage(),e); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { ; } rsg = null; }
			if (rssub != null) { try { rssub.close(); } catch (SQLException e) { ; } rssub = null; }
		}		
	} 
}
