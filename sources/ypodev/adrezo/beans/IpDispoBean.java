package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.util.*;

public class IpDispoBean implements Serializable {
	// Properties
	private Integer nbIP;
	private String subnet;
	private String startIP;
	private String errLog = "";
	private boolean erreur = false;
	private String realStartIP;
	private String realEndIP;
	private String subnetIP;
	private String subnetBC;
	private String subnetMASK;
	private transient Connection conn;
	private Vector ipTotal;
	private Vector ipSubnet;
	private Vector subnetVector;
	private String ipFinal = "";
	private transient ResourceBundle prop;
	private String lang;
	private static Logger mylog = Logger.getLogger(IpDispoBean.class);
	
	//Private functions
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg;
	}
	private void ClearAll() {
		errLog = "";
		erreur = false;
		ipFinal = "";
	}
	private boolean validStartIP(String ip, String subnet, String mask) {
		if (ip == null ) { return true; }
		else { return IPFmt.in_subnet(ip,subnet,mask); }
	}
	private void ConnectDB() {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			Context env = (Context) new InitialContext().lookup("java:comp/env");
			String jdbc_jndi = (String) env.lookup("jdbc_jndi");
			javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
			conn = ds.getConnection();
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select lang from usercookie where login = 'admin'");
			if (rs.next()) {this.lang = rs.getString("lang");} else {this.lang="en";}
			Locale locale = new Locale(lang);
			this.prop = ResourceBundle.getBundle("ypodev.adrezo.props.java",locale);
			rs.close();rs = null;
			stmt.close();stmt = null;
		} catch (Exception e) { printLog("ConnectDB: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		}
	}
	private void CloseDB() {
		try {
			conn.close();conn = null;
		} catch (Exception e) { printLog("CloseDB: ",e); }
		finally {
			if (conn != null) { try { conn.close(); } catch (SQLException e) { ; } conn = null; }
		}
	}
	private void GetInfoSubnet() {
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT IP,BC,MASK FROM SUBNETS WHERE ID = " + subnet);
			if (rs.next()) {
				subnetIP = rs.getString("IP");
				subnetBC = rs.getString("BC");
				subnetMASK = rs.getString("MASK");
			} else { printLog("GetInfoSubnet: "+prop.getString("ipdispo.subnet"),null); }
			rs.close();rs = null;
			stmt.close();stmt = null;
			if (startIP == null) { realStartIP = subnetIP; }
			else { realStartIP = startIP; }	
		} catch (Exception e) { printLog("GetInfoSubnet: ",e); }
		finally {
			if (rs != null) { try { rs.close(); } catch (SQLException e) { ; } rs = null; }
    	if (stmt != null) { try { stmt.close(); } catch (SQLException e) { ; } stmt = null; }
		}
	}
	private void GetIPTotal() {
		try {
			this.ipTotal = new Vector();
			this.ipTotal = IPFmt.VectorIP(realStartIP,realEndIP);
		} catch (Exception e) { printLog("GetIPTotal: ",e); }
	}
	private void GetIPSubnet() {
		this.ipSubnet = new Vector();
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("SELECT IP FROM ADRESSES WHERE SUBNET = " + this.subnet + " AND IP > '" + this.realStartIP + "' AND IP < '" + this.realEndIP + "' ORDER BY IP");
			rs = stmt.getResultSet(); 	
			while (rs.next()) {
				ipSubnet.add(rs.getString("IP"));
			}
			rs.close();
			rs = null;
			stmt.close();
			stmt = null;
		} catch (Exception e) {
			printLog("GetIPSubnet: ",e);
		} finally {
			if (rs != null) {
				try { rs.close(); } catch (SQLException e) { ; }
      	rs = null;
    	}
    	if (stmt != null) {
      	try { stmt.close(); } catch (SQLException e) { ; }
      	stmt = null;
    	}
		}
	}
	private void DiffVector() {
		try {
			int borne;
		
			for (int i=0;i<ipSubnet.size();i++) { ipTotal.remove(ipSubnet.get(i).toString()); }
			if (ipTotal.size()>nbIP) { borne = nbIP; } else { borne = ipTotal.size(); }

			for (int i=0;i<borne;i++) {
				ipFinal += IPFmt.displayIP(ipTotal.get(i).toString());
				if (i!=borne-1) { ipFinal += ","; }
			}
		} catch (Exception e) { printLog("DiffVector: ",e); }
	}
	// Public Getters
	public String getIpFinal() { return ipFinal; }
	public boolean getErreur() { return erreur; }
	public String getErrLog() { return errLog; }
	// Public Setters
	public void setSubnet(String subnet) { this.subnet = subnet; }
	public void setStartIP(String startIP) { this.startIP = startIP; }
	public void setNbIP(Integer nbIP) {
		try {
			this.nbIP = nbIP;
			int cptRequest = 0;
			boolean bFound = false;
			ClearAll();
			ConnectDB();
			GetInfoSubnet();
			if (validStartIP(startIP,subnetIP,subnetMASK)) {
				if (Integer.parseInt((String)subnetMASK) < 24) {
					this.subnetVector = IPFmt.SplitSubnet(subnetIP,subnetMASK,"24");
				}
				while (cptRequest < nbIP) {
					if (Integer.parseInt((String)subnetMASK) < 24) {
						String newsubnet = subnetVector.remove(0).toString();
						if (startIP == null || bFound) {
							realStartIP = newsubnet;
							realEndIP = IPFmt.GetBroadcast(newsubnet,"24");
							GetIPTotal();
							GetIPSubnet();
							DiffVector();
						} else {
							if (validStartIP(startIP,newsubnet,"24")) {
								realStartIP = startIP;
								bFound = true;
								realEndIP = IPFmt.GetBroadcast(newsubnet,"24");
								GetIPTotal();
								GetIPSubnet();
								DiffVector();
							}
						}
					} else {
						realEndIP = subnetBC;
						GetIPTotal();
						GetIPSubnet();
						DiffVector();
					}
					if (Integer.parseInt((String)subnetMASK) < 24) {
						if (!(startIP != null && !bFound)) { cptRequest += ipTotal.size(); }
						if (subnetVector.size() == 0) {cptRequest = nbIP; }
					} else { cptRequest = nbIP; }
				}
			} else { printLog(prop.getString("ipdispo.err"),null); }
			CloseDB();	
		} catch (Exception e) { printLog("Main: ",e); }	
	}
}
