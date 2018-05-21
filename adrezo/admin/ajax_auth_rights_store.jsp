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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.admin && !empty param.ctx && !empty param.role}">
	<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="err">
		<sql:transaction>
			<c:forEach items="${param.ctx}" var="ctx">
				<c:set var="rights" scope="page">r${ctx}</c:set>
				<sql:update>
					update auth_rights
					set rights = ?${adrezo:dbCast('INTEGER')}
					where ctx = ?${adrezo:dbCast('INTEGER')}
					and role = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param[rights]}" />
					<sql:param value="${ctx}" />
					<sql:param value="${param.role}" />
				</sql:update>
			</c:forEach>
		</sql:transaction>			
	</c:catch>
	<c:choose>
		<c:when test="${err != null}">
			<adrezo:fileDB value="${err}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authright" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authright" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
