<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.rezo}">
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="sla.device.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/sla_devices.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="devices">select * from sladevice_display order by client_name,site_name,name</sql:query>
<sql:query var="clients">select id,name from slaclient where id > 0 order by name</sql:query>
<sql:query var="sites">select id,name from slasite where id > 0 order by name</sql:query>
<sql:query var="plans">select * from slaplanning order by id</sql:query>
<div><fmt:message key="sla.device.list" /> :<br /><input type="checkbox" id="cb_unk" onchange="javascript:SearchUnknown()" /> <fmt:message key="sla.device.unaffect" /></div>
<table>
<thead><tr><th /><th><fmt:message key="common.table.client" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.cacti" /></th><th><fmt:message key="common.table.status" /></th><th><fmt:message key="sla.planning.plan" /></th></tr></thead>
<tbody id="mytable">
<c:forEach items="${devices.rows}" var="device">
<tr>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
<td><select style="display:none" onchange="javascript:FillSite(this,false)"><option><fmt:message key="common.select.client" /></option><c:forEach items="${clients.rows}" var="client"><option value="${client.ID}"<c:if test="${client.id == device.client}"> selected="selected"</c:if>>${client.name}</option></c:forEach></select><input type="hidden" value="${device.client}" />${device.client_name}</td>
<td><select style="display:none"><option><fmt:message key="common.select.site" /></option></select><input type="hidden" value="${device.site}" />${device.site_name}</td>
<td><input type="hidden" value="${device.ID}" />${device.name}</td>
<td>${device.cacti}</td>
<td><c:choose><c:when test="${device.status == 0}"><fmt:message key="sla.inactive" /></c:when><c:when test="${device.status == 1}"><fmt:message key="sla.active" /></c:when><c:when test="${device.status == 2}"><fmt:message key="sla.destroyed" /></c:when></c:choose></td>
<td><select style="display:none"><option><fmt:message key="common.select.plan" /></option><c:forEach items="${plans.rows}" var="plan"><option value="${plan.id}"<c:if test="${plan.id == device.plan}"> selected="selected"</c:if>>${plan.id}-<c:choose><c:when test="${plan.id == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${plan.name}</c:otherwise></c:choose></option></c:forEach></select><input type="hidden" value="${device.plan}" /><c:choose><c:when test="${device.plan == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${device.plan_name}</c:otherwise></c:choose></td></tr>
</c:forEach>
</tbody>
</table>
<div id="dlgcontent"/>
</body></html>
</c:if>
