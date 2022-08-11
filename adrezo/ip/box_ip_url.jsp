<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser != null && validUser.read && pageContext.request.method == 'POST' && !empty param.ip}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title>Box IP URL</title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<style>
ul.prefs {list-style:none; margin:0; padding:0}
ul.prefs * {margin:0; padding:0; text-align: center}
ul.prefs li {position:relative; border:1px solid #aaa; width:auto; margin:0}
ul.prefs li a {display:block; padding:2px; background-color:#dedeff}
ul.prefs li a:hover {background-color:#cacaff}
</style>
</head>
<body>
<sql:query var="urls">select * from ipurl order by proto,port,uri</sql:query>
<ul class="prefs">
	<c:forEach items="${urls.rows}" var="url">
		<li>
		<c:set var="myurl">${url.proto}://${param.ip}<c:if test="${!empty url.port}">:${url.port}</c:if>/${url.uri}</c:set>
			<a href="javascript:ClickURL('${myurl}');">${myurl}</a>
		</li>
	</c:forEach>
</ul>
</body></html>
</c:if>
