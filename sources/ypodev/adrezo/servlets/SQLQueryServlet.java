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
import ypodev.adrezo.beans.UserInfoBean;

public class SQLQueryServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String queryid = "";
	private Integer id = 0;
	private String querylimit = "";
	private String queryoffset = "";
	private String querysearch = "";
	private String querysearchip = "";
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
		if (msg!=null) {
			msg = msg.replaceAll("\\s+"," ");
			msg = msg.replaceAll("\r","");
			msg = msg.replaceAll("\n","");
			msg = msg.replaceAll("&","&amp;");
  		msg = msg.replaceAll("<","&lt;");
 	  	msg = msg.replaceAll(">","&gt;");
   		msg = msg.replaceAll("\"","&quot;");
   		msg = msg.replaceAll("'","&apos;");
   	}
   	return msg;
	}

	public void init() throws ServletException {
		// Initialize Hashmaps
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String db_type = (String) env.lookup("db_type");
			String castchar = "";
			if (db_type.equals("postgresql")) {
				castchar="varchar";
			} else if (db_type.equals("oracle")) {
				castchar="varchar2(5)";
			}
			// ID 1 : Infos Subnets
			this.selectlist.put(1,"select id,ctx_name,cod_site,site_name,ip,mask,def,gw,vid,vdef,surnet,surip,surmask,surdef from subnets_display");
			this.searchlist.put(1,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHIPSTR#%' or lower(def) like lower('%#SEARCHSTR#%') or gw like '%#SEARCHIPSTR#%' or lower(vdef) like lower('%#SEARCHSTR#%') or lower(surdef) like lower('%#SEARCHSTR#%') or surip like '%#SEARCHIPSTR#%' or cast(vid as "+castchar+") like '%#SEARCHSTR#%' or cast(mask as "+castchar+") like '%#SEARCHSTR#%' or cast(surmask as "+castchar+") like '%#SEARCHSTR#%'");
			// ID 2 : Infos Sites
			this.selectlist.put(2,"select id,ctx_name,cod_site,name from sites_display");
			this.searchlist.put(2,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(name) like lower ('%#SEARCHSTR#%')");
			// ID 3 : Infos Vlans
			this.selectlist.put(3,"select id,vid,def,site_name,cod_site,ctx_name from vlan_display");
			this.searchlist.put(3,"lower(def) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%') or lower(ctx_name) like lower('%#SEARCHSTR#%') or cast(vid as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(3,"vid != 0");
			// ID 4 : Infos Subnet Fill
			this.selectlist.put(4,"select subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def,count(adresses.ip) as mycount,power(2,32-subnets_display.mask)-2 as mymax,round((count(adresses.ip)*100/(power(2,32-subnets_display.mask)-2))"+DbCast.dbCast("NUMERIC")+",1) as mypercent from subnets_display left outer join adresses on subnets_display.id = adresses.subnet");
			this.wherelist.put(4,"(adresses.def is null or adresses.def != 'Reservation DHCP')");
			this.groupbylist.put(4,"subnets_display.ctx_name,subnets_display.cod_site,subnets_display.site_name,subnets_display.ip,subnets_display.mask,subnets_display.def");
			this.searchlist.put(4,"lower(subnets_display.ctx_name) like lower('%#SEARCHSTR#%') or lower(subnets_display.cod_site) like lower('%#SEARCHSTR#%') or lower(subnets_display.site_name) like lower('%#SEARCHSTR#%') or lower(subnets_display.def) like lower('%#SEARCHSTR#%') or subnets_display.ip like '%#SEARCHIPSTR#%' or cast(subnets_display.mask as "+castchar+") like '%#SEARCHSTR#%'");
			// ID 5 : Infos Redundancy
			this.selectlist.put(5,"select ctx_name,site_name,subnet_name,ptype_name,pid,ip,mask,ip_name from redundancy_display");
			this.searchlist.put(5,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(subnet_name) like lower('%#SEARCHSTR#%') or lower(ptype_name) like lower('%#SEARCHSTR#%') or cast(pid as "+castchar+") like '%#SEARCHSTR#%' or ip like '%#SEARCHIPSTR#%' or cast(mask as "+castchar+") like '%#SEARCHSTR#%' or lower(ip_name) like lower('%#SEARCHSTR#%')");
			// ID 6 : Network Sites
			this.selectlist.put(6,"select id,ctx,cod_site,name from sites");
			this.searchlist.put(6,"lower(name) like lower('%#SEARCHSTR#%') or lower(cod_site) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(6,"ctx=#VALIDUSERCTX#");
			// ID 7 : Network Subnets
			this.selectlist.put(7,"select id,ctx,site,site_name,ip,mask,def,gw,bc,vlan,vid,vdef from subnets_display");
			this.searchlist.put(7,"lower(site_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHIPSTR#%' or gw like '%#SEARCHIPSTR#%' or bc like '%#SEARCHIPSTR#%' or lower(vdef) like lower('%#SEARCHSTR#%') or lower(def) like lower('%#SEARCHSTR#%') or cast(vid as "+castchar+") like '%#SEARCHSTR#%' or cast(mask as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(7,"ctx=#VALIDUSERCTX#");
			// ID 8 : Network Vlans
			this.selectlist.put(8,"select id,site,site_name,vid,def from vlan_display");
			this.searchlist.put(8,"lower(site_name) like lower('%#SEARCHSTR#%') or lower(def) like lower('%#SEARCHSTR#%') or cast(vid as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(8,"ctx=#VALIDUSERCTX# and vid!=0");
			// ID 9 : Network Redundancies
			this.selectlist.put(9,"select ptype,ptype_name,id,pid,ipid,ip,mask,ip_name,site_name,subnet_name from redundancy_display");
			this.searchlist.put(9,"lower(ptype_name) like lower('%#SEARCHSTR#%') or lower(ip_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(subnet_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHIPSTR#%' or cast(pid as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(9,"ctx=#VALIDUSERCTX#");
			// ID 10 : Photo Rooms
			this.selectlist.put(10,"select id,name,idsite,site_name from salles_display");
			this.searchlist.put(10,"lower(name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(10,"ctx=#VALIDUSERCTX#");
			// ID 11 : Photo Sets
			this.selectlist.put(11,"select id,idsite,idsalle,site_name,salle_name,name from photo_box_display");
			this.searchlist.put(11,"lower(name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(salle_name) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(11,"ctx=#VALIDUSERCTX#");
			// ID 12 : Photo Racks
			this.selectlist.put(12,"select id,numero,idsite,idsalle,idbox,site_name,salle_name,box_name,name from photo_baie_display");
			this.searchlist.put(12,"lower(name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or lower(salle_name) like lower('%#SEARCHSTR#%') or lower(box_name) like lower('%#SEARCHSTR#%') or cast(numero as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(12,"ctx=#VALIDUSERCTX#");
			// ID 13 : Network Subnet no surnet
			this.selectlist.put(13,"select ctx_name,site_name,ip,mask,def,vid,vdef from subnets_display");
			this.searchlist.put(13,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHIPSTR#%' or lower(def) like lower('%#SEARCHSTR#%') or lower(vdef) like lower('%#SEARCHSTR#%') or cast(vid as "+castchar+") like '%#SEARCHSTR#%' or cast(mask as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(13,"surnet=0");
			// ID 14 : Network Subnet no vlan
			this.selectlist.put(14,"select ctx_name,site_name,ip,mask,def from subnets_display");
			this.searchlist.put(14,"lower(ctx_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%') or ip like '%#SEARCHIPSTR#%' or lower(def) like lower('%#SEARCHSTR#%') or cast(mask as "+castchar+") like '%#SEARCHSTR#%'");
			this.wherelist.put(14,"vid=0");
			// ID 15 : Admin DHCP
			this.selectlist.put(15,"select type,type_name,id,hostname,port,ssl,auth,login,pwd,enable from dhcp_server_display");
			this.searchlist.put(15,"lower(type_name) like lower('%#SEARCHSTR#%') or lower(hostname) like lower('%#SEARCHSTR#%') or lower(login) like lower('%#SEARCHSTR#%') or cast(port as "+castchar+") like '%#SEARCHSTR#%'");
			// ID 16 : SLA Clients
			this.selectlist.put(16,"select id,name,disp,plan,plan_name from slaclient_display");
			this.searchlist.put(16,"lower(name) like lower('%#SEARCHSTR#%') or lower(plan_name) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(16,"id > 0");
			// ID 17 : SLA Sites
			this.selectlist.put(17,"select id,name,disp,plan,plan_name,client,client_name from slasite_display");
			this.searchlist.put(17,"lower(name) like lower('%#SEARCHSTR#%') or lower(client_name) like lower('%#SEARCHSTR#%') or lower(plan_name) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(17,"id > 0");
			// ID 18 : SLA Equipements
			this.selectlist.put(18,"select * from sladevice_display");
			this.searchlist.put(18,"lower(name) like lower('%#SEARCHSTR#%') or lower(client_name) like lower('%#SEARCHSTR#%') or lower(plan_name) like lower('%#SEARCHSTR#%') or lower(site_name) like lower('%#SEARCHSTR#%')");
			// ID 19 : SLA Plannings
			this.selectlist.put(19,"select id,name from slaplanning");
			this.searchlist.put(19,"lower(name) like lower('%#SEARCHSTR#%')");
			this.wherelist.put(19,"id > 0");
		} catch (Exception e) { printLog("Init: ",e); }
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
			this.querysearchip = req.getParameter("searchip");
			this.queryorder = req.getParameter("order");
			this.querysort = req.getParameter("sort");
			UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
			mylog.debug("Starting whith id: "+queryid+", limit: "+querylimit+",offset: "+queryoffset+",search: "+querysearch+", order: "+queryorder+", sort: "+querysort);
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			String db_type = (String) env.lookup("db_type");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			String myquery = selectlist.get(this.id);
			String mysearch = searchlist.get(this.id).replaceAll("#SEARCHSTR#",querysearch);
			mysearch = mysearch.replaceAll("#SEARCHIPSTR#",querysearchip);
			if (wherelist.containsKey(this.id)) {
				myquery += " where "+wherelist.get(this.id).replaceAll("#VALIDUSERCTX#",validUser.getCtx());
				if (!querysearch.equals("")) { myquery += " and ( "+mysearch+" )"; }
			} else {
				if (!querysearch.equals("")) { myquery += " where "+mysearch; }
			}
			if (groupbylist.containsKey(this.id)) { myquery += " group by "+groupbylist.get(this.id); }
			if (!queryorder.equals("")) { myquery += " order by "+queryorder; }
			if (!queryorder.equals("") && querysort.equals("desc")) { myquery += " desc"; }
			if (db_type.equals("postgresql")) {
				myquery+=" limit "+this.querylimit+" offset "+this.queryoffset;
			} else if (db_type.equals("oracle")) {
				myquery+=" offset "+this.queryoffset+" rows fetch next "+this.querylimit+" rows only";
			}
			mylog.debug("Executing SQL: "+myquery);
			rs = stmt.executeQuery(myquery);
			while (rs.next()) {
				if (this.id==1) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><def>"+shapeXML(rs.getString("def"))+"</def><gw>"+rs.getString("gw")+"</gw><vid>"+String.valueOf(rs.getInt("vid"))+"</vid><vdef>"+shapeXML(rs.getString("vdef"))+"</vdef><surnet>"+String.valueOf(rs.getInt("surnet"))+"</surnet><surdef>"+shapeXML(rs.getString("surdef"))+"</surdef><surip>"+rs.getString("surip")+"</surip><surmask>"+String.valueOf(rs.getInt("surmask"))+"</surmask></line>"; }
				if (this.id==2) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==3) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><def>"+shapeXML(rs.getString("def"))+"</def><vid>"+String.valueOf(rs.getInt("vid"))+"</vid></line>"; }
				if (this.id==4) {	result += "<line><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><def>"+shapeXML(rs.getString("def"))+"</def><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><mycount>"+String.valueOf(rs.getInt("mycount"))+"</mycount><mymax>"+String.valueOf(rs.getInt("mymax"))+"</mymax><mypercent>"+String.valueOf(rs.getInt("mypercent"))+"</mypercent></line>"; }
				if (this.id==5) {	result += "<line><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><subnet_name>"+shapeXML(rs.getString("subnet_name"))+"</subnet_name><ptype_name>"+shapeXML(rs.getString("ptype_name"))+"</ptype_name><pid>"+String.valueOf(rs.getInt("pid"))+"</pid><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><ip_name>"+shapeXML(rs.getString("ip_name"))+"</ip_name></line>"; }
				if (this.id==6) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx>"+String.valueOf(rs.getInt("ctx"))+"</ctx><cod_site>"+shapeXML(rs.getString("cod_site"))+"</cod_site><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==7) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ctx>"+String.valueOf(rs.getInt("ctx"))+"</ctx><site>"+String.valueOf(rs.getInt("site"))+"</site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><def>"+shapeXML(rs.getString("def"))+"</def><gw>"+rs.getString("gw")+"</gw><bc>"+rs.getString("bc")+"</bc><vlan>"+String.valueOf(rs.getInt("vlan"))+"</vlan><vid>"+String.valueOf(rs.getInt("vid"))+"</vid><vdef>"+shapeXML(rs.getString("vdef"))+"</vdef></line>"; }
				if (this.id==8) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><site>"+String.valueOf(rs.getInt("site"))+"</site><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><def>"+shapeXML(rs.getString("def"))+"</def><vid>"+String.valueOf(rs.getInt("vid"))+"</vid></line>"; }
				if (this.id==9) {	result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><ptype>"+String.valueOf(rs.getInt("ptype"))+"</ptype><pid>"+String.valueOf(rs.getInt("pid"))+"</pid><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ip>"+rs.getString("ip")+"</ip><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><ptype_name>"+shapeXML(rs.getString("ptype_name"))+"</ptype_name><ipid>"+String.valueOf(rs.getInt("ipid"))+"</ipid><ip_name>"+shapeXML(rs.getString("ip_name"))+"</ip_name><subnet_name>"+shapeXML(rs.getString("subnet_name"))+"</subnet_name></line>"; }
				if (this.id==10) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><idsite>"+String.valueOf(rs.getInt("idsite"))+"</idsite><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==11) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><idsite>"+String.valueOf(rs.getInt("idsite"))+"</idsite><idsalle>"+String.valueOf(rs.getInt("idsalle"))+"</idsalle><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><salle_name>"+shapeXML(rs.getString("salle_name"))+"</salle_name><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==12) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><idsite>"+String.valueOf(rs.getInt("idsite"))+"</idsite><idsalle>"+String.valueOf(rs.getInt("idsalle"))+"</idsalle><idbox>"+String.valueOf(rs.getInt("idbox"))+"</idbox><numero>"+String.valueOf(rs.getInt("numero"))+"</numero><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><salle_name>"+shapeXML(rs.getString("salle_name"))+"</salle_name><box_name>"+shapeXML(rs.getString("box_name"))+"</box_name><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
				if (this.id==13) { result += "<line><vid>"+String.valueOf(rs.getInt("vid"))+"</vid><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><ip>"+rs.getString("ip")+"</ip><def>"+shapeXML(rs.getString("def"))+"</def><vdef>"+shapeXML(rs.getString("vdef"))+"</vdef></line>"; }
				if (this.id==14) { result += "<line><mask>"+String.valueOf(rs.getInt("mask"))+"</mask><site_name>"+shapeXML(rs.getString("site_name"))+"</site_name><ctx_name>"+shapeXML(rs.getString("ctx_name"))+"</ctx_name><ip>"+rs.getString("ip")+"</ip><def>"+shapeXML(rs.getString("def"))+"</def></line>"; }
				if (this.id==15) {
					String mypwd = rs.getString("pwd");
					if (mypwd!=null && !mypwd.equals("")) { mypwd = "password"; }
					result += "<line><type>"+String.valueOf(rs.getInt("type"))+"</type><id>"+String.valueOf(rs.getInt("id"))+"</id><port>"+String.valueOf(rs.getInt("port"))+"</port><ssl>"+String.valueOf(rs.getInt("ssl"))+"</ssl><auth>"+String.valueOf(rs.getInt("auth"))+"</auth><enable>"+String.valueOf(rs.getInt("enable"))+"</enable><type_name>"+shapeXML(rs.getString("type_name"))+"</type_name><hostname>"+shapeXML(rs.getString("hostname"))+"</hostname><login>"+shapeXML(rs.getString("login"))+"</login><pwd>"+mypwd+"</pwd></line>";
				}
				if (this.id==16) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><name>"+shapeXML(rs.getString("name"))+"</name><disp>"+String.valueOf(rs.getInt("disp"))+"</disp><plan>"+String.valueOf(rs.getInt("plan"))+"</plan><plan_name>"+shapeXML(rs.getString("plan_name"))+"</plan_name></line>"; }
				if (this.id==17) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><name>"+shapeXML(rs.getString("name"))+"</name><disp>"+String.valueOf(rs.getInt("disp"))+"</disp><plan>"+String.valueOf(rs.getInt("plan"))+"</plan><plan_name>"+shapeXML(rs.getString("plan_name"))+"</plan_name><client>"+String.valueOf(rs.getInt("client"))+"</client><client_name>"+shapeXML(rs.getString("client_name"))+"</client_name></line>"; }
				if (this.id==18) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><name>"+shapeXML(rs.getString("name"))+"</name><disp>"+String.valueOf(rs.getInt("disp"))+"</disp><plan>"+String.valueOf(rs.getInt("plan"))+"</plan><plan_name>"+shapeXML(rs.getString("plan_name"))+"</plan_name><client>"+String.valueOf(rs.getInt("client"))+"</client><client_name>"+shapeXML(rs.getString("client_name"))+"</client_name></line>"; }
				if (this.id==19) { result += "<line><id>"+String.valueOf(rs.getInt("id"))+"</id><name>"+shapeXML(rs.getString("name"))+"</name></line>"; }
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
		querysearchip = "";
		queryorder = "";
		querysort = "";
		result = "";
  }
}
