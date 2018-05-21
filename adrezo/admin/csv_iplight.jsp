<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/csv" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_iplight.csv");%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<sql:query var="ips">select id,ctx,site,subnet,ip,mask,name,def,mac from adresses order by id</sql:query>
<c:forEach items="${ips.rows}" var="ip">IP,${ip.id},${ip.ctx},${ip.site},${ip.subnet},${ip.ip},${ip.mask},${ip.name},${ip.def},${ip.mac}${newLineChar}</c:forEach>
