<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin}">
<jsp:useBean id="today" scope="page" class="java.util.Date" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="admin.schedulers.launch.click" var="lang_adminschedclick" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.schedulers.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/user_prefs.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_schedulers.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<h3><fmt:message key="admin.schedulers.info" /> <span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:displayJobs()" /></span></h3>
<div id="jobwait"></div>
<table id="tJobList">
<thead><tr><th>Job</th><th><fmt:message key="common.table.grp" /></th><th><fmt:message key="admin.schedulers.prev" /></th><th><fmt:message key="admin.schedulers.next" /></th></tr></thead>
<tbody />
</table>
<hr />
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span>Sauvegarder les changements
<table>
<tr><th>Job</th><th><fmt:message key="common.enabled" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="admin.schedulers.launch" /></th><th><fmt:message key="admin.settings" /></th><th><fmt:message key="sla.purge.stats" /></th></tr>

<sql:query var="userJobs">select * from schedulers where id=1</sql:query>
<c:forEach items="${userJobs.rows}" var="userJob">
<tr class="sideA"><td align="center"><b>1</b></td>
<td><select id="sel1"><option value="1" <c:if test="${userJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${userJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job1.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${userJob.jobname}')" /></span></td>
<td><fmt:message key="admin.schedulers.days" /> : <input type="text" id="day1" value="${userJob.param}"></td>
</c:forEach>
<td><fmt:message key="admin.schedulers.job1.stats" />
<sql:query var="users">select TO_CHAR(last,'YYYY') as annee,count(*) as nb from usercookie where login!='admin' group by TO_CHAR(last,'YYYY') order by annee</sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.year" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody><c:forEach items="${users.rows}" var="user"><tr><td>${user.annee}</td><td>${user.nb}</td></tr></c:forEach></tbody>
</table></td></tr>

<sql:query var="stkJobs">select * from schedulers where id=2</sql:query>
<c:forEach items="${stkJobs.rows}" var="stkJob">
<tr class="sideB"><td align="center"><b>2</b></td>
<td><select id="sel2"><option value="1" <c:if test="${stkJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${stkJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job2.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${stkJob.jobname}')" /></span></td>
<td><fmt:message key="admin.schedulers.days" /> : <input type="text" id="day2" value="${stkJob.param}"></td>
</c:forEach>
<td><fmt:message key="admin.schedulers.job2.stats" />
<sql:query var="stks">select TO_CHAR(stamp,'YYYY') as annee,count(*) as nb from stock_mvt group by TO_CHAR(stamp,'YYYY') order by annee</sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.year" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody><c:forEach items="${stks.rows}" var="stk"><tr><td>${stk.annee}</td><td>${stk.nb}</td></tr></c:forEach></tbody>
</table></td></tr>

<sql:query var="photoJobs">select * from schedulers where id=3</sql:query>
<c:forEach items="${photoJobs.rows}" var="photoJob">
<tr class="sideA"><td align="center"><b>3</b></td>
<td><select id="sel3"><option value="1" <c:if test="${photoJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${photoJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job3.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${photoJob.jobname}')" /></span></td>
<td><ul class="prefs"><li><a href="javascript:getPurgePhoto()"><fmt:message key="admin.schedulers.purgephoto" /></a></li></ul></td>
</c:forEach>
<td /></tr>

<sql:query var="tmpipJobs">select * from schedulers where id=4</sql:query>
<c:forEach items="${tmpipJobs.rows}" var="tmpipJob">
<tr class="sideB"><td align="center"><b>4</b></td>
<td><select id="sel4"><option value="1" <c:if test="${tmpipJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${tmpipJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job4.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${tmpipJob.jobname}')" /></span></td>
<td />
</c:forEach>
<sql:query var="tmps">select count(*) as nb from adresses where temp = 1 and type = 'static' and date_temp < ?<sql:dateParam value="${today}" /></sql:query>
<td><fmt:message key="admin.schedulers.job4.stats" /> : <c:forEach items="${tmps.rows}" var="tmp">${tmp.nb}</c:forEach></td></tr>

<sql:query var="migipJobs">select * from schedulers where id=5</sql:query>
<c:forEach items="${migipJobs.rows}" var="migipJob">
<tr class="sideA"><td align="center"><b>5</b></td>
<td><select id="sel5"><option value="1" <c:if test="${migipJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${migipJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job5.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${migipJob.jobname}')" /></span></td>
<td />
</c:forEach>
<sql:query var="migs">select count(*) as nb from adresses where mig = 1 and type = 'static' and date_mig < ?<sql:dateParam value="${today}" /></sql:query>
<td><fmt:message key="admin.schedulers.job5.stats" /> : <c:forEach items="${migs.rows}" var="mig">${mig.nb}</c:forEach></td></tr>

<sql:query var="NormAddSubnetJobs">select * from schedulers where id=6</sql:query>
<c:forEach items="${NormAddSubnetJobs.rows}" var="nasJob">
<tr class="sideB"><td align="center"><b>6</b></td>
<td><select id="sel6"><option value="1" <c:if test="${nasJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${nasJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job6.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${nasJob.jobname}')" /></span></td>
<td />
</c:forEach>
<sql:query var="nass">select count(*) as nb from subnets where surnet = 0</sql:query>
<td><fmt:message key="admin.schedulers.job6.stats" /> : <c:forEach items="${nass.rows}" var="nas">${nas.nb}</c:forEach></td></tr>

<sql:query var="CactiDevicesJobs">select * from schedulers where id=7</sql:query>
<c:forEach items="${CactiDevicesJobs.rows}" var="cactidJob">
<tr class="sideA"><td align="center"><b>7</b></td>
<td><select id="sel7"><option value="1" <c:if test="${cactidJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${cactidJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job7.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${cactidJob.jobname}')" /></span></td>
<td />
</c:forEach>
<td /></tr>

<sql:query var="CactiStatsJobs">select * from schedulers where id=8</sql:query>
<c:forEach items="${CactiStatsJobs.rows}" var="cactisJob">
<tr class="sideB"><td align="center"><b>8</b></td>
<td><select id="sel8"><option value="1" <c:if test="${cactisJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${cactisJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job8.title" /></h3></td>
<td />
<td><fmt:message key="admin.schedulers.job8.param" />
<p><input type="radio" id="job8_param_hour" name="job8_param" <c:if test="${cactisJob.param == 1}"> checked="checked"</c:if> value="1" /><label for="job8_param_hour"><fmt:message key="admin.schedulers.job8.hourly" /></label> <input type="radio" id="job8_param_day" name="job8_param" <c:if test="${cactisJob.param == 2}"> checked="checked"</c:if> value="2" /><label for="job8_param_day"><fmt:message key="admin.schedulers.job8.daily" /></label> <input type="radio" id="job8_param_month" name="job8_param" <c:if test="${cactisJob.param == 3}"> checked="checked"</c:if> value="3" /><label for="job8_param_month"><fmt:message key="admin.schedulers.job8.monthly" /></label><br /><i><fmt:message key="admin.schedulers.job8.warning" /></i></p></td>
</c:forEach>
<td /></tr>

<sql:query var="CactiDaysJobs">select * from schedulers where id=9</sql:query>
<c:forEach items="${CactiDaysJobs.rows}" var="cactidaysJob">
<tr class="sideA"><td align="center"><b>9</b></td>
<td><select id="sel9"><option value="1" <c:if test="${cactidaysJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${cactidaysJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job9.title" /></h3></td>
<td />
<td />
</c:forEach>
<td /></tr>

<sql:query var="CactiMonthsJobs">select * from schedulers where id=10</sql:query>
<c:forEach items="${CactiMonthsJobs.rows}" var="cactimonthsJob">
<tr class="sideB"><td align="center"><b>10</b></td>
<td><select id="sel10"><option value="1" <c:if test="${cactimonthsJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${cactimonthsJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job10.title" /></h3></td>
<td />
<td />
</c:forEach>
<td /></tr>

<sql:query var="DHCPJobs">select * from schedulers where id=11</sql:query>
<c:forEach items="${DHCPJobs.rows}" var="DHCPJob">
<tr class="sideA"><td align="center"><b>11</b></td>
<td><select id="sel11"><option value="1" <c:if test="${DHCPJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option><option value="0" <c:if test="${DHCPJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option></select></td>
<td><h3><fmt:message key="admin.schedulers.job11.title" /></h3></td>
<td align="center"><span onmouseover="javascript:tooltip.show('${lang_adminschedclick}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_script.png" alt="${lang_adminschedclick}" onclick="javascript:launchJob('${DHCPJob.jobname}')" /></span></td>
<td />
</c:forEach>
<td /></tr>

</table>

<div id="dlgcontent"/>
</body></html>
</c:if>

