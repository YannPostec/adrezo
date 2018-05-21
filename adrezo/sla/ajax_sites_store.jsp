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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose>
	<c:when test="${empty param.id}">
		<c:catch var="errInsert">
			<sql:update>
				INSERT INTO slasite (id,client,name,disp,plan)
				VALUES (${adrezo:dbSeqNextval('slasite_seq')}, ?${adrezo:dbCast('INTEGER')}, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.client}"/>
				<sql:param value="${param.name}"/>
				<sql:param value="${param.disp}"/>
				<sql:param value="${param.plan}"/>
			</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.site" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.site" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:catch var="errUpdate">
			<sql:transaction>
				<sql:update>
					update slasite
					set client = ?${adrezo:dbCast('INTEGER')},
						name = ?,
						disp = ?${adrezo:dbCast('INTEGER')},
						plan = ?${adrezo:dbCast('INTEGER')}
					where id = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.client}" />
   		  	<sql:param value="${param.name}" />
   		  	<sql:param value="${param.disp}" />
   		  	<sql:param value="${param.plan}" />
      		<sql:param value="${param.id}" />
				</sql:update>
				<sql:update>
					update sladevice
					set plan = ?${adrezo:dbCast('INTEGER')}
					where site = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.plan}" />
					<sql:param value="${param.id}" />
				</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.site" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.site" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>	
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
