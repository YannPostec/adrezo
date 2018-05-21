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
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;
import ypodev.adrezo.util.IPFmt;
import ypodev.adrezo.util.DbFunc;

public class MailTempIPJob implements Job {
	private String lang = "";
	private String adminmail = "";
	
	private void sendMsg(String to, String subject, String message) {
		Configurations cfgs = new Configurations();
		String myhost = "";
		String myfrom = "";
		int myport = 25;
		Boolean myssl = false;
		Boolean myauth = false;
		String myuser = "";
		String mypwd = "";
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			myhost = cfg.getString("mail.host");
			myfrom = cfg.getString("mail.from");
			myport = cfg.getInt("mail.port");
			myssl = cfg.getBoolean("mail.ssl");
			myuser = cfg.getString("mail.user");
			mypwd = cfg.getString("mail.pwd");
			myauth = cfg.getBoolean("mail.auth");
		}
		catch (Exception cex) { mylog.error("MailConf: "+cex.getMessage(),cex); }
		try {
			if (!myhost.equals("")) {
				Email email = new SimpleEmail();
				email.setHostName(myhost);
				email.setSmtpPort(myport);
				email.setSSLOnConnect(myssl);
				if (myauth) {
					email.setAuthenticator(new DefaultAuthenticator(myuser,mypwd));
				}
				email.setFrom(myfrom);
				email.setSubject(subject);
				email.setMsg(message);
				email.addTo(to);
				email.send();
			} else { mylog.info("MailHost : host non renseigné"); }
		}
		catch (EmailException e) { mylog.error("Mail: "+e.getMessage(),e); }
	}	

	private Logger mylog = Logger.getLogger(MailTempIPJob.class);

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		Connection conn = null;
		Statement stmt = null;
		Statement stmtUser = null;
		ResultSet rslang = null;
		ResultSet rsg = null;
		ResultSet rsmail = null;
		ResultSet rsuser = null;
		ResultSet rsadmin = null;
		ResultSet rsinfos = null;		
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			String db_type = (String) env.lookup("db_type");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rslang = stmt.executeQuery("select lang from usercookie where login = 'admin'");
			if (rslang.next()) {this.lang = rslang.getString("lang");} else {this.lang="en";}
			rslang = stmt.executeQuery("select mail from auth_users where id=0");
			if (rslang.next()) {this.adminmail=rslang.getString("mail");}
			rslang.close();rslang=null;
			rsg = stmt.executeQuery("select * from schedulers where id=4");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 4 enabled");
					// Users presents avec mail
					rsmail = stmt.executeQuery("select distinct(a.usr_temp) from adresses a, usercookie u where a.usr_temp=u.login and a.temp = 1 and a.type = 'static' and a.date_temp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS')");
					while (rsmail.next()) {
						String myuser=rsmail.getString("usr_temp");
						String userlang = this.lang;
						String usermail = "";
						stmtUser = conn.createStatement();
						if (myuser.equals("admin")) {
							usermail = adminmail;
						} else {
							rsinfos = stmtUser.executeQuery("select mail,lang from usercookie where login='"+myuser+"'");
							if (rsinfos.next()) {
								usermail = rsinfos.getString("mail");
								userlang = rsinfos.getString("lang");
							}
							rsinfos.close();rsinfos=null;
						}
						rsuser = stmtUser.executeQuery("select ctx_name,subnet_name,site_name,name,ip,mask,date_temp from adresses_display where usr_temp='"+myuser+"' and temp = 1 and type = 'static' and date_temp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS') order by date_temp");
						List<String> messages = new ArrayList<String>();
						while (rsuser.next()) {
							String myfdate = "";
							if (db_type.equals("oracle")) { myfdate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(rsuser.getDate("date_temp")); }
    					if (db_type.equals("postgresql")) { myfdate = new java.text.SimpleDateFormat("yyyy-MM-dd").format(rsuser.getTimestamp("date_temp")); }
							messages.add(myuser+" : IP "+IPFmt.displayIP(rsuser.getString("ip"))+"/"+rsuser.getString("mask")+" , "+rsuser.getString("name")+" , [ "+rsuser.getString("ctx_name")+" | "+rsuser.getString("site_name")+" | "+rsuser.getString("subnet_name")+" ] , "+myfdate);
						}
						if (!messages.isEmpty()) {
							rsuser = stmtUser.executeQuery("select * from mail where id=2 and lang='"+userlang+"'");
							if (rsuser.next()) {
								String finalmsg = rsuser.getString("message");
								for (String msg: messages) {
									finalmsg += "\n"+msg;
								}
								if (usermail.equals("") || usermail == null || usermail.equals("null")) {
									mylog.info("Send user mail to admin, mail field for "+myuser+" is empty");
									usermail=adminmail;
									sendMsg(usermail,rsuser.getString("subject")+" - User "+myuser,finalmsg);
								} else {
									mylog.info("Send user mail to "+myuser+" with "+usermail);
									sendMsg(usermail,rsuser.getString("subject"),finalmsg);
								}
							}
						}
						rsuser.close();rsuser=null;
					}
					rsmail.close();rsmail=null;
					stmtUser.close();stmtUser=null;
					// Users absents -> mail admin
					String listusers="";
					rsadmin = stmt.executeQuery("select distinct(usr_temp) as UserList from adresses where temp = 1 and type = 'static' and date_temp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS') and usr_temp not in (select login from usercookie)");
					while (rsadmin.next()) {
						listusers+="'"+rsadmin.getString("UserList")+"',";
					}
					if (!listusers.equals("")) {
						listusers=listusers.substring(0,listusers.lastIndexOf(","));
						List<String> messages = new ArrayList<String>();
						rsadmin = stmt.executeQuery("select ctx_name,subnet_name,site_name,name,ip,mask,usr_temp,date_temp from adresses_display where usr_temp in ("+listusers+") and temp = 1 and type = 'static' and date_temp<"+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS') order by date_temp");
						while (rsadmin.next()) {
							String myfdate="";
							if (db_type.equals("oracle")) { myfdate=new java.text.SimpleDateFormat("yyyy-MM-dd").format(rsadmin.getDate("date_temp")); }
    					if (db_type.equals("postgresql")) { myfdate=new java.text.SimpleDateFormat("yyyy-MM-dd").format(rsadmin.getTimestamp("date_temp")); }
							messages.add(rsadmin.getString("usr_temp")+" : IP "+IPFmt.displayIP(rsadmin.getString("ip"))+"/"+rsadmin.getString("mask")+" , "+rsadmin.getString("name")+" , [ "+rsadmin.getString("ctx_name")+" | "+rsadmin.getString("site_name")+" | "+rsadmin.getString("subnet_name")+" ] , "+myfdate);
						}
						if (!messages.isEmpty()) {
							rsadmin = stmt.executeQuery("select * from mail where id=2 and lang='"+this.lang+"'");
							if (rsadmin.next()) {
								String finalmsg = rsadmin.getString("message");
								for (String msg: messages) {
									finalmsg += "\n"+msg;
								}
								mylog.info("Send admin mail to admin with "+adminmail);
								sendMsg(adminmail,rsadmin.getString("subject"),finalmsg);
							}
						}
					} else { mylog.info("No admin mail"); }
					rsadmin.close();rsadmin=null;
				} else mylog.debug("Job 4 disabled");
			}
			rsg.close();rsg=null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("MailTempIP/DB: "+e.getMessage(),e); }
		finally {    
			if (rslang != null) { try { rslang.close(); } catch (SQLException e) { ; } rslang = null; }
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { ; } rsg = null; }
			if (rsmail != null) { try { rsmail.close(); } catch (SQLException e) { ; } rsmail = null; }
			if (rsuser != null) { try { rsuser.close(); } catch (SQLException e) { ; } rsuser = null; }
			if (rsinfos != null) { try { rsinfos.close(); } catch (SQLException e) { ; } rsinfos = null; }
			if (rsadmin != null) { try { rsadmin.close(); } catch (SQLException e) { ; } rsadmin = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (stmtUser != null) { try { stmtUser.close(); } catch (SQLException e) { ; } stmtUser = null; }
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}
}
