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
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.site.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/sla_sites.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="sites">select * from slasite_display where id > 0 order by client_name,name</sql:query>
<sql:query var="clients">select id,name from slaclient where id > 0 order by name</sql:query>
<sql:query var="plans">select * from slaplanning order by id</sql:query>
<div><fmt:message key="admin.site.list" /> :</div>
<table>
<thead>
<tr><th /><th /><th><fmt:message key="common.table.client" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.view" /></th><th><fmt:message key="sla.planning.plan" /></th></tr>
<tr><td /><td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
<td><select id="add_client"><option><fmt:message key="common.select.client" /></option><c:forEach items="${clients.rows}" var="client"><option value="${client.ID}">${client.name}</option></c:forEach></select></td>
<td><input type="hidden" id="add_id" value="" /><input type="text" size="40" id="add_name" value="" /></td>
<td><input type="checkbox" id="add_disp" checked="checked" /></td>
<td><select id="add_plan"><option><fmt:message key="common.select.plan" /></option><c:forEach items="${plans.rows}" var="plan"><option value="${plan.id}">${plan.id}-<c:choose><c:when test="${plan.id == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${plan.name}</c:otherwise></c:choose></option></c:forEach></select></td></tr>
</thead>
<tbody>
<c:forEach items="${sites.rows}" var="site">
<tr>
<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${site.ID})" /></span></td>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
<td><select style="display:none"><option><fmt:message key="common.select.client" /></option><c:forEach items="${clients.rows}" var="client"><option value="${client.ID}"<c:if test="${client.ID == site.CLIENT}"> selected="selected"</c:if>>${client.name}</option></c:forEach></select><input type="hidden" value="${site.CLIENT}" />${site.client_name}</td>
<td><input type="hidden" value="${site.ID}" />${site.name}</td>
<td><c:choose><c:when test="${site.DISP == 1}"><fmt:message key="common.yes" /></c:when><c:otherwise><fmt:message key="common.no" /></c:otherwise></c:choose></td>
<td><select style="display:none"><option><fmt:message key="common.select.plan" /></option><c:forEach items="${plans.rows}" var="plan"><option value="${plan.id}"<c:if test="${plan.id == site.plan}"> selected="selected"</c:if>>${plan.id}-<c:choose><c:when test="${plan.id == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${plan.name}</c:otherwise></c:choose></option></c:forEach></select><input type="hidden" value="${site.plan}" /><c:choose><c:when test="${site.plan == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${site.plan_name}</c:otherwise></c:choose></td></tr>
</c:forEach>
</tbody>
</table>
<div id="dlgcontent"/>
</body></html>
</c:if>
