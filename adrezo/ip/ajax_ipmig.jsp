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
<jsp:useBean id="now" class="java.util.Date" />
<c:catch var="errMig">
<sql:transaction>
	<sql:update>
		DELETE FROM adresses WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND IP in (select ip_mig from adresses where id in (${param.listIP}))
		<sql:param value="${param.ctx}"/>
	</sql:update>
	<sql:update>
		UPDATE ADRESSES
		SET	IP = ip_mig,
			MASK = mask_mig,
			SUBNET = subnet_mig,
			SITE = site_mig,
			MIG = 0,
			USR_MIG = NULL,
			DATE_MIG = NULL,
			IP_MIG = NULL,
			MASK_MIG = NULL,
			SUBNET_MIG = NULL,
			SITE_MIG = NULL,
			USR_MODIF = ?,
			DATE_MODIF = ?${adrezo:dbCast('TIMESTAMP')}
		WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND ID in (${param.listIP})
		<sql:param value="${validUser.login}"/>
		<sql:dateParam value="${now}" />
		<sql:param value="${param.ctx}"/>
	</sql:update>
</sql:transaction>
</c:catch>
<c:choose>
	<c:when test="${errMig != null}">
		<adrezo:fileDB value="${errMig}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="common.table.ip" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errMig}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="common.table.ip" /> : <fmt:message key="common.ok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
