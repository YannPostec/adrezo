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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.id && !empty param.list}">
	<c:set var="message"><valid>true</valid></c:set>
	<c:choose>
		<c:when test="${param.list == '()'}">
			<c:catch var="errUpdate">
				<sql:update>
						UPDATE subnets set surnet = 0 where surnet = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${param.id}"/>
				</sql:update>
			</c:catch>
		</c:when>
		<c:otherwise>
			<c:catch var="errUpdate">
				<sql:transaction>
					<sql:update>
						UPDATE subnets set surnet = 0 where surnet = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${param.id}"/>
					</sql:update>
					<sql:update>
						UPDATE subnets SET surnet = ?${adrezo:dbCast('INTEGER')} WHERE id IN ${param.list}
						<sql:param value="${param.id}"/>
					</sql:update>
				</sql:transaction>
			</c:catch>
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${errUpdate != null}">
			<adrezo:fileDB value="${errUpdate}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="norm.surnet.update" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="norm.surnet.update" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>	
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
