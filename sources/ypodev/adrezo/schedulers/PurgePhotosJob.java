package ypodev.adrezo.schedulers;

/*
 * @Author : Yann POSTEC
 */

import org.quartz.*;
import org.apache.logging.log4j.*;
import java.io.*;
import java.util.*; 
import java.sql.*;
import javax.naming.*;
import javax.servlet.*;
import jcifs.*;
import jcifs.smb.*;

public class PurgePhotosJob implements Job {

	private Logger mylog = LogManager.getLogger(PurgePhotosJob.class);
	private Vector<String> urls = new Vector<String>();
	private String dirLog = "";
	private String fileLog = "";
	private ResourceBundle prop;
	private boolean bDelDir = false;
	private boolean bDelFile = false;

	private void printDir(String msg) {
		this.bDelDir = true;
		this.dirLog += msg + ",";
	}
	private void printFile(String msg) {
		this.bDelFile = true;
		this.fileLog += msg + ",";
	}

	@Override
	public void execute(JobExecutionContext context) throws JobExecutionException {
		Connection conn = null;
		Statement stmt = null;
		Statement stmtg = null;
		ResultSet rsl = null;
		ResultSet rsg = null;
		ResultSet rs = null;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			String photo_cifshost = (String) env.lookup("photo_cifshost");
			String photo_dir = (String) env.lookup("photo_dir");
			boolean photo_cifs = ((Boolean) env.lookup("photo_cifs")).booleanValue();
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmtg = conn.createStatement();
			rsl = stmtg.executeQuery("select lang from usercookie where login='admin'");
			if (rsl.next()) {
				Locale locale = new Locale(rsl.getString("lang"));
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			} else {
				Locale locale = new Locale("en");
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale); 
			}
			rsl.close();rsl=null;
			rsg = stmtg.executeQuery("select enabled from schedulers where id=3");
			if (rsg.next()) {
				if (rsg.getInt("enabled")>0) {
					mylog.debug("Job 3 enabled");
					stmt = conn.createStatement();
					if (photo_cifs) {
						SmbFile uploadDir = new SmbFile("smb://" + photo_cifshost);
						SmbFile[] lstDir = uploadDir.listFiles();
						for(int i=0;i<lstDir.length;i++) {
							if (lstDir[i].isDirectory()) {
								urls.clear();
								String path = lstDir[i].getName().replace("/","");
								rs = stmt.executeQuery("select id,suf from photo where dir=" + path);
								while (rs.next()) { urls.add(String.valueOf(rs.getInt("id")) + '.' + rs.getString("suf").toLowerCase()); }
								SmbFile delDir = new SmbFile(uploadDir,lstDir[i].getName());
								SmbFile[] lstDelDirFiles = delDir.listFiles();
								if (urls.size() == 0) {
									printDir(lstDir[i].getName());
									for(int j=0;j<lstDelDirFiles.length;j++) {
										printFile(lstDir[i].getName() + lstDelDirFiles[j].getName());
										try { lstDelDirFiles[j].delete(); } catch (SmbException e) { mylog.error(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()+". "+e.getMessage()); }
									}
									try { lstDir[i].delete(); } catch (SmbException e) { mylog.error(prop.getString("purge.err.dir")+" "+lstDir[i].getName()+". "+e.getMessage()); }
								} else {
									for(int j=0;j<lstDelDirFiles.length;j++) {
										if (lstDelDirFiles[j].isFile()) {
											String imgname = lstDelDirFiles[j].getName().toLowerCase().replaceFirst("th_","");
											if (!urls.contains(imgname)) {
												printFile(lstDir[i].getName() + lstDelDirFiles[j].getName());
												try { lstDelDirFiles[j].delete(); } catch (SmbException e) { mylog.error(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()+". "+e.getMessage()); }
											}
										}
									}
								}
								rs.close();rs=null;
							}
						}
					} else {
						Scheduler scheduler = context.getScheduler();
						SchedulerContext schedulerContext = scheduler.getContext();
						ServletContext servletContext = (ServletContext)schedulerContext.get("servletContext");
						File uploadDir = new File(servletContext.getRealPath(photo_dir));
						File[] lstDir = uploadDir.listFiles();
						for(int i=0;i<lstDir.length;i++) {
							if (lstDir[i].isDirectory()) {
								urls.clear();
								rs = stmt.executeQuery("select id,suf from photo where dir=" + lstDir[i].getName());
								while (rs.next()) { urls.add(String.valueOf((int)rs.getInt("ID")) + '.' + rs.getString("SUF").toLowerCase()); }
								File delDir = new File(servletContext.getRealPath(photo_dir + lstDir[i].getName()));
								File[] lstDelDirFiles = delDir.listFiles();
								if (urls.size() == 0) {
									printDir(lstDir[i].getName());
									for(int j=0;j<lstDelDirFiles.length;j++) {
										printFile(lstDir[i].getName() + '/' + lstDelDirFiles[j].getName());
										if (!lstDelDirFiles[j].delete()) { mylog.error(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()); }
									}
									if (!lstDir[i].delete()) { mylog.error(prop.getString("purge.err.dir")+" "+lstDir[i].getName()); }
								} else {
									for(int j=0;j<lstDelDirFiles.length;j++) {
										if (lstDelDirFiles[j].isFile()) {
											String imgname = lstDelDirFiles[j].getName().toLowerCase().replaceFirst("th_","");
											if (!urls.contains(imgname)) {
												printFile(lstDir[i].getName() + '/' + lstDelDirFiles[j].getName());
												if (!lstDelDirFiles[j].delete()) { mylog.error(prop.getString("purge.err.file")+" "+lstDir[i].getName()+'/'+lstDelDirFiles[j].getName()); }
											}
										}
									}
								}
								rs.close();rs=null;
							}
						}
					}
					stmt.close();stmt=null;
					if (!bDelDir) { mylog.info(prop.getString("purge.nodir")); }
					else { mylog.info(prop.getString("purge.dir")+" = "+this.dirLog); }
					if (!bDelFile) { mylog.info(prop.getString("purge.nofile")); }
					else { mylog.info(prop.getString("purge.file")+" = "+this.fileLog); }
				} else mylog.debug("Job 3 disabled");
			}
			rsg.close();rsg=null;
			stmtg.close();stmtg=null;
			conn.close();conn=null;
		} catch (Exception e) { mylog.error("PurgePhotos/DB: "+e.getMessage()); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
			if (rsg != null) { try { rsg.close(); } catch (SQLException e) { ; } rsg = null; }
			if (rsl != null) { try { rsl.close(); } catch (SQLException e) { ; } rsl = null; }
			if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			if (stmtg != null) { try { stmtg.close(); } catch (SQLException e) { ; } stmtg = null; }
			if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}				
	}
}
