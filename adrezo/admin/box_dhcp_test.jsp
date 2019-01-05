<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin && !empty param.id}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.dhcp.test" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<jsp:useBean id="mytest" scope="page" class="ypodev.adrezo.beans.TestDHCPServerBean">
	<c:set target="${mytest}" property="myid" value="${param.id}" />
	<c:set target="${mytest}" property="lang" value="${validUser.lang}" />
</jsp:useBean>
<c:choose>
	<c:when test="${mytest.erreur}">
		<h3><fmt:message key="admin.dhcp.test.error" /></h3>
		<p>${mytest.errLog}</p>
	</c:when>
	<c:otherwise>
		<h3><fmt:message key="admin.dhcp.test.ok" /></h3>
	</c:otherwise>
</c:choose>
</body>
</html>
<c:remove var="mytest" scope="page" />
</c:if>
