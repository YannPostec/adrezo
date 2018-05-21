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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.listIP && validUser.ip && !empty param.ctx}">
<c:set var="message"><valid>true</valid></c:set>
<c:catch var="errDelete">
	<sql:transaction>
		<sql:update>
			DELETE FROM adresses WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND IP in (select ip_mig from adresses where id in (${param.listIP}) and ip_mig is not null)
			<sql:param value="${param.ctx}"/>
		</sql:update>
		<sql:update>
			DELETE FROM adresses WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND ID in (${param.listIP})
			<sql:param value="${param.ctx}"/>
		</sql:update>
	</sql:transaction>
</c:catch>
<c:choose>
	<c:when test="${errDelete != null}">
		<adrezo:fileDB value="${errDelete}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.delete" /><fmt:message key="common.table.ip" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errDelete}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.delete" /><fmt:message key="common.table.ip" /> : <fmt:message key="common.ok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
