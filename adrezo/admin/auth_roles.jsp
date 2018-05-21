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
<fmt:message key="admin.role.rightnewctx" var="lang_rightsnewctx" />
<fmt:message key="admin.role.changerights" var="lang_changerights" />
<fmt:message key="admin.role.rightmgt" var="lang_rightmgt" />
<fmt:message key="admin.role.groupmapmgt" var="lang_groupmapmgt" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.role.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_auth_roles.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="roles">select * from auth_roles_display order by id</sql:query>
<sql:query var="annuaires">select * from auth_annu order by ordre</sql:query>
<sql:query var="contextes">select * from contextes order by name</sql:query>
<div><fmt:message key="admin.role.list" /> :</div>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.directory" /></th><th><fmt:message key="common.table.initctx" /></th><th><fmt:message key="common.table.newctx" /></th><th><fmt:message key="common.table.rights" /></th><th><fmt:message key="common.table.groupmap" /></th></tr>
<tr style="text-align:center">
	<td />
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="40" id="add_name" value="" /></td>
	<td><select id="add_annu"><option><fmt:message key="common.select.dir" /></option><c:forEach items="${annuaires.rows}" var="annu"><option value="${annu.id}">${annu.name}</option></c:forEach></select></td>
	<td><select id="add_ctx"><option><fmt:message key="common.select.ctx" /></option><c:forEach items="${contextes.rows}" var="ctx"><option value="${ctx.id}">${ctx.name}</option></c:forEach></select></td>
	<td style="text-align:center"><input type="text" size="3" id="add_new" value="0" /><span onmouseover="javascript:tooltip.show('${lang_rightsnewctx}')" onmouseout="javascript:tooltip.hide()" id="add_newspan"><img src="../img/icon_database.png" alt="${lang_rightsnewctx}" onclick="javascript:NewCtx(event,0)" /></span></td>
	<td><fmt:message key="admin.modaftercreate" /></td>
	<td><fmt:message key="admin.modaftercreate" /></td>
</tr>
</thead>
<tbody>
<c:forEach items="${roles.rows}" var="role">
<tr style="text-align:center">
	<td><c:if test="${role.id > 1}"><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${role.id})" /></span></c:if></td>
	<td style="text-align:center"><c:if test="${role.id > 1}"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></c:if></td>
	<td><input type="hidden" value="${role.id}" />${role.name}</td>
	<td><select style="display:none"><option><fmt:message key="common.select.dir" /></option><c:forEach items="${annuaires.rows}" var="annu"><option value="${annu.id}"<c:if test="${annu.id == role.annu}"> selected="selected"</c:if>>${annu.name}</option></c:forEach></select><input type="hidden" value="${role.annu}" />${role.annu_name}</td>
	<td><select style="display:none"><option><fmt:message key="common.select.ctx" /></option><c:forEach items="${contextes.rows}" var="ctx"><option value="${ctx.id}"<c:if test="${ctx.id == role.pref_ctx}"> selected="selected"</c:if>>${ctx.name}</option></c:forEach></select><input type="hidden" value="${role.pref_ctx}" />${role.pref_ctx_name}</td>
	<td>${role.new_ctx}<span onmouseover="javascript:tooltip.show('${lang_changerights}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_database.png" alt="${lang_changerights}" onclick="javascript:NewCtx(event,${role.new_ctx})" /></span></td>
	<td><c:if test="${role.id > 1}"><span onmouseover="javascript:tooltip.show('${lang_rightmgt}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_rightmgt}" onclick="javascript:RightsManage(${role.id},'${role.name}')" /></span></c:if></td>
	<td><c:if test="${role.annu > 0}">${role.grp}<span onmouseover="javascript:tooltip.show('${lang_groupmapmgt}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_groupmapmgt}" onclick="javascript:GroupMap(${role.id},'${role.name}','${role.annu_name}')" /></span></c:if></td>
</tr>
</c:forEach>
</tbody></table>
<div id="dlgcontent"/>
</body></html>
</c:if>
