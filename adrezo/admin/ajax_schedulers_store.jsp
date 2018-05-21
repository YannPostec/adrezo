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
	<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.admin && !empty param.s1 && !empty param.s2 && !empty param.s3 && !empty param.s4 && !empty param.s5 && !empty param.d1 && !empty param.d2 && !empty param.s6 && !empty param.s7 && !empty param.s8 && !empty param.s9 && !empty param.s10 && !empty param.p8}">
	<c:set var="message"><valid>true</valid></c:set>
	<c:catch var="errUpdate">
		<sql:transaction>
			<sql:update>update schedulers set param = ?${adrezo:dbCast('INTEGER')}, enabled = ?${adrezo:dbCast('INTEGER')} where id=1<sql:param value="${param.d1}" /><sql:param value="${param.s1}" /></sql:update>
			<sql:update>update schedulers set param = ?${adrezo:dbCast('INTEGER')}, enabled = ?${adrezo:dbCast('INTEGER')} where id=2<sql:param value="${param.d2}" /><sql:param value="${param.s2}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=3<sql:param value="${param.s3}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=4<sql:param value="${param.s4}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=5<sql:param value="${param.s5}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=6<sql:param value="${param.s6}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=7<sql:param value="${param.s7}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')}, param = ?${adrezo:dbCast('INTEGER')} where id=8<sql:param value="${param.s8}" /><sql:param value="${param.p8}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=9<sql:param value="${param.s9}" /></sql:update>
			<sql:update>update schedulers set enabled = ?${adrezo:dbCast('INTEGER')} where id=10<sql:param value="${param.s10}" /></sql:update>
		</sql:transaction>
	</c:catch>
	<c:choose>
		<c:when test="${errUpdate != null}">
			<adrezo:fileDB value="${errUpdate}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.schedulers" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.schedulers" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
