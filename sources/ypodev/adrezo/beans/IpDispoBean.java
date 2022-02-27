package ypodev.adrezo.beans;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import java.util.*;
import java.sql.*;
import javax.naming.*;
import org.apache.logging.log4j.*;
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
	private Vector<String> ipTotal;
	private Vector<String> ipSubnet;
	private Vector<String> subnetVector;
	private String ipFinal = "";
	private transient ResourceBundle prop;
	private String lang;
	private static Logger mylog = LogManager.getLogger(IpDispoBean.class);
	
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
	private void GetIPTotal(boolean split) {
		try {
			this.ipTotal = new Vector<String>();
			this.ipTotal = IPFmt.VectorIP(realStartIP,realEndIP);
			if (split) { ipTotal.add(realEndIP); }
		} catch (Exception e) { printLog("GetIPTotal: ",e); }
	}
	private void GetIPSubnet() {
		this.ipSubnet = new Vector<String>();
		Statement stmt = null;
		ResultSet rs = null;
		try {
			stmt = conn.createStatement();
			rs = stmt.executeQuery("select ip from adresses where subnet = " + this.subnet + " and ip > '" + this.realStartIP + "' and ip <= '" + this.realEndIP + "' order by ip");
			rs = stmt.getResultSet(); 	
			while (rs.next()) {
				ipSubnet.add(rs.getString("ip"));
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
	private void DiffVector(int alreadyFound) {
		try {
			int borne;
		
			for (int i=0;i<ipSubnet.size();i++) { ipTotal.remove(ipSubnet.get(i).toString()); }
			if (ipTotal.size()>nbIP-alreadyFound) { borne = nbIP-alreadyFound; } else { borne = ipTotal.size(); }
			for (int i=0;i<borne;i++) {
				ipFinal += IPFmt.displayIP(ipTotal.get(i).toString());
				ipFinal += ",";
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
							if (subnetVector.size() == 0) { GetIPTotal(false); }
							else { GetIPTotal(true); }
							GetIPSubnet();
							DiffVector(cptRequest);
						} else {
							if (validStartIP(startIP,newsubnet,"24")) {
								realStartIP = startIP;
								bFound = true;
								realEndIP = IPFmt.GetBroadcast(newsubnet,"24");
								if (subnetVector.size() == 0) { GetIPTotal(false); }
								else { GetIPTotal(true); }
								GetIPSubnet();
								DiffVector(cptRequest);
							}
						}
					} else {
						realEndIP = subnetBC;
						GetIPTotal(false);
						GetIPSubnet();
						DiffVector(cptRequest);
					}
					if (Integer.parseInt((String)subnetMASK) < 24) {
						if (!(startIP != null && !bFound)) { cptRequest += ipTotal.size(); }
						if (subnetVector.size() == 0) {cptRequest = nbIP; }
					} else { cptRequest = nbIP; }
				}
				if (ipFinal.length()>0) {
					if (ipFinal.lastIndexOf(',') == ipFinal.length()-1) { ipFinal = ipFinal.substring(0,ipFinal.length()-1); }
				}
			} else { printLog(prop.getString("ipdispo.err"),null); }
			CloseDB();	
		} catch (Exception e) { printLog("Main: ",e); }	
	}
}
