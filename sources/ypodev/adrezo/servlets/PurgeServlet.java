package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import java.util.*; 
import javax.servlet.*;
import javax.servlet.http.*;
import java.sql.*;
import javax.naming.*;
import jcifs.*;
import jcifs.smb.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.beans.UserInfoBean;

public class PurgeServlet extends HttpServlet {
	//Properties
	private Vector urls = new Vector();
	private String errLog;
	private boolean erreur = false;
	private String dirLog;
	private String fileLog;
	private String lang;
	private ResourceBundle prop;
	private boolean bDelDir = false;
	private boolean bDelFile = false;
	private Logger mylog = Logger.getLogger(PurgeServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private void printDir(String msg) {
		this.bDelDir = true;
		this.dirLog += msg + ",";
	}
	private void printFile(String msg) {
		this.bDelFile = true;
		this.fileLog += msg + ",";
	}

  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
    errLog = "";
    dirLog = "";
    fileLog = "";
    lang = "";
    erreur = false;
		urls.clear();
    res.setContentType("text/xml; charset=UTF-8");
    PrintWriter out = res.getWriter();
    out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
		if (validUser != null) {
			out.println("<valid>true</valid>");
			try {
				this.lang = validUser.getLang();
				Locale locale = new Locale(this.lang);
 				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
 			} catch (Exception e) { printLog("Err Lang: ",e); }
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				String photo_cifshost = (String) env.lookup("photo_cifshost");
				String photo_dir = (String) env.lookup("photo_dir");
				boolean photo_cifs = ((Boolean) env.lookup("photo_cifs")).booleanValue();
	    	Connection conn = null;
  	  	Statement stmt = null;
				ResultSet rs = null;
	    	try {
		   		javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
					conn = ds.getConnection();
					stmt = conn.createStatement();
			
					if (photo_cifs) {
						SmbFile uploadDir = new SmbFile("smb://" + photo_cifshost);
						SmbFile[] lstDir = uploadDir.listFiles();
						for(int i=0;i<lstDir.length;i++) {
							if (lstDir[i].isDirectory()) {
								urls.clear();
								String path = lstDir[i].getName().replace("/","");
								stmt.execute("select id,suf from photo where dir=" + path);
								rs = stmt.getResultSet();
								while (rs.next()) { urls.add(String.valueOf((int)rs.getInt("ID")) + '.' + rs.getString("SUF").toLowerCase()); }
								SmbFile delDir = new SmbFile(uploadDir,lstDir[i].getName());
								SmbFile[] lstDelDirFiles = delDir.listFiles();
								if (urls.size() == 0) {
									printDir(lstDir[i].getName());
									for(int j=0;j<lstDelDirFiles.length;j++) {
										printFile(lstDir[i].getName() + lstDelDirFiles[j].getName());
										try { lstDelDirFiles[j].delete(); } catch (SmbException e) { printLog(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()+". "+e.getMessage(),e); }
									}
									try { lstDir[i].delete(); } catch (SmbException e) { printLog(prop.getString("purge.err.dir")+" "+lstDir[i].getName()+". "+e.getMessage(),e); }
								} else {
									for(int j=0;j<lstDelDirFiles.length;j++) {
										if (lstDelDirFiles[j].isFile()) {
											String imgname = lstDelDirFiles[j].getName().toLowerCase().replaceFirst("th_","");
											if (!urls.contains(imgname)) {
												printFile(lstDir[i].getName() + lstDelDirFiles[j].getName());
												try { lstDelDirFiles[j].delete(); } catch (SmbException e) { printLog(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()+". "+e.getMessage(),e); }
											}
										}
									}
								}
							}
						}
					} else {
						File uploadDir = new File(this.getServletContext().getRealPath(photo_dir));
						File[] lstDir = uploadDir.listFiles();
						for(int i=0;i<lstDir.length;i++) {
							if (lstDir[i].isDirectory()) {
								urls.clear();
								stmt.execute("select id,suf from photo where dir=" + lstDir[i].getName());
								rs = stmt.getResultSet();
								while (rs.next()) { urls.add(String.valueOf((int)rs.getInt("ID")) + '.' + rs.getString("SUF").toLowerCase()); }
								File delDir = new File(this.getServletContext().getRealPath(photo_dir + lstDir[i].getName()));
								File[] lstDelDirFiles = delDir.listFiles();
								if (urls.size() == 0) {
									printDir(lstDir[i].getName());
									for(int j=0;j<lstDelDirFiles.length;j++) {
										printFile(lstDir[i].getName() + '/' + lstDelDirFiles[j].getName());
										if (!lstDelDirFiles[j].delete()) { printLog(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName(),null); }
									}
									if (!lstDir[i].delete()) { printLog(prop.getString("purge.err.dir")+" "+lstDir[i].getName(),null); }
								} else {
									for(int j=0;j<lstDelDirFiles.length;j++) {
										if (lstDelDirFiles[j].isFile()) {
											String imgname = lstDelDirFiles[j].getName().toLowerCase().replaceFirst("th_","");
											if (!urls.contains(imgname)) {
												printFile(lstDir[i].getName() + '/' + lstDelDirFiles[j].getName());
												if (!lstDelDirFiles[j].delete()) { printLog(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName(),null); }
											}
										}
									}
								}
							}
						}
					}
					rs.close();rs = null;
					stmt.close();stmt = null;
					conn.close();conn = null;
				} catch (Exception e) { printLog("Err Main: ",e); }
				finally {    
					if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
					if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
				}
			} catch (Exception e) { printLog("Err Env: ",e); }
			if (erreur) {
				errLog = errLog.replaceAll("\\s+"," ");
				errLog = errLog.replaceAll("\r","");
				errLog = errLog.replaceAll("\n","");
				errLog = errLog.replaceAll("&","&amp;");
	    	errLog = errLog.replaceAll("<","&lt;");
	  	  errLog = errLog.replaceAll(">","&gt;");
  	  	errLog = errLog.replaceAll("\"","&quot;");
    	 	errLog = errLog.replaceAll("'","&apos;");
				out.println("<erreur>true</erreur><msg>" + errLog + "</msg></reponse>");
			} else {
				out.println("<erreur>false</erreur><msg>");
				if (!bDelDir) { out.println("&lt;h2&gt;"+prop.getString("purge.nodir")+"&lt;/h2&gt;"); }
				else { out.println("&lt;h2&gt;"+prop.getString("purge.dir")+" :&lt;/h2&gt;"+this.dirLog); }
				if (!bDelFile) { out.println("&lt;h2&gt;"+prop.getString("purge.nofile")+"&lt;/h2&gt;"); }
				else { out.println("&lt;h2&gt;"+prop.getString("purge.file")+" :&lt;/h2&gt;"+this.fileLog); }
				out.println("</msg></reponse>");
			}
		} else {
			out.println("<valid>false</valid></reponse>");
		}
		out.flush();
    out.close();
  }
}
