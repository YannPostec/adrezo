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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.stock}">
<c:set var="message"><valid>true</valid></c:set>
<jsp:useBean id="today" class="java.util.Date" />
<c:choose>
	<c:when test="${param.inv == 'false'}"><c:set var="invent" value="0"/></c:when>
	<c:otherwise><c:set var="invent" value="1"/></c:otherwise>
</c:choose>
<c:catch var="err">
		<c:forEach items="${param}" var="curr">
			<c:if test="${fn:indexOf(curr.key,'var') != -1}">
				<c:set var="id">${fn:substringAfter(curr.key,'var')}</c:set>
				<sql:query var="infos">select stock,encours,seuil from stock_etat where id = ${id}</sql:query>
				<c:set var="newstock" value="${infos.rows[0].stock + curr.value}" />
				<c:set var="seuil" value="${infos.rows[0].seuil}" />
				<c:set var="encours" value="${infos.rows[0].encours}" />
				<sql:transaction>
					<sql:update>
						INSERT INTO STOCK_MVT	(ID, STAMP, USR, MVT, INVENT, SEUIL)
						VALUES(?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('TIMESTAMP')}, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
						<sql:param value="${id}"/>
						<sql:dateParam value="${today}"/>
						<sql:param value="${validUser.login}"/>
						<sql:param value="${curr.value}"/>
						<sql:param value="${invent}"/>
						<c:choose>
							<c:when test="${(newstock + encours) < seuil}"><sql:param value="1"/></c:when>
							<c:otherwise><sql:param value="0"/></c:otherwise>
						</c:choose>
					</sql:update>
					<c:if test="${newstock < 0}"><c:set var="newstock" value="0" /></c:if>
					<sql:update>
						UPDATE STOCK_ETAT
						SET STOCK = ?${adrezo:dbCast('INTEGER')}
						WHERE ID = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${newstock}"/>
						<sql:param value="${id}"/>
					</sql:update>
				</sql:transaction>
				<c:if test="${(newstock + encours) < seuil}">
					<jsp:useBean id="mail" scope="page" class="ypodev.adrezo.beans.MailBean">
						<jsp:setProperty name="mail" property="lang" value="${validUser.lang}" />
						<jsp:setProperty name="mail" property="tableId" value="${id}" />
						<jsp:setProperty name="mail" property="mailId" value="1" />
					</jsp:useBean>
					<c:set var="errMail" scope="page">${mail.erreur}</c:set>
					<c:set var="errMailLog" scope="page">${mail.errLog}</c:set>
					<c:remove var="mail"/>
				</c:if>
			</c:if>
		</c:forEach>
</c:catch>
<c:choose>
	<c:when test="${err != null}">
		<adrezo:fileDB value="${err}"/>
		<adrezo:logger exception="${err}"/>
		<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="stock.db" /> : <fmt:message key="common.error" />, <adrezo:trim value="${err}"/></msg></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="stock.update" /></c:set>
		<c:if test="${errMail}"><c:set var="message" scope="page">${message} <fmt:message key="stock.mail" /> ${errMailLog}</c:set></c:if>
		<c:set var="message" scope="page">${message}</msg></c:set>
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
