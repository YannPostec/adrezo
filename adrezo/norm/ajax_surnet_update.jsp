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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.id}">
<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="errUpdate">
		<sql:update>
			UPDATE surnets
			SET def = ?,
				infos = ?,
				ip = ?,
				mask = ?${adrezo:dbCast('INTEGER')},
				calc = ?${adrezo:dbCast('INTEGER')}
			WHERE id = ?${adrezo:dbCast('INTEGER')}
			<sql:param value="${param.def}"/>
			<sql:param value="${param.infos}"/>
			<sql:param value="${param.ip}"/>
			<sql:param value="${param.mask}"/>
			<sql:param value="${param.calc}"/>
			<sql:param value="${param.id}"/>
		</sql:update>
	</c:catch>
	<c:choose>
		<c:when test="${errUpdate != null}">
			<adrezo:fileDB value="${errUpdate}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>	
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
