package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import javax.naming.*;
import org.apache.logging.log4j.*;

public class DbCast {
	private static Logger mylog = LogManager.getLogger(DbCast.class);
	public static String dbCast(String value) {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String db_type = (String) env.lookup("db_type");
			String resultat = "Unknown DB Type";
			if (db_type.equals("oracle")) {
				resultat = "";
			}
			else if (db_type.equals("postgresql")) {
				resultat = "::"+value;
			}
			else { mylog.error("Unknown DB Type"); }
			return((String) resultat);
		} catch (Exception e) { mylog.error("Error:",e);return(e.getMessage()); }
	}
}
