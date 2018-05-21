package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import java.util.*;
import javax.naming.*;

public class DbFunc {
	public static String ToDateStr() {
		String result="TODATESTRERROR";
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String db_type = (String) env.lookup("db_type");
			if (db_type.equals("oracle")) { result="TO_DATE"; }
			if (db_type.equals("postgresql")) { result="TO_TIMESTAMP"; }
		} catch (Exception e) { return result; }
		finally {
			return result;
		}
	}
}
