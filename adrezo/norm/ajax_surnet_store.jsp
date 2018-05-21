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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.parent}">
<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="errInsert">
		<sql:update>
			INSERT INTO surnets (id,ip,mask,def,infos,parent,calc)
			VALUES (${adrezo:dbSeqNextval('surnets_seq')}, ?, ?${adrezo:dbCast('INTEGER')}, ?, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
			<sql:param value="${param.ip}"/>
			<sql:param value="${param.mask}"/>
			<sql:param value="${param.def}"/>
			<sql:param value="${param.infos}"/>
			<sql:param value="${param.parent}"/>
			<sql:param value="${param.calc}"/>
		</sql:update>
	</c:catch>
	<c:choose>
		<c:when test="${errInsert != null}">
			<adrezo:fileDB value="${errInsert}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
