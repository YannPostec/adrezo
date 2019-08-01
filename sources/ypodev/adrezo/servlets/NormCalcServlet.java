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

public class NormCalcServlet extends HttpServlet {
	//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String surnetid = "";
	private String newmask = "";
	private String oldmask = "";
	private String oldnet = "";
	private HashMap<String,String> existing = new HashMap<String,String>();
	private ArrayList<String> allnet = new ArrayList<String>();
	private ArrayList<String> existnet = new ArrayList<String>();
	private ArrayList<String> resnet = new ArrayList<String>();
	private Logger mylog = Logger.getLogger(NormCalcServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	private void listAvailable(ArrayList<String> a,ArrayList<String> e) {
		for (int i=0;i<e.size();i++) { a.remove(e.get(i).toString()); }
		for (int i=0;i<a.size();i++) { resnet.add(IPFmt.displayIP(a.get(i).toString())+"/"+this.newmask); }
	}
	
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		this.surnetid = req.getParameter("id");
		this.newmask = req.getParameter("mask");
		if (!this.surnetid.equals("")&&!this.newmask.equals("")) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet result = null;
			ResultSet ressur = null;
			ResultSet ressub = null;
			try {
				Context env = (Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				result = stmt.executeQuery("select ip,mask from surnets where id="+this.surnetid);
				if (result.next()) {
					this.oldnet = result.getString("ip");
					this.oldmask = String.valueOf(result.getInt("mask"));
				}
				result.close();result = null;
				ressur = stmt.executeQuery("select ip,mask from surnets where parent="+this.surnetid);
				while (ressur.next()) { this.existing.put(ressur.getString("ip"),String.valueOf(ressur.getInt("mask"))); }						
				ressur.close();ressur = null;
				ressub = stmt.executeQuery("select ip,mask from subnets where surnet="+this.surnetid);
				while (ressub.next()) { this.existing.put(ressub.getString("ip"),String.valueOf(ressub.getInt("mask"))); }						
				ressub.close();ressub = null;
				stmt.close();stmt = null;
				conn.close();conn = null;
			} catch (Exception e) { printLog("DB: ",e); }
			finally {    
					if (result != null) { try { result.close(); } catch (SQLException e) { ; } result = null; }
					if (ressur != null) { try { ressur.close(); } catch (SQLException e) { ; } ressur = null; }
					if (ressub != null) { try { ressub.close(); } catch (SQLException e) { ; } ressub = null; }
					if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		    	if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
			}
			for(Map.Entry<String,String> entry : existing.entrySet()) {
				Integer m = Integer.parseInt(entry.getValue());
				Integer n = Integer.parseInt(this.newmask); 
				if (m<n) { this.existnet.addAll(IPFmt.SplitSubnet(entry.getKey(),entry.getValue(),this.newmask)); }
				if (m==n) { this.existnet.add(entry.getKey()); }
				if (m>n) { this.existnet.add(IPFmt.GetNetwork(entry.getKey(),this.newmask)); }
			}
			this.allnet.addAll(IPFmt.SplitSubnet(this.oldnet,this.oldmask,this.newmask));
			listAvailable(this.allnet,this.existnet);
		}
		res.setContentType("text/xml; charset=UTF-8");
	  res.setCharacterEncoding("UTF-8");
		PrintWriter out = res.getWriter();
		out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		if (erreur) {
			errLog = errLog.replaceAll("\\s+"," ");
			errLog = errLog.replaceAll("\r","");
			errLog = errLog.replaceAll("\n","");
			errLog = errLog.replaceAll("&","&amp;");
  		errLog = errLog.replaceAll("<","&lt;");
 	  	errLog = errLog.replaceAll(">","&gt;");
   		errLog = errLog.replaceAll("\"","&quot;");
   		errLog = errLog.replaceAll("'","&apos;");
			out.println("<err>true</err><msg>" + errLog + "</msg>");
		} else {
			out.println("<err>false</err><msg>OK</msg>");
		}
		for(int i=0;i<this.resnet.size();i++) {
			out.print("<sub>"+this.resnet.get(i)+"</sub>");
		}
		out.println("</reponse>");		
		out.flush();
		out.close();
		errLog = "";
		erreur = false;
		surnetid = "";
		newmask = "";
		oldmask = "";
		oldnet = "";
		existing.clear();
		allnet.clear();
		existnet.clear();
		resnet.clear();
  }
}
