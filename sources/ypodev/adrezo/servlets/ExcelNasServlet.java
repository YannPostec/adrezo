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
import org.apache.log4j.Logger;
import ypodev.adrezo.util.IPFmt;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

public class ExcelNasServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(ExcelNasServlet.class);
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
		SXSSFWorkbook wb = new SXSSFWorkbook(100);
		wb.setCompressTempFiles(true);
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
			Sheet sh = wb.createSheet("NAS");
			int rownum=0;
			Row row = sh.createRow(rownum);
			row.createCell(0).setCellValue(prop.getString("common.table.date"));
			row.createCell(1).setCellValue(prop.getString("common.table.client"));
			row.createCell(2).setCellValue(prop.getString("admin.site"));
			row.createCell(3).setCellValue(prop.getString("common.table.device"));
			row.createCell(4).setCellValue(prop.getString("common.table.dispo"));
			Font font= wb.createFont();
			font.setBold(true);
			CellStyle style= wb.createCellStyle();
			style.setAlignment(HorizontalAlignment.CENTER);
   		style.setFont(font);
   		for (Cell mycell : row) { mycell.setCellStyle(style); }
			result = stmt.executeQuery("select device_name,client_name,site_name,stamp,availability from slastats_display order by stamp,client_name,site_name,device_name");
			while (result.next()) {
				rownum++;
				Row myrow = sh.createRow(rownum);
				myrow.createCell(0).setCellValue(result.getString("stamp"));
				myrow.createCell(1).setCellValue(result.getString("client_name"));
				myrow.createCell(2).setCellValue(result.getString("site_name"));
				myrow.createCell(3).setCellValue(result.getString("device_name"));
				myrow.createCell(4).setCellValue(String.valueOf(result.getDouble("availability")));
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
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			Sheet errsh = wb.createSheet("Error");
			Cell cell = errsh.createRow(0).createCell(0);
			cell.setCellValue(errLog);
		}
		res.setContentType("application/vnd.ms-excel");
		res.setHeader("Content-Disposition", "attachment; filename=adrezo_nas.xlsx");
		wb.write(res.getOutputStream());
		wb.close();
		wb.dispose();
		errLog = "";
		erreur = false;
  }
}
