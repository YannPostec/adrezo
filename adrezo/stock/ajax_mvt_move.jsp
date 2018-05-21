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
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.qty && !empty param.src && !empty param.dst && validUser.stockAdmin}">
	<c:set var="message"><valid>true</valid></c:set>
	<jsp:useBean id="today" class="java.util.Date" />
	<c:catch var="err">				
		<sql:query var="srcstk">select stock,seuil,encours from stock_etat where id = ${param.src}</sql:query>
		<sql:query var="dststk">select stock,seuil,encours from stock_etat where id = ${param.dst}</sql:query>
		<c:set var="newsrcstk" value="${srcstk.rows[0].stock - param.qty}" />
		<c:set var="srcvar" value="${0 - param.qty}" />
		<c:set var="newdststk" value="${dststk.rows[0].stock + param.qty}" />
		<c:set var="srcseuil" value="${srcstk.rows[0].seuil}" />
		<c:set var="srcencours" value="${srcstk.rows[0].encours}" />
		<c:set var="dstseuil" value="${dststk.rows[0].seuil}" />
		<c:set var="dstencours" value="${dststk.rows[0].encours}" />		
		<sql:transaction>
			<sql:update>
				insert into stock_mvt (id, stamp, usr, mvt, invent, seuil) values (?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('TIMESTAMP')}, ?, ?${adrezo:dbCast('INTEGER')}, 1, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.src}"/>
				<sql:dateParam value="${today}"/>
				<sql:param value="${validUser.login}"/>
				<sql:param value="${srcvar}"/>
				<c:choose>
					<c:when test="${(newsrcstk + srcencours) < srcseuil}"><sql:param value="1"/></c:when>
					<c:otherwise><sql:param value="0"/></c:otherwise>
				</c:choose>
			</sql:update>
			<c:if test="${newsrcstk < 0}"><c:set var="newsrcstk" value="0" /></c:if>
			<sql:update>
				insert into stock_mvt (id, stamp, usr, mvt, invent, seuil) values (?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('TIMESTAMP')}, ?, ?${adrezo:dbCast('INTEGER')}, 1, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.dst}"/>
				<sql:dateParam value="${today}"/>
				<sql:param value="${validUser.login}"/>
				<sql:param value="${param.qty}"/>
				<c:choose>
					<c:when test="${(newdststk + dstencours) < dstseuil}"><sql:param value="1"/></c:when>
					<c:otherwise><sql:param value="0"/></c:otherwise>
				</c:choose>
			</sql:update>
			<sql:update>
				update stock_etat
				set stock = ?${adrezo:dbCast('INTEGER')}
				where id = ?${adrezo:dbCast('INTEGER')}
				<sql:param value="${newsrcstk}"/>
				<sql:param value="${param.src}"/>
			</sql:update>
			<sql:update>
				update stock_etat
				set stock = ?${adrezo:dbCast('INTEGER')}
				where id = ?${adrezo:dbCast('INTEGER')}
				<sql:param value="${newdststk}"/>
				<sql:param value="${param.dst}"/>
			</sql:update>
		</sql:transaction>
		<c:if test="${(newsrcstk + srcencours) < srcseuil}">
			<jsp:useBean id="mail" scope="page" class="ypodev.adrezo.beans.MailBean">
				<jsp:setProperty name="mail" property="lang" value="${validUser.lang}" />
				<jsp:setProperty name="mail" property="tableId" value="${param.src}" />
				<jsp:setProperty name="mail" property="mailId" value="1" />
			</jsp:useBean>
			<c:set var="errMail" scope="page">${mail.erreur}</c:set>
			<c:set var="errMailLog" scope="page">${mail.errLog}</c:set>
			<c:remove var="mail"/>
		</c:if>
	</c:catch>
	<c:choose>
		<c:when test="${err != null}">
			<adrezo:fileDB value="${err}"/>
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
