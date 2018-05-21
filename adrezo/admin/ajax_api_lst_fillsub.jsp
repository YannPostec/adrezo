<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.id && !empty param.type && validUser.rezo}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose><c:when test="${param.type == 'site'}"><sql:query var="subnets">select id,ip,mask,def from subnets where site=${param.id} order by def</sql:query></c:when>
<c:otherwise><sql:query var="subnets">select id,ip,mask,def from subnets where ctx=${param.id} order by def</sql:query></c:otherwise></c:choose>
<c:forEach items="${subnets.rows}" var="subnet">
	<c:set var="message">${message}<option><value>${subnet.id}</value><texte>${subnet.def} (<adrezo:displayIP value="${subnet.ip}" />/${subnet.mask})</texte></option></c:set>
</c:forEach>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
