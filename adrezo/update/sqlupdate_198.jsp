<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:choose>
	<c:when test="${pageContext.request.method == 'POST' && fn:contains(header.referer,'update.jsp') }">
		<c:set var="message"><valid>true</valid></c:set>
		<c:catch var="err">
			<sql:transaction>
				<c:choose>
				<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
					<sql:update>alter table schedulers add jobname varchar2(50)</sql:update>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<sql:update>alter table schedulers add jobname varchar(50)</sql:update>
				</c:when>
				</c:choose>
				<sql:update>update schedulers set jobname='PurgeUsersJob' where id=1</sql:update>
				<sql:update>update schedulers set jobname='PurgeSupplyMvtJob' where id=2</sql:update>
				<sql:update>update schedulers set jobname='PurgePhotosJob' where id=3</sql:update>
				<sql:update>update schedulers set jobname='MailTempIPJob' where id=4</sql:update>
				<sql:update>update schedulers set jobname='MailMigIPJob' where id=5</sql:update>
				<sql:update>update schedulers set jobname='NormAddSubnetJob' where id=6</sql:update>
				<sql:update>update schedulers set jobname='CactiDevicesJob' where id=7</sql:update>
				<sql:update>update schedulers set jobname='CactiStatsJob' where id=8</sql:update>
				<sql:update>update schedulers set jobname='CactiAggregateHoursJob' where id=9</sql:update>
				<sql:update>update schedulers set jobname='CactiAggregateDaysJob' where id=10</sql:update>
				<sql:update>update schedulers set jobname='DHCPJob' where id=11</sql:update>
				<c:choose>
				<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
					<sql:update>alter table schedulers modify jobname not null</sql:update>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<sql:update>alter table schedulers alter column jobname set not null</sql:update>
				</c:when>
				</c:choose>
				<sql:update>update usercookie set mail='199' where login='admin'</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${err != null}">
				<adrezo:fileDB value="${err}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><adrezo:trim value="${err}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:set var="message"><valid>false</valid></c:set>
	</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
