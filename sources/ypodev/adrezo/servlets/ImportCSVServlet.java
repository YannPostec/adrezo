package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*; 
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.log4j.Logger;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import ypodev.adrezo.beans.UserInfoBean;

public class ImportCSVServlet extends HttpServlet {
	//Constants
	private static final int ctxmax = 5000;
	private static final int sitemax = 2500;
	private static final int submax = 1000;
	private static final int vlanmax = 2000;
	private static final int ipmax = 1000;
	private static final int maxFileSize = 3145728;
	//Properties
	private String errLog;
	private boolean erreur;
	private int ignored;
	private int treated;
	private String xmlResult;
	private String lang;
	private ResourceBundle prop;
	private int cptctx;
	private int cptsite;
	private int cptsub;
	private int cptvlan;
	private int cptip;
	private Logger mylog = Logger.getLogger(ImportCSVServlet.class);

	private void printLog(String msg) {
		this.erreur = true;
		this.errLog += msg + "<br />";
	}
	private void parseCTX(String myline) {
		String[] arrLine = myline.split(",",-1);
		if (arrLine.length != 4) { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("verif.nbvar")); }
		else {
			boolean errParse = false;
			if (!arrLine[1].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : ID : "+prop.getString("verif.number"));errParse=true; }
			if (arrLine[2].equals("")) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.null"));errParse=true; }
			if (!errParse) {
				this.xmlResult += "<ctx><ctxid>"+arrLine[1]+"</ctxid><ctxname>"+arrLine[2]+"</ctxname></ctx>";
			}
		}
	}
	private void parseSITE(String myline) {
		String[] arrLine = myline.split(",",-1);
		if (arrLine.length != 5) { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("verif.nbvar")); }
		else {
			boolean errParse = false;
			if (!arrLine[1].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : ID : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[2].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : CTX : "+prop.getString("verif.number"));errParse=true; }
			if (arrLine[3].length() > 8 || arrLine[3].length() < 1) { printLog(prop.getString("csv.error")+myline+" : COD : "+prop.getString("verif.null")+" - "+prop.getString("verif.max")+" : 8");errParse=true; }
			if (arrLine[4].equals("")) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.null"));errParse=true; }
			if (!errParse) {
				this.xmlResult += "<site><siteid>"+arrLine[1]+"</siteid><sitectx>"+arrLine[2]+"</sitectx><sitecod>"+arrLine[3]+"</sitecod><sitename>"+arrLine[4]+"</sitename></site>";
			}
		}		
	}
	private void parseSUBNET(String myline) {
		String[] arrLine = myline.split(",",-1);
		if (arrLine.length != 10) { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("verif.nbvar")); }
		else {
			boolean errParse = false;
			if (!arrLine[1].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : ID : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[2].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : CTX : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[3].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : SITE : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[4].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : VLAN : "+prop.getString("verif.number"));errParse=true; }
			if (arrLine[5].length() != 12) { printLog(prop.getString("csv.error")+myline+" : IP : "+prop.getString("verif.null")+" - "+prop.getString("verif.ip"));errParse=true; }
			if (!arrLine[6].matches("\\d+") || Integer.parseInt(arrLine[6]) < 2 || Integer.parseInt(arrLine[6]) > 32) { printLog(prop.getString("csv.error")+myline+" : MASK : "+prop.getString("verif.number")+" - "+prop.getString("verif.mask"));errParse=true; }
			if (arrLine[7].equals("") || arrLine[7].length() > 40) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.null")+" - "+prop.getString("verif.max")+" : 40");errParse=true; }
			if (arrLine[7].indexOf("/") != -1) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.noslash"));errParse=true; }
			if (!arrLine[8].equals("")) {
				if (arrLine[8].length() != 12) { printLog(prop.getString("csv.error")+myline+" : GW : "+prop.getString("verif.ip"));errParse=true; }
			}
			if (arrLine[9].length() != 12) { printLog(prop.getString("csv.error")+myline+" : BC : "+prop.getString("verif.null")+" - "+prop.getString("verif.ip"));errParse=true; }
			if (!errParse) {
				this.xmlResult += "<subnet><subnetid>"+arrLine[1]+"</subnetid><subnetctx>"+arrLine[2]+"</subnetctx><subnetsite>"+arrLine[3]+"</subnetsite><subnetvlan>"+arrLine[4]+"</subnetvlan><subnetip>"+arrLine[5]+"</subnetip><subnetmask>"+arrLine[6]+"</subnetmask><subnetname>"+arrLine[7]+"</subnetname><subnetgw>"+arrLine[8]+"</subnetgw><subnetbc>"+arrLine[9]+"</subnetbc></subnet>";
			}
		}		
	}
	private void parseVLAN(String myline) {
		String[] arrLine = myline.split(",",-1);
		if (arrLine.length != 5) { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("verif.nbvar")); }
		else {
			boolean errParse = false;
			if (!arrLine[1].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : ID : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[2].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : SITE : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[3].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : VID : "+prop.getString("verif.number"));errParse=true; }
			if (arrLine[4].equals("") || arrLine[5].length() > 50) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.null")+" - "+prop.getString("verif.max")+" : 50");errParse=true; }
			if (!errParse) {
				this.xmlResult += "<vlan><vlanid>"+arrLine[1]+"</vlanid><vlansite>"+arrLine[2]+"</vlansite><vlanvid>"+arrLine[3]+"</vlanvid><vlanname>"+arrLine[4]+"</vlanname></vlan>";
			}
		}		
	}
	private void parseIP(String myline) {
		String[] arrLine = myline.split(",",-1);
		if (arrLine.length != 10) { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("verif.nbvar")); }
		else {
			boolean errParse = false;
			if (!arrLine[1].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : ID : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[2].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : CTX : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[3].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : SITE : "+prop.getString("verif.number"));errParse=true; }
			if (!arrLine[4].matches("\\d+")) { printLog(prop.getString("csv.error")+myline+" : SUBNET : "+prop.getString("verif.number"));errParse=true; }
			if (arrLine[5].length() != 12) { printLog(prop.getString("csv.error")+myline+" : IP : "+prop.getString("verif.null")+" - "+prop.getString("verif.ip"));errParse=true; }
			if (!arrLine[6].matches("\\d+") || Integer.parseInt(arrLine[6]) < 2 || Integer.parseInt(arrLine[6]) > 32) { printLog(prop.getString("csv.error")+myline+" : MASK : "+prop.getString("verif.number")+" - "+prop.getString("verif.mask"));errParse=true; }
			if (arrLine[7].equals("")) { printLog(prop.getString("csv.error")+myline+" : NAME : "+prop.getString("verif.null"));errParse=true; }
			if (!errParse) {
				this.xmlResult += "<ip><ipid>"+arrLine[1]+"</ipid><ipctx>"+arrLine[2]+"</ipctx><ipsite>"+arrLine[3]+"</ipsite><ipsubnet>"+arrLine[4]+"</ipsubnet><ipip>"+arrLine[5]+"</ipip><ipmask>"+arrLine[6]+"</ipmask><ipname>"+arrLine[7]+"</ipname><ipdef>"+arrLine[8]+"</ipdef><ipmac>"+arrLine[9]+"</ipmac></ip>";
			}
		}		
	}
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
  	res.setCharacterEncoding("UTF-8");
		this.errLog = "";
  	this.erreur = false;
  	this.ignored = 0;
  	this.treated = 0;
  	this.cptctx = 0;
  	this.cptsite = 0;
  	this.cptsub = 0;
  	this.cptvlan = 0;
  	this.cptip = 0;
		this.xmlResult = "";
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
    try {
			UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
			if (validUser != null) { this.lang = validUser.getLang(); } else { this.lang="en"; }
			Locale locale = new Locale(lang);
	 		this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
   		if (isMultipart) {
				DiskFileItemFactory factory = new DiskFileItemFactory();
				ServletFileUpload upload = new ServletFileUpload(factory);
				upload.setHeaderEncoding("UTF-8");
				upload.setSizeMax(this.maxFileSize);
				List items = upload.parseRequest(req);
				Iterator iter = items.iterator();
				while (iter.hasNext()) {
					FileItem item = (FileItem) iter.next();
					if (!item.isFormField()) {
						if (item.getContentType().startsWith("text/")) {
							InputStream is = item.getInputStream();
							Scanner sc = new Scanner(is,"UTF-8").useDelimiter("$");
							try {
								while(!erreur && sc.hasNextLine()) {
									String myline = sc.nextLine();
									this.treated++;
									if (!myline.isEmpty() && myline.substring(0,1).matches("[A-Z]")) {
										if (myline.split(",")[0].equals("CTX")) { this.cptctx++;parseCTX(myline); }
										else if (myline.split(",")[0].equals("SITE")) { this.cptsite++;parseSITE(myline); }
										else if (myline.split(",")[0].equals("SUBNET")) { this.cptsub++;parseSUBNET(myline); }
										else if (myline.split(",")[0].equals("VLAN")) { this.cptvlan++;parseVLAN(myline); }
										else if (myline.split(",")[0].equals("IP")) { this.cptip++;parseIP(myline); }
										else { printLog(prop.getString("csv.error")+myline+" : "+prop.getString("csv.unknown")); }
									} else { this.ignored++; }
								}
							} catch (Exception e) { mylog.error("Err Line: ",e); }
						} else { printLog("MIME type: " + item.getContentType()); }
					}
				}
			} else { printLog(prop.getString("common.error")+" : "+prop.getString("up.multipart")); }
		} catch (Exception e) { mylog.error("Err Env: ",e); }
		if (this.cptctx>this.ctxmax) { printLog("CTX: "+Integer.toString(this.cptctx)+": "+prop.getString("csv.max")+": "+Integer.toString(this.ctxmax)); }
		if (this.cptsite>this.sitemax) { printLog("SITE: "+Integer.toString(this.cptsite)+": "+prop.getString("csv.max")+": "+Integer.toString(this.sitemax)); }
		if (this.cptsub>this.submax) { printLog("SUBNET: "+Integer.toString(this.cptsub)+": "+prop.getString("csv.max")+": "+Integer.toString(this.submax)); }
		if (this.cptvlan>this.vlanmax) { printLog("VLAN: "+Integer.toString(this.cptvlan)+": "+prop.getString("csv.max")+": "+Integer.toString(this.vlanmax)); }
		if (this.cptip>this.ipmax) { printLog("IP: "+Integer.toString(this.cptip)+": "+prop.getString("csv.max")+": "+Integer.toString(this.ipmax)); }
		res.setContentType("text/xml; charset=UTF-8");
		PrintWriter out = res.getWriter();
		out.print("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			errLog = errLog.replaceAll("&","&amp;");
     	errLog = errLog.replaceAll("<","&lt;");
 	   	errLog = errLog.replaceAll(">","&gt;");
   	 	errLog = errLog.replaceAll("\"","&quot;");
   		errLog = errLog.replaceAll("'","&apos;");
			out.println("<err>true</err><msg>" + errLog + "</msg></reponse>");
		} else {
			out.println("<err>false</err><msg>"+prop.getString("csv.analysis")+" : "+Integer.toString(this.treated)+". "+prop.getString("csv.ignored")+" : "+Integer.toString(this.ignored)+".&lt;br /&gt;");
			out.println(Integer.toString(this.cptctx)+" CTX, "+Integer.toString(this.cptsite)+" SITE, "+Integer.toString(this.cptsub)+" SUBNET, "+Integer.toString(this.cptvlan)+" VLAN, "+Integer.toString(this.cptip)+" IP</msg>");
			out.println(this.xmlResult + "</reponse>");
		}
		out.flush();
   	out.close();
  }
}
