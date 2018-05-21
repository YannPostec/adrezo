<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.site && validUser.rezo}">
<c:set var="message"><valid>true</valid></c:set>
<sql:query var="vlans">select id,vid,def from vlan where site= ${param.site} order by vid</sql:query>
<c:forEach items="${vlans.rows}" var="vlan">
	<c:set var="message">${message}<option><value>${vlan.ID}</value><texte>${vlan.VID} : ${vlan.DEF}</texte></option></c:set>
</c:forEach>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
