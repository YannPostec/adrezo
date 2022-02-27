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
import org.apache.logging.log4j.*;
import ypodev.adrezo.util.DbSeqNextval;
import ypodev.adrezo.util.DbSeqCurrval;

@Path("/photo")
@Secured({Role.API})
public class PhotoAPI {
	
	@Context
	SecurityContext securityContext;
	
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = LogManager.getLogger(PhotoAPI.class);
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}
	
	private class ApiPhotoRoomList {
		private List<ApiPhotoRoom> photoroom_list = new ArrayList<ApiPhotoRoom>();
	}
	private class ApiPhotoRoom {
		private Integer id;
		private String name;
		private Integer site;
	}
	private class ApiPhotoSetList {
		private List<ApiPhotoSet> photoset_list = new ArrayList<ApiPhotoSet>();
	}
	private class ApiPhotoSet {
		private Integer id;
		private String name;
		private Integer room;
	}
	private class ApiPhotoRackList {
		private List<ApiPhotoRack> photorack_list = new ArrayList<ApiPhotoRack>();
	}
	private class ApiPhotoRack {
		private Integer id;
		private String name;
		private Integer position;
		private Integer set;
	}
	private class ApiPhotoPictureList {
		private List<ApiPhotoPicture> photo_list = new ArrayList<ApiPhotoPicture>();
	}
	private class ApiPhotoPicture {
		private Integer id;
		private String name;
		private Integer directory;
		private String suffix;
		private String update;
	}

	@GET
	@Secured
	@Path("/room/list/{site}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photoroomlistRESTService(@PathParam("site") String site) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(site); } catch (NumberFormatException e) { printLog("PhotoRoomList/Check: Site not a number",null); }
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
				rs = stmt.executeQuery("select id,name from salles where idsite="+site);
				if (rs.isBeforeFirst()) {
					ApiPhotoRoomList mylist = new ApiPhotoRoomList();
					while (rs.next()) {
						ApiPhotoRoom myroom = new ApiPhotoRoom();
						myroom.id = rs.getInt("id");
    				myroom.name = rs.getString("name");
						mylist.photoroom_list.add(myroom);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Room list empty or site not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/room/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photoroominfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoRoomGet/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select * from salles where id="+id);
				if (rs.next()) {
					ApiPhotoRoom myroom = new ApiPhotoRoom();
					myroom.id = rs.getInt("id");
   				myroom.name = rs.getString("name");
   				myroom.site = rs.getInt("idsite");
					Gson gson = new Gson();
					result = gson.toJson(myroom);
				} else {
					errcode=404;
					result="Room not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@DELETE
	@Secured({Role.PHOTO})
	@Path("/room/{id}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response photoroomdelRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoRoomDelete/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select id from salles where id="+id);
				if (rs.next()) {
					try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from salles where id="+id);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoRoomDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Room not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRoomDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomDelete/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@POST
	@Secured({Role.PHOTO})
	@Path("/room/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photoroomaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String insite="";
		try {
			Gson gson = new Gson();
			ApiPhotoRoom obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoRoom.class);
			inname = obj.name;
 			insite = String.valueOf(obj.site);
		} catch (Exception e) { printLog("PhotoRoomAdd/ReadJSON: ",e); }
		if (inname==null) { printLog("PhotoRoomAdd/Check: name not null",null); }
		if (inname!=null&&inname.length()>6) { printLog("PhotoRoomAdd/Check: name too long",null); }
		try { Integer.parseInt(insite); } catch (NumberFormatException e) { printLog("PhotoRoomAdd/Check: site not a number",null); }		
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
				rs = stmt.executeQuery("select id from sites where id="+insite);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into salles (id,idsite,name) values ("+DbSeqNextval.dbSeqNextval("salles_seq")+","+insite+",'"+inname+"')");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("salles_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Photo Room "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Photo Room created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoRoomAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Site not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("PhotoRoomAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRoomAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.PHOTO})
	@Path("/room/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photoroommodRESTService(@PathParam("id") String id,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String insite="";
		try {
			Gson gson = new Gson();
			ApiPhotoRoom obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoRoom.class);
			inname = obj.name;
 			insite = obj.site==null?null:String.valueOf(obj.site);
		} catch (Exception e) { printLog("PhotoRoomMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>6) { printLog("PhotoRoomMod/Check: name too long",null); }
		try {
			if (insite!=null) {
				Integer test = Integer.parseInt(insite);
				if (test<0) { printLog("PhotoRoomMod/Check: site must be positive",null); }
			}
		} catch (NumberFormatException e) { printLog("PhotoRoomMod/Check: site not a number",null); }
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
				rs = stmt.executeQuery("select id from salles where id="+id);					
				if (rs.next()) {
  				try {
						if (inname==null && insite==null) {
							errcode=200;
							result="Nothing to patch";
						} else {
	   					stmtup = conn.createStatement();
	   					String queryupdt = "update salles set ";
	   					List<String> mylist = new ArrayList<String>();
	   					if (inname!=null) { mylist.add("name='"+inname+"'"); }
	   					if (insite!=null) { mylist.add("idsite="+insite); }
							queryupdt = queryupdt + String.join(",",mylist);
							queryupdt = queryupdt + " where id=" + id;
							stmtup.executeUpdate(queryupdt);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("PhotoRoomMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Room not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRoomMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/set/list/{room}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photosetlistRESTService(@PathParam("room") String room) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(room); } catch (NumberFormatException e) { printLog("PhotoSetList/Check: Room not a number",null); }
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
				rs = stmt.executeQuery("select id,name from photo_box where idsalle="+room);
				if (rs.isBeforeFirst()) {
					ApiPhotoSetList mylist = new ApiPhotoSetList();
					while (rs.next()) {
						ApiPhotoSet myset = new ApiPhotoSet();
						myset.id = rs.getInt("id");
    				myset.name = rs.getString("name");
						mylist.photoset_list.add(myset);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Set list empty or room not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoSetList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoSetList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoSetList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoSetList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/set/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photosetinfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoSetGet/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select * from photo_box where id="+id);
				if (rs.next()) {
					ApiPhotoSet myset = new ApiPhotoSet();
					myset.id = rs.getInt("id");
   				myset.name = rs.getString("name");
   				myset.room = rs.getInt("idsalle");
					Gson gson = new Gson();
					result = gson.toJson(myset);
				} else {
					errcode=404;
					result="Set not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoSetGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoSetGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoSetGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoSetGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@DELETE
	@Secured({Role.PHOTO})
	@Path("/set/{id}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response photosetdelRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoSetDelete/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select id from photo_box where id="+id);
				if (rs.next()) {
					try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from photo_box where id="+id);
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoSetDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Set not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoSetDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoSetDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoSetDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoSetDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoSetDelete/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@POST
	@Secured({Role.PHOTO})
	@Path("/set/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photosetaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inroom="";
		try {
			Gson gson = new Gson();
			ApiPhotoSet obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoSet.class);
			inname = obj.name;
 			inroom = String.valueOf(obj.room);
		} catch (Exception e) { printLog("PhotoSetAdd/ReadJSON: ",e); }
		if (inname==null) { printLog("PhotoSetAdd/Check: name not null",null); }
		if (inname!=null&&inname.length()>50) { printLog("PhotoSetAdd/Check: name too long",null); }
		try { Integer.parseInt(inroom); } catch (NumberFormatException e) { printLog("PhotoSetAdd/Check: room not a number",null); }		
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
				rs = stmt.executeQuery("select id from salles where id="+inroom);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
						stmtup.executeUpdate("insert into photo_box (id,idsalle,name) values ("+DbSeqNextval.dbSeqNextval("photo_box_seq")+","+inroom+",'"+inname+"')");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("photo_box_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Photo Set "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Photo Set created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoSetAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Room not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoSetAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoSetAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("PhotoSetAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoSetAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoSetAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoSetAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.PHOTO})
	@Path("/set/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photosetmodRESTService(@PathParam("id") String id,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inroom="";
		try {
			Gson gson = new Gson();
			ApiPhotoSet obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoSet.class);
			inname = obj.name;
 			inroom = obj.room==null?null:String.valueOf(obj.room);
		} catch (Exception e) { printLog("PhotoSetMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>50) { printLog("PhotoSetMod/Check: name too long",null); }
		try {
			if (inroom!=null) {
				Integer test = Integer.parseInt(inroom);
				if (test<0) { printLog("PhotoSetMod/Check: room must be positive",null); }
			}
		} catch (NumberFormatException e) { printLog("PhotoSetMod/Check: room not a number",null); }
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
				rs = stmt.executeQuery("select id from photo_box where id="+id);					
				if (rs.next()) {
  				try {
						if (inname==null && inroom==null) {
							errcode=200;
							result="Nothing to patch";
						} else {
	   					stmtup = conn.createStatement();
	   					String queryupdt = "update photo_box set ";
	   					List<String> mylist = new ArrayList<String>();
	   					if (inname!=null) { mylist.add("name='"+inname+"'"); }
	   					if (inroom!=null) { mylist.add("idsalle="+inroom); }
							queryupdt = queryupdt + String.join(",",mylist);
							queryupdt = queryupdt + " where id=" + id;
							stmtup.executeUpdate(queryupdt);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("PhotoSetMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Set not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoSetMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoSetMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoSetMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoSetMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoSetMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Secured
	@Path("/rack/list/{set}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photoracklistRESTService(@PathParam("set") String set) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(set); } catch (NumberFormatException e) { printLog("PhotoRackList/Check: Set not a number",null); }
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
				rs = stmt.executeQuery("select id,name,numero from photo_baie where idbox="+set);
				if (rs.isBeforeFirst()) {
					ApiPhotoRackList mylist = new ApiPhotoRackList();
					while (rs.next()) {
						ApiPhotoRack myrack = new ApiPhotoRack();
						myrack.id = rs.getInt("id");
    				myrack.name = rs.getString("name");
    				myrack.position = rs.getInt("numero");
						mylist.photorack_list.add(myrack);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Rack list empty or set not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackList/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackList/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackList/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackList/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/rack/{id}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photorackinfoRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoRackGet/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select * from photo_baie where id="+id);
				if (rs.next()) {
					ApiPhotoRack myrack = new ApiPhotoRack();
					myrack.id = rs.getInt("id");
   				myrack.name = rs.getString("name");
   				myrack.set = rs.getInt("idbox");
   				myrack.position = rs.getInt("numero");
					Gson gson = new Gson();
					result = gson.toJson(myrack);
				} else {
					errcode=404;
					result="Rack not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackGet/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackGet/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackGet/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackGet/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@DELETE
	@Secured({Role.PHOTO})
	@Path("/rack/{id}")
	@Produces(MediaType.TEXT_PLAIN)
	public Response photorackdelRESTService(@PathParam("id") String id) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(id); } catch (NumberFormatException e) { printLog("PhotoRackDelete/Check: ID not a number",null); }
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
				rs = stmt.executeQuery("select id,idbox,numero from photo_baie where id="+id);
				if (rs.next()) {
					try {
						stmtup = conn.createStatement();
						stmtup.executeUpdate("delete from photo_baie where id="+id);
						stmtup.executeUpdate("update photo_baie set numero = numero - 1 where idbox = "+rs.getInt("idbox")+" and numero > "+rs.getInt("numero"));
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoRackDelete/Fail: ",e); }
				} else {
					errcode=404;
					result="Rack not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackDelete/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackDelete/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackDelete/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRackDelete/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackDelete/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@POST
	@Secured({Role.PHOTO})
	@Path("/rack/")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photorackaddRESTService(InputStream incomingData) {
		String result="";
		String db_type="";
		int errcode=201;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inset="";
		String inposition="";
		try {
			Gson gson = new Gson();
			ApiPhotoRack obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoRack.class);
			inname = obj.name;
 			inset = String.valueOf(obj.set);
 			inposition = String.valueOf(obj.position);
		} catch (Exception e) { printLog("PhotoRackAdd/ReadJSON: ",e); }
		if (inname==null) { printLog("PhotoRackAdd/Check: name not null",null); }
		if (inname!=null&&inname.length()>15) { printLog("PhotoRackAdd/Check: name too long",null); }
		try { Integer.parseInt(inset); } catch (NumberFormatException e) { printLog("PhotoRackAdd/Check: set not a number",null); }
		try { Integer.parseInt(inposition); } catch (NumberFormatException e) { printLog("PhotoRackAdd/Check: position not a number",null); }
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
				rs = stmt.executeQuery("select id from photo_box where id="+inset);					
				if (rs.next()) {
  				try {
	   				stmtup = conn.createStatement();
	   				stmtup.executeUpdate("update photo_baie set numero = numero + 1 where idbox = "+inset+" and numero >= "+inposition);
						stmtup.executeUpdate("insert into photo_baie (id,idbox,name,numero) values ("+DbSeqNextval.dbSeqNextval("photo_baie_seq")+","+inset+",'"+inname+"',"+inposition+")");
						String myquery = "select "+DbSeqCurrval.dbSeqCurrval("photo_baie_seq")+" as seq";
						if (db_type.equals("oracle")) { myquery += " from dual"; }
						rsv = stmtup.executeQuery(myquery);
						if (rsv.next()) { result="Photo Rack "+String.valueOf(rsv.getInt("seq"))+" created"; }
						else { result="Photo Rack created, no id returned"; }
						rsv.close();rsv=null;
						stmtup.close();stmtup=null;
					} catch (Exception e) { printLog("PhotoRackAdd/Failed: ",e); }
				} else {
					errcode=404;
					result="Set not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackAdd/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackAdd/Close rs",e); } rs = null; }
				if (rsv != null) { try { rsv.close(); } catch (SQLException e) { printLog("PhotoRackAdd/Close rsv",e); } rsv = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackAdd/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRackAdd/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackAdd/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@PATCH
	@Secured({Role.PHOTO})
	@Path("/rack/{id}")
	@Consumes(MediaType.APPLICATION_JSON)
	@Produces(MediaType.TEXT_PLAIN)
	public Response photorackmodRESTService(@PathParam("id") String id,InputStream incomingData) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		String inname="";
		String inset="";
		String inposition="";
		try {
			Gson gson = new Gson();
			ApiPhotoRack obj = gson.fromJson(new InputStreamReader(incomingData, "UTF-8"),ApiPhotoRack.class);
			inname = obj.name;
 			inset = obj.set==null?null:String.valueOf(obj.set);
 			inposition = obj.position==null?null:String.valueOf(obj.position);
		} catch (Exception e) { printLog("PhotoRackMod/ReadJSON: ",e); }
		if (inname!=null&&inname.length()>15) { printLog("PhotoRackMod/Check: name too long",null); }
		try {
			if (inset!=null) {
				Integer test = Integer.parseInt(inset);
				if (test<0) { printLog("PhotoRackMod/Check: set must be positive",null); }
			}
		} catch (NumberFormatException e) { printLog("PhotoRackMod/Check: set not a number",null); }
		try {
			if (inposition!=null) {
				Integer test = Integer.parseInt(inposition);
				if (test<1) { printLog("PhotoRackMod/Check: position must be > 0",null); }
			}
		} catch (NumberFormatException e) { printLog("PhotoRackMod/Check: position not a number",null); }
		if (inset!=null && inposition==null) { printLog("PhotoRackMod/Check : position not null if set defined",null); }
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
				rs = stmt.executeQuery("select id,idbox,numero from photo_baie where id="+id);					
				if (rs.next()) {
  				try {
						if (inname==null && inset==null && inposition==null) {
							errcode=200;
							result="Nothing to patch";
						} else {							
							if (inset==null) { inset = String.valueOf(rs.getInt("idbox")); }
							if (inposition==null) { inposition = String.valueOf(rs.getInt("numero")); }
	   					stmtup = conn.createStatement();
	   					String mybox = "";
	   					if (!String.valueOf(rs.getInt("idbox")).equals(inset)) { mybox = String.valueOf(rs.getInt("idbox")); } else { mybox = inset; }
	   					stmtup.executeUpdate("update photo_baie set numero = numero - 1 where idbox = "+mybox+" and numero > "+String.valueOf(rs.getInt("numero")));
	   					stmtup.executeUpdate("update photo_baie set numero = numero + 1 where id != "+id+"and idbox = "+inset+" and numero >= "+inposition);
	   					String queryupdt = "update photo_baie set idbox="+inset+", numero="+inposition;
	   					if (inname!=null) { queryupdt = queryupdt + ", name='"+inname+"'"; }
							queryupdt = queryupdt + " where id=" + id;
							stmtup.executeUpdate(queryupdt);
							stmtup.close();stmtup=null;
						}
					} catch (Exception e) { printLog("PhotoRackMod/Failed: ",e); }
				} else {
					errcode=404;
					result="Rack not found";
				}
				rs.close();rs=null;
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackMod/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackMod/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackMod/Close stmt",e); } stmt = null; }
				if (stmtup != null) { try { stmtup.close(); } catch (SQLException e) { printLog("PhotoRackMod/Close stmtup",e); } stmtup = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackMod/Close conn",e); } conn = null; }				
			}
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}	

	@GET
	@Secured
	@Path("/room/pictures/{room}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photoroompicturesRESTService(@PathParam("room") String room) {
		String result="";
		String db_type="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(room); } catch (NumberFormatException e) { printLog("PhotoRoomPictures/Check: Room not a number",null); }
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
				rs = stmt.executeQuery("select id,name,dir,suf,updt from photo where type = 0 and idparent="+room+" order by name");
				if (rs.isBeforeFirst()) {
					ApiPhotoPictureList mylist = new ApiPhotoPictureList();
					while (rs.next()) {
						ApiPhotoPicture mypicture = new ApiPhotoPicture();
						mypicture.id = rs.getInt("id");
    				mypicture.name = rs.getString("name");
    				mypicture.directory = rs.getInt("dir");
    				mypicture.suffix = rs.getString("suf");
    				if (db_type.equals("oracle")) { mypicture.update = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getDate("updt")); }
    				if (db_type.equals("postgresql")) { mypicture.update = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("updt")); }
						mylist.photo_list.add(mypicture);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Pictures list empty or room not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRoomPictures/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRoomPictures/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRoomPictures/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRoomPictures/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Secured
	@Path("/rack/pictures/{rack}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response photorackpicturesRESTService(@PathParam("rack") String rack) {
		String result="";
		String db_type="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try { Integer.parseInt(rack); } catch (NumberFormatException e) { printLog("PhotoRackPictures/Check: Rack not a number",null); }
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
				rs = stmt.executeQuery("select id,name,dir,suf,updt from photo where type = 1 and idparent="+rack);
				if (rs.isBeforeFirst()) {
					ApiPhotoPictureList mylist = new ApiPhotoPictureList();
					while (rs.next()) {
						ApiPhotoPicture mypicture = new ApiPhotoPicture();
						mypicture.id = rs.getInt("id");
    				mypicture.name = rs.getString("name");
    				mypicture.directory = rs.getInt("dir");
    				mypicture.suffix = rs.getString("suf");
    				if (db_type.equals("oracle")) { mypicture.update = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getDate("updt")); }
    				if (db_type.equals("postgresql")) { mypicture.update = new java.text.SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(rs.getTimestamp("updt")); }
						mylist.photo_list.add(mypicture);
					}
					Gson gson = new Gson();
					result = gson.toJson(mylist);
				} else {
					errcode=404;
					result="Pictures list empty or rack not found";
				}
				rs.close();rs=null;				
				stmt.close();stmt=null;
				conn.close();conn=null;
			} catch (Exception e) { printLog("PhotoRackPictures/Global: ",e); }
			finally {
				if (rs != null) { try { rs.close(); } catch (SQLException e) { printLog("PhotoRackPictures/Close rs",e); } rs = null; }
				if (stmt != null) { try { stmt.close(); } catch (SQLException e) { printLog("PhotoRackPictures/Close stmt",e); } stmt = null; }
				if (conn != null) { try { conn.close(); } catch (SQLException e) { printLog("PhotoRackPictures/Close conn",e); } conn = null; }				
			}			
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

}
