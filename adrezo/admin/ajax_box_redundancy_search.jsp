<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.ctx && !empty param.key && !empty param.value && validUser.rezo}">
<c:set var="message"><valid>true</valid></c:set>
<sql:query var="ips">select id,name,ip,mask,subnet_name,site_name from adresses_display where ctx=${param.ctx} and lower(${param.key}) like lower('%${param.value}%')</sql:query>
<c:forEach items="${ips.rows}" var="ip">
	<c:set var="message">${message}<adr><id>${ip.id}</id><name>${ip.name}</name><ip>${ip.ip}</ip><mask>${ip.mask}</mask><subnet>${ip.subnet_name}</subnet><site>${ip.site_name}</site></adr></c:set>
</c:forEach>
</c:when>
<c:otherwise><c:set var="message"><valid>false</valid></c:set></c:otherwise></c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
