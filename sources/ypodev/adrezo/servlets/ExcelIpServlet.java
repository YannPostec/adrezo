package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.sql.*;
import javax.servlet.*;
import javax.servlet.http.*;
import javax.naming.*;
import org.apache.logging.log4j.*;
import ypodev.adrezo.util.IPFmt;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

public class ExcelIpServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String rctx = "";
	private String rtype = "";
	private String rsearch = "";
	private Logger mylog = LogManager.getLogger(ExcelIpServlet.class);
	private transient ResourceBundle prop;
	private String lang;

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + " | ";
	}
	
  public void doGet(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		this.rctx = req.getParameter("ctx");
		this.rtype = req.getParameter("type");
		this.rsearch = req.getParameter("search");
		SXSSFWorkbook wb = new SXSSFWorkbook(100);
		wb.setCompressTempFiles(true);
		if (!this.rtype.equals("")) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet result = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				String db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				result = stmt.executeQuery("select lang from usercookie where login = 'admin'");
				if (result.next()) {this.lang = result.getString("lang");} else {this.lang="en";}
				Locale locale = new Locale(lang);
				this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.lang",locale);
				result.close();result = null;
				Sheet sh = wb.createSheet("IP");
				int rownum=0;
				Row row = sh.createRow(rownum);
				row.createCell(0).setCellValue(prop.getString("admin.ctx"));
				row.createCell(1).setCellValue(prop.getString("common.table.type"));
				row.createCell(2).setCellValue(prop.getString("admin.site"));
				row.createCell(3).setCellValue(prop.getString("common.table.name"));
				row.createCell(4).setCellValue(prop.getString("common.table.def"));
				row.createCell(5).setCellValue(prop.getString("common.table.ip"));
				row.createCell(6).setCellValue(prop.getString("admin.subnet"));
				row.createCell(7).setCellValue(prop.getString("common.table.mac"));
				row.createCell(8).setCellValue(prop.getString("common.table.lastmodif"));
				row.createCell(9).setCellValue(prop.getString("common.table.temp"));
				row.createCell(10).setCellValue(prop.getString("common.table.mig"));
				row.createCell(11).setCellValue(prop.getString("common.table.ipfutur"));
				Font font= wb.createFont();
				font.setBold(true);
				CellStyle style= wb.createCellStyle();
				style.setAlignment(HorizontalAlignment.CENTER);
    		style.setFont(font);
    		for (Cell mycell : row) { mycell.setCellStyle(style); }
				String myquery = "select ctx_name,date_mig,date_modif,date_temp,def,ip,ip_mig,mac,mask,mask_mig,mig,name,site_mig_name,site_name,subnet_mig_name,subnet_name,temp,type,usr_mig,usr_modif,usr_temp from adresses_display";
				if (this.rtype.equals("ctx") || this.rtype.equals("search")) { myquery += " where ctx = "+this.rctx; }
				if (this.rtype.equals("search") && !this.rsearch.equals("")) { myquery += " and "+this.rsearch; }
				myquery += " order by ip";
				result = stmt.executeQuery(myquery);
				while (result.next()) {
					rownum++;
					Row myrow = sh.createRow(rownum);
					myrow.createCell(0).setCellValue(result.getString("ctx_name"));
					myrow.createCell(1).setCellValue(result.getString("type"));
					myrow.createCell(2).setCellValue(result.getString("site_name"));
					myrow.createCell(3).setCellValue(result.getString("name"));
					myrow.createCell(4).setCellValue(result.getString("def"));
					myrow.createCell(5).setCellValue(IPFmt.displayIP(result.getString("ip"))+"/"+String.valueOf(result.getInt("mask")));
					myrow.createCell(6).setCellValue(result.getString("subnet_name"));
					myrow.createCell(7).setCellValue(result.getString("mac"));
					String fmtDateModif = "";
					if (db_type.equals("oracle")) { fmtDateModif = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(result.getDate("date_modif")); }
    			if (db_type.equals("postgresql")) { fmtDateModif = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(result.getTimestamp("date_modif")); }
					myrow.createCell(8).setCellValue(result.getString("usr_modif")+", "+fmtDateModif);
					if (result.getInt("temp")==1) {
						String fmtDateTemp = "";
						if (db_type.equals("oracle")) { fmtDateTemp = new java.text.SimpleDateFormat("dd/MM/yyyy").format(result.getDate("date_temp")); }
    				if (db_type.equals("postgresql")) { fmtDateTemp = new java.text.SimpleDateFormat("dd/MM/yyyy").format(result.getTimestamp("date_temp")); }
						myrow.createCell(9).setCellValue(prop.getString("common.yes") + " (" + result.getString("usr_temp") + ") " + fmtDateTemp);
					} else { myrow.createCell(9).setCellValue(prop.getString("common.no")); }
					if (result.getInt("mig")==1) {
						String fmtDateMig = "";
						if (db_type.equals("oracle")) { fmtDateMig = new java.text.SimpleDateFormat("dd/MM/yyyy").format(result.getDate("date_mig")); }
    				if (db_type.equals("postgresql")) { fmtDateMig = new java.text.SimpleDateFormat("dd/MM/yyyy").format(result.getTimestamp("date_mig")); }
						myrow.createCell(10).setCellValue(prop.getString("common.yes") + " (" + result.getString("usr_mig") + ") " + fmtDateMig);
						myrow.createCell(11).setCellValue(IPFmt.displayIP(result.getString("ip_mig"))+"/"+String.valueOf(result.getInt("mask_mig"))+" ("+result.getString("site_mig_name")+"/"+result.getString("subnet_mig_name")+")");	
					} else {
						myrow.createCell(10).setCellValue(prop.getString("common.no"));
						myrow.createCell(11).setCellValue("N/A");
					}
				}
				result.close();result = null;
				stmt.close();stmt = null;
				conn.close();conn = null;
			} catch (Exception e) { printLog("DB: ",e); }
			finally {    
					if (result != null) { try { result.close(); } catch (SQLException e) { ; } result = null; }
					if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
			}
		}
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			Sheet errsh = wb.createSheet("Error");
			Cell cell = errsh.createRow(0).createCell(0);
			cell.setCellValue(errLog);
		}
		res.setContentType("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet");
		res.setHeader("Content-Disposition", "attachment; filename=adrezo_ip.xlsx");
		wb.write(res.getOutputStream());
		wb.close();
		wb.dispose();
		errLog = "";
		erreur = false;
		rctx = "";
		rtype = "";
		rsearch = "";
  }
}
