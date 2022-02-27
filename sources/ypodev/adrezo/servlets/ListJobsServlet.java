package ypodev.adrezo.servlets;

/*
 * @Author : Yann POSTEC
 */

import java.io.*;
import java.util.*; 
import javax.servlet.*;
import javax.servlet.http.*;
import org.quartz.*;
import org.quartz.ee.servlet.*;
import org.quartz.impl.*;
import org.quartz.impl.matchers.*;
import org.apache.logging.log4j.*;
import ypodev.adrezo.beans.UserInfoBean;

public class ListJobsServlet extends HttpServlet {
		//Properties
	private String errLog = "";
	private boolean erreur = false;
	private String jobs = "";
	private Logger mylog = LogManager.getLogger(ListJobsServlet.class);

	private void printLog(String msg,Exception e) {
		this.erreur = true;
		if (e != null) {
			msg += e.getMessage();		
			mylog.error(msg,e);
		}
		this.errLog += msg + "<br />";
	}
	
  public void doPost(HttpServletRequest req, HttpServletResponse res) throws ServletException, IOException {
		res.setContentType("text/xml; charset=UTF-8");
		res.setCharacterEncoding("UTF-8");
    PrintWriter out = res.getWriter();
    out.println("<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>");
		UserInfoBean validUser = (UserInfoBean) req.getSession().getAttribute("validUser");
		if (validUser != null && validUser.isAdmin()) {
			out.println("<valid>true</valid>");
    	try {
				ServletContext ctx = req.getSession().getServletContext();
				StdSchedulerFactory stdSchedulerFactory = (StdSchedulerFactory) ctx.getAttribute(QuartzInitializerListener.QUARTZ_FACTORY_KEY);
			  Scheduler scheduler = stdSchedulerFactory.getScheduler();
				for (String groupName : scheduler.getJobGroupNames()) {
					for (JobKey jobKey : scheduler.getJobKeys(GroupMatcher.jobGroupEquals(groupName))) {
						String jobName = jobKey.getName();
						String jobGroup = jobKey.getGroup();
						List<? extends Trigger> triggers = scheduler.getTriggersOfJob(jobKey);
						for (int i=0;i<triggers.size();i++) {
							Trigger trigger = triggers.get(i);
							Date nextFire = trigger.getNextFireTime();
							Date prevFire = trigger.getPreviousFireTime();
							jobs+="<job><name>"+jobName+"</name><group>"+jobGroup+"</group><prev>"+prevFire+"</prev><next>"+nextFire+"</next></job>";
						}
					}
				}
			} catch (Exception e) { printLog("Quartz: ",e); }
			if (erreur) {
				errLog = errLog.replaceAll("\\s+"," ");
				errLog = errLog.replaceAll("\r","");
				errLog = errLog.replaceAll("\n","");
				errLog = errLog.replaceAll("&","&amp;");
  			errLog = errLog.replaceAll("<","&lt;");
 	  		errLog = errLog.replaceAll(">","&gt;");
	   		errLog = errLog.replaceAll("\"","&quot;");
  	 		errLog = errLog.replaceAll("'","&apos;");
				out.println("<erreur>true</erreur><msg>" + errLog + "</msg></reponse>");
			} else {
				out.println("<erreur>false</erreur><msg>"+jobs+"</msg></reponse>");
			}
		} else {
			out.println("<valid>false</valid></reponse>");
		}
		out.flush();
		out.close();
		errLog = "";
		erreur = false;
		jobs="";
  }
}
