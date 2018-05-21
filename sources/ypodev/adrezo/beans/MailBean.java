package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*; 
import java.sql.*;
import javax.naming.*;
import org.apache.log4j.Logger;
import org.apache.commons.mail.*;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;

public class MailBean implements Serializable {
	private String to = "";
	private String subject = "";
	private String message = "";
	private String separateur = "#";
	private String db_type = "";
	private int mailId = 0;
	private int tableId = 0;
	private int custom = 0;
	private String errLog = "";
	private boolean erreur = false;
	private transient ResourceBundle prop;
	private String lang = "";
	private static Logger mylog = Logger.getLogger(MailBean.class);
	
	// Private procedures
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg;
	}
	
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
		catch (Exception cex) { printLog("MailConf: ",cex); }
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
		catch (EmailException e) { printLog("Mail: ",e); }
	}	

	private void ParseMail(Connection conn, String sep) {
		Statement stmt = null;
		ResultSet rs = null;
		String msg;
		
		try {
			stmt = conn.createStatement();
			String sqlMailId = "select * from mail where id="+mailId+" and lang='"+this.lang+"'";
			stmt.execute(sqlMailId);
			rs = stmt.getResultSet(); 
			
			if (rs.next()) {
				String dest = rs.getString("destinataire");
				if (dest.equals("USERDEF")) { dest = to; }
				String sub = rs.getString("subject");
				if (sub.equals("USERDEF")) { sub = subject; }
				msg = rs.getString("message");
				if (msg.equals("USERDEF")) { msg = message; }
				String table = rs.getString("location");
				if (db_type.equals("postgresql")) { table = table.toLowerCase(); }
				Statement stmtMail = null;
				ResultSet rsMail = null;
				try {
					stmtMail = conn.createStatement();
					String sqlTableId = "select * from "+table+" where id=" + tableId;
					stmtMail.execute(sqlTableId);
					rsMail = stmtMail.getResultSet();
					if (rsMail.next()) {
						DatabaseMetaData metaData = conn.getMetaData();
						if (metaData != null) {
							ResultSet rsDesc = metaData.getColumns(null,null,table,"%");
							while (rsDesc.next()) {
								String colName = rsDesc.getString("COLUMN_NAME");
								int colType = rsDesc.getInt("DATA_TYPE");
								boolean bChaine = false;
								String myval;
								if (colType != 3) { bChaine = true; }
								if (bChaine) { myval = rsMail.getString(colName); }
								else { myval = String.valueOf((int)rsMail.getInt(colName)); }
								if (db_type.equals("postgresql")) { colName = colName.toUpperCase(); }
								msg = msg.replaceAll(sep+colName+sep,myval);
								sub = sub.replaceAll(sep+colName+sep,myval);
							}
						} else { printLog(prop.getString("mail.err.metadata"),null); }			
					} else { printLog(prop.getString("mail.err.ref"),null);	}
					rsMail.close();rsMail = null;
					stmtMail.close();stmtMail = null;
					sendMsg(dest,sub,msg);
				} catch (Exception e) { printLog("Err ParseMail: ",e); }
				finally {    
					if (rsMail != null) { try { rsMail.close(); } catch (SQLException e) { ; } rsMail = null; }
		    	if (stmtMail != null) { try { stmtMail.close(); } catch (SQLException e) { ; } stmtMail = null; }
				}
			} else { printLog(prop.getString("mail.err.model"),null); }
			rs.close();rs = null;
			stmt.close();stmt = null;
			msg = "";
		} catch (Exception e) { printLog("Err Parse: ",e); }
		finally {    
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		}
	}
	
	private void ClearAll() {
		errLog = "";
		erreur = false;
	}
	
	// Public getters
	public boolean getErreur() {
		if (this.mailId == 0) { this.errLog += prop.getString("mail.err.mailid");return false; }
		else { return erreur; }
	}
	public String getErrLog() {
		return errLog;
	}
	
	// Public setters
	public void setTableId (int tableId) {
		this.tableId = tableId;
	}
	public void setTo(String to) {
		this.to = to;
	}
	public void setSeparateur(String separateur) {
		this.separateur = separateur;
	}
	public void setSubject(String subject) {
		this.subject = subject;
	}
	public void setMessage(String message) {
		this.message = message;
	}
	public void setLang(String lang) {
		this.lang = lang;
	}
		
	public void setMailId(int id) {
		this.mailId = id;
		ClearAll(); //Reinit des variables
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			db_type = (String) env.lookup("db_type");
				
			Connection conn = null;
			Statement stmt = null;
			ResultSet rslang = null;
			try {
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rslang = stmt.executeQuery("select lang from usercookie where login = 'admin'");
				if (this.lang.equals("")) {
					if (rslang.next()) {this.lang = rslang.getString("lang");} else {this.lang="en";}
				}
				rslang.close();rslang = null;
				Locale locale = new Locale(lang);
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
				stmt.close();stmt = null;
				if (tableId > 0) { ParseMail(conn,separateur); }
				else { this.errLog += prop.getString("mail.err.tableid"); }
				conn.close();conn = null;
			} catch (Exception e) { printLog("Main :",e); }
			finally {
				if (rslang != null) { try { rslang.close(); } catch (SQLException e) { ; } rslang = null; }
    		if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
			}
		} catch (Exception e) { printLog("Env : ",e); }
	}
	


}
