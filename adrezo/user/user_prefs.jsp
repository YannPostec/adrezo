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
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="userprefs.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/user_prefs.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/user_prefs.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<c:if test="${validUser.login != 'admin'}">
<sql:query var="prefs">select ctx,lang,url,slidetime,macsearch from usercookie where login = '${validUser.login}'</sql:query>
<c:choose><c:when test="${prefs.rowCount == 0}"><h2><fmt:message key="userprefs.undefined" /></h2></c:when>
<c:otherwise>
	<sql:query var="langues">select * from langues order by code</sql:query>
	<sql:query var="ctxs">select id,name from contextes order by name</sql:query>
	<c:forEach items="${prefs.rows}" var="pref">
		<h2><fmt:message key="userprefs.lang" /></h2>
		<ul class="prefs"><c:forEach items="${langues.rows}" var="lang"><li><a <c:if test="${pref.lang == lang.code}">class="prefselect" </c:if>href="javascript:chgUsrLang('${lang.code}');"><img src="${pageContext.request.contextPath}/img/flags/${lang.code}.png" /></a></li></c:forEach></ul>
		<h2><fmt:message key="userprefs.ctx" /></h2>
		<ul class="prefs"><c:forEach items="${ctxs.rows}" var="ctx"><li><a <c:if test="${pref.ctx == ctx.id}">class="prefselect" </c:if>href="javascript:chgUsrCtx('${ctx.id}');">${ctx.name}</a></li></c:forEach></ul>
		<h2><fmt:message key="userprefs.url" /></h2>
		<ul class="prefs"><li><a <c:if test="${pref.url == 1}">class="prefselect" </c:if>href="javascript:chgUsrUrl(1)"><fmt:message key="common.enabled" /></a></li><li><a <c:if test="${pref.url == 0}">class="prefselect" </c:if>href="javascript:chgUsrUrl(0)"><fmt:message key="common.disabled" /></a></li></ul>
		<h2><fmt:message key="userprefs.mac" /></h2>
		<ul class="prefs"><li><a <c:if test="${pref.macsearch == 1}">class="prefselect" </c:if>href="javascript:chgUsrMac(1)"><fmt:message key="common.enabled" /></a></li><li><a <c:if test="${pref.macsearch == 0}">class="prefselect" </c:if>href="javascript:chgUsrMac(0)"><fmt:message key="common.disabled" /></a></li></ul>
		<h2><fmt:message key="userprefs.slideshow" /></h2>
		<fmt:message key="userprefs.slideshow.def" /> (ms) : <input type="text" id="slidetime" size="10" value="${pref.slidetime}" /><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:chgUsrSlideTime()" /></span>
	</c:forEach>
</c:otherwise>
</c:choose>
<sql:query var="pwds">select id from auth_users where auth=0 and login = '${validUser.login}' and id > 0</sql:query>
<c:forEach items="${pwds.rows}" var="pwd">
<h2><fmt:message key="userprefs.pwd" /></h2>
<table><thead><tr><th /><th><fmt:message key="common.table.pwd" /></th></tr></thead>
<tbody><tr>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span></td>
<td><input type="password" size="20" id="adm_pwd" value="" /></td>
</tr></tbody></table>
</c:forEach>
<div id="dlgcontent"/>
</c:if>
</body></html>
