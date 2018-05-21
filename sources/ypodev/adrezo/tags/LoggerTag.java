package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import java.util.*;
import org.apache.log4j.Logger;

public class LoggerTag extends SimpleTagSupport {
	private Throwable t;
	private Logger mylog = Logger.getLogger(LoggerTag.class);

	public void setException(Throwable e) {
		this.t = e;
	}

	public void doTag() throws IOException {
		try {
			mylog.error("JSP: ",t);
		} catch (Exception e) { }
	}
}
