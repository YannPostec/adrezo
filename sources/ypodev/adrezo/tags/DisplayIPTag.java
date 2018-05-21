package ypodev.adrezo.tags;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import javax.servlet.jsp.*;
import javax.servlet.jsp.tagext.*;
import ypodev.adrezo.util.*;

public class DisplayIPTag extends SimpleTagSupport {
	private String value;

	public void setValue(String value) {
		this.value = value;
	}

	public void doTag() throws IOException {
		getJspContext().getOut().print(IPFmt.displayIP(value));
	}
}
