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
<fmt:message key="admin.global.logo.back" var="lang_logoback" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.global.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/admin_csv.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/user_prefs.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_global.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="appctxs">select pref_ctx from auth_roles where id = 0</sql:query>
<sql:query var="applangs">select mail,lang from usercookie where login = 'admin'</sql:query>
<sql:query var="mails">select mail from auth_users where id = 0</sql:query>
<sql:query var="settings">select exppref,expsuff from settings</sql:query>
<sql:query var="langues">select * from langues order by code</sql:query>
<sql:query var="ctxs">select id,name from contextes order by name</sql:query>
Adrezo Version : ${applangs.rows[0].mail}
<h2><fmt:message key="admin.global.lang" /></h2>
<ul class="prefs"><c:forEach items="${langues.rows}" var="lang"><li><a <c:if test="${applangs.rows[0].lang == lang.code}">class="prefselect" </c:if>href="javascript:chgAppLang('${lang.code}');"><img src="${pageContext.request.contextPath}/img/flags/${lang.code}.png" /></a></li></c:forEach></ul>
<h2><fmt:message key="admin.global.ctx" /></h2>
<ul class="prefs"><c:forEach items="${ctxs.rows}" var="ctx"><li><a <c:if test="${appctxs.rows[0].pref_ctx == ctx.id}">class="prefselect" </c:if>href="javascript:chgAppCtx('${ctx.id}');">${ctx.name}</a></li></c:forEach></ul>
<h2><fmt:message key="admin.global.admin" /></h2>
<table><thead><tr><th /><th><fmt:message key="common.table.pwd" /></th><th><fmt:message key="common.table.mail" /></th></tr></thead>
<tbody><tr>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span></td>
<td><input type="password" size="20" id="adm_pwd" value="" /></td>
<td><input type="text" size="40" id="adm_mail" value="${mails.rows[0].mail}" /></td>
</tr></tbody></table>
<h2><fmt:message key="admin.global.url" /></h2>
<sql:query var="urls">select * from ipurl order by proto,port,uri</sql:query>
<table><thead>
<tr><th /><th /><th><fmt:message key="common.table.proto" /></th><th><fmt:message key="common.table.port" /></th><th><fmt:message key="common.table.uri" /></th></tr>
<tr><td /><td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
<td><input type="hidden" id="add_id" value="" /><input type="text" size="10" id="add_proto" value="" /></td>
<td><input type="text" size="10" id="add_port" value="" /></td>
<td><input type="text" size="100" id="add_uri" value="" /></td>
</tr>
</thead>
<tbody>
<c:forEach items="${urls.rows}" var="url">
<tr>
<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${url.id})" /></span></td>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
<td><input type="hidden" value="${url.ID}" />${url.proto}</td>
<td>${url.port}</td>
<td>${url.uri}</td>
</tr>
</c:forEach>
</tbody>
</table>
<h2><fmt:message key="admin.global.expaccount" /></h2>
<table><thead><tr><th /><th><fmt:message key="common.prefix" /></th><th><fmt:message key="common.suffix" /></th></tr></thead>
<tbody><tr>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:expaccSubmit()" /></span></td>
<td><input type="text" size="30" maxlength="20" id="adm_exppref" value="${settings.rows[0].exppref}" /></td>
<td><input type="text" size="30" maxlength="20" id="adm_expsuff" value="${settings.rows[0].expsuff}" /></td>
</tr></tbody></table>
<h2><fmt:message key="admin.global.maintenance" /></h2>
<ul class="prefs">
<li><a href="javascript:getDbLog()"><fmt:message key="admin.global.logdb" /></a></li>
<li><a href="javascript:getPhotoLog()"><fmt:message key="admin.global.logphoto" /></a></li>
<li><a href="javascript:getDefaultLog()"><fmt:message key="admin.global.logdefault" /></a></li>
<li><a href="javascript:getApiLog()"><fmt:message key="admin.global.logapi" /></a></li>
<li><a href="javascript:getBeansLog()"><fmt:message key="admin.global.logbeans" /></a></li>
<li><a href="javascript:getJspLog()"><fmt:message key="admin.global.logjsp" /></a></li>
<li><a href="javascript:getServletsLog()"><fmt:message key="admin.global.logservlets" /></a></li>
<li><a href="javascript:getListenerLog()"><fmt:message key="admin.global.loglistener" /></a></li>
<li><a href="javascript:getQuartzLog()"><fmt:message key="admin.global.logquartz" /></a></li>
<li><a href="javascript:getQuartzJobsLog()"><fmt:message key="admin.global.logjobs" /></a></li>
<li><a href="javascript:TestMySQL()"><fmt:message key="admin.global.mysql" /></a></li>
</ul>
<h2><fmt:message key="admin.global.logo" /></h2>
<img id="logoimg" src="../img/login_company.png" alt="logo" width="100" height="90" />
<p><fmt:message key="admin.global.logo.text" /></p>
<form method="POST" enctype="multipart/form-data" id="fUpload">
	<input type="hidden" name="type" id="upType" value="new" />
	<p><input type="file" size="40" name="file" id="upFile" /> <input id="upBtnUpload" type="button" value="Upload" onclick="javascript:submitUpload()" /></p>
	<progress class="progress" id="upProgress" value="0" max="100"></progress>
	<p class="upstatus" id="upStatus"></p>
	<p class="uperror" id="upError"></p>
	<p><input class="upreset" id="upBtnReset" type="button" value="Reset" onclick="javascript:resetUpload()" /></p>
	<p><input id="upBtnBack" type="button" value="${lang_logoback}" onclick="javascript:backUpload()" /></p>
</form>
<div id="dlgcontent"/>
</body></html>
</c:if>
