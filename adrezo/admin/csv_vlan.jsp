<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/csv" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%response.setHeader("Content-Disposition", "attachment; filename=adrezo_vlan.csv");%>
<% pageContext.setAttribute("newLineChar", "\n"); %>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<sql:query var="vlans">select * from vlan order by id</sql:query>
<c:forEach items="${vlans.rows}" var="vlan">VLAN,${vlan.id},${vlan.site},${vlan.vid},${vlan.def}${newLineChar}</c:forEach>
