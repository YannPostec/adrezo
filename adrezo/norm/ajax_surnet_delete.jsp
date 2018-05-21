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
<c:catch var="err">
<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
	<sql:update>
		delete from surnets where id in (select id from surnets start with id = ? connect by prior id = parent)
		<sql:param value="${param.id}"/>
	</sql:update>
</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
	<sql:update>
		delete from surnets where id in (with recursive pgprior as (select id, 1 as level from surnets where id = ?::INTEGER union all select s.id, pg.level + 1 from pgprior pg join surnets s on s.parent = pg.id) select id from pgprior order by level)
		<sql:param value="${param.id}"/>
	</sql:update>
</c:when></c:choose>
</c:catch>
<c:choose>
	<c:when test="${err != null}">
		<adrezo:fileDB value="${err}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.delete" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.delete" /><fmt:message key="norm.surnet" /> : <fmt:message key="common.ok" /></msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
