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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.box && validUser.admin}">
	<c:set var="message"><valid>true</valid></c:set>
	<sql:query var="baies">select numero from photo_baie where idbox = ${param.box} order by numero</sql:query>
	<c:forEach items="${baies.rows}" var="baie" varStatus="cptBaie">
		<c:set var="message">${message}<option><value>${baie.numero}</value><texte>${baie.numero}</texte></option></c:set>
		<c:set var="numero" value="${cptBaie.count}" />
	</c:forEach>
	<c:set var="message">${message}<option><value>${numero+1}</value><texte><fmt:message key="common.last" /></texte></option></c:set>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
