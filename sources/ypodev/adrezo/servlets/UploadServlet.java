package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*; 
import javax.servlet.*;
import javax.servlet.http.*;
import org.apache.commons.fileupload.*;
import org.apache.commons.fileupload.disk.*;
import org.apache.commons.fileupload.servlet.*;
import jcifs.smb.*;
import java.sql.*;
import javax.naming.*;
import static org.imgscalr.Scalr.*;
import java.awt.image.BufferedImage;
import javax.imageio.ImageIO;
import org.apache.logging.log4j.*;
import ypodev.adrezo.beans.UserInfoBean;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;

public class UploadServlet extends HttpServlet {
	//Properties
	private String idparent;
	private String type;
	private String name;
	private String errLog;
	private boolean erreur;
	private Connection conn = null;
	private String photoid;
	private String photodir;
	private String photosuf;
	private String photo_cifshost;
	private String photo_dir;
	private boolean photo_cifs;
	private String lang;
	private ResourceBundle prop;
	private Logger mylog = LogManager.getLogger(UploadServlet.class);
	private String db_type;

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private void processFormField(FileItem item) {
		try {
			String name = item.getFieldName();
			String value = item.getString("UTF-8");
			if (name.equals("idparent")) { this.idparent = value; }
			if (name.equals("type")) { this.type = value; }
			if (name.equals("name")) {
				value = value.replaceAll("'","''");
				this.name = value;
			}
		} catch (IOException e) { printLog("Err FormField: ",e); }
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
			if (!photoid.equals("-1")) {
				String fn = item.getName();
				photosuf = fn.substring(fn.lastIndexOf('.')+1,fn.length()).toLowerCase();
				if (photosuf.equals("jpeg")) { photosuf = "jpg"; }
				int ddir = (int)Math.ceil((int)Integer.parseInt(photoid)/100.0);
				photodir = Integer.toString(ddir);
			
				if (photo_cifs) {
					File updir = new File(this.getServletContext().getRealPath(photo_dir));
					SmbFile dirSmb = new SmbFile("smb://" + photo_cifshost + photodir + "/");
					if (!dirSmb.exists()) { dirSmb.mkdirs(); }
					File uploadedFile = new File(updir,photoid + "." + photosuf);
					SmbFile fSmb = new SmbFile(dirSmb,photoid + "." + photosuf);
					item.write(uploadedFile);
					byte uploadedFileContent[] = new byte[(int)uploadedFile.length()];
					FileInputStream uploadedFileIn = new FileInputStream(uploadedFile);
					uploadedFileIn.read(uploadedFileContent);
					new SmbFileOutputStream(fSmb).write(uploadedFileContent);
					if (photosuf.equals("jpg")||photosuf.equals("png")) {
						File thumbFile = new File(updir,"th_" + photoid + "." + photosuf);
						createThumb(uploadedFile,thumbFile,100,photosuf);
						SmbFile thSmb = new SmbFile(dirSmb,"th_" + photoid + "." + photosuf);
						byte thumbFileContent[] = new byte[(int)thumbFile.length()];
						FileInputStream thumbFileIn = new FileInputStream(thumbFile);
						thumbFileIn.read(thumbFileContent);
						new SmbFileOutputStream(thSmb).write(thumbFileContent);
						thumbFile.delete();
					}
					uploadedFile.delete();
				} else {
					File updir = new File(this.getServletContext().getRealPath(photo_dir + photodir + "/"));
					if (!updir.exists()) { updir.mkdirs(); }
					File uploadedFile = new File(updir,photoid + "." + photosuf);
					item.write(uploadedFile);
					if (photosuf.equals("jpg")||photosuf.equals("png")) {
						File thumbFile = new File(updir,"th_" + photoid + "." + photosuf);
						createThumb(uploadedFile,thumbFile,100,photosuf);
					}
				}
			}
		}
		catch (Exception e) { printLog("Err UpFile: ",e); }
	}
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
  	res.setCharacterEncoding("UTF-8");
		errLog = "";
  	erreur = false;
  	photoid = "-1";
		conn = null;
		boolean isMultipart = ServletFileUpload.isMultipartContent(req);
    try {
			UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
			if (validUser != null) { this.lang = validUser.getLang(); } else { this.lang="en"; }
			Locale locale = new Locale(lang);
	 		this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			db_type = (String) env.lookup("db_type");
			photo_cifshost = (String) env.lookup("photo_cifshost");
			photo_dir = (String) env.lookup("photo_dir");
			photo_cifs = ((Boolean) env.lookup("photo_cifs")).booleanValue();
			Statement stmtUpdate = null;
			ResultSet rsv = null;
    	try {
    		if (isMultipart) {
					javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
					conn = ds.getConnection();
					stmtUpdate = conn.createStatement();
					stmtUpdate.executeUpdate("insert into photo (id,idparent) values (" + DbSeqNextval.dbSeqNextval("photo_seq") + ",-1)");
					String myquery = "select "+DbSeqCurrval.dbSeqCurrval("photo_seq")+" as seq";
					if (db_type.equals("oracle")) { myquery += " from dual"; }
					rsv = stmtUpdate.executeQuery(myquery);
					if (rsv.next()) { photoid = String.valueOf(rsv.getInt("seq")); }
					else { printLog("Unable to acquire Photo ID",null); }
					rsv.close();rsv=null;
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
					if (!erreur) {
						stmtUpdate.executeUpdate("update photo set idparent="+idparent+",type="+type+",name='"+name+"',dir="+photodir+",suf='"+photosuf+"' where id=" + photoid);
					} else {
						stmtUpdate.executeUpdate("delete from photo where id="+photoid);
					}
					stmtUpdate.close();stmtUpdate=null;
					conn.close();conn = null;			
				} else { printLog(prop.getString("common.error")+" : "+prop.getString("up.multipart"),null); }
			} catch (Exception e) { printLog("Err Main: ",e); }
			finally {
				if (stmtUpdate != null) { try { stmtUpdate.close(); } catch (SQLException e) { ; } stmtUpdate = null; }
		  	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
			}
		} catch (Exception e) { printLog("Err Env: ",e); }
		res.setContentType("text/xml; charset=UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			try{
				UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
				String login = null;
				if (validUser == null) { login = "nologin"; } else { login = validUser.getLogin(); }
				String pms = login + " in " + req.getRequestURI() + ". Params: idparent: " + idparent + ", Type: " + type + ", Nom: " + name + ", PhotoDir: " + photodir + ", PhotoSuf: " + photosuf + ", PhotoId: " + photoid;
				mylog.info(pms);
				mylog.warn("Err PhotoUpload: " + errLog);
			} catch (Exception e) {	printLog("Err PhotoLog: ",e); }
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
