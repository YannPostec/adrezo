package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import org.jasypt.util.password.*;
import org.apache.log4j.Logger;

public class EncryptPwd {
	public static String encryptPwd(String value) {
		try {
			BasicPasswordEncryptor pwd = new BasicPasswordEncryptor();
			return pwd.encryptPassword(value);
		} catch (Exception e) { Logger.getLogger(EncryptPwd.class).error("Error:",e);return(e.getMessage()); }
	}
}
