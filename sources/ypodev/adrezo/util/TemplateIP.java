package ypodev.adrezo.util;

/*
 * @Author : Yann POSTEC
 */
 
import org.apache.logging.log4j.*;
import ypodev.adrezo.util.IPFmt;

public class TemplateIP {
	public static String templateIP(String surnet, String addip) {
		try {
			return IPFmt.addTwoIP(surnet,addip);
		} catch (Exception e) { LogManager.getLogger(TemplateIP.class).error("Error:",e);return(e.getMessage()); }
	}
}
