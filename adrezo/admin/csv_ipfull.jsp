<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/csv" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_ipfull.csv");%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin}">
<sql:query var="ips">select * from adresses order by id</sql:query>
<c:forEach items="${ips.rows}" var="ip">IP,${ip.id},${ip.ctx},${ip.site},${ip.subnet},${ip.ip},${ip.mask},${ip.name},${ip.def},${ip.mac},${ip.type},${ip.usr_modif},${ip.date_modif},${ip.temp},${ip.usr_temp},${ip.date_temp},${ip.mig},${ip.usr_mig},${ip.date_mig},${ip.ip_mig},${ip.mask_mig},${ip.site_mig},${ip.subnet_mig}${newLineChar}</c:forEach>
</c:if>
