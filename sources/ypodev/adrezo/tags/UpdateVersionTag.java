package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class UpdateVersionTag extends SimpleTagSupport {
	private String begin;
	private String end;
	private ResourceBundle prop;

	private String constructHash(String val) {
		if (!val.equals(this.end)) {
			if (this.end.equals(prop.getString(val+".next"))) {
				return val;
			} else {
				return val+","+constructHash(prop.getString(val+".next"));
			}
		} else {
			return this.end;
		}
	}
	public void setBegin(String begin) {
		this.begin = begin;
	}
	public void setEnd(String end) {
		this.end = end;
	}
	public void doTag() throws IOException {
		this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.sqlupdate");
		getJspContext().getOut().print(constructHash(this.begin));
	}
}
