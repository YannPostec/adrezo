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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.id && !empty param.name}">
	<c:set var="message"><valid>true</valid></c:set>
	<sql:query var="plans">select * from slaplanning where id = ${param.id}</sql:query>
	<c:forEach items="${plans.rows}" var="plan">
		<c:catch var="errInsert">
				<sql:update>
					insert into slaplanning (id,name,h1,h2,h3,h4,h5,h6,h7)
					values (${adrezo:dbSeqNextval('slaplanning_seq')}, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
					<sql:param value="${param.name}"/>
					<sql:param value="${plan.h1}"/>
					<sql:param value="${plan.h2}"/>
					<sql:param value="${plan.h3}"/>
					<sql:param value="${plan.h4}"/>
					<sql:param value="${plan.h5}"/>
					<sql:param value="${plan.h6}"/>
					<sql:param value="${plan.h7}"/>
				</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.click.copy" /><fmt:message key="sla.planning.plan" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.click.copy" /><fmt:message key="sla.planning.plan" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:forEach>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
