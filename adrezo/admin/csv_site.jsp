<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/csv" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_site.csv");%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin}">
<sql:query var="sites">select * from sites order by id</sql:query>
<c:forEach items="${sites.rows}" var="site">SITE,${site.id},${site.ctx},${site.cod_site},${site.name}${newLineChar}</c:forEach>
</c:if>
