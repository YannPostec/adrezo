package ypodev.adrezo.schedulers;

/*
 * @Author : Yann POSTEC
 */
 
import org.quartz.*;
import org.apache.log4j.Logger;
import java.io.*;
import java.util.*;
import java.text.*;
import java.math.BigDecimal;
import java.sql.*;
import javax.naming.*;
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import org.apache.commons.lang3.time.DateUtils;

public class CactiAggregateDaysJob implements Job {
	private Logger mylog = Logger.getLogger(CactiAggregateDaysJob.class);
	private Connection conn = null;
	private Statement stmt = null;
	private boolean erreur = false;
	private String mailhost="";
	private String mailfrom="";
	private Integer mailport=25;
	private boolean mailssl=false;
	private String mailuser="";
	private String mailpwd="";
	private boolean mailauth=false;

	private void ReadConf() {
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			mailhost = cfg.getString("mail.host");
			mailfrom = cfg.getString("mail.from");
			mailport = cfg.getInt("mail.port");
			mailssl = cfg.getBoolean("mail.ssl");
			mailuser = cfg.getString("mail.user");
			mailpwd = cfg.getString("mail.pwd");
			mailauth = cfg.getBoolean("mail.auth");
		}
		catch (Exception cex) { mylog.error("CactiAggDays/ReadConf: "+cex.getMessage(),cex); }
	}
	
	private void sendMsg(String to, String subject, String message) {
		try {
			if (!mailhost.equals("")) {
				Email email = new SimpleEmail();
				email.setHostName(mailhost);
				email.setSmtpPort(mailport);
				email.setSSLOnConnect(mailssl);
				if (mailauth) {
					email.setAuthenticator(new DefaultAuthenticator(mailuser,mailpwd));
				}
				email.setFrom(mailfrom);
				email.setSubject(subject);
				email.setMsg(message);
				email.addTo(to);
				email.send();
			} else { mylog.info("MailHost : no host in configuration"); }
		}
		catch (EmailException e) { mylog.error("Mail: "+e.getMessage(),e); }
	}	
		
	private void OpenDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			mylog.debug("Connected to Adrezo DB");
		} catch (Exception e) { mylog.error("CactiAggDays/OpenDB: "+e.getMessage(),e); }
	}
	
	private void CloseDB() {
		try {
			stmt.close();stmt=null;
			conn.close();conn=null;
			mylog.debug("Closed Adrezo DB");
		} catch (Exception e) { mylog.error("CactiAggDays/CloseDB: "+e.getMessage(),e); }
		finally {    
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("CactiAggDays/CloseDB-stmt",e); } stmt = null; }
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("CactiAggDays/CloseDB-conn",e); } conn = null; }
		}
	}

	private void AggregateStats() {
		ResultSet rs = null;
		Statement stmtagg = null;
		erreur=false;
		String stamp = new java.text.SimpleDateFormat("yyyyMM").format(DateUtils.addDays(new java.util.Date(),-1));

		try {
			mylog.info("Aggregate Daily Stats in Stats table");
			stmtagg = conn.createStatement();
			rs = stmt.executeQuery("select device,avg(availability) as dispo from sladays where stamp like '"+stamp+"%' group by device");
			while (rs.next()) {
				stmtagg.execute("insert into slastats (device,stamp,availability) values ("+String.valueOf(rs.getInt("device"))+",'"+stamp+"',"+rs.getBigDecimal("dispo").toPlainString()+")");
			}
			rs.close();rs=null;
			stmtagg.close();stmtagg=null;
		} catch (Exception e) { erreur=true;mylog.error("CactiAggDays/AggregateStats: "+e.getMessage(),e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { mylog.error("CactiAggDays/AggregateStats-rs",e); } rs = null; }
			if (stmtagg != null) { try { stmtagg.close(); } catch (SQLException e) { mylog.error("CactiAggDays/AggregateStats-stmtagg",e); } stmtagg = null; }
		}
	}
	
	private void ZeroStats() {
		try {
			stmt.execute("delete from sladays where stamp like '"+new java.text.SimpleDateFormat("yyyyMM").format(DateUtils.addDays(new java.util.Date(),-1))+"%'");
		} catch (Exception e) { mylog.error("CactiAggDays/ZeroStats: "+e.getMessage(),e); }
	}

	private void SendErrorMail() {
		ResultSet rsa = null;
		ResultSet rsm = null;
		Statement stmtm = null;
	
		try {
			String myto = "";
			rsa = stmt.executeQuery("select mail from auth_users where id=0");
			if (rsa.next()) {
				myto = rsa.getString("mail");
				stmtm = conn.createStatement();
				rsm = stmtm.executeQuery("select * from mail where id=7 and lang=(select lang from usercookie where login='admin')");
				if (rsm.next()) {
					if (!rsm.getString("destinataire").equals("USERDEF")) { myto = rsm.getString("destinataire"); }
					sendMsg(myto,rsm.getString("subject"),rsm.getString("message"));
				}
				rsm.close();rsm=null;
				stmtm.close();stmtm=null;
			}
			rsa.close();rsa=null;
		} catch (Exception e) { mylog.error("CactiAggDays/SendErrorMail: "+e.getMessage(),e); }
		finally {
			if (rsa != null) { try { rsa.close(); } catch (SQLException e) { mylog.error("CactiAggDays/SendErrorMail-rsa",e); } rsa = null; }
			if (rsm != null) { try { rsm.close(); } catch (SQLException e) { mylog.error("CactiAggDays/SendErrorMail-rsm",e); } rsm = null; }
			if (stmtm != null) { try { stmtm.close(); } catch (SQLException e) { mylog.error("CactiAggDays/SendErrorMail-stmtm",e); } stmtm = null; }
		}
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ResultSet rsg = null;
		try {
			OpenDB();
			rsg = stmt.executeQuery("select * from schedulers where id=10");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 10 enabled");
					AggregateStats();
					if (erreur) { SendErrorMail(); }
					else { ZeroStats(); }
				} else mylog.debug("Job 10 disabled");
			}
			rsg.close();rsg=null;
			CloseDB();
		} catch (Exception e) { mylog.error("CactiAggDays/Global: "+e.getMessage(),e); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { mylog.error("CactiAggDays/Global-CloseRSG",e); } rsg = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { mylog.error("CactiAggDays/Global-stmt",e); } stmt = null; }
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { mylog.error("CactiAggDays/Global-conn",e); } conn = null; }
		}		
	} 
}
