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
import com.mysql.cj.jdbc.MysqlDataSource;
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import ypodev.adrezo.util.DbSeqNextval;

public class CactiDevicesJob implements Job {
	private Logger mylog = Logger.getLogger(CactiDevicesJob.class);
	private Connection conna = null;
	private Connection connc = null;
	private Statement stmta = null;
	private Statement stmtc = null;
	private boolean erreur = false;
	private class Adrezo_ida {
		private Integer cacti;
		private String name;
		private Integer status;
		private Adrezo_ida(Integer c,String n,Integer s) {
			this.cacti = c;
			this.name = n;
			this.status = s;
		}
	}
	private class Cacti_id {
		private String name;
		private String disabled;
		private Integer status;
		private Cacti_id(String n,String d,Integer s) {
			this.name = n;
			this.disabled = d;
			this.status = s;
		}
	}
	private Map<Integer,Adrezo_ida> ida = new HashMap<Integer,Adrezo_ida>();
	private Map<Integer,Integer> idc = new HashMap<Integer,Integer>();
	private Map<Integer,Cacti_id> cid = new HashMap<Integer,Cacti_id>();
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
		catch (Exception cex) { mylog.error("CactiDevice/ReadConf: "+cex.getMessage(),cex); }
	}
	
	private void OpenAdrezoDB() {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conna = ds.getConnection();
			stmta = conna.createStatement();
			mylog.debug("Connected to Adrezo DB");
		} catch (Exception e) { erreur=true;mylog.error("CactiDevice/OpenAdrezoDB: "+e.getMessage(),e); }
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
		} catch (Exception e) { erreur=true;mylog.error("CactiDevice/OpenCactiDB: "+e.getMessage(),e); }
	}
	
	private void CloseAdrezoDB() {
		try {
			stmta.close();stmta=null;
			conna.close();conna=null;
			mylog.debug("Closed Adrezo DB");
		} catch (Exception e) { mylog.error("CactiDevice/CloseAdrezoDB: "+e.getMessage(),e); }
		finally {    
			if (stmta != null) { try { stmta.close(); } catch (SQLException e) { mylog.error("CactiDevice/CloseAdrezoDB-stmta",e); } stmta = null; }
		  if (conna != null) { try { conna.close(); } catch (SQLException e) { mylog.error("CactiDevice/CloseAdrezoDB-conna",e); } conna = null; }
		}
	}
	private void CloseCactiDB() {
		try {
			stmtc.close();stmtc=null;
			connc.close();connc=null;
			mylog.debug("Closed Cacti DB");
		} catch (Exception e) { mylog.error("CactiDevice/CloseCactiDB: "+e.getMessage(),e); }
		finally {    
			if (stmtc != null) { try { stmtc.close(); } catch (SQLException e) { mylog.error("CactiDevice/CloseCactiDB-stmtc",e); } stmtc = null; }
		  if (connc != null) { try { connc.close(); } catch (SQLException e) { mylog.error("CactiDevice/CloseCactiDB-connc",e); } connc = null; }
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
	
	private void UpdateData() {
		ResultSet rsa = null;
		ResultSet rsc = null;
		Statement stmtm = null;
		ResultSet rsm = null;

		try {
			mylog.info("Parsing Cacti data");
			mylog.debug("Creating adrezo list with adrezo id as key");
			rsa = stmta.executeQuery("select id,cacti,name,status from sladevice");
			while (rsa.next()) { this.ida.put(rsa.getInt("id"),new Adrezo_ida(rsa.getInt("cacti"),rsa.getString("name"),rsa.getInt("status"))); }
			
			mylog.debug("Creating adrezo list with cacti id as key");
			rsa = stmta.executeQuery("select distinct cacti,id from sladevice where status<2 order by cacti");
			while (rsa.next()) { this.idc.put(rsa.getInt("cacti"),rsa.getInt("id")); }
			
			mylog.debug("Creating cacti list");
			rsc = stmtc.executeQuery("select id,description,disabled,status from host");
			while (rsc.next()) { this.cid.put(rsc.getInt("id"),new Cacti_id(rsc.getString("description"),rsc.getString("disabled"),rsc.getInt("status"))); }
			rsc.close();rsc=null;
						
			mylog.info("Inject Cacti data into Adrezo");
			mylog.debug("Check adrezo data vs cacti");
			for (Integer key : ida.keySet()) {
				Adrezo_ida myida = ida.get(key);
				if (cid.containsKey(myida.cacti)) {
					Cacti_id mycid = cid.get(myida.cacti);
					// If different name, update adrezo
					if (!myida.name.equals(mycid.name)) { stmta.execute("update sladevice set name='"+mycid.name+"' where id="+String.valueOf(key)); }
					// If cacti device disabled and adrezo isn't up-to-date then update adrezo
					if ((mycid.disabled.equals("on") || mycid.status == 0) && myida.status > 0) { stmta.execute("update sladevice set status=0 where id="+String.valueOf(key)); } 
					// If cacti device up and adrezo isn't up-o-date then update adrezo
					if (!mycid.disabled.equals("on") && mycid.status > 0 && myida.status != 1) { stmta.execute("update sladevice set status=1 where id="+String.valueOf(key)); }
				} else {
					// If adrezo device doesn't exist anymore in cacti, status destroyed
					stmta.executeUpdate("update sladevice set status=2 where id="+String.valueOf(key));
				}
			}
			
			mylog.debug("Check cacti data vs adrezo");
			// Check cacti list, add if not existing in adrezo
			Integer cpt = 0;
			for (Integer key : cid.keySet()) {
				if (!idc.containsKey(key)) {
					Cacti_id mycid = cid.get(key);
					cpt++;
					String status = "1";
					if (mycid.disabled.equals("on") || mycid.status == 0) { status = "0"; }
					stmta.execute("insert into sladevice (id,site,cacti,name,status) values("+DbSeqNextval.dbSeqNextval("sladevice_seq")+",0,"+String.valueOf(key)+",'"+mycid.name+"',"+status+")");
				}
			}
	
			// If add in adrezo, send mail
			if (cpt>0) {
				mylog.info("End with "+String.valueOf(cpt)+" new devices");
				String myto = "";
				rsa = stmta.executeQuery("select mail from auth_users where id=0");
				if (rsa.next()) {
					myto = rsa.getString("mail");
					stmtm = conna.createStatement();
					rsm = stmtm.executeQuery("select * from mail where id=4 and lang=(select lang from usercookie where login='admin')");
					if (rsm.next()) {
						if (!rsm.getString("destinataire").equals("USERDEF")) { myto = rsm.getString("destinataire"); }
						sendMsg(myto,rsm.getString("subject"),rsm.getString("message")+String.valueOf(cpt));
					}
					rsm.close();rsm=null;
					stmtm.close();stmtm=null;
				}
			}
			rsa.close();rsa=null;
		} catch (Exception e) { mylog.error("CactiDevice/UpdateData: "+e.getMessage(),e); }
		finally {
			if (rsa != null) { try { rsa.close(); } catch (SQLException e) { mylog.error("CactiDevice/UpdateData - Close rsa",e); } rsa = null; }
			if (rsc != null) { try { rsc.close(); } catch (SQLException e) { mylog.error("CactiDevice/UpdateData - Close rsc",e); } rsc = null; }
			if (rsm != null) { try { rsm.close(); } catch (SQLException e) { mylog.error("CactiDevice/UpdateData - Close rsm",e); } rsm = null; }
			if (stmtm != null) { try { stmtm.close(); } catch (SQLException e) { mylog.error("CactiDevice/UpdateData - Close stmtm",e); } stmtm = null; }
		}		
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		ResultSet rsg = null;
		try {
			OpenAdrezoDB();
			rsg = stmta.executeQuery("select * from schedulers where id=7");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 7 enabled");
					ReadConf();
					OpenCactiDB();
					if (!erreur) { UpdateData(); }
					CloseCactiDB();
				} else mylog.debug("Job 7 disabled");
			}
			rsg.close();rsg=null;
			CloseAdrezoDB();
		} catch (Exception e) { mylog.error("CactiDevice/Global: "+e.getMessage(),e); }
		finally {
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { mylog.error("CactiDevice/Global-CloseRSG",e); } rsg = null; }
			if (stmta != null) { try { stmta.close(); } catch (SQLException e) { mylog.error("CactiDevice/Global-stmta",e); } stmta = null; }
		  if (conna != null) { try { conna.close(); } catch (SQLException e) { mylog.error("CactiDevice/Global-conna",e); } conna = null; }
		  if (stmtc != null) { try { stmtc.close(); } catch (SQLException e) { mylog.error("CactiDevice/Global-stmtc",e); } stmtc = null; }
		  if (connc != null) { try { connc.close(); } catch (SQLException e) { mylog.error("CactiDevice/Global-connc",e); } connc = null; }
		}		
	} 
}
