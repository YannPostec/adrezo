package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import org.jasypt.util.text.*;
import org.apache.logging.log4j.*;

public class EncryptLDAPPwd {
	public static String encryptLDAPPwd(String value) {
		try {
			BasicTextEncryptor pwd = new BasicTextEncryptor();
			pwd.setPassword("ceciestlepasswordldap");
			return pwd.encrypt(value);
		} catch (Exception e) { LogManager.getLogger(EncryptLDAPPwd.class).error("Error:",e);return(e.getMessage()); }
	}
}
