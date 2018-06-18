<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:message key="install.install" var="lang_install" />
<fmt:message key="install.retry" var="lang_retry" />
<fmt:message key="up.return" var="lang_return" />
<fmt:message key="common.error" var="lang_uperr" />
<fmt:message key="up.xml" var="lang_upxml" />
<c:set var="adrezoVersion" scope="application"><fmt:bundle basename="ypodev.adrezo.props.version" prefix="version."><fmt:message key="major" /><fmt:message key="minor" /><fmt:message key="revision" /></fmt:bundle></c:set>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Adrezo : Install</title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" charset="utf-8" src="../js/dbinstall.js"></script>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/update.css" type="text/css" />
</head>
<body>
<h2><fmt:message key="install.title" /> ${adrezoVersion}</h2>
<input type="hidden" id="errorTxt" value="${lang_uperr}" />
<input type="hidden" id="xmlTxt" value="${lang_upxml}" />
<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"><sql:query var="installs">select count(*) as install from user_tables</sql:query></c:if>
<c:if test="${adrezo:envEntry('db_type') == 'postgresql'}"><sql:query var="installs">select count(*) as install from pg_stat_user_tables</sql:query></c:if>
<c:choose>
	<c:when test="${installs.rows[0].install == 0}">
		<p><fmt:message key="install.list" /></p>
		<p><input type="checkbox" id="checkTable" checked="true" /> <fmt:message key="install.table" /></p>
		<p><input type="checkbox" id="checkPrimary" checked="true" /> <fmt:message key="install.primary" /></p>
		<p><input type="checkbox" id="checkView" checked="true" /> <fmt:message key="install.view" /></p>
		<p><input type="checkbox" id="checkData" checked="true" /> <fmt:message key="install.data" /></p>
		<p><input type="checkbox" id="checkForeign" checked="true" /> <fmt:message key="install.foreign" /></p>
		<p><input type="checkbox" id="checkSequence" checked="true" /> <fmt:message key="install.sequence" /></p>
		<p><input type="checkbox" id="checkTrigger" checked="true" /> <fmt:message key="install.trigger" /></p>
		<p><fmt:message key="install.warn" /></p>
		<div class="btn"><input type="button" value="${lang_install}" id="installBtn" onclick="javascript:installDB()" /></div>
		<div id="divtable" style="display:none;"><p class="ver"><fmt:message key="install.table" /></p></div>
		<div id="divprimary" style="display:none;"><p class="ver"><fmt:message key="install.primary" /></p></div>
		<div id="divview" style="display:none;"><p class="ver"><fmt:message key="install.view" /></p></div>
		<div id="divdata" style="display:none;"><p class="ver"><fmt:message key="install.data" /></p></div>
		<div id="divforeign" style="display:none;"><p class="ver"><fmt:message key="install.foreign" /></p></div>
		<div id="divsequence" style="display:none;"><p class="ver"><fmt:message key="install.sequence" /></p></div>
		<div id="divtrigger" style="display:none;"><p class="ver"><fmt:message key="install.trigger" /></p></div>
		<div class="btn"><input type="button" id="returnBtn" value="${lang_return}" onclick="javascript:returnLogin()" style="display:none;" /></div>
		<div class="btn"><input type="button" id="retryBtn" value="${lang_retry}" onclick="javascript:reloadPage()" style="display:none;" /></div>
	</c:when>
	<c:otherwise><p><fmt:message key="install.already" /></p><div class="btn"><input type="button" value="${lang_return}" onclick="javascript:returnLogin()" /></div></c:otherwise>
</c:choose>
</body>
</html>
