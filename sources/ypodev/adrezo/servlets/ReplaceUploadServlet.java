package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.text.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import jcifs.smb.*;
import java.sql.*;
import static org.imgscalr.Scalr.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import org.apache.log4j.Logger;
import ypodev.adrezo.beans.UserInfoBean;
import ypodev.adrezo.util.DbFunc;

public class ReplaceUploadServlet extends HttpServlet {
	//Properties
	private String dir;
	private String suf;
	private String id;
	private String errLog;
	private boolean erreur;
	private String photo_cifshost;
	private String photo_dir;
	private boolean photo_cifs;
	private String lang;
	private ResourceBundle prop;
	private Logger mylog = Logger.getLogger(ReplaceUploadServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private void processFormField(FileItem item) {
		String name = item.getFieldName();
		String value = item.getString();
		if (name.equals("dir")) { this.dir = value; }
		if (name.equals("suf")) { this.suf = value; }
		if (name.equals("id")) { this.id = value; }
	}
	private void createThumb(File infile, File outfile, int thumbBounds, String format) {
		try {
			BufferedImage srcimg = ImageIO.read(infile);
			BufferedImage dstimg = resize(srcimg,Method.SPEED,thumbBounds,OP_ANTIALIAS,OP_BRIGHTER);
			ImageIO.write(dstimg,format,outfile);
		}
		catch (Exception e) { printLog("Err Thumb: ",e); }	
	}
	private void processUploadedFile(FileItem item) {
		try {
			String fn = item.getName();
			String suffixe = fn.substring(fn.lastIndexOf('.')+1,fn.length()).toLowerCase();
			if (suffixe.equals("jpeg")) { suffixe = "jpg"; }
			if (!suf.toLowerCase().equals(suffixe.toLowerCase())) { printLog(prop.getString("up.type"),null); }
			else {			
				if (photo_cifs) {
					File updir = new File(this.getServletContext().getRealPath(photo_dir));
					SmbFile dirSmb = new SmbFile("smb://" + photo_cifshost + dir + "/");
					File uploadedFile = new File(updir,id + "." + suf);
					SmbFile fSmb = new SmbFile(dirSmb,id + "." + suf);
					item.write(uploadedFile);
					byte uploadedFileContent[] = new byte[(int)uploadedFile.length()];
					FileInputStream uploadedFileIn = new FileInputStream(uploadedFile);
					uploadedFileIn.read(uploadedFileContent);
					new SmbFileOutputStream(fSmb).write(uploadedFileContent);
					if (suffixe.equals("jpg")||suffixe.equals("png")) {
						File thumbFile = new File(updir,"th_" + id + "." + suf);
						createThumb(uploadedFile,thumbFile,100,suffixe);
						SmbFile thSmb = new SmbFile(dirSmb,"th_" + id + "." + suf);
						byte thumbFileContent[] = new byte[(int)thumbFile.length()];
						FileInputStream thumbFileIn = new FileInputStream(thumbFile);
						thumbFileIn.read(thumbFileContent);
						new SmbFileOutputStream(thSmb).write(thumbFileContent);
						thumbFile.delete();
					}
					uploadedFile.delete();
				} else {
					File uploadedFile = new File(this.getServletContext().getRealPath(photo_dir + dir + "/" + id + "." + suf));
					item.write(uploadedFile);
					if (suffixe.equals("jpg")||suffixe.equals("png")) {
						File thumbFile = new File(this.getServletContext().getRealPath(photo_dir + dir + "/" + "th_" + id + "." + suf));
						createThumb(uploadedFile,thumbFile,100,suffixe);
					}
				}
			}
		} catch (Exception e) { printLog("Err UpFile: ",e); }
	}
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
  	System.setProperty("com.sun.media.jai.disableMediaLib", "true");
		errLog = "";
  	erreur = false;
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
		
		try {
			UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
			if (validUser != null) { this.lang = validUser.getLang(); } else { this.lang="en"; }
			Locale locale = new Locale(lang);
	 		this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			photo_cifshost = (String) env.lookup("photo_cifshost");
			photo_dir = (String) env.lookup("photo_dir");
			photo_cifs = ((Boolean) env.lookup("photo_cifs")).booleanValue();
			try {
  			if (isMultipart) {
					DiskFileItemFactory factory = new DiskFileItemFactory();
					ServletFileUpload upload = new ServletFileUpload(factory);
					List items = upload.parseRequest(req);
					Iterator iter = items.iterator();
					while (iter.hasNext()) {
						FileItem item = (FileItem) iter.next();
						if (item.isFormField()) {	processFormField(item); }
						else { processUploadedFile(item); }
					}
					if (!erreur) {
						Connection conn = null;
						Statement stmtUpdate = null;
						try {
							javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
							conn = ds.getConnection();
							stmtUpdate = conn.createStatement();
							stmtUpdate.executeUpdate("update photo set updt="+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS') where id="+this.id);
							stmtUpdate.close();stmtUpdate=null;
							conn.close();conn = null;
						} catch (Exception e) { printLog("Err Update DB: ",e); }
						finally {
							if (stmtUpdate != null) { try { stmtUpdate.close(); } catch (SQLException e) { ; } stmtUpdate = null; }
		    			if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		    		}
					}
				} else { printLog(prop.getString("common.error")+" : "+prop.getString("up.multipart"),null); }
			} catch (Exception e) { printLog("Err Main: ",e); }
		} catch (Exception e) { printLog("Err Env: ",e); }
		res.setContentType("text/xml; charset=UTF-8");
    res.setCharacterEncoding("UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			try{
				File verifdir = new File(this.getServletContext().getRealPath("/log/"));
				if (!verifdir.exists()) {	verifdir.mkdirs(); }
				PrintWriter pw = new PrintWriter(new FileWriter(this.getServletContext().getRealPath("/log/photo.log"), true));
				UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
				String login = null;
				if (validUser == null) { login = "nologin"; } else { login = validUser.getLogin(); }
				pw.println("\n" + new java.util.Date().toString() + ", " + login + " in " + req.getRequestURI());
				pw.println("Params: Filename = " + dir + "/" + id + "." + suf);
				pw.println("Err: " + errLog);
				pw.close();
				pw = null;
			} catch (IOException e) {	printLog("Err PhotoLog: ",e); }
			errLog = errLog.replaceAll("&","&amp;");
     	errLog = errLog.replaceAll("<","&lt;");
 	   	errLog = errLog.replaceAll(">","&gt;");
   	 	errLog = errLog.replaceAll("\"","&quot;");
   		errLog = errLog.replaceAll("'","&apos;");
			out.println("<err>true</err><msg>" + errLog + "</msg></reponse>");
			out.flush();
    	out.close();
		} else {
			out.println("<err>false</err><msg>OK</msg></reponse>");
			out.flush();
    	out.close();
		}
  }
}
