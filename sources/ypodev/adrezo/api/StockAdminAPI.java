package ypodev.adrezo.api;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
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

@Path("/stockadmin")
@Secured({Role.API})
public class StockAdminAPI {
	
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(StockAdminAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiStockSiteList {
		private List<ApiStockSite> stocksite_list = new ArrayList<ApiStockSite>();
	}
	private class ApiStockSite {
		private Integer id;
		private String name;
		private boolean main;
	}
	private class ApiStockTypeList {
		private List<ApiStockType> stocktype_list = new ArrayList<ApiStockType>();
	}
	private class ApiStockType {
		private Integer id;
		private String name;
		private Integer threshold;
		private Integer category;
		private String index;
		private Integer ongoing;
		private Integer ctx;
		private Integer site;
	}
	private class ApiStockCategoryList {
		private List<ApiStockCategory> stockcategory_list = new ArrayList<ApiStockCategory>();
	}
	private class ApiStockCategory {
		private Integer id;
		private String name;
	}

	@GET
	@Secured({Role.STKADMIN})
	@Path("/site/list/{ctx}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocksitelistRESTService(@PathParam("ctx") String ctx) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(ctx); } catch (NumberFormatException e) { printLog("StockSiteList/Check: Context not a number",null); }
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
				rs = stmt.executeQuery("select s.id,s.name,c.site_main from sites s,contextes c where s.ctx=c.id and s.ctx="+ctx);
				if (rs.isBeforeFirst()) {
					ApiStockSiteList mylist = new ApiStockSiteList();
					while (rs.next()) {
						ApiStockSite mysite = new ApiStockSite();
						mysite.id = rs.getInt("id");
    				mysite.name = rs.getString("name");
		    		if (rs.getInt("site_main") == mysite.id) { mysite.main = true; }
		    		else { mysite.main = false; }
						mylist.stocksite_list.add(mysite);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Site list empty or context not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockSiteList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockSiteList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockSiteList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockSiteList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured({Role.STKADMIN})
	@Path("/type/list/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocktypelistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("StockTypeList/Check: Site not a number",null); }
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
					ApiStockTypeList mylist = new ApiStockTypeList();
					while (rs.next()) {
						ApiStockType mytype = new ApiStockType();
						mytype.id = rs.getInt("id");
    				mytype.name = rs.getString("def");
    				mytype.threshold = rs.getInt("seuil");
    				mytype.category = rs.getInt("cat");
    				mytype.index = rs.getString("idx");
    				mytype.ongoing = rs.getInt("encours");
    				mytype.ctx = rs.getInt("ctx");
   					mytype.site = rs.getInt("site");
						mylist.stocktype_list.add(mytype);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Type list empty or site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured({Role.STKADMIN})
	@Path("/category/list")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stockcategorylistRESTService() {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
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
				rs = stmt.executeQuery("select * from stock_cat");
				if (rs.isBeforeFirst()) {
					ApiStockCategoryList mylist = new ApiStockCategoryList();
					while (rs.next()) {
						ApiStockCategory mycategory = new ApiStockCategory();
						mycategory.id = rs.getInt("id");
    				mycategory.name = rs.getString("name");
						mylist.stockcategory_list.add(mycategory);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Category list empty";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockCategoryList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockCategoryList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockCategoryList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockCategoryList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured({Role.STKADMIN})
	@Path("/type/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stocktypeinfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockTypeGet/Check: ID not a number",null); }
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
					ApiStockType mytype = new ApiStockType();
					mytype.id = rs.getInt("id");
   				mytype.name = rs.getString("def");
   				mytype.threshold = rs.getInt("seuil");
   				mytype.category = rs.getInt("cat");
   				mytype.index = rs.getString("idx");
   				mytype.ongoing = rs.getInt("encours");
   				mytype.ctx = rs.getInt("ctx");
   				mytype.site = rs.getInt("site");
					Gson gson = new Gson();
					result = gson.toJson(mytype);
				} else {
					errcode=404;
					result="Type not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@DELETE
	@Secured({Role.STKADMIN})
	@Path("/type/{id}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response stocktypedelRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockTypeDelete/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from stock_etat where id="+id);
				if (rs.next()) {
					try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from stock_etat where id="+id);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("StockTypeDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Type not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockTypeDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeDelete/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@POST
	@Secured({Role.STKADMIN})
	@Path("/type/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response stocktypeaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inthreshold="";
		String incategory="";
		String inindex="";
		String inongoing="";
		String inctx="";
		String insite="";
		try {
			Gson gson = new Gson();
			ApiStockType obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiStockType.class);
			inname = obj.name;
 			inthreshold = obj.threshold==null?null:String.valueOf(obj.threshold);
 			incategory = obj.category==null?null:String.valueOf(obj.category);
 			inindex = obj.index;
 			inongoing = obj.ongoing==null?null:String.valueOf(obj.ongoing);
 			inctx = String.valueOf(obj.ctx);
 			insite = String.valueOf(obj.site);
		} catch (Exception e) { printLog("StockTypeAdd/ReadJSON: ",e); }
		if (inname==null) { printLog("StockTypeAdd/Check: name not null",null); }
		if (inname!=null&&inname.length()>255) { printLog("StockTypeAdd/Check: name too long",null); }
		if (inindex==null) { printLog("StockTypeAdd/Check: index not null",null); }
		if (inindex!=null&&inindex.length()>8) { printLog("StockTypeAdd/Check: index too long",null); }
		try {
			if (inthreshold!=null) {
				Integer test = Integer.parseInt(inthreshold);
				if (test<0) { printLog("StockTypeAdd/Check: threshold must be positive",null); }
				if (test>9999) { printLog("StockTypeMod/Check: threshold must be < 10000",null); }
			} else { inthreshold = "0"; }
		} catch (NumberFormatException e) { printLog("StockTypeAdd/Check: threshold not a number",null); }
		try {
			Integer test = Integer.parseInt(incategory);
			if (test<0) { printLog("StockTypeAdd/Check: category must be positive",null); }
		} catch (NumberFormatException e) { printLog("StockTypeAdd/Check: category not a number",null); }
		try {
			if (inongoing!=null) {
				Integer test = Integer.parseInt(inongoing);
				if (test<0) { printLog("StockTypeAdd/Check: ongoing must be positive",null); }
				if (test>9999) { printLog("StockTypeMod/Check: ongoing must be < 10000",null); }
			} else { inongoing = "0"; }
		} catch (NumberFormatException e) { printLog("StockTypeAdd/Check: ongoing not a number",null); }
		try { Integer.parseInt(inctx); } catch (NumberFormatException e) { printLog("StockTypeAdd/Check: ctx not a number",null); }
		try { Integer.parseInt(insite); } catch (NumberFormatException e) { printLog("StockTypeAdd/Check: site not a number",null); }		
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			ResultSet rsv = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				db_type = (String) env.lookup("db_type");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from sites where id="+insite+" and ctx="+inctx);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into stock_etat (id,idx,def,seuil,cat,encours,ctx,site) values ("+DbSeqNextval.dbSeqNextval("stock_seq")+",'"+inindex+"','"+inname+"',"+inthreshold+","+incategory+","+inongoing+","+inctx+","+insite+")");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("stock_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Stock Type "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Stock Type created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("StockTypeAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Context,Site not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("StockTypeAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockTypeAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.STKADMIN})
	@Path("/type/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response stocktypemodRESTService(@PathParam("id") String id,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inthreshold="";
		String incategory="";
		String inindex="";
		String inongoing="";
		try {
			Gson gson = new Gson();
			ApiStockType obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiStockType.class);
			inname = obj.name;
 			inthreshold = obj.threshold==null?null:String.valueOf(obj.threshold);
 			incategory = obj.category==null?null:String.valueOf(obj.category);
 			inindex = obj.index;
 			inongoing = obj.ongoing==null?null:String.valueOf(obj.ongoing);
		} catch (Exception e) { printLog("StockTypeMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>255) { printLog("StockTypeMod/Check: name too long",null); }
		if (inindex!=null&&inindex.length()>8) { printLog("StockTypeMod/Check: index too long",null); }
		try {
			if (inthreshold!=null) {
				Integer test = Integer.parseInt(inthreshold);
				if (test<0) { printLog("StockTypeMod/Check: threshold must be positive",null); }
				if (test>9999) { printLog("StockTypeMod/Check: threshold must be < 10000",null); }
			}
		} catch (NumberFormatException e) { printLog("StockTypeMod/Check: threshold not a number",null); }
		try {
			if (incategory!=null) {
				Integer test = Integer.parseInt(incategory);
				if (test<0) { printLog("StockTypeMod/Check: category must be positive",null); }
			}
		} catch (NumberFormatException e) { printLog("StockTypeMod/Check: category not a number",null); }
		try {
			if (inongoing!=null) {
				Integer test = Integer.parseInt(inongoing);
				if (test<0) { printLog("StockTypeMod/Check: ongoing must be positive",null); }
				if (test>9999) { printLog("StockTypeMod/Check: ongoing must be < 10000",null); }
			}
		} catch (NumberFormatException e) { printLog("StockTypeMod/Check: ongoing not a number",null); }
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockTypeMod/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from stock_etat where id="+id);					
				if (rs.next()) {
  				try {
						if (inname==null && inthreshold==null && incategory==null && inindex==null && inongoing==null) {
							errcode=200;
							result="Nothing to patch";
						} else {
	   					stmtup = conn.createStatement();
	   					String queryupdt = "update stock_etat set ";
	   					List<String> mylist = new ArrayList<String>();
	   					if (inname!=null) { mylist.add("def='"+inname+"'"); }
	   					if (inindex!=null) { mylist.add("idx='"+inindex+"'"); }
							if (inthreshold!=null) { mylist.add("seuil="+inthreshold); }
							if (incategory!=null) { mylist.add("cat="+incategory); }
							if (inongoing!=null) { mylist.add("encours="+inongoing); }
							queryupdt = queryupdt + String.join(",",mylist);
							queryupdt = queryupdt + " where id=" + id;
							stmtup.executeUpdate(queryupdt);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("StockTypeMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Stock Type not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockTypeMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}	

	@PATCH
	@Secured({Role.STKADMIN})
	@Path("/type/{id}/reception")
	@Produces(MediaType.TEXT_PLAIN)
	public Response stocktypereceptionRESTService(@PathParam("id") String id) {
		Principal principal = securityContext.getUserPrincipal();
		String username = principal.getName();
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockTypeReception/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id,encours from stock_etat where id="+id);					
				if (rs.next()) {
  				try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("update stock_etat set stock = stock + encours, encours=0 where id="+id);
						stmtup.executeUpdate("insert into stock_mvt (id,stamp,usr,mvt,invent,seuil) values("+id+","+DbFunc.ToDateStr()+"('"+new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new java.util.Date())+"','YYYY-MM-DD HH24:MI:SS'),'"+username+"',"+String.valueOf(rs.getInt("encours"))+",2,0)");
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("StockTypeReception/Failed: ",e); }
				} else {
					errcode=404;
					result="Stock Type not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockTypeReception/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockTypeReception/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockTypeReception/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockTypeReception/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockTypeReception/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}	

	@GET
	@Secured({Role.STKADMIN})
	@Path("/category/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response stockcategoryinfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockCategoryGet/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select * from stock_cat where id="+id);
				if (rs.next()) {
					ApiStockCategory mycategory = new ApiStockCategory();
					mycategory.id = rs.getInt("id");
   				mycategory.name = rs.getString("name");
					Gson gson = new Gson();
					result = gson.toJson(mycategory);
				} else {
					errcode=404;
					result="Category not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockCategoryGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockCategoryGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockCategoryGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockCategoryGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@DELETE
	@Secured({Role.STKADMIN})
	@Path("/category/{id}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response stockcategorydelRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("StockCategoryDelete/Check: ID not a number",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from stock_cat where id="+id);
				if (rs.next()) {
					try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from stock_cat where id="+id);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("StockCategoryDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Category not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockCategoryDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockCategoryDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockCategoryDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockCategoryDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockCategoryDelete/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@POST
	@Secured({Role.STKADMIN})
	@Path("/category/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response stockcategoryaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		try {
			Gson gson = new Gson();
			ApiStockCategory obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiStockCategory.class);
			inname = obj.name;
		} catch (Exception e) { printLog("StockCategoryAdd/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>30) { printLog("StockCategoryAdd/Check: name too long",null); }
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
				stmt.executeUpdate("insert into stock_cat (id,name) values ("+DbSeqNextval.dbSeqNextval("stock_cat_seq")+",'"+inname+"')");
				String myquery = "select "+DbSeqCurrval.dbSeqCurrval("stock_cat_seq")+" as seq";
				if (db_type.equals("oracle")) { myquery += " from dual"; }
				rs = stmt.executeQuery(myquery);
				if (rs.next()) { result="Stock Category "+String.valueOf(rs.getInt("seq"))+" created"; }
				else { result="Stock Category created, no id returned"; }
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockCategoryAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockCategoryAdd/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockCategoryAdd/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockCategoryAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.STKADMIN})
	@Path("/category/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response stockcategorymodRESTService(@PathParam("id") String id,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		try {
			Gson gson = new Gson();
			ApiStockCategory obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiStockCategory.class);
			inname = obj.name;
		} catch (Exception e) { printLog("StockCategoryMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>30) { printLog("StockCategoryMod/Check: name too long",null); }
		if (!erreur) {
			Connection conn = null;
			Statement stmt = null;
			Statement stmtup = null;
			ResultSet rs = null;
			try {
				javax.naming.Context env = (javax.naming.Context) new InitialContext().lookup("java:comp/env");
				String jdbc_jndi = (String) env.lookup("jdbc_jndi");
				javax.sql.DataSource ds = (javax.sql.DataSource) env.lookup (jdbc_jndi);
				conn = ds.getConnection();
				stmt = conn.createStatement();
				rs = stmt.executeQuery("select id from stock_cat where id="+id);					
				if (rs.next()) {
  				try {
						if (inname==null) {
							errcode=200;
							result="Nothing to patch";
						} else {
	   					stmtup = conn.createStatement();
							stmtup.executeUpdate("update stock_cat set name='"+inname+"' where id="+id);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("StockCategoryMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Stock Category not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("StockCategoryMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("StockCategoryMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("StockCategoryMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("StockCategoryMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("StockCategoryMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
}
