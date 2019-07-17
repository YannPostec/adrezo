<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:requestEncoding value="UTF-8" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.xls" var="lang_commonclickxls" />
<fmt:message key="sla.display" var="lang_sladisplay" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="sla.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyaccordion.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/sla_stats.js"></script>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinyaccordion.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/sla_stats.css" type="text/css" />
</head>
<c:set var="min_stamp" scope="page" value="0" />
<c:set var="max_stamp" scope="page" value="0" />
<sql:query var="stamps">select min(stamp) as mini, max(stamp) as maxi from slastats</sql:query>
<c:forEach items="${stamps.rows}" var="stamp">
<c:set var="min_year" value="${fn:substring(stamp.mini,0,4)}" scope="page"/>
<c:set var="max_year" value="${fn:substring(stamp.maxi,0,4)}" scope="page"/>
<c:set var="max_stamp" value="${stamp.maxi}" scope="page"/>
</c:forEach>
<body onload="javascript:statsLoad(${fn:substring(max_stamp,0,4)},${fn:substring(max_stamp,4,6)})">
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="sla.title" /></h2>
<c:choose>
<c:when test="${max_stamp == null}"><fmt:message key="sla.empty" /></c:when>
<c:otherwise>
<div class="first"><fmt:message key="sla.displaystat" /> <select id="s_m1" onchange="javascript:fillCompDate()"><option value="0"><fmt:message key="common.entire" /></option><option value="1"><fmt:message key="cal.jan" /></option><option value="2"><fmt:message key="cal.feb" /></option><option value="3"><fmt:message key="cal.mar" /></option><option value="4"><fmt:message key="cal.apr" /></option><option value="5"><fmt:message key="cal.may" /></option><option value="6"><fmt:message key="cal.jun" /></option><option value="7"><fmt:message key="cal.jul" /></option><option value="8"><fmt:message key="cal.aug" /></option><option value="9"><fmt:message key="cal.sep" /></option><option value="10"><fmt:message key="cal.oct" /></option><option value="11"><fmt:message key="cal.nov" /></option><option value="12"><fmt:message key="cal.dec" /></option></select> <select id="s_y1" onchange="javascript:fillCompDate()"><c:forEach var="idx" begin="${min_year}" end="${max_year}" step="1"><option value="${idx}">${idx}</option></c:forEach></select> <span id="span_compare"><fmt:message key="sla.compareto" /> <select id="s_m2"><option value="0"><fmt:message key="common.entire" /></option><option value="1"><fmt:message key="cal.jan" /></option><option value="2"><fmt:message key="cal.feb" /></option><option value="3"><fmt:message key="cal.mar" /></option><option value="4"><fmt:message key="cal.apr" /></option><option value="5"><fmt:message key="cal.may" /></option><option value="6"><fmt:message key="cal.jun" /></option><option value="7"><fmt:message key="cal.jul" /></option><option value="8"><fmt:message key="cal.aug" /></option><option value="9"><fmt:message key="cal.sep" /></option><option value="10"><fmt:message key="cal.oct" /></option><option value="11"><fmt:message key="cal.nov" /></option><option value="12"><fmt:message key="cal.dec" /></option></select> <select id="s_y2"><c:forEach var="idx" begin="${min_year}" end="${max_year}" step="1"><option value="${idx}">${idx}</option></c:forEach></select></span> <span onmouseover="javascript:tooltip.show('${lang_sladisplay}')" onmouseout="javascript:tooltip.hide()"><img class="image" src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:fillClients()" /></span></div>
<span class="fl" onmouseover="javascript:tooltip.show('${lang_commonclickxls}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:window.open('${pageContext.request.contextPath}/excelnas')"><img class="image" src="../img/icon_excel.jpg" alt="${lang_commonclickxls}" /></span>
<span class="fl"><input type="checkbox" id="cb_compare" onchange="javascript:dispCompare()" checked="checked"> <fmt:message key="sla.compareon" /></span>
<span class="end"><fmt:message key="sla.decimale" /><select id="s_digit" onchange="javascript:fillClients()"><option value="1">1</option><option value="2">2</option><option value="3" selected="selected">3</option><option value="4">4</option><option value="5">5</option></select></span>
<input type="hidden" id="h_m1" />
<input type="hidden" id="h_m2" />
<input type="hidden" id="h_y1" />
<input type="hidden" id="h_y2" />
<hr />
<div id="stats" />
<div id="dlgcontent"/>
</c:otherwise>
</c:choose>
</body>
</html>
