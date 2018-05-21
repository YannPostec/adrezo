<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.ip && !empty param.sub && validUser.ip}">
<c:set var="message"><valid>true</valid></c:set>
<jsp:useBean id="dispo" scope="request" class="ypodev.adrezo.beans.IpDispoBean">
	<jsp:setProperty name="dispo" property="subnet" param="sub"/>
	<jsp:setProperty name="dispo" property="startIP" param="start"/>
	<jsp:setProperty name="dispo" property="nbIP" param="ip"/>
</jsp:useBean>
<c:choose>
	<c:when test="${dispo.erreur}"><c:set var="message">${message}<erreur>true</erreur><msg>${dispo.errLog}</msg></c:set></c:when>
	<c:otherwise><c:set var="message">${message}<erreur>false</erreur><listeip>${dispo.ipFinal}</listeip></c:set></c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
