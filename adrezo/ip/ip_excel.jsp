<%-- @Author: Yann POSTEC --%>
<%@ page contentType="application/vnd.ms-excel" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${!empty param.type}">
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_ip.xls");%>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="ip.excel.title" /></title>
<meta http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8" />
</head>
<body>
<table border="1">
<thead><tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="common.table.type" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.ip" /></th><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="common.table.mac" /></th><th><fmt:message key="common.table.lastmodif" /></th><th><fmt:message key="common.table.temp" /></th><th><fmt:message key="common.table.mig" /></th><th><fmt:message key="common.table.ipfutur" /></th></tr></thead>
<sql:query var="adr">
	select * from adresses_display
	<c:if test="${param.type == 'contexte' || param.type == 'recherche'}">WHERE CTX = ${param.ctx}</c:if>
	<c:if test="${param.type == 'recherche' && !empty param.search}">AND ${param.search}</c:if>
	ORDER BY IP
</sql:query>
<tbody><c:forEach items="${adr.rows}" var="row">
	<tr>
	<td>${row.CTX_NAME}</td>
	<td>${row.TYPE}</td>
	<td>${row.SITE_NAME}</td>
	<td>${row.NAME}</td>
	<td>${row.DEF}</td>
	<td><adrezo:displayIP value="${row.IP}"/>/${row.MASK}</td>
	<td>${row.SUBNET_NAME}</td>
	<td>${row.MAC}</td>
	<fmt:formatDate value="${row.DATE_MODIF}" type="both" pattern="dd/MM/yyyy HH:mm:ss" var="fmtDateModif" scope="page" />
	<td>${row.USR_MODIF}, ${fmtDateModif}</td>
	<c:choose>
		<c:when test="${row.TEMP == 1}">
			<fmt:formatDate value="${row.DATE_TEMP}" type="date" pattern="dd/MM/yyyy" var="fmtDateTemp" scope="page" />
			<td><fmt:message key="common.yes" /> (${row.USR_TEMP}) <fmt:message key="common.space" />${fmtDateTemp}</td>
		</c:when>
		<c:otherwise><td><fmt:message key="common.no" /></td></c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${row.MIG == 1}">
			<fmt:formatDate value="${row.DATE_MIG}" type="date" pattern="dd/MM/yyyy" var="fmtDateMig" scope="page" />
			<td><fmt:message key="common.yes" /> (${row.USR_MIG}) <fmt:message key="common.space" />${fmtDateMig}</td>
			<td><adrezo:displayIP value="${row.IP_MIG}"/>/${row.MASK_MIG} (${row.SITE_MIG_NAME}/${row.SUBNET_MIG_NAME})</td>
		</c:when>
		<c:otherwise><td><fmt:message key="common.no" /></td><td>NON</td></c:otherwise>
	</c:choose>
	</tr>
</c:forEach></tbody>
</table>
</body></html>
</c:if>
