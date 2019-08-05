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

public class ExcelStockServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String rtype = "";
	private Logger mylog = Logger.getLogger(ExcelStockServlet.class);
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
		this.rtype = req.getParameter("type");
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
				String sheetname = "";
				if (this.rtype.equals("stock")) { sheetname = "Stock"; }
				if (this.rtype.equals("mvt")) { sheetname = "Mvt"; } 
				Sheet sh = wb.createSheet(sheetname);
				int rownum=0;
				Row row = sh.createRow(rownum);
				if (this.rtype.equals("stock")) {
					row.createCell(0).setCellValue(prop.getString("admin.ctx"));
					row.createCell(1).setCellValue(prop.getString("admin.site"));
					row.createCell(2).setCellValue(prop.getString("common.table.cat"));
					row.createCell(3).setCellValue(prop.getString("common.table.idx"));
					row.createCell(4).setCellValue(prop.getString("common.table.def"));
					row.createCell(5).setCellValue(prop.getString("common.table.stock"));
					row.createCell(6).setCellValue(prop.getString("common.table.threshold"));
					row.createCell(7).setCellValue(prop.getString("common.table.ongoing"));
				}
				if (this.rtype.equals("mvt")) {
					row.createCell(0).setCellValue(prop.getString("admin.ctx"));
					row.createCell(1).setCellValue(prop.getString("admin.site"));
					row.createCell(2).setCellValue(prop.getString("common.table.date"));
					row.createCell(3).setCellValue(prop.getString("common.table.cat"));
					row.createCell(4).setCellValue(prop.getString("common.table.idx"));
					row.createCell(5).setCellValue(prop.getString("common.table.def"));
					row.createCell(6).setCellValue(prop.getString("admin.user"));
					row.createCell(7).setCellValue(prop.getString("common.table.move"));
					row.createCell(8).setCellValue(prop.getString("common.table.inventory"));
					row.createCell(9).setCellValue(prop.getString("common.table.thresholdcross"));
				}
				Font font= wb.createFont();
				font.setBold(true);
				CellStyle style= wb.createCellStyle();
				style.setAlignment(HorizontalAlignment.CENTER);
    		style.setFont(font);
    		for (Cell mycell : row) { mycell.setCellStyle(style); }
				String myquery = "";
				if (this.rtype.equals("stock")) { myquery="select ctx_name,site_name,cat,idx,def,seuil,stock,encours from stock_etat_display order by ctx_name,site_name,idx"; }
				if (this.rtype.equals("mvt")) { myquery="select e.idx, m.stamp, m.usr, m.mvt, m.invent, m.seuil, e.def, e.cat, e.ctx_name, e.site_name from stock_etat_display e, stock_mvt m where m.id = e.id order by m.stamp desc"; }
				result = stmt.executeQuery(myquery);
				while (result.next()) {
					rownum++;
					Row myrow = sh.createRow(rownum);
					CellStyle centerstyle= wb.createCellStyle();
					centerstyle.setAlignment(HorizontalAlignment.CENTER);
					if (this.rtype.equals("stock")) {
						myrow.createCell(0).setCellValue(result.getString("ctx_name"));
						myrow.createCell(1).setCellValue(result.getString("site_name"));
						myrow.createCell(2).setCellValue(result.getString("cat"));
						myrow.createCell(3).setCellValue(result.getString("idx"));
						myrow.createCell(4).setCellValue(result.getString("def"));
						myrow.createCell(5).setCellValue(String.valueOf(result.getInt("stock")));
						myrow.getCell(5).setCellStyle(centerstyle);
						myrow.createCell(6).setCellValue(String.valueOf(result.getInt("seuil")));
						myrow.getCell(6).setCellStyle(centerstyle);
						myrow.createCell(7).setCellValue(String.valueOf(result.getInt("encours")));
						myrow.getCell(7).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("mvt")) {
						myrow.createCell(0).setCellValue(result.getString("ctx_name"));
						myrow.createCell(1).setCellValue(result.getString("site_name"));
						String fmtStamp = "";
						if (db_type.equals("oracle")) { fmtStamp = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(result.getDate("stamp")); }
    				if (db_type.equals("postgresql")) { fmtStamp = new java.text.SimpleDateFormat("dd/MM/yyyy HH:mm:ss").format(result.getTimestamp("stamp")); }
						myrow.createCell(2).setCellValue(fmtStamp);
						myrow.createCell(3).setCellValue(result.getString("cat"));
						myrow.createCell(4).setCellValue(result.getString("idx"));
						myrow.getCell(4).setCellStyle(centerstyle);
						myrow.createCell(5).setCellValue(result.getString("def"));
						myrow.createCell(6).setCellValue(result.getString("usr"));
						myrow.getCell(6).setCellStyle(centerstyle);
						myrow.createCell(7).setCellValue(String.valueOf(result.getInt("mvt")));
						myrow.getCell(7).setCellStyle(centerstyle);
						if (result.getInt("invent")==1) { myrow.createCell(8).setCellValue(prop.getString("common.yes")); }
						else if (result.getInt("invent")==2) { myrow.createCell(8).setCellValue(prop.getString("stock.reception")); }
						else { myrow.createCell(8).setCellValue(""); }
						myrow.getCell(8).setCellStyle(centerstyle);
						if (result.getInt("seuil")==1) { myrow.createCell(9).setCellValue(prop.getString("common.yes")); }
						else { myrow.createCell(9).setCellValue(""); }
						myrow.getCell(9).setCellStyle(centerstyle);
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
		if (this.rtype.equals("stock")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_stock.xlsx"); }
		if (this.rtype.equals("mvt")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_stock_mvt.xlsx"); }
		wb.write(res.getOutputStream());
		wb.close();
		wb.dispose();
		errLog = "";
		erreur = false;
		rtype = "";
  }
}
