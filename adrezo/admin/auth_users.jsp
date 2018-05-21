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
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.user.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_auth_users.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="users">select * from auth_users_display where id > 0 order by login</sql:query>
<sql:query var="roles">select id,name from auth_roles where annu=0 order by name</sql:query>
<div><fmt:message key="admin.user.list" /> :</div>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.login" /></th><th><fmt:message key="common.table.pwd" /></th><th><fmt:message key="common.table.mail" /></th><th><fmt:message key="common.table.role" /></th><th><fmt:message key="common.table.authorization" /></th></tr>
<tr>
	<td />
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="20" id="add_login" value="" /></td>
	<td><input type="hidden" value="1" /><input type="password" size="20" id="add_pwd" value="" /></td>
	<td><input type="text" size="40" id="add_mail" value="" /></td>
	<td><select id="add_role"><option><fmt:message key="common.select.role" /></option><c:forEach items="${roles.rows}" var="role"><option value="${role.id}">${role.name}</option></c:forEach></select></td>
	<td><select id="add_auth"><option><fmt:message key="common.select.method" /></option><option value="0"><fmt:message key="admin.user.select.local" /></option><option value="1"><fmt:message key="admin.user.select.external" /></option></select></td>
</tr>
</thead>
<tbody>
<c:forEach items="${users.rows}" var="usr">
<tr style="text-align:center">
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${usr.id})" /></span></td>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
	<td><input type="hidden" value="${usr.id}" />${usr.login}</td>
	<td><input type="hidden" value="0" /></td>
	<td>${usr.mail}</td>
	<td><select style="display:none"><option><fmt:message key="common.select.role" /></option><c:forEach items="${roles.rows}" var="role"><option value="${role.id}"<c:if test="${role.id == usr.role}"> selected="selected"</c:if>>${role.name}</option></c:forEach></select><input type="hidden" value="${usr.role}" />${usr.role_name}</td>
	<td><select style="display:none"><option><fmt:message key="common.select.method" /></option><option value="0"<c:if test="${usr.auth == 0}"> selected="selected"</c:if>>Locale</option><option value="1"<c:if test="${usr.auth == 1}"> selected="selected"</c:if>>Externe</option></select><input type="hidden" value="${usr.auth}" /><c:if test="${usr.auth == 0}"><fmt:message key="admin.user.select.local" /></c:if><c:if test="${usr.auth == 1}"><fmt:message key="admin.user.select.external" /></c:if></td>
</tr>
</c:forEach>
</tbody></table>
<div id="dlgcontent"/>
</body></html>
</c:if>
