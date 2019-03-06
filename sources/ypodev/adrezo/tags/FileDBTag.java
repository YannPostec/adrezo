package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import ypodev.adrezo.beans.UserInfoBean;
import org.apache.log4j.Logger;

public class FileDBTag extends SimpleTagSupport {
	private String value;
	private Logger mylog = Logger.getLogger(FileDBTag.class);

	public void setValue(String value) {
		this.value = value;
	}

	public void doTag() throws JspException {
		PageContext pageContext = (PageContext) getJspContext();
		HttpServletRequest req = (HttpServletRequest) pageContext.getRequest();
		UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
		String login = null;
		if (validUser == null) { login = "nologin"; } else { login = validUser.getLogin(); }
		Map params = req.getParameterMap();
		
		try {
			String pms = login + " in " + req.getRequestURI() + ". Params: ";
			Iterator i = params.keySet().iterator();
			while ( i.hasNext() ) {
				String key = (String) i.next();
        String value = ((String[]) params.get( key ))[ 0 ];
				pms=pms+key+"="+value+",";
      }
      mylog.info(pms);
			mylog.warn("Error Database : " + value);
		}
		catch (Exception e) { mylog.error("Error writing in database log file: ",e); }
	}
}
