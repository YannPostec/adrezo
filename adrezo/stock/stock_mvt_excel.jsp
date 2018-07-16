<%-- @Author: Yann POSTEC --%>
<%@ page contentType="application/vnd.ms-excel" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_mvt.xls");%>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head><title><fmt:message key="stock.xls.mvt" /></title>
<meta http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8" /></head><body>
<sql:query var="mvts">
	select e.idx, m.stamp, m.usr, m.mvt, m.invent, m.seuil, e.def, e.cat, e.ctx_name, e.site_name
	from stock_etat_display e, stock_mvt m
	where m.id = e.id
	order by m.stamp desc
</sql:query>
<table border="1"><thead>
<tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.date" /></th><th><fmt:message key="common.table.cat" /></th><th><fmt:message key="common.table.idx" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="admin.user" /></th><th><fmt:message key="common.table.move" /></th><th><fmt:message key="common.table.inventory" /></th><th><fmt:message key="common.table.thresholdcross" /></th></tr></thead>
<tbody><c:forEach items="${mvts.rows}" var="mvt">
<tr>
	<td>${mvt.CTX_NAME}</td>
	<td>${mvt.SITE_NAME}</td>
	<fmt:formatDate value="${mvt.STAMP}" type="both" pattern="dd/MM/yyyy HH:mm:ss" var="fmtStamp" scope="page" />
	<td>${fmtStamp}</td>
	<td>${mvt.CAT}</td>
	<td align='center'>${mvt.IDX}</td>
	<td>${mvt.DEF}</td>
	<td align='center'>${mvt.USR}</td>
	<td align='center'>${mvt.MVT}</td>
	<td align='center'><c:choose><c:when test="${mvt.INVENT == 1}"><fmt:message key="common.yes" /></c:when><c:when test="${mvt.INVENT == 2}"><fmt:message key="stock.reception" /></c:when></c:choose></td>
	<td align='center'><c:if test="${mvt.SEUIL == 1}"><fmt:message key="common.yes" /></c:if></td>
</tr>
</c:forEach></tbody>
</table></body></html>
