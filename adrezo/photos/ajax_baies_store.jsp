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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.admin}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose>
	<c:when test="${empty param.id}">
		<c:catch var="errInsert">
			<sql:transaction>
				<sql:update>
					update photo_baie set numero = numero + 1 where idbox = ?${adrezo:dbCast('INTEGER')} and numero >= ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.box}"/>
					<sql:param value="${param.num}"/>
				</sql:update>
				<sql:update>
					insert into photo_baie (id,idbox,name,numero) values (${adrezo:dbSeqNextval('photo_baie_seq')}, ?${adrezo:dbCast('INTEGER')}, ?, ?${adrezo:dbCast('INTEGER')})
					<sql:param value="${param.box}"/>
					<sql:param value="${param.name}"/>
					<sql:param value="${param.num}"/>
				</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="photo.rack" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="photo.rack" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:catch var="errUpdate">
			<sql:transaction>
				<sql:query var="oldboxs">select idbox,numero from photo_baie where id = ${param.id}</sql:query>
				<sql:update>
					update photo_baie set numero = numero - 1 where idbox = ?${adrezo:dbCast('INTEGER')} and numero > ?${adrezo:dbCast('INTEGER')}
					<c:choose>
						<c:when test="${param.box != oldboxs.rows[0].idbox}"><sql:param value="${oldboxs.rows[0].idbox}"/></c:when>
						<c:otherwise><sql:param value="${param.idbox}"/></c:otherwise>
					</c:choose>
					<sql:param value="${oldboxs.rows[0].numero}"/>
				</sql:update>
				<sql:update>
					update photo_baie set numero = numero + 1 where id != ?${adrezo:dbCast('INTEGER')} and idbox = ?${adrezo:dbCast('INTEGER')} and numero >= ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.id}"/>
					<sql:param value="${param.box}"/>
					<sql:param value="${param.num}"/>
				</sql:update>
				<sql:update>
					update photo_baie set name = ?,idbox = ?${adrezo:dbCast('INTEGER')},numero = ?${adrezo:dbCast('INTEGER')}	where id = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.name}"/>
					<sql:param value="${param.box}"/>
					<sql:param value="${param.num}"/>
					<sql:param value="${param.id}"/>
				</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="photo.rack" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="photo.rack" /> : <fmt:message key="common.ok" /></msg></c:set>
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
