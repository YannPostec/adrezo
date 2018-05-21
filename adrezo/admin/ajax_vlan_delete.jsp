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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.id && validUser.rezo}">
<c:set var="message"><valid>true</valid></c:set>
<sql:query var="novlan">SELECT id from vlan where vid=0 and site in (select site from vlan where id = ${param.id})</sql:query>
<c:catch var="err">
	<c:forEach items="${novlan.rows}" var="nov">
		<sql:transaction>
			<sql:update>
				UPDATE subnets
				SET vlan = ?${adrezo:dbCast('INTEGER')}
				WHERE vlan = ?${adrezo:dbCast('INTEGER')}
				<sql:param value="${nov.ID}"/>
				<sql:param value="${param.id}"/>
			</sql:update>
			<sql:update>
				DELETE FROM vlan
				WHERE ID = ?${adrezo:dbCast('INTEGER')}
				<sql:param value="${param.id}"/>
			</sql:update>
		</sql:transaction>
	</c:forEach>
</c:catch>
<c:choose>
	<c:when test="${err != null}">
		<adrezo:fileDB value="${err}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.delete" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.delete" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.ok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
