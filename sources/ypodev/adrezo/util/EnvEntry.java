package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import javax.naming.*;
import org.apache.logging.log4j.*;

public class EnvEntry {
	public static String envEntry(String value) {
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			return((String) env.lookup(value));
		} catch (Exception e) { LogManager.getLogger(EnvEntry.class).error("Error:",e);return(e.getMessage()); }
	}
}
