<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.csv.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/admin_csv.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_csv.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="admin.csv.export" /></h2>
<table>
<thead><tr><th><fmt:message key="common.table.table" /></th><th /></tr></thead>
<tbody>
<tr><td><fmt:message key="admin.ctx" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_ctx.jsp')" /></td></tr>
<tr><td><fmt:message key="admin.site" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_site.jsp')" /></td></tr>
<tr><td><fmt:message key="admin.vlan" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_vlan.jsp')" /></td></tr>
<tr><td><fmt:message key="admin.subnet" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_subnet.jsp')" /></td></tr>
<tr><td><fmt:message key="admin.csv.ipimport" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_iplight.jsp')" /></td></tr>
<tr><td><fmt:message key="admin.csv.ipfull" /></td><td><input type="button" value="Export" onclick="javascript:window.open('${pageContext.request.contextPath}/admin/csv_ipfull.jsp')" /></td></tr>
</tbody>
</table>
<hr />
<h2><fmt:message key="admin.csv.import" /></h2>
<fmt:message key="admin.csv.maxfile" /><br />
<fmt:message key="admin.csv.maxrecord" /> :<ul>
<li>CTX : <fmt:message key="admin.csv.maxline" /> = 5000</li>
<li>SITE : <fmt:message key="admin.csv.maxline" /> = 2500</li>
<li>VLAN : <fmt:message key="admin.csv.maxline" /> = 2000</li>
<li>SUBNET : <fmt:message key="admin.csv.maxline" /> = 1000</li>
<li>IP : <fmt:message key="admin.csv.maxline" /> = 1000</li>
</ul>
<b><fmt:message key="admin.csv.warning" /></b>
<form method="POST" enctype="multipart/form-data" id="fUpload">
	<p><input type="file" size="40" name="file" id="upFile" /> <input id="upBtnUpload" type="button" value="Upload" onclick="javascript:submitUpload()" /></p>
	<progress class="progress" id="upProgress" value="0" max="100"></progress>
	<p class="upstatus" id="upStatus"></p>
	<p class="upresult" id="upResult"></p>
	<p class="uperror" id="upError"></p>
	<p><input class="upreset" id="upBtnReset" type="button" value="Reset" onclick="javascript:resetUpload()" /></p>
</form>
</body></html>
</c:if>
