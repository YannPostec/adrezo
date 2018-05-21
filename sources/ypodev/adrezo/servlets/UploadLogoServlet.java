package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.nio.channels.FileChannel;
import java.util.*; 
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.beans.UserInfoBean;

public class UploadLogoServlet extends HttpServlet {
	//Properties
	private String errLog;
	private boolean erreur;
	private String lang;
	private ResourceBundle prop;
	private String type;
	private Logger mylog = Logger.getLogger(UploadLogoServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private static void copyFileUsingFileChannels(File source, File dest) throws IOException {
		FileChannel inputChannel = null;
		FileChannel outputChannel = null;
		try {
			inputChannel = new FileInputStream(source).getChannel();
			outputChannel = new FileOutputStream(dest).getChannel();
			outputChannel.transferFrom(inputChannel, 0, inputChannel.size());
		} finally {
			inputChannel.close();
			outputChannel.close();
		}
	}
	private void copyDefault() {
		File imgdir = new File(this.getServletContext().getRealPath("/img/"));
		File logoFile = new File(imgdir,"login_company.png");
		File defaultFile = new File(imgdir,"login_company_default.png");
		try {
			copyFileUsingFileChannels(defaultFile,logoFile);
		} catch (IOException e) { printLog("Err Copy: ",e); }
	}
	private void processFormField(FileItem item) {
		try {
			String name = item.getFieldName();
			String value = item.getString("UTF-8");
			if (name.equals("type")) { this.type = value; }
		} catch (IOException e) { printLog("Err FormField: ",e); }
	}	
	private void processUploadedFile(FileItem item) {
		try {
			String fn = item.getName();
			String photosuf = fn.substring(fn.lastIndexOf('.')+1,fn.length()).toLowerCase();
			if (!photosuf.equals("png")) { printLog(prop.getString("common.error")+" : "+prop.getString("up.filetype"),null); }
			else {
				File imgdir = new File(this.getServletContext().getRealPath("/img/"));
				File uploadedFile = new File(imgdir,"login_company.png");
				item.write(uploadedFile);
			}
		} catch (Exception e) { printLog("Err UpFile: ",e); }
	}
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
  	res.setCharacterEncoding("UTF-8");
		errLog = "";
  	erreur = false;
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
    try {
			UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
			if (validUser != null) { this.lang = validUser.getLang(); } else { this.lang="en"; }
			Locale locale = new Locale(lang);
	 		this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
    	try {
    		if (isMultipart) {
					DiskFileItemFactory factory = new DiskFileItemFactory();
					ServletFileUpload upload = new ServletFileUpload(factory);
					upload.setHeaderEncoding("UTF-8");
					List items = upload.parseRequest(req);
					Iterator iter = items.iterator();
					while (iter.hasNext()) {
						FileItem item = (FileItem) iter.next();
						if (item.isFormField()) {	processFormField(item); }
						else { processUploadedFile(item); }
					}
					if (type.equals("back")) { copyDefault(); }
				} else { printLog(prop.getString("common.error")+" : "+prop.getString("up.multipart"),null); }
			} catch (Exception e) { printLog("Err Main: ",e); }
		} catch (Exception e) { printLog("Err Env: ",e); }
		res.setContentType("text/xml; charset=UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
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
			out.println("<err>false</err><msg>OK</msg></reponse>");
		}
		out.flush();
    out.close();
  }
}
