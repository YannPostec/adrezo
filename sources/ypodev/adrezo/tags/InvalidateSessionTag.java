package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import javax.servlet.http.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import org.apache.log4j.Logger;

public class InvalidateSessionTag extends SimpleTagSupport {
	private Logger mylog = Logger.getLogger(InvalidateSessionTag.class);
	public void doTag() {
		try {
			PageContext pageContext = (PageContext) getJspContext();
			HttpSession session = pageContext.getSession();
			if (session != null) { session.invalidate(); }
		} catch (Exception e) { mylog.error("Error:",e); }
	}
}
