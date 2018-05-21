<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/csv" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_contexte.csv");%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<sql:query var="ctxs">select * from contextes order by id</sql:query>
<c:forEach items="${ctxs.rows}" var="ctx">CTX,${ctx.id},${ctx.name},${ctx.site_main}${newLineChar}</c:forEach>
