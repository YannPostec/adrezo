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
<fmt:message key="common.click.api" var="lang_commonclickapi" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.api.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/admin_api.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_api.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
<sql:query var="users">select id,login from auth_users where role in (select distinct role from auth_rights where BITAND(rights,64)=64) and id > 0 order by login</sql:query>
</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
<sql:query var="users">select id,login from auth_users where role in (select distinct role from auth_rights where rights & 64 = 64) and id > 0 order by login</sql:query>
</c:when></c:choose>
<sql:query var="apis">select * from api order by login</sql:query>
<div><fmt:message key="admin.api.list" /> :</div>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.login" /></th><th><fmt:message key="admin.subnet.list" /></th><th><fmt:message key="common.table.choice" /></th></tr>
<tr style="text-align:center">
	<td />
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_usr" onchange="javascript:ResetMod()"><option><fmt:message key="common.select.user" /></option><c:forEach items="${users.rows}" var="user"><option value="${user.id}">${user.login}</option></c:forEach></select></td>
	<td><input type="text" size="30" id="add_sub" value="" disabled="disabled" /></td>
	<td><input type="hidden" id="add_update" value="" /><span onmouseover="javascript:tooltip.show('${lang_commonclickapi}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_commonclickapi}" onclick="javascript:subChange()" /></span></td>
</tr>
</thead>
<tbody>
<c:forEach items="${apis.rows}" var="api">
<tr style="text-align:center">
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${api.id})" /></span></td>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span></td>
	<td>${api.login}</td>
	<td>${api.subnets}</td>
	<td><input type="hidden" value="${api.id}" /></td>
</tr>
</c:forEach>
</tbody></table>
<div id="dlgcontent"/>
</body></html>
</c:if>
