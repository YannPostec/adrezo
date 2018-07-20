package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import java.text.*;
import java.sql.*;
import javax.naming.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.SecurityContext;
import java.security.Principal;
import com.google.gson.*;
import org.apache.log4j.Logger;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;
import ypodev.adrezo.util.DbFunc;
import ypodev.adrezo.beans.MailBean;

@Path("/stock")
@Secured({Role.API})
public class StockAPI {
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(StockAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiStockSupplyList {
		private List<ApiStockSupply> stocksupply_list = new ArrayList<ApiStockSupply>();
	}
	private class ApiStockSupply {
		private Integer id;
		private String name;
		private Integer stock;
		private Integer threshold;
		private Integer category;
		private String index;
		private Integer ongoing;
	}
	private class ApiStockHistoryList {
		private List<ApiStockHistory> stockhistory_list = new ArrayList<ApiStockHistory>();
	}
	private class ApiStockHistory {
		private String stamp;
		private String user;
		private Integer movement;
		private boolean inventory;
		private boolean threshold;
	}
	private class ApiStockChange {
		private Integer variation;
		private boolean inventory;
	}

	@GET
	@Secured
	@Path("/supply/list/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocksupplylistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("StockSupplyList/Check: Site not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from stock_etat where site="+site+" order by idx");
				if (rs.isBeforeFirst()) {
					ApiStockSupplyList mylist = new ApiStockSupplyList();
					while (rs.next()) {
						ApiStockSupply mysupply = new ApiStockSupply();
						mysupply.id = rs.getInt("id");
    				mysupply.name = rs.getString("def");
    				mysupply.stock = rs.getInt("stock");
    				mysupply.threshold = rs.getInt("seuil");
    				mysupply.category = rs.getInt("cat");
    				mysupply.index = rs.getString("idx");
    				mysupply.ongoing = rs.getInt("encours");
						mylist.stocksupply_list.add(mysupply);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Supply list empty or site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockSupplyList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockSupplyList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockSupplyList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockSupplyList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/supply/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocksupplyinfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockSupplyGet/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from stock_etat where id="+id);
				if (rs.next()) {
					ApiStockSupply mysupply = new ApiStockSupply();
					mysupply.id = rs.getInt("id");
   				mysupply.name = rs.getString("def");
   				mysupply.stock = rs.getInt("stock");
   				mysupply.threshold = rs.getInt("seuil");
   				mysupply.category = rs.getInt("cat");
   				mysupply.index = rs.getString("idx");
   				mysupply.ongoing = rs.getInt("encours");
					Gson gson = new Gson();
					result = gson.toJson(mysupply);
				} else {
					errcode=404;
					result="Supply not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockSupplyGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockSupplyGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockSupplyGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockSupplyGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/supply/history/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocksupplyhistoryRESTService(@PathParam("id") String id) {
		String result="";
		String db_type="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockSupplyHistory/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select * from stock_mvt where id="+id+" order by stamp desc");
				if (rs.isBeforeFirst()) {
					ApiStockHistoryList mylist = new ApiStockHistoryList();
					while (rs.next()) {
						ApiStockHistory myhistory = new ApiStockHistory();
						if (db_type.equals("oracle")) { myhistory.stamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getDate("stamp")); }
    				if (db_type.equals("postgresql")) { myhistory.stamp = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("stamp")); }
   					myhistory.user = rs.getString("usr");
   					myhistory.movement = rs.getInt("mvt");
   					if (rs.getInt("invent") == 0) { myhistory.inventory = false; } else { myhistory.inventory = true; }
   					if (rs.getInt("seuil") == 0) { myhistory.threshold = false; } else { myhistory.threshold = true; }
   					mylist.stockhistory_list.add(myhistory);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Supply history empty";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockSupplyHistory/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockSupplyHistory/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockSupplyHistory/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockSupplyHistory/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.STOCK})
	@Path("/supply/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response stocksupplychangeRESTService(@PathParam("id") String id,InputStream incomingData) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String invariation="";
		String ininventory="";
		try {
			Gson gson = new Gson();
			ApiStockChange obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiStockChange.class);
 			invariation = String.valueOf(obj.variation);
 			if (obj.inventory==true) { ininventory = "1"; } else { ininventory = "0"; }
		} catch (Exception e) { printLog("StockSupplyChange/ReadJSON: ",e); }
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockSupplyChange/Check: ID not a number",null); }
		try { Integer.parseInt(invariation); } catch (NumberFormatException e) { printLog("StockSupplyChange/Check: Variation not a number",null); }		
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			ResultSet rsm = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select stock,encours,seuil from stock_etat where id="+id);					
				if (rs.next()) {
  				try {
						Integer newstock = rs.getInt("stock") + Integer.parseInt(invariation);
						String threshold = "1";
						if ((newstock + rs.getInt("encours")) < rs.getInt("seuil")) { threshold = "0"; }
	   				stmtup = conn.createStatement();
	   				stmtup.executeUpdate("insert into stock_mvt (id,stamp,usr,mvt,invent,seuil) values("+id+","+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS'),'"+username+"',"+invariation+","+ininventory+","+threshold+")");
	   				if (newstock < 0) { newstock=0; }
	   				stmtup.executeUpdate("update stock_etat set stock="+newstock+" where id="+id);
						if ((newstock + rs.getInt("encours")) < rs.getInt("seuil")) {
							rsm = stmtup.executeQuery("select lang from usercookie where login='admin'");
							if (rsm.next()) {
								MailBean mymail = new MailBean();
								mymail.setLang(rsm.getString("lang"));
								mymail.setTableId(Integer.parseInt(id));
								mymail.setMailId(1);
							}
							rsm.close();rsm=null;
						}
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("StockSupplyChange/Failed: ",e); }
				} else {
					errcode=404;
					result="Supply not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockSupplyChange/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockSupplyChange/Close rs",e); } rs = null; }
				if (rsm != null) { try { rsm.close(); } catch (SQLException e) { printLog("StockSupplyChange/Close rsm",e); } rsm = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockSupplyChange/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockSupplyChange/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockSupplyChange/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
}
