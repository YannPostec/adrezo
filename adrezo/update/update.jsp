<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<sql:query var="applangs">select mail,lang from usercookie where login = 'admin'</sql:query>
<fmt:setLocale value="${applangs.rows[0].lang}" scope="session" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:set var="adrezoVersion"><fmt:bundle basename="ypodev.adrezo.props.version" prefix="version."><fmt:message key="major" /><fmt:message key="minor" /><fmt:message key="revision" /></fmt:bundle></c:set>
<c:set var="dbVersion" value="${applangs.rows[0].mail}" />
<fmt:message key="up.update" var="lang_upupdate" />
<fmt:message key="up.return" var="lang_upreturn" />
<fmt:message key="up.process" var="lang_upprocess" />
<fmt:message key="common.error" var="lang_uperr" />
<fmt:message key="up.xml" var="lang_upxml" />
<fmt:message key="up.pwd" var="lang_uppwd" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Adrezo : Update</title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" charset="utf-8" src="../js/dbupdate.js"></script>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/update.css" type="text/css" />
</head>
<body>
<p><fmt:message key="up.db" />${dbVersion}</p>
<p><fmt:message key="up.app" />${adrezoVersion}</p>
<c:choose>
<c:when test="${adrezoVersion > dbVersion}">
	<c:set var="listVersion"><adrezo:updateVersion begin="${dbVersion}" end="${adrezoVersion}" /></c:set>
	<p><fmt:message key="up.credentials" /> : <input type="password" size="15" id ="upPwd" value="" maxlength="30" onkeypress="return handleEnter(this,event,'${listVersion}')" /></p>
	<p class="err" id="errorP"></p>
	<div class="btn"><input type="button" value="${lang_upupdate}" id="upBtn" onclick="javascript:updateDB('${listVersion}')" /></div>
</c:when>
<c:otherwise>
	<p><fmt:message key="up.already" /></p>
	<div class="btn"><input type="button" value="${lang_upreturn}" onclick="javascript:returnLogin()" /></div>
</c:otherwise>
</c:choose>
<input type="hidden" id="processTxt" value="${lang_upprocess}" />
<input type="hidden" id="errorTxt" value="${lang_uperr}" />
<input type="hidden" id="xmlTxt" value="${lang_upxml}" />
<input type="hidden" id="pwdTxt" value="${lang_uppwd}" />
<div id="upResult"></div>
<div class="btn"><input type="button" id="returnBtn" value="${lang_upreturn}" onclick="javascript:returnLogin()" style="display:none;"/></div>
</body>
</html>
