<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin}">
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<fmt:message key="admin.directory.config" var="lang_annuconfig" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.directory.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_auth_annu.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="annuaires">select * from auth_annu_display order by ordre</sql:query>
<sql:query var="types">select * from auth_annu_types where id > 0 order by id</sql:query>
<p><fmt:message key="admin.directory.warn" /></p>
<div><fmt:message key="admin.directory.list" /> :</div>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.order" /></th><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.config" /></th></tr>
<tr style="text-align:center">
	<td />
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="40" id="add_name" value="" /></td>
	<td><input type="text" size="3" id="add_ordre" value="" /></td>
	<td><select id="add_type"><option><fmt:message key="common.select.type" /></option><c:forEach items="${types.rows}" var="type"><option value="${type.id}">${type.name}</option></c:forEach></select></td>
	<td><fmt:message key="admin.modaftercreate" /></td>
</tr>
</thead>
<tbody>
<c:forEach items="${annuaires.rows}" var="annu">
<tr style="text-align:center">
	<td><c:if test="${annu.id > 0}"><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${annu.id})" /></span></c:if></td>
	<td><c:if test="${annu.id > 0}"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></c:if></td>
	<td><input type="hidden" value="${annu.id}" />${annu.name}</td>
	<td>${annu.ordre}</td>
	<td><select style="display:none"><option><fmt:message key="common.select.type" /></option><c:forEach items="${types.rows}" var="type"><option value="${type.id}"<c:if test="${type.id == annu.type}"> selected="selected"</c:if>>${type.name}</option></c:forEach></select><input type="hidden" value="${annu.type}" />${annu.type_name}</td>
	<td><c:if test="${annu.id > 0}"><span onmouseover="javascript:tooltip.show('${lang_annuconfig}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_annuconfig}" onclick="javascript:AnnuConfig(${annu.id},${annu.type},'${annu.name}')" /></span></c:if></td>
</tr>
</c:forEach>
</tbody></table>
<div id="dlgcontent"/>
</body></html>
</c:if>
