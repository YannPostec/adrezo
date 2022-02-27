package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import org.apache.logging.log4j.*;
import com.mysql.cj.jdbc.MysqlDataSource;
import org.apache.commons.configuration2.builder.fluent.Configurations;
import org.apache.commons.configuration2.*;

public class TestMySQLBean implements Serializable {
	private String errLog = "";
	private boolean erreur = false;
	private transient Connection conn;
	private transient ResourceBundle prop;
	private String lang;
	private static Logger mylog = LogManager.getLogger(TestMySQLBean.class);
	private String cactihost="localhost";
	private Integer cactiport=3306;
	private String cactidbname="cacti";
	private String cactiuser="cactiuser";
	private String cactipwd="cactiuser";
	private String cactitz="Europe/Paris";

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg;
	}
	private void ReadConf() {
		Configurations cfgs = new Configurations();
		try {
			Configuration cfg = cfgs.properties(new File("adrezo.properties"));
			cactihost = cfg.getString("cacti.host");
			cactiport = cfg.getInt("cacti.port");
			cactidbname = cfg.getString("cacti.dbname");
			cactiuser = cfg.getString("cacti.user");
			cactipwd = cfg.getString("cacti.pwd");
			cactitz = cfg.getString("cacti.tz");
		}
		catch (Exception cex) { mylog.error("TestMySQL/ReadConf: "+cex.getMessage(),cex); }
	}
	private void OpenCactiDB() {
		try {
			MysqlDataSource ds = new MysqlDataSource();
			ds.setUrl("jdbc:mysql://"+cactihost+":"+String.valueOf(cactiport)+"/"+cactidbname+"?useLegacyDatetimeCode=false&serverTimezone="+cactitz);
			ds.setUser(cactiuser);
			ds.setPassword(cactipwd);
			conn = ds.getConnection();
		} catch (Exception e) { printLog(prop.getString("testmysql.error")+" (jdbc:mysql://"+cactihost+":"+String.valueOf(cactiport)+"/"+cactidbname+"?useLegacyDatetimeCode=false&serverTimezone="+cactitz+")<br />",e); }
	}
	private void CloseCactiDB() {
		try {
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("TestMySQL/Closing: "+e.getMessage(),e); }
		finally {    
		  if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}

	public boolean getErreur() { return erreur; }
	public String getErrLog() { return errLog; }

	public void setLang(String lang) {
		try {
			Locale locale = new Locale(lang);
			this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			ReadConf();
			OpenCactiDB();
			CloseCactiDB();
		} catch (Exception e) { printLog("TestMySQL/Main: ",e); }	
	}
}
