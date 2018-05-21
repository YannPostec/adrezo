<%-- @Author: Yann POSTEC --%>
<%@ page contentType="application/vnd.ms-excel" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_stk.xls");%>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head><title><fmt:message key="stock.xls.stock" /></title>
<meta http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8" /></head><body>
<sql:query var="types">
	select ctx_name,site_name,cat,idx,def,seuil,stock,encours from stock_etat_display order by ctx_name,site_name,idx
</sql:query>
<table border="1">
<thead><tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.cat" /></th><th><fmt:message key="common.table.idx" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.stock" /></th><th><fmt:message key="common.table.threshold" /></th><th><fmt:message key="common.table.ongoing" /></th></tr></thead>
<tbody><c:forEach items="${types.rows}" var="type">
<tr>
<td>${type.CTX_NAME}</td>
<td>${type.SITE_NAME}</td>
<td>${type.CAT}</td>
<td>${type.IDX}</td>
<td>${type.DEF}</td>
<td align="center"><c:choose>
<c:when test="${type.STOCK < type.SEUIL}"><font color="red"><b>${type.STOCK}</b></font></c:when>
<c:otherwise>${type.STOCK}</c:otherwise>
</c:choose></td>
<td align="center">${type.SEUIL}</td>
<td align="center">${type.ENCOURS}</td>
</tr>
</c:forEach></tbody>
</table></body></html>
