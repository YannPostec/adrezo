<%-- @Author: Yann POSTEC --%>
<%@ page contentType="application/vnd.ms-excel" pageEncoding="UTF-8"  %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_stats.xls");%>
<!DOCTYPE html PUBLIC "-//W3C//Dtd XHTML 1.0 Transitional//EN" "http://www.w3.org/tr/xhtml1/Dtd/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml"><head><title><fmt:message key="sla.xls.title" /></title>
<meta http-equiv="Content-Type" content="application/vnd.ms-excel; charset=UTF-8" /></head><body>
<sql:query var="slas">select device_name,client_name,site_name,stamp,availability from slastats_display order by stamp,client_name,site_name,device_name</sql:query>
<fmt:message key="sla.title" />
<table border="1"><thead>
<tr><th><fmt:message key="common.table.date" /></th><th><fmt:message key="common.table.client" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.device" /></th><th><fmt:message key="common.table.dispo" /></th></tr></thead>
<tbody><c:forEach items="${slas.rows}" var="sla"><tr><td>${sla.STAMP}</td><td>${sla.CLIENT_NAME}</td><td>${sla.SITE_NAME}</td><td>${sla.DEVICE_NAME}</td><td>${sla.AVAILABILITY}</td></tr></c:forEach></tbody>
</table></body></html>
