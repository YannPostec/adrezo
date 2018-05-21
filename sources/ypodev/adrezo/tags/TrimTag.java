package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;

public class TrimTag extends SimpleTagSupport {
	private String value;

	public void setValue(String value) {
		this.value = value;
	}

	public void doTag() throws IOException {
		value=value.replaceAll("\n","");		
		value=value.replaceAll("\r","");
		value=value.replaceAll("\t","");
		getJspContext().getOut().print(value);
	}
}
