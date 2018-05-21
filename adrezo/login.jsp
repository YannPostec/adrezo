<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<c:remove var="validUser" scope="session"/>
<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"><sql:query var="installs">select count(*) as install from user_tables</sql:query></c:if>
<c:if test="${adrezo:envEntry('db_type') == 'postgresql'}"><sql:query var="installs">select count(*) as install from pg_stat_user_tables</sql:query></c:if>
<c:if test="${installs.rows[0].install == 0}"><c:redirect url="/update/install.jsp" /></c:if>
<sql:query var="applangs">select mail,lang from usercookie where login = 'admin'</sql:query>
<c:choose><c:when test="${applangs.rowCount !=0}"><fmt:setLocale value="${applangs.rows[0].lang}" scope="session" /></c:when>
<c:otherwise><fmt:setLocale value="fr" scope="session" /></c:otherwise></c:choose>
<c:set var="dbVersion" value="${applangs.rows[0].mail}" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:setBundle basename="ypodev.adrezo.props.version" var="bunver"/>
<c:set var="adrezoVersion"><fmt:message key="adrezo.version" bundle="${bunver}" /></c:set>
<c:set var="versionFull"><fmt:bundle basename="ypodev.adrezo.props.version" prefix="version."><fmt:message key="major" /><fmt:message key="minor" /><fmt:message key="revision" /></fmt:bundle></c:set>
<c:if test="${versionFull > dbVersion}"><c:redirect url="/update/update.jsp" /></c:if>
<c:set var="errorVersion"><c:choose><c:when test="${versionFull < dbVersion}">true</c:when><c:otherwise>false</c:otherwise></c:choose></c:set>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Adrezo : Login</title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" charset="utf-8" src="${pageContext.request.contextPath}/js/login.js"></script>
<link rel="stylesheet" href="${pageContext.request.contextPath}/stylesheet/login.css" type="text/css" />
</head>
<body onload="document.getElementById('login').focus()">
<form method="post" action="${pageContext.request.contextPath}/loginAction.jsp" id="fCnx">
<input type="hidden" name="origURL" value='<c:out value="${param.origURL}" escapeXml="true"/>' />
<img class="company" src="${pageContext.request.contextPath}/img/login_company.png" border="0" alt="Company" />
<div class="logo">
	<p class="name">ADREZO</p>
	<p class="version">${adrezoVersion}</p>
	<p class="login">Login:</p>
	<input type="text" size="15" id ="login" name="login" value="" maxlength="30" class="login" onkeypress="return handleEnter(this,event,${errorVersion})" />
	<p class="pwd">Password:</p>
	<input type="password" size="15" id ="pwd" name="pwd" value="" maxlength="30" class="pwd" onkeypress="return handleEnter(this,event,${errorVersion})" />
	<img class="login" src="${pageContext.request.contextPath}/img/enter.gif" border="0" alt="Entrer" onclick="javascript:cnxSubmit(${errorVersion})" />
	<c:choose>
		<c:when test="${!empty param.errorKey}">
			<p class="error"><fmt:message key="${param.errorKey}" /></p>
		</c:when>
		<c:when test="${!empty param.errorMsg}">
			<p class="error">${param.errorMsg}</p>
		</c:when>
		<c:otherwise>
			<p class="comment"><fmt:message key="login.first" /></p>
			</c:otherwise>
	</c:choose>
	<noscript><p class="error"><fmt:message key="login.js" /></p></noscript>
</div>
</form>
<p class="browser" id="browserTest" style="display:none;"><fmt:message key="login.browser" /></p>
<p class="errver" id="versionTest" style="display:none;"><fmt:message key="login.version" /></p>
</body>
</html>
