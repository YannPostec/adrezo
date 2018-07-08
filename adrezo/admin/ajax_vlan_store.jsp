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
				INSERT INTO vlan (id,vid,def,site)
				VALUES (${adrezo:dbSeqNextval('vlan_seq')}, ?${adrezo:dbCast('INTEGER')}, ?, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.vid}"/>
				<sql:param value="${param.def}"/>
				<sql:param value="${param.site}"/>
			</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<sql:query var="sites">select site from vlan where id = ${param.id}</sql:query>
		<c:choose>
		<c:when test="${sites.rows[0].site == param.site}">
			<c:catch var="errUpdate">
				<sql:update>
					UPDATE vlan
					SET vid = ?${adrezo:dbCast('INTEGER')},
							def = ?
					WHERE id = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.vid}" />
			    <sql:param value="${param.def}" />
     			<sql:param value="${param.id}" />
				</sql:update>
			</c:catch>
		</c:when>
		<c:otherwise>
			<sql:query var="novlan">Select id from vlan where vid=0 and site in (select site from vlan where id = ${param.id})</sql:query>
			<c:catch var="errUpdate">
				<c:forEach items="${novlan.rows}" var="nov">
					<sql:transaction>
						<sql:update>
							UPDATE subnets
							SET vlan = ?${adrezo:dbCast('INTEGER')}
							WHERE vlan = ?${adrezo:dbCast('INTEGER')}
							<sql:param value="${nov.ID}" />
							<sql:param value="${param.id}" />
						</sql:update>
						<sql:update>
							UPDATE vlan
							SET vid = ?${adrezo:dbCast('INTEGER')},
									def = ?,
									site = ?${adrezo:dbCast('INTEGER')}
							WHERE id = ?${adrezo:dbCast('INTEGER')}
							<sql:param value="${param.vid}" />
			  		  <sql:param value="${param.def}" />
  					  <sql:param value="${param.site}" />
     					<sql:param value="${param.id}" />
						</sql:update>
					</sql:transaction>
				</c:forEach>
			</c:catch>
		</c:otherwise>
		</c:choose>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.vlan" /> : <fmt:message key="common.ok" /></msg></c:set>
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
