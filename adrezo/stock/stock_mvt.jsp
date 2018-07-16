<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose><c:when test="${empty param.limit}"><c:set var="limit" value="20" /></c:when><c:otherwise><c:set var="limit" value="${param.limit}" /></c:otherwise></c:choose>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="stock.mvt.title" /></title>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<style type="text/css">
td.mvt {white-space:nowrap; text-align:center}
</style>
</head>
<body>
<table>
<thead><tr><th><fmt:message key="common.table.date" /></th><th><fmt:message key="common.table.cat" /></th><th><fmt:message key="common.table.idx" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="admin.user" /></th><th><fmt:message key="common.table.move" /></th><th><fmt:message key="common.table.inventory" /></th><th><fmt:message key="common.table.thresholdcross" /></th></tr></thead>
<tbody>
<c:if test="${!empty param.type}">
	<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
		<sql:query var="mvts">
			select * from (
				select idx,stamp,usr,mvt,invent,seuil,def,cat,rownum n from (
					select e.idx, m.stamp, m.usr, m.mvt, m.invent, m.seuil, e.def, e.cat
					from stock_etat_display e, stock_mvt m
					where m.id = e.id
					and e.id = ?
					order by m.stamp desc
			)) where n <= ?
			<sql:param value="${param.type}"/>
			<sql:param value="${limit}"/>
		</sql:query>
	</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">	
		<sql:query var="mvts">
			select e.idx, m.stamp, m.usr, m.mvt, m.invent, m.seuil, e.def, e.cat
			from stock_etat_display e, stock_mvt m
			where m.id = e.id
			and e.id = ?::INTEGER
			order by m.stamp desc
			limit ?::INTEGER
			<sql:param value="${param.type}"/>
			<sql:param value="${limit}"/>
		</sql:query>
	</c:when></c:choose>
	<c:choose>
	<c:when test="${mvts.rowCount != 0}">
		<c:forEach items="${mvts.rows}" var="mvt">
			<tr>
			<fmt:formatDate value="${mvt.STAMP}" type="both" pattern="dd/MM/yyyy HH:mm:ss" var="fmtStamp" scope="page" />
			<td class="mvt">${fmtStamp}</td>
			<td class="mvt">${mvt.CAT}</td>
			<td class="mvt">${mvt.IDX}</td>
			<td class="mvt">${mvt.DEF}</td>
			<td class="mvt">${mvt.USR}</td>
			<td class="mvt">${mvt.MVT}</td>
			<td class="mvt"><c:choose><c:when test="${mvt.INVENT == 1}"><fmt:message key="common.yes" /></c:when><c:when test="${mvt.INVENT == 2}"><fmt:message key="stock.reception" /></c:when></c:choose></td>
			<td class="mvt"><c:if test="${mvt.SEUIL == 1}"><fmt:message key="common.yes" /></c:if></td>
			</tr>
		</c:forEach>
	</c:when>
	<c:otherwise><tr><td colspan="8"><fmt:message key="stock.nomvt" /></td></tr></c:otherwise>
	</c:choose>
</c:if>
</tbody>
</table>
</body>
</html>
