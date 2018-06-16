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
<c:if test="${validUser.admin && !empty param.id && !empty param.name}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.dhcp.boxlist.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<sql:query var="exclusions">select * from dhcp_exclu where srv=${param.id} order by scope</sql:query>
<h2><fmt:message key="admin.dhcp.boxlist.text" /><fmt:message key="common.space" />${param.name}</h2>
<table>
	<thead><tr><th /><th><fmt:message key="common.table.scope" /></th></tr></thead>
	<tbody>
		<c:forEach items="${exclusions.rows}" var="exclu">
		<tr>
			<td style="text-align:center"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:listValid(${exclu.id})" /></td>
			<td>${exclu.scope}</td>
		</tr>
		</c:forEach>
	</tbody>
</table>
</body></html>
</c:if>
