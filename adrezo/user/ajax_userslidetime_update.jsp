<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.st}">
	<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="errUpdate">
		<sql:update>
			update usercookie set slidetime = ?${adrezo:dbCast('INTEGER')} where login = ?
			<sql:param value="${param.st}"/>
			<sql:param value="${validUser.login}"/>
		</sql:update>
	</c:catch>
	<c:choose>
		<c:when test="${errUpdate != null}">
			<adrezo:fileDB value="${errUpdate}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="userprefs.slideshow.timeout" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="userprefs.slideshow.timeout" /> : <fmt:message key="common.ok" /></msg></c:set>
			<c:set target="${validUser}" property="slidetime" value="${param.st}" />
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
