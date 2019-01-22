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
import ypodev.adrezo.util.DbCast;

public class SQLQueryServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String queryid = "";
	private Integer id = 0;
	private String querylimit = "";
	private String queryoffset = "";
	private String querysearch = "";
	private String queryorder = "";
	private String querysort = "";
	private String result = "";
	private Map<Integer,String> selectlist = new HashMap<Integer,String>();
	private Map<Integer,String> searchlist = new HashMap<Integer,String>();
	private Map<Integer,String> wherelist = new HashMap<Integer,String>();
	private Map<Integer,String> groupbylist = new HashMap<Integer,String>();
	private Logger mylog = Logger.getLogger(SQLQueryServlet.class);
	
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}

	private String shapeXML(String msg) {
		msg = msg.replaceAll("\\s+"," ");
		msg = msg.replaceAll("\r","");
		msg = msg.replaceAll("\n","");
		msg = msg.replaceAll("&","&amp;");
  	msg = msg.replaceAll("<","&lt;");
 	  msg = msg.replaceAll(">","&gt;");
   	msg = msg.replaceAll("\"","&quot;");
   	msg = msg.replaceAll("'","&apos;");
   	return msg;
	}

	public void init() throws ServletException {
		// Initialize Hashmaps
		// ID 1 : Infos Subnets
		this.selectlist.put(1,"select id,ctx_name,cod_site,site_name,ip,mask,def,gw,vid,vdef from subnets_display");
		this.searchlist.put(1,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHSTR#%' or lower(def) like lower('%#SEARCHSTR#%') or gw like '%#SEARCHSTR#%' or lower(vdef) like lower('%#SEARCHSTR#%') or cast(vid as varchar) like '%#SEARCHSTR#%' or cast(mask as varchar) like '%#SEARCHSTR#%'");
		// ID 2 : Infos Sites
		this.selectlist.put(2,"select id,ctx_name,cod_site,name from sites_display");
		this.searchlist.put(2,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(name) like lower ('%#SEARCHSTR#%')");
		// ID 3 : Infos Vlans
		this.selectlist.put(3,"select id,vid,def,site_name,cod_site,ctx_name from vlan_display");
		this.searchlist.put(3,"lower(def) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(ctx_name) like lower('%#SEARCHSTR#%') or cast(vid as varchar) like '%#SEARCHSTR#%'");
		this.wherelist.put(3,"vid != 0");
		// ID 4 : Infos Subnet Fill
		this.selectlist.put(4,"select subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def,count(adresses.ip) as mycount,power(2,32-subnets_display.mask)-2 as mymax,round((count(adresses.ip)*100/(power(2,32-subnets_display.mask)-2))"+DbCast.dbCast("NUMERIC")+",1) as mypercent from subnets_display left outer join adresses on subnets_display.id = adresses.subnet");
		this.wherelist.put(4,"(adresses.def is null or adresses.def != 'Reservation DHCP')");
		this.groupbylist.put(4,"subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def");
		this.searchlist.put(4,"lower(subnets_display.ctx_name) like lower('%#SEARCHSTR#%') or lower(subnets_display.cod_site) like lower('%#SEARCHSTR#%') or lower(subnets_display.site_name) like lower('%#SEARCHSTR#%') or lower(subnets_display.def) like lower('%#SEARCHSTR#%') or subnets_display.ip like '%#SEARCHSTR#%' or cast(subnets_display.mask as varchar) like '%#SEARCHSTR#%'");
		// ID 5 : Infos Redundancy
		this.selectlist.put(5,"select ctx_name,site_name,subnet_name,ptype_name,pid,ip,mask,ip_name from redundancy_display");
		this.searchlist.put(5,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(subnet_name) like lower('%#SEARCHSTR#%') or lower(ptype_name) like lower('%#SEARCHSTR#%') or cast(pid as varchar) like '%#SEARCHSTR#%' or ip like '%#SEARCHSTR#%' or cast(mask as varchar) like '%#SEARCHSTR#%' or lower(ip_name) like lower('%#SEARCHSTR#%')");
	}

  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		Connection conn = null;
		Statement stmt = null;
		ResultSet rs = null;
		try {
			this.queryid = req.getParameter("id");
			this.id = Integer.parseInt((String)this.queryid);
			this.querylimit = req.getParameter("limit");
			this.queryoffset = req.getParameter("offset");
			this.querysearch = req.getParameter("search");
			this.queryorder = req.getParameter("order");
			this.querysort = req.getParameter("sort");
			mylog.debug("Starting whith id: "+queryid+", limit: "+querylimit+",offset: "+queryoffset+",search: "+querysearch+", order: "+queryorder+", sort: "+querysort);
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			String myquery = selectlist.get(this.id);
			if (wherelist.containsKey(this.id)) {
				myquery += " where "+wherelist.get(this.id);
				if (!querysearch.equals("")) { myquery += " and "+searchlist.get(this.id).replaceAll("#SEARCHSTR#",querysearch); }
			} else {
				if (!querysearch.equals("")) { myquery += " where "+searchlist.get(this.id).replaceAll("#SEARCHSTR#",querysearch); }
			}
			if (groupbylist.containsKey(this.id)) { myquery += " group by "+groupbylist.get(this.id); }
			if (!queryorder.equals("")) { myquery += " order by "+queryorder; }
			if (!queryorder.equals("") && querysort.equals("desc")) { myquery += " desc"; }
			myquery+=" limit "+this.querylimit+" offset "+this.queryoffset;
			mylog.debug("Executing SQL: "+myquery);
			rs = stmt.executeQuery(myquery);
			while (rs.next()) {
				if (this.id==1) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><def>"+shapeXML(rs.getString("def"))+"</def><gw>"+rs.getString("gw")+"</gw><vid>"+String.valueOf(rs.getInt("vid"))+"</vid><vdef>"+shapeXML(rs.getString("vdef"))+"</vdef></line>"; }
				if (this.id==2) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==3) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><def>"+shapeXML(rs.getString("def"))+"</def><vid>"+String.valueOf(rs.getInt("vid"))+"</vid></line>"; }
				if (this.id==4) {	result += "<line><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><def>"+shapeXML(rs.getString("def"))+"</def><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><mycount>"+String.valueOf(rs.getInt("mycount"))+"</mycount><mymax>"+String.valueOf(rs.getInt("mymax"))+"</mymax><mypercent>"+String.valueOf(rs.getInt("mypercent"))+"</mypercent></line>"; }
				if (this.id==5) {	result += "<line><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><subnet_name>"+shapeXML(rs.getString("subnet_name"))+"</subnet_name><ptype_name>"+shapeXML(rs.getString("ptype_name"))+"</ptype_name><pid>"+String.valueOf(rs.getInt("pid"))+"</pid><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><ip_name>"+shapeXML(rs.getString("ip_name"))+"</ip_name></line>"; }
			}
			mylog.debug("Finish Processing SQL");
			rs.close();rs=null;
			stmt.close();stmt=null;
			conn.close();conn=null;
		} catch (Exception e) { printLog("Global: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
		res.setContentType("text/xml; charset=UTF-8");
	  res.setCharacterEncoding("UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		mylog.debug("Construct XML");
		if (erreur) {
			out.println("<err>true</err><msg>" + shapeXML(errLog) + "</msg>");
		} else {
			out.println("<err>false</err><msg>OK</msg>");
			out.println(result);
		}
		out.println("</reponse>");		
		out.flush();
		out.close();
		mylog.debug("Cleaning");
		errLog = "";
		erreur = false;
		queryid = "";
		id=0;
		querylimit = "";
		queryoffset = "";
		querysearch = "";
		queryorder = "";
		querysort = "";
		result = "";
  }
}
