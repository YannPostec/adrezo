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
<h2>Job 1 : <fmt:message key="admin.schedulers.job1.title" /></h2>
<sql:query var="userJobs">select * from schedulers where id=1</sql:query>
<c:forEach items="${userJobs.rows}" var="userJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel1"><option value="1" <c:if test="${userJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${userJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
<fmt:message key="admin.schedulers.days" /> : <input type="text" id="day1" value="${userJob.param}">
</c:forEach>
<h3><fmt:message key="sla.purge.stats" /> : <fmt:message key="admin.schedulers.job1.stats" /></h3>
<sql:query var="users">select TO_CHAR(last,'YYYY') as annee,count(*) as nb from usercookie where login!='admin' group by TO_CHAR(last,'YYYY') order by annee</sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.year" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody><c:forEach items="${users.rows}" var="user"><tr><td>${user.annee}</td><td>${user.nb}</td></tr></c:forEach></tbody>
</table>
<hr />
<h2>Job 2 : <fmt:message key="admin.schedulers.job2.title" /></h2>
<sql:query var="stkJobs">select * from schedulers where id=2</sql:query>
<c:forEach items="${stkJobs.rows}" var="stkJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel2"><option value="1" <c:if test="${stkJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${stkJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
<fmt:message key="admin.schedulers.days" /> : <input type="text" id="day2" value="${stkJob.param}">
</c:forEach>
<h3><fmt:message key="sla.purge.stats" /> : <fmt:message key="admin.schedulers.job2.stats" /></h3>
<sql:query var="stks">select TO_CHAR(stamp,'YYYY') as annee,count(*) as nb from stock_mvt group by TO_CHAR(stamp,'YYYY') order by annee</sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.year" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody><c:forEach items="${stks.rows}" var="stk"><tr><td>${stk.annee}</td><td>${stk.nb}</td></tr></c:forEach></tbody>
</table>
<hr />
<h2>Job 3 : <fmt:message key="admin.schedulers.job3.title" /></h2>
<sql:query var="photoJobs">select enabled from schedulers where id=3</sql:query>
<c:forEach items="${photoJobs.rows}" var="photoJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel3"><option value="1" <c:if test="${photoJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${photoJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<ul class="prefs">
<li><a href="javascript:getPurgePhoto()"><fmt:message key="admin.schedulers.purgephoto" /></a></li>
</ul>
<hr />
<h2>Job 4 : <fmt:message key="admin.schedulers.job4.title" /></h2>
<sql:query var="tmpipJobs">select enabled from schedulers where id=4</sql:query>
<c:forEach items="${tmpipJobs.rows}" var="tmpipJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel4"><option value="1" <c:if test="${tmpipJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${tmpipJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<h3><fmt:message key="sla.purge.stats" /> : <fmt:message key="admin.schedulers.job4.stats" /></h3>
<sql:query var="tmps">select count(*) as nb from adresses where temp = 1 and type = 'static' and date_temp < ?<sql:dateParam value="${today}" /></sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody>
<c:forEach items="${tmps.rows}" var="tmp"><tr><td><fmt:message key="common.table.temp" /></td><td>${tmp.nb}</td></tr></c:forEach>
</tbody>
</table>
<hr />
<h2>Job 5 : <fmt:message key="admin.schedulers.job5.title" /></h2>
<sql:query var="migipJobs">select enabled from schedulers where id=5</sql:query>
<c:forEach items="${migipJobs.rows}" var="migipJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel5"><option value="1" <c:if test="${migipJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${migipJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<h3><fmt:message key="sla.purge.stats" /> : <fmt:message key="admin.schedulers.job5.stats" /></h3>
<sql:query var="migs">select count(*) as nb from adresses where mig = 1 and type = 'static' and date_mig < ?<sql:dateParam value="${today}" /></sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody>
<c:forEach items="${migs.rows}" var="mig"><tr><td><fmt:message key="common.table.mig" /></td><td>${mig.nb}</td></tr></c:forEach>
</tbody>
</table>
<hr />
<h2>Job 6 : <fmt:message key="admin.schedulers.job6.title" /></h2>
<sql:query var="NormAddSubnetJobs">select enabled from schedulers where id=6</sql:query>
<c:forEach items="${NormAddSubnetJobs.rows}" var="nasJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel6"><option value="1" <c:if test="${nasJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${nasJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<h3><fmt:message key="sla.purge.stats" /> : <fmt:message key="admin.schedulers.job6.stats" /></h3>
<sql:query var="nass">select count(*) as nb from subnets where surnet = 0</sql:query>
<table>
<thead><tr><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.count" /></th></tr></thead>
<tbody>
<c:forEach items="${nass.rows}" var="nas"><tr><td><fmt:message key="admin.subnet" /></td><td>${nas.nb}</td></tr></c:forEach>
</tbody>
</table>
<hr />
<h2>Job 7 : <fmt:message key="admin.schedulers.job7.title" /></h2>
<sql:query var="CactiDevicesJobs">select enabled from schedulers where id=7</sql:query>
<c:forEach items="${CactiDevicesJobs.rows}" var="cactidJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel7"><option value="1" <c:if test="${cactidJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${cactidJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<hr />
<h2>Job 8 : <fmt:message key="admin.schedulers.job8.title" /></h2>
<sql:query var="CactiStatsJobs">select param,enabled from schedulers where id=8</sql:query>
<c:forEach items="${CactiStatsJobs.rows}" var="cactisJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel8"><option value="1" <c:if test="${cactisJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${cactisJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
<h3><fmt:message key="admin.schedulers.job8.param" /></h3>
<p><input type="radio" id="job8_param_hour" name="job8_param" <c:if test="${cactisJob.param == 1}"> checked="checked"</c:if> value="1" /><label for="job8_param_hour"><fmt:message key="admin.schedulers.job8.hourly" /></label> <input type="radio" id="job8_param_day" name="job8_param" <c:if test="${cactisJob.param == 2}"> checked="checked"</c:if> value="2" /><label for="job8_param_day"><fmt:message key="admin.schedulers.job8.daily" /></label> <input type="radio" id="job8_param_month" name="job8_param" <c:if test="${cactisJob.param == 3}"> checked="checked"</c:if> value="3" /><label for="job8_param_month"><fmt:message key="admin.schedulers.job8.monthly" /></label><br /><i><fmt:message key="admin.schedulers.job8.warning" /></i></p>
</c:forEach>
<hr />
<h2>Job 9 : <fmt:message key="admin.schedulers.job9.title" /></h2>
<sql:query var="CactiDaysJobs">select enabled from schedulers where id=9</sql:query>
<c:forEach items="${CactiDaysJobs.rows}" var="cactidaysJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel9"><option value="1" <c:if test="${cactidaysJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${cactidaysJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<hr />
<h2>Job 10 : <fmt:message key="admin.schedulers.job10.title" /></h2>
<sql:query var="CactiMonthsJobs">select enabled from schedulers where id=10</sql:query>
<c:forEach items="${CactiMonthsJobs.rows}" var="cactimonthsJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel10"><option value="1" <c:if test="${cactimonthsJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${cactimonthsJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<hr />
<h2>Job 11 : <fmt:message key="admin.schedulers.job11.title" /></h2>
<sql:query var="DHCPJobs">select enabled from schedulers where id=11</sql:query>
<c:forEach items="${DHCPJobs.rows}" var="DHCPJob">
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit()" /></span> <fmt:message key="common.enabled" /> : <select id="sel11"><option value="1" <c:if test="${DHCPJob.enabled == 1}">selected="selected"</c:if>><fmt:message key="common.yes" /></option>
<option value="0" <c:if test="${DHCPJob.enabled == 0}">selected="selected"</c:if>><fmt:message key="common.no" /></option>
</select>
</c:forEach>
<div id="dlgcontent"/>
</body></html>
</c:if>

