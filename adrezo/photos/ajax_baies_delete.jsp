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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.id && !empty param.box && !empty param.num && validUser.admin}">
<c:set var="message"><valid>true</valid></c:set>
<c:catch var="err">
<sql:transaction>
	<sql:update>
		delete from photo_baie where id = ?${adrezo:dbCast('INTEGER')}
		<sql:param value="${param.id}"/>
	</sql:update>
	<sql:update>
		update photo_baie set numero = numero - 1 where idbox = ?${adrezo:dbCast('INTEGER')} and numero > ?${adrezo:dbCast('INTEGER')}
		<sql:param value="${param.box}"/>
		<sql:param value="${param.num}"/>
	</sql:update>
</sql:transaction>
</c:catch>
<c:choose>
	<c:when test="${err != null}">
		<adrezo:fileDB value="${err}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.delete" /><fmt:message key="photo.rack" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.delete" /><fmt:message key="photo.rack" /> : <fmt:message key="common.ok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
