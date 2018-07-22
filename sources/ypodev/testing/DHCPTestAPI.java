package ypodev.testing;

/*
 * @Author : Yann POSTEC
 */
 
import java.io.*;
import java.util.*;
import javax.ws.rs.*;
import javax.ws.rs.core.MediaType;
import javax.ws.rs.core.Response;
import javax.ws.rs.core.Context;
import javax.ws.rs.core.SecurityContext;
import java.security.Principal;
import com.google.gson.*;
import org.apache.log4j.Logger;

public class DHCPTestAPI {
	private String errLog = "";
	private boolean erreur = false;
	private Logger mylog = Logger.getLogger(DHCPTestAPI.class);

	private class Scope {
		private String ip;
		private Scope(String s) { this.ip = s; }
	}
	private class ScopeList {
		private List<Scope> scopes = new ArrayList<Scope>();
	}
	private class ScopeRange {
		private String start;
		private String end;
		private ScopeRange(String s, String e) {
			this.start = s;
			this.end = e;
		}
	}
	private class ScopeExcludeRangeList {
		private List<ScopeRange> excluderanges = new ArrayList<ScopeRange>();
	}
	private class Lease {
		private String ip;
		private String mac;
		private String stamp;
		private String name;
		private String def;
		private Integer type;
		private Lease(String i,String m, String s, String n, String d, Integer t) {
			this.ip = i;
			this.mac = m;
			this.stamp = s;
			this.name = n;
			this.def = d;
			this.type = t;
		}
	}
	private class ScopeLeaseList {
		private List<Lease> leases = new ArrayList<Lease>();
	}
		
	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();
			mylog.error(msg,e);
		}
		this.errLog += msg + "\n";
	}

	@GET
	@Path("/scopelist")
	@Produces(MediaType.APPLICATION_JSON)
	public Response dhcpscopeRESTService() {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		try {
			ScopeList mylist = new ScopeList();
			mylist.scopes.add(new Scope("192.168.66.0"));
			mylist.scopes.add(new Scope("192.168.67.0"));
			mylist.scopes.add(new Scope("192.168.68.0"));
			mylist.scopes.add(new Scope("192.168.69.0"));
			mylist.scopes.add(new Scope("192.168.70.0"));
			mylist.scopes.add(new Scope("192.168.71.0"));
			mylist.scopes.add(new Scope("192.168.72.0"));
			mylist.scopes.add(new Scope("192.168.73.0"));
			mylist.scopes.add(new Scope("192.168.74.0"));
			mylist.scopes.add(new Scope("192.168.75.0"));
			mylist.scopes.add(new Scope("192.168.76.0"));
			mylist.scopes.add(new Scope("192.168.77.0"));
			mylist.scopes.add(new Scope("192.168.78.0"));
			mylist.scopes.add(new Scope("192.168.79.0"));
			mylist.scopes.add(new Scope("192.168.80.0"));
			Gson gson = new Gson();
			result = gson.toJson(mylist);
		} catch (Exception e) { printLog("Scope: ",e); }
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/range/{scope}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response dhcprangeRESTService(@PathParam("scope") String scope) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (scope.equals("192.168.66.0") || scope.equals("192.168.67.0") || scope.equals("192.168.68.0")) {
			try {
				ScopeRange myrange = new ScopeRange(null,null);
				if (scope.equals("192.168.66.0")) {
					myrange.start = "192.168.66.10";
					myrange.end = "192.168.66.100";
				}
				if (scope.equals("192.168.67.0")) {
					myrange.start = "192.168.67.101";
					myrange.end = "192.168.67.150";
				}
				if (scope.equals("192.168.68.0")) {
					myrange.start = "192.168.68.200";
					myrange.end = "192.168.68.220";
				}
				Gson gson = new Gson();
				result = gson.toJson(myrange);
			} catch (Exception e) { printLog("Range: ",e); }
		} else {
			errcode=404;
			result="Scope not found";
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}
	
	@GET
	@Path("/exclude/{scope}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response dhcpexcludeRESTService(@PathParam("scope") String scope) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (scope.equals("192.168.66.0") || scope.equals("192.168.67.0") || scope.equals("192.168.68.0")) {
			try {
				ScopeExcludeRangeList mylist = new ScopeExcludeRangeList();
				if (scope.equals("192.168.66.0")) {
					mylist.excluderanges.add(new ScopeRange("192.168.66.10","192.168.66.20"));
					mylist.excluderanges.add(new ScopeRange("192.168.66.70","192.168.66.75"));
				}
				if (scope.equals("192.168.67.0")) {
					mylist.excluderanges.add(new ScopeRange("192.168.67.110","192.168.67.110"));
				}
				Gson gson = new Gson();
				result = gson.toJson(mylist);
			} catch (Exception e) { printLog("Exclude: ",e); }
		} else {
			errcode=404;
			result="Scope not found";
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Path("/reserve/{scope}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response dhcpreserveRESTService(@PathParam("scope") String scope) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (scope.equals("192.168.66.0") || scope.equals("192.168.67.0") || scope.equals("192.168.68.0")) {
			try {
				ScopeLeaseList mylist = new ScopeLeaseList();
				if (scope.equals("192.168.66.0")) {
					mylist.leases.add(new Lease("192.168.66.21","aa0b3e4f6c44",null,"resa1",null,null));
					mylist.leases.add(new Lease("192.168.66.22","aa0b354f6c4e",null,"resa2",null,null));
				}
				Gson gson = new Gson();
				result = gson.toJson(mylist);
			} catch (Exception e) { printLog("Exclude: ",e); }
		} else {
			errcode=404;
			result="Scope not found";
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

	@GET
	@Path("/lease/{scope}")
	@Produces(MediaType.APPLICATION_JSON)
	public Response dhcpleaseRESTService(@PathParam("scope") String scope) {
		String result="";
		int errcode=200;
		this.erreur=false;
		this.errLog="";
		if (scope.equals("192.168.66.0") || scope.equals("192.168.67.0") || scope.equals("192.168.68.0")) {
			try {
				ScopeLeaseList mylist = new ScopeLeaseList();
				if (scope.equals("192.168.66.0")) {
					mylist.leases.add(new Lease("192.168.66.50","02996f3c9b5d","2018-06-24 07:12:00","lease1",null,null));
					mylist.leases.add(new Lease("192.168.66.51","56748a3b9c6e","2018-06-23 15:23:45","lease2",null,null));
				}
				if (scope.equals("192.168.67.0")) {
					mylist.leases.add(new Lease("192.168.67.101","123456789a6b","2018-06-20 10:46:00","lease3",null,null));
				}
				if (scope.equals("192.168.68.0")) {
					mylist.leases.add(new Lease("192.168.68.200","1a2b3c4d5e6f","2018-06-22 17:23:21","lease4",null,null));
				}
				Gson gson = new Gson();
				result = gson.toJson(mylist);
			} catch (Exception e) { printLog("Exclude: ",e); }
		} else {
			errcode=404;
			result="Scope not found";
		}
		if (erreur) {
			return Response.status(500).entity(errLog).build();
		} else { return Response.status(errcode).entity(result).build(); }
	}

}
