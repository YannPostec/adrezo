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
<c:if test="${validUser.template && !empty param.id}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="template.boxsiteview.title" /> ${param.id}</title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<sql:query var="sites">select * from tpl_site where id = ${param.id}</sql:query>
<sql:query var="subnets">select * from tpl_subnet where tpl = ${param.id}</sql:query>
<sql:query var="vlans">select * from tpl_vlan where tpl = ${param.id}</sql:query>
<h2><fmt:message key="template.boxsiteview.title" />&nbsp;${param.id}</h2>
<c:forEach items="${sites.rows}" var="site">
<p>
<fmt:message key="common.table.name" /> : ${site.name}<br />
<fmt:message key="common.table.mask" /> : ${site.mask}
</p>
</c:forEach>
<hr />
<h2><fmt:message key="admin.vlan.list" /></h2>
<table><thead><tr><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.vid" /></th></tr></thead><tbody>
<c:forEach items="${vlans.rows}" var="vlan">
<tr>
	<td>${vlan.def}</td>
	<td style="text-align:center">${vlan.vid}</td>
</tr>
</c:forEach>
</tbody></table>
<hr />
<h2><fmt:message key="admin.subnet.list" /></h2>
<table><thead><tr><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.ip" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="common.table.ipgw" /></th></tr></thead><tbody>
<c:forEach items="${subnets.rows}" var="subnet">
<tr>
	<td>${subnet.def}</td>
	<td><adrezo:displayIP value="${subnet.ip}" /></td>
	<td style="text-align:center">${subnet.mask}</td>
	<td>${subnet.gw}</td>
</tr>
</c:forEach>
</tbody></table>
<p>&nbsp;</p>
</body></html>
</c:if>
