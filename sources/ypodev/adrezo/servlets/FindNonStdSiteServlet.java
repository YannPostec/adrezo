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
import ypodev.adrezo.util.*;
import ypodev.adrezo.beans.UserInfoBean;

public class FindNonStdSiteServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String templateid = "";
	private String siteid = "";
	private String sitectx = "";
	private String sitecod = "";
	private String sitename = "";
	private String result = "";
	private String lang;
	private ResourceBundle prop;
	private HashMap<String,String> existing = new HashMap<String,String>();
	private ArrayList<String> allnet = new ArrayList<String>();
	private ArrayList<String> existnet = new ArrayList<String>();
	private Logger mylog = Logger.getLogger(FindNonStdSiteServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private String formatXML(String s) {
		s = s.replaceAll("\\s+"," ");
		s = s.replaceAll("\r","");
		s = s.replaceAll("\n","");
		s = s.replaceAll("&","&amp;");
  	s = s.replaceAll("<","&lt;");
 	  s = s.replaceAll(">","&gt;");
   	s = s.replaceAll("\"","&quot;");
   	s = s.replaceAll("'","&apos;");
   	return s;
  }
	private String listAvailable(ArrayList<String> a,ArrayList<String> e) {
		for (int i=0;i<e.size();i++) { a.remove(e.get(i).toString()); }
		if (a.size()>0) {
			return a.get(0).toString();
		} else {
			return "";
		}
	}

  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		this.templateid = req.getParameter("tpl");
		this.siteid = req.getParameter("id");
		this.sitectx = req.getParameter("ctx");
		this.sitecod = req.getParameter("cod");
		this.sitename = req.getParameter("name");
		mylog.debug("Processing NonStd Site "+this.siteid+" in context "+this.sitectx+", Code: "+this.sitecod+", Name: "+this.sitename);
		UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
		if (validUser != null && validUser.isRezo()) {
			this.lang = validUser.getLang();
			Locale locale = new Locale(lang);
			this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			mylog.debug("Found user, getting locale");
			if (!this.templateid.equals("")&&!this.sitectx.equals("")&&!this.sitecod.equals("")&&!this.sitename.equals("")) {
				Connection conn = null;
				Statement stmt = null;
				Statement stmtres = null;
				ResultSet result = null;
				ResultSet resother = null;
				try {
					Context env = (Context) new InitialContext().lookup("java:comp/env");
					String jdbc_jndi = (String) env.lookup("jdbc_jndi");
					javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
					conn = ds.getConnection();
					stmt = conn.createStatement();
					result = stmt.executeQuery("select id,vid,mask,def,gw,bc,surnet from tpl_subnet_display where tpl="+this.templateid);
					boolean bHadResults = false;
					boolean bContinue = true;
					while (bContinue && result.next()) {
						bHadResults = true;
						String myid = String.valueOf(result.getInt("id"));
						String mydef = result.getString("def");
						String mygw = result.getString("gw");
						String mybc = result.getString("bc");
						String surnets = result.getString("surnet");
						String myvid = String.valueOf(result.getInt("vid"));
						String mymask = String.valueOf(result.getInt("mask"));
						mydef = mydef.replaceAll("#CODE#",this.sitecod);
						mydef = mydef.replaceAll("#SITE#",this.sitename);
						mylog.debug("Processing template subnet "+myid+". Mask: "+mymask+", Def: "+mydef+", GW: "+mygw+", BC: "+mybc+", VID: "+myvid+" in Surnets "+surnets);

						stmtres = conn.createStatement();
						boolean bFound = false;
						for(String surnetid : surnets.split(",")) {
							if (!bFound) {
								String mainip = "";
								String mainmask = "";
								resother = stmtres.executeQuery("select ip,mask from surnets where id="+surnetid);
								while (resother.next()) {
									mainip = resother.getString("ip");
									mainmask = String.valueOf(resother.getInt("mask"));
								}
								resother.close();
								mylog.debug("Searching surnet "+surnetid+", "+mainip+"/"+mainmask);
								resother = stmtres.executeQuery("select ip,mask from surnets where parent="+surnetid);
								while (resother.next()) { this.existing.put(resother.getString("ip"),String.valueOf(resother.getInt("mask"))); }
								resother.close();
								resother = stmtres.executeQuery("select ip,mask from subnets where surnet="+surnetid);
								while (resother.next()) { this.existing.put(resother.getString("ip"),String.valueOf(resother.getInt("mask"))); }
								resother.close();
								for(Map.Entry<String,String> entry : existing.entrySet()) {
									Integer m = Integer.parseInt(entry.getValue());
									Integer n = Integer.parseInt(mymask);
									if (m<n) { this.existnet.addAll(IPFmt.SplitSubnet(entry.getKey(),entry.getValue(),mymask)); }
									if (m==n) { this.existnet.add(entry.getKey()); }
									if (m>n) { this.existnet.add(IPFmt.GetNetwork(entry.getKey(),mymask)); }
								}
								this.allnet.addAll(IPFmt.SplitSubnet(mainip,mainmask,mymask));
								String myip = listAvailable(this.allnet,this.existnet);
								if (!myip.equals("")) {
									bFound=true;
									mylog.debug("Subnet found "+myip+" for surnet "+surnetid);
									String gw = IPFmt.addTwoIP(myip,mygw);
									String bc = IPFmt.addTwoIP(myip,mybc);
									String myvlan = "";
									resother = stmtres.executeQuery("select id from vlan where vid = " + myvid + " and site = " + this.siteid);
									while (resother.next()) { myvlan = String.valueOf(resother.getInt("id")); }
									resother.close();resother=null;
									mylog.debug("Add subnet with query "+"insert into subnets (id,ctx,site,ip,mask,def,gw,bc,vlan) values (" + DbSeqNextval.dbSeqNextval("subnets_seq") + "," + this.sitectx + "," + this.siteid + ",'" + myip + "'," + mymask + ",'" + mydef + "','" + gw + "','" + bc + "'," + myvlan+")");
									stmtres.executeUpdate("insert into subnets (id,ctx,site,ip,mask,def,gw,bc,vlan) values (" + DbSeqNextval.dbSeqNextval("subnets_seq") + "," + this.sitectx + "," + this.siteid + ",'" + myip + "'," + mymask + ",'" + mydef + "','" + gw + "','" + bc + "'," + myvlan+")");
									this.result += prop.getString("findnonstdsite.subfound") + ". " + IPFmt.displayIP(myip) + "/" + mymask + ", " + mydef + "<br />";
								}
								existing.clear();
								allnet.clear();
								existnet.clear();
							}
						}
						if (!bFound) {
							mylog.warn("No available subnet found for subnet "+myid+" : "+mydef+", /"+mymask+" in surnets "+surnets);
							this.result += prop.getString("findnonstdsite.nosubfound")+". "+mydef+", /"+mymask+"<br />";
							bContinue = false;
						}
						stmtres.close();stmtres = null;
					}
					result.close();result = null;
					if (!bHadResults) {
						printLog(prop.getString("findnonstdsite.nosubdefined"),null);
					}
					stmt.close();stmt = null;
					conn.close();conn = null;
				} catch (Exception e) { printLog("DB: ",e); }
				finally {    
						if (result != null) { try { result.close(); } catch (SQLException e) { ; } result = null; }
						if (resother != null) { try { resother.close(); } catch (SQLException e) { ; } resother = null; }
						if (stmtres != null) { try { stmtres.close(); } catch (SQLException e) { ; } stmtres = null; }
						if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
			    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
				}
			} else {
				printLog(prop.getString("findnonstdsite.badparams"),null);
			}
		} else {
			printLog("No valid user",null);
		}
		res.setContentType("text/xml; charset=UTF-8");
	  res.setCharacterEncoding("UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = formatXML(errLog);
			result = formatXML(result);
			out.println("<err>true</err><msg>" + errLog + "</msg><result>" + result + "</result>");
		} else {
			result = formatXML(result);
			out.println("<err>false</err><msg>" + result + "</msg>");
		}
		out.println("</reponse>");		
		out.flush();
		out.close();
		errLog = "";
		erreur = false;
		templateid = "";
		siteid = "";
		sitectx = "";
		sitecod = "";
		sitename = "";
		result = "";
		lang="";
		prop=null;
		existing.clear();
		allnet.clear();
		existnet.clear();
  }
}
