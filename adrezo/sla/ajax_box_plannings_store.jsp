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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.id && !empty param.h1 && !empty param.h2 && !empty param.h3 && !empty param.h4 && !empty param.h5 && !empty param.h6 && !empty param.h7 && param.id > 0 }">
	<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="err">
		<sql:update>
			update slaplanning
			set h1 = ?${adrezo:dbCast('INTEGER')},
				h2 = ?${adrezo:dbCast('INTEGER')},
				h3 = ?${adrezo:dbCast('INTEGER')},
				h4 = ?${adrezo:dbCast('INTEGER')},
				h5 = ?${adrezo:dbCast('INTEGER')},
				h6 = ?${adrezo:dbCast('INTEGER')},
				h7 = ?${adrezo:dbCast('INTEGER')}
			where id = ?${adrezo:dbCast('INTEGER')}
			<sql:param value="${param.h1}" />
			<sql:param value="${param.h2}" />
			<sql:param value="${param.h3}" />
			<sql:param value="${param.h4}" />
			<sql:param value="${param.h5}" />
			<sql:param value="${param.h6}" />
			<sql:param value="${param.h7}" />
			<sql:param value="${param.id}" />
		</sql:update>
	</c:catch>
	<c:choose>
		<c:when test="${err != null}">
			<adrezo:fileDB value="${err}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="sla.planning.box.save" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="sla.planning.box.save" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
