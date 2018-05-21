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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.ctx}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose>
	<c:when test="${empty param.id}">
		<c:catch var="errInsert">
			<sql:update>
				INSERT INTO subnets (id,ctx,site,ip,mask,def,gw,bc,vlan)
				VALUES (${adrezo:dbSeqNextval('subnets_seq')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?, ?${adrezo:dbCast('INTEGER')}, ?, ?, ?, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.ctx}"/>
				<sql:param value="${param.site}"/>
				<sql:param value="${param.ip}"/>
				<sql:param value="${param.mask}"/>
				<sql:param value="${param.def}"/>
				<sql:param value="${param.gw}"/>
				<sql:param value="${param.bc}"/>
				<sql:param value="${param.vlan}"/>
			</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.subnet" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.subnet" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:catch var="errUpdate">
			<sql:transaction>
				<sql:update>
					UPDATE adresses
					SET site = ?${adrezo:dbCast('INTEGER')}
					WHERE subnet = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.site}"/>
					<sql:param value="${param.id}"/>
				</sql:update>
				<sql:update>
					UPDATE adresses
					SET site_mig = ?${adrezo:dbCast('INTEGER')}
					WHERE subnet_mig = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.site}"/>
					<sql:param value="${param.id}"/>
				</sql:update>
				<sql:update>
					UPDATE subnets
					SET def =?,
						gw = ?,
						bc = ?,
						ip = ?,
						mask = ?${adrezo:dbCast('INTEGER')},
						site = ?${adrezo:dbCast('INTEGER')},
						ctx = ?${adrezo:dbCast('INTEGER')},
						vlan = ?${adrezo:dbCast('INTEGER')}
					WHERE id = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.def}"/>
					<sql:param value="${param.gw}"/>
					<sql:param value="${param.bc}"/>
					<sql:param value="${param.ip}"/>
					<sql:param value="${param.mask}"/>
					<sql:param value="${param.site}"/>
					<sql:param value="${param.ctx}"/>
					<sql:param value="${param.vlan}"/>
					<sql:param value="${param.id}"/>
				</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.subnet" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.subnet" /> : <fmt:message key="common.ok" /></msg></c:set>
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
