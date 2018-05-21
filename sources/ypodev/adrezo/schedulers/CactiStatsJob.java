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
import com.mysql.cj.jdbc.MysqlDataSource;
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import org.apache.commons.lang3.time.DateUtils;
import ypodev.adrezo.beans.TestHoursBean;

public class CactiStatsJob implements Job {
	private Logger mylog = Logger.getLogger(CactiStatsJob.class);
	private Connection conna = null;
	private Connection connc = null;
	private Statement stmta = null;
	private Statement stmtc = null;
	private boolean erreur = false;
	private class Adrezo_id {
		private Integer id;
		private Integer plan;
		private Adrezo_id (Integer id,Integer plan) {
			this.id = id;
			this.plan = plan;
		}
	}			
	private Map<Integer,Adrezo_id> adrezo = new HashMap<Integer,Adrezo_id>();
	private Map<Integer,BigDecimal> cacti = new HashMap<Integer,BigDecimal>();
	private String mailhost="";
	private String mailfrom="";
	private Integer mailport=25;
	private boolean mailssl=false;
	private String mailuser="";
	private String mailpwd="";
	private boolean mailauth=false;
	private String cactihost="localhost";
	private Integer cactiport=3306;
	private String cactidbname="cacti";
	private String cactiuser="cactiuser";
	private String cactipwd="cactiuser";
	private String cactitz="Europe/Paris";
	
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
			cactihost = cfg.getString("cacti.host");
			cactiport = cfg.getInt("cacti.port");
			cactidbname = cfg.getString("cacti.dbname");
			cactiuser = cfg.getString("cacti.user");
			cactipwd = cfg.getString("cacti.pwd");
			cactitz = cfg.getString("cacti.tz");
		}
		catch (Exception cex) { mylog.error("CactiStats/ReadConf: "+cex.getMessage(),cex); }
	}
	
	private void OpenAdrezoDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conna = ds.getConnection();
			stmta = conna.createStatement();
			mylog.debug("Connected to Adrezo DB");
		} catch (Exception e) { erreur=true;mylog.error("CactiStats/OpenAdrezoDB: "+e.getMessage(),e); }
	}
	private void OpenCactiDB() {
		try {
			MysqlDataSource ds = new MysqlDataSource();
			ds.setUrl("jdbc:mysql://"+cactihost+":"+String.valueOf(cactiport)+"/"+cactidbname+"?useLegacyDatetimeCode=false&serverTimezone="+cactitz);
			ds.setUser(cactiuser);
			ds.setPassword(cactipwd);
			connc = ds.getConnection();
			stmtc = connc.createStatement();
			mylog.debug("Connected to Cacti DB");
		} catch (Exception e) { erreur=true;mylog.error("CactiStats/OpenCactiDB: "+e.getMessage(),e); }
	}
	
	private void CloseAdrezoDB() {
		try {
			stmta.close();stmta=null;
			conna.close();conna=null;
			mylog.debug("Closed Adrezo DB");
		} catch (Exception e) { mylog.error("CactiStats/CloseAdrezoDB: "+e.getMessage(),e); }
		finally {    
			if (stmta != null) { try { stmta.close(); } catch (SQLException e) { mylog.error("CactiStats/CloseAdrezoDB-stmta",e); } stmta = null; }
		  if (conna != null) { try { conna.close(); } catch (SQLException e) { mylog.error("CactiStats/CloseAdrezoDB-conna",e); } conna = null; }
		}
	}
	private void CloseCactiDB() {
		try {
			stmtc.close();stmtc=null;
			connc.close();connc=null;
			mylog.debug("Closed Cacti DB");
		} catch (Exception e) { mylog.error("CactiStats/CloseCactiDB: "+e.getMessage(),e); }
		finally {    
			if (stmtc != null) { try { stmtc.close(); } catch (SQLException e) { mylog.error("CactiStats/CloseCactiDB-stmtc",e); } stmtc = null; }
		  if (connc != null) { try { connc.close(); } catch (SQLException e) { mylog.error("CactiStats/CloseCactiDB-connc",e); } connc = null; }
		}
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
	
	private void GatherStats(Integer param) {
		ResultSet rsa = null;
		ResultSet rsc = null;
		ResultSet rsp = null;
		erreur=false;
		String slatable;
		String stamp;
		
		if (param==3) {
			// Gather Monthly Stats
			slatable = "slastats";
			stamp = new java.text.SimpleDateFormat("yyyyMM").format(DateUtils.addDays(new java.util.Date(),-1));

		} else if (param==2) {
			// Gather Daily Stats
			slatable = "sladays";
			stamp = new java.text.SimpleDateFormat("yyyyMMdd").format(DateUtils.addDays(new java.util.Date(),-1));
		} else {
			// Gather Hourly Stats
			slatable = "slahours";
			stamp = new java.text.SimpleDateFormat("yyyyMMddHH").format(DateUtils.addHours(new java.util.Date(),-1));
		}

		try {
			mylog.debug("Creating adrezo list");
			rsa = stmta.executeQuery("select distinct cacti,id,plan from sladevice where status<2 order by cacti");
			while (rsa.next()) { this.adrezo.put(rsa.getInt("cacti"),new Adrezo_id(rsa.getInt("id"),rsa.getInt("plan"))); }
			rsa.close();rsa=null;
			
			mylog.debug("Creating cacti list");
			rsc = stmtc.executeQuery("select id,availability from host");
			while (rsc.next()) { this.cacti.put(rsc.getInt("id"),rsc.getBigDecimal("availability")); }
			rsc.close();rsc=null;
						
			mylog.debug("Start gathering statistics");
			for (Integer key : cacti.keySet()) {
				if (adrezo.containsKey(key)) {
					Adrezo_id myadrezo = adrezo.get(key);
					boolean gather = false;
					if (param == 3 || myadrezo.plan == 0) { gather = true; }
					else {
						rsp = stmta.executeQuery("select * from slaplanning where id="+String.valueOf(myadrezo.plan));
						if (rsp.next()) {
							if (param == 2) {
								String myday = new java.text.SimpleDateFormat("u").format(DateUtils.addDays(new java.util.Date(),-1));
								if (rsp.getInt("h"+myday) < 16777215) { gather = true; }
							}
							else if (param == 1) {
								String myday = new java.text.SimpleDateFormat("u").format(DateUtils.addHours(new java.util.Date(),-1));
								String myhour = new java.text.SimpleDateFormat("H").format(DateUtils.addHours(new java.util.Date(),-1));
								TestHoursBean test = new TestHoursBean();
								test.setHours(rsp.getInt("h"+myday));
								if (!test.isHour(Double.parseDouble(myhour))) { gather = true; }
							}
						}
						rsp.close();rsp=null;
					}
					if (gather) {
						mylog.debug("Gathering stats for device "+String.valueOf(myadrezo.id));
						BigDecimal mydispo = cacti.get(key);
						stmta.execute("insert into "+slatable+" (device,stamp,availability) values ("+String.valueOf(myadrezo.id)+",'"+stamp+"',"+mydispo.toPlainString()+")");
					} else { mylog.debug("Not gathering stats for device "+String.valueOf(myadrezo.id)); }
				} else {
					mylog.error("ID Cacti ("+String.valueOf(key)+") not in adrezo");
					erreur=true;
				}
			}
			mylog.info("Statistics collected");
		} catch (Exception e) { erreur=true;mylog.error("CactiStats/GatherStats: "+e.getMessage(),e); }
		finally {
			if (rsa != null) { try { rsa.close(); } catch (SQLException e) { mylog.error("CactiStats/GatherStats-rsa",e); } rsa = null; }
			if (rsc != null) { try { rsc.close(); } catch (SQLException e) { mylog.error("CactiStats/GatherStats-rsc",e); } rsc = null; }
			if (rsp != null) { try { rsp.close(); } catch (SQLException e) { mylog.error("CactiStats/GatherStats-rsp",e); } rsp = null; }
		}		
	}

	private void ZeroCacti() {
		try {
			mylog.debug("Zeroize cacti availability statistics");
			stmtc.execute("update host set availability='100.00',min_time='9.99999',max_time='0',cur_time='0',avg_time='0',total_polls='0',failed_polls='0'");
		} catch (Exception e) { mylog.error("CactiStats/ZeroCacti: "+e.getMessage(),e); }
	}

	private void SendErrorMail() {
		ResultSet rsa = null;
		ResultSet rsm = null;
		Statement stmtm = null;
	
		try {
			String myto = "";
			rsa = stmta.executeQuery("select mail from auth_users where id=0");
			if (rsa.next()) {
				myto = rsa.getString("mail");
				stmtm = conna.createStatement();
				rsm = stmtm.executeQuery("select * from mail where id=5 and lang=(select lang from usercookie where login='admin')");
				if (rsm.next()) {
					if (!rsm.getString("destinataire").equals("USERDEF")) { myto = rsm.getString("destinataire"); }
					sendMsg(myto,rsm.getString("subject"),rsm.getString("message"));
				}
				rsm.close();rsm=null;
				stmtm.close();stmtm=null;
			}
			rsa.close();rsa=null;
		} catch (Exception e) { mylog.error("CactiStats/SendErrorMail: "+e.getMessage(),e); }
		finally {
			if (rsa != null) { try { rsa.close(); } catch (SQLException e) { mylog.error("CactiStats/SendErrorMail-rsa",e); } rsa = null; }
			if (rsm != null) { try { rsm.close(); } catch (SQLException e) { mylog.error("CactiStats/SendErrorMail-rsm",e); } rsm = null; }
			if (stmtm != null) { try { stmtm.close(); } catch (SQLException e) { mylog.error("CactiStats/SendErrorMail-stmtm",e); } stmtm = null; }
		}
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ResultSet rsg = null;
		try {
			OpenAdrezoDB();
			rsg = stmta.executeQuery("select * from schedulers where id=8");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 8 enabled");
					ReadConf();
					OpenCactiDB();
					if (!erreur) {
						GatherStats(rsg.getInt("param"));
						if (!erreur) {
							ZeroCacti();
						} else {
							SendErrorMail();
						}
					}
					CloseCactiDB();
				} else mylog.debug("Job 8 disabled");
			}
			rsg.close();rsg=null;
			CloseAdrezoDB();
		} catch (Exception e) { mylog.error("CactiStats/Global: "+e.getMessage(),e); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { mylog.error("CactiStats/Global-CloseRSG",e); } rsg = null; }
			if (stmta != null) { try { stmta.close(); } catch (SQLException e) { mylog.error("CactiStats/Global-stmta",e); } stmta = null; }
		  if (conna != null) { try { conna.close(); } catch (SQLException e) { mylog.error("CactiStats/Global-conna",e); } conna = null; }
		  if (stmtc != null) { try { stmtc.close(); } catch (SQLException e) { mylog.error("CactiStats/Global-stmtc",e); } stmtc = null; }
		  if (connc != null) { try { connc.close(); } catch (SQLException e) { mylog.error("CactiStats/Global-connc",e); } connc = null; }
		}		
	} 
}
