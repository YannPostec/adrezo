<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.id && validUser.stockAdmin}">
<c:set var="message"><valid>true</valid></c:set>
<jsp:useBean id="today" class="java.util.Date" />
<c:catch var="err">
	<sql:transaction>
		<sql:update>
			UPDATE STOCK_ETAT
			SET STOCK = STOCK + ENCOURS,ENCOURS = 0
			WHERE ID = ?${adrezo:dbCast('INTEGER')}
			<sql:param value="${param.id}"/>
		</sql:update>
		<sql:update>
			INSERT INTO STOCK_MVT	(ID, STAMP, USR, MVT, INVENT, SEUIL)
			VALUES(?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('TIMESTAMP')}, ?, ?${adrezo:dbCast('INTEGER')}, 2, 0)
			<sql:param value="${param.id}"/>
			<sql:dateParam value="${today}"/>
			<sql:param value="${validUser.login}"/>
			<sql:param value="${param.ec}"/>
		</sql:update>
	</sql:transaction>
</c:catch>
<c:choose>
	<c:when test="${err != null}">
		<adrezo:fileDB value="${err}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="stock.reception" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="stock.recepok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
