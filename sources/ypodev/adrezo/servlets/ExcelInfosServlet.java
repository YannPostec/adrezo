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
import ypodev.adrezo.util.DbCast;
import org.apache.poi.ss.usermodel.Cell;
import org.apache.poi.ss.usermodel.Row;
import org.apache.poi.ss.usermodel.Sheet;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.CellStyle;
import org.apache.poi.ss.usermodel.Font;
import org.apache.poi.ss.usermodel.HorizontalAlignment;
import org.apache.poi.xssf.streaming.SXSSFWorkbook;

public class ExcelInfosServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String rtype = "";
	private Logger mylog = Logger.getLogger(ExcelInfosServlet.class);
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
				if (this.rtype.equals("site")) { sheetname = "Site"; }
				if (this.rtype.equals("subnet")) { sheetname = "Subnet"; }
				if (this.rtype.equals("vlan")) { sheetname = "Vlan"; }
				if (this.rtype.equals("red")) { sheetname = "Redundancy"; }
				if (this.rtype.equals("fill")) { sheetname = "FillSubnet"; }
				Sheet sh = wb.createSheet(sheetname);
				int rownum=0;
				Row row = sh.createRow(rownum);
				if (this.rtype.equals("site")) {
					row.createCell(0).setCellValue("ID");
					row.createCell(1).setCellValue(prop.getString("admin.ctx"));
					row.createCell(2).setCellValue(prop.getString("common.table.codesite"));
					row.createCell(3).setCellValue(prop.getString("common.table.name"));
				}
				if (this.rtype.equals("subnet")) {
					row.createCell(0).setCellValue("ID");
					row.createCell(1).setCellValue(prop.getString("admin.ctx"));
					row.createCell(2).setCellValue(prop.getString("common.table.codesite"));
					row.createCell(3).setCellValue(prop.getString("admin.site"));
					row.createCell(4).setCellValue(prop.getString("admin.subnet"));
					row.createCell(5).setCellValue(prop.getString("common.table.name"));
					row.createCell(6).setCellValue(prop.getString("common.table.ipgw"));
					row.createCell(7).setCellValue(prop.getString("admin.vlan"));
					row.createCell(8).setCellValue(prop.getString("norm.surnet"));
				}
				if (this.rtype.equals("vlan")) {
					row.createCell(0).setCellValue("ID");
					row.createCell(1).setCellValue(prop.getString("admin.ctx"));
					row.createCell(2).setCellValue(prop.getString("common.table.codesite"));
					row.createCell(3).setCellValue(prop.getString("admin.site"));
					row.createCell(4).setCellValue(prop.getString("common.table.vid"));
					row.createCell(5).setCellValue(prop.getString("common.table.name"));
				}
				if (this.rtype.equals("red")) {
					row.createCell(0).setCellValue(prop.getString("admin.ctx"));
					row.createCell(1).setCellValue(prop.getString("admin.site"));
					row.createCell(2).setCellValue(prop.getString("admin.subnet"));
					row.createCell(3).setCellValue(prop.getString("common.table.proto"));
					row.createCell(4).setCellValue("ID");
					row.createCell(5).setCellValue(prop.getString("common.table.ipshort"));
					row.createCell(6).setCellValue(prop.getString("common.table.device"));
				}
				if (this.rtype.equals("fill")) {
					row.createCell(0).setCellValue(prop.getString("admin.ctx"));
					row.createCell(1).setCellValue(prop.getString("common.table.codesite"));
					row.createCell(2).setCellValue(prop.getString("admin.site"));
					row.createCell(3).setCellValue(prop.getString("admin.subnet"));
					row.createCell(4).setCellValue(prop.getString("common.table.ipmask"));
					row.createCell(5).setCellValue(prop.getString("common.table.used"));
					row.createCell(6).setCellValue(prop.getString("common.table.max"));
					row.createCell(7).setCellValue(prop.getString("common.table.percent"));
				}
				Font font= wb.createFont();
				font.setBold(true);
				CellStyle style= wb.createCellStyle();
				style.setAlignment(HorizontalAlignment.CENTER);
    		style.setFont(font);
    		for (Cell mycell : row) { mycell.setCellStyle(style); }
				String myquery = "";
				if (this.rtype.equals("site")) { myquery="select id,ctx_name,cod_site,name from sites_display"; }
				if (this.rtype.equals("subnet")) { myquery="select id,ctx_name,cod_site,site_name,ip,mask,def,gw,vid,vdef,surnet,surip,surmask,surdef from subnets_display"; }
				if (this.rtype.equals("vlan")) { myquery="select id,vid,def,site_name,cod_site,ctx_name from vlan_display where vid != 0"; }
				if (this.rtype.equals("red")) { myquery="select ctx_name,site_name,subnet_name,ptype_name,pid,ip,mask,ip_name from redundancy_display"; }
				if (this.rtype.equals("fill")) { myquery="select subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def,count(adresses.ip) as mycount,power(2,32-subnets_display.mask)-2 as mymax,round((count(adresses.ip)*100/(power(2,32-subnets_display.mask)-2))"+DbCast.dbCast("NUMERIC")+",1) as mypercent from subnets_display left outer join adresses on subnets_display.id = adresses.subnet where (adresses.def is null or adresses.def != 'Reservation DHCP') group by subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def"; }
				result = stmt.executeQuery(myquery);
				while (result.next()) {
					rownum++;
					Row myrow = sh.createRow(rownum);
					CellStyle centerstyle= wb.createCellStyle();
					centerstyle.setAlignment(HorizontalAlignment.CENTER);
					if (this.rtype.equals("site")) {
						myrow.createCell(0).setCellValue(String.valueOf(result.getInt("id")));
						myrow.createCell(1).setCellValue(result.getString("ctx_name"));
						myrow.createCell(2).setCellValue(result.getString("cod_site"));
						myrow.createCell(3).setCellValue(result.getString("name"));
						myrow.getCell(0).setCellStyle(centerstyle);
						myrow.getCell(2).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("subnet")) {
						myrow.createCell(0).setCellValue(String.valueOf(result.getInt("id")));
						myrow.createCell(1).setCellValue(result.getString("ctx_name"));
						myrow.createCell(2).setCellValue(result.getString("cod_site"));
						myrow.createCell(3).setCellValue(result.getString("site_name"));
						myrow.createCell(4).setCellValue(IPFmt.displayIP(result.getString("ip"))+"/"+String.valueOf(result.getInt("mask")));
						myrow.createCell(5).setCellValue(result.getString("def"));
						myrow.createCell(6).setCellValue(IPFmt.displayIP(result.getString("gw")));
						myrow.createCell(7).setCellValue(String.valueOf(result.getInt("vid"))+" ("+result.getString("vdef")+")");
						if (result.getInt("surnet")>0) { myrow.createCell(8).setCellValue(result.getString("surdef")+" ("+IPFmt.displayIP(result.getString("surip"))+"/"+String.valueOf(result.getInt("surmask"))); }
						else { myrow.createCell(8).setCellValue(""); }
						myrow.getCell(0).setCellStyle(centerstyle);
						myrow.getCell(2).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("vlan")) {
						myrow.createCell(0).setCellValue(String.valueOf(result.getInt("id")));
						myrow.createCell(1).setCellValue(result.getString("ctx_name"));
						myrow.createCell(2).setCellValue(result.getString("cod_site"));
						myrow.createCell(3).setCellValue(result.getString("site_name"));
						myrow.createCell(4).setCellValue(String.valueOf(result.getInt("vid")));
						myrow.createCell(5).setCellValue(result.getString("def"));
						myrow.getCell(0).setCellStyle(centerstyle);
						myrow.getCell(2).setCellStyle(centerstyle);
						myrow.getCell(4).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("red")) {
						myrow.createCell(0).setCellValue(result.getString("ctx_name"));
						myrow.createCell(1).setCellValue(result.getString("site_name"));
						myrow.createCell(2).setCellValue(result.getString("subnet_name"));
						myrow.createCell(3).setCellValue(result.getString("ptype_name"));
						myrow.createCell(4).setCellValue(String.valueOf(result.getInt("pid")));
						myrow.createCell(5).setCellValue(IPFmt.displayIP(result.getString("ip"))+"/"+String.valueOf(result.getInt("mask")));
						myrow.createCell(6).setCellValue(result.getString("ip_name"));
						myrow.getCell(4).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("fill")) {
						myrow.createCell(0).setCellValue(result.getString("ctx_name"));
						myrow.createCell(1).setCellValue(result.getString("cod_site"));
						myrow.createCell(2).setCellValue(result.getString("site_name"));
						myrow.createCell(3).setCellValue(result.getString("def"));
						myrow.createCell(4).setCellValue(IPFmt.displayIP(result.getString("ip"))+"/"+String.valueOf(result.getInt("mask")));
						myrow.createCell(5).setCellValue(String.valueOf(result.getInt("mycount")));
						myrow.createCell(6).setCellValue(String.valueOf(result.getInt("mymax")));
						myrow.createCell(7).setCellValue(String.valueOf(result.getInt("mypercent")));
						myrow.getCell(5).setCellStyle(centerstyle);
						myrow.getCell(6).setCellStyle(centerstyle);
						myrow.getCell(7).setCellStyle(centerstyle);
					}
					if (this.rtype.equals("mvt")) {
						myrow.createCell(4).setCellValue(result.getString("ctx_name"));
						myrow.getCell(4).setCellStyle(centerstyle);
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
		if (this.rtype.equals("site")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_info_site.xlsx"); }
		if (this.rtype.equals("subnet")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_info_subnet.xlsx"); }
		if (this.rtype.equals("vlan")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_info_vlan.xlsx"); }
		if (this.rtype.equals("red")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_info_redundancy.xlsx"); }
		if (this.rtype.equals("fill")) { res.setHeader("Content-Disposition", "attachment; filename=adrezo_info_fillsubnet.xlsx"); }
		if (this.rtype.equals("")) { res.setHeader("Content-Disposition", "attachment; filename=error.xlsx"); }
		wb.write(res.getOutputStream());
		wb.close();
		wb.dispose();
		errLog = "";
		erreur = false;
		rtype = "";
  }
}
