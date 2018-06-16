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
<head><title><fmt:message key="admin.dhcp.boxadd.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<h2><fmt:message key="admin.dhcp.boxadd.text" /><fmt:message key="common.space" />${param.name}</h2>
<div id="addexclu_err" style="color:red"></div>
<div id="addexclu_wait"></div>
<div id="addtablewrapper">
	<div id="addtableheader">
		<div id="addtablenav">
			<div>
				<img src="../img/nav_first.gif" alt="First Page" onclick="addsortiny.move(-1,true)" />
				<img src="../img/nav_previous.gif" alt="Previous Page" onclick="addsortiny.move(-1)" />
				<img src="../img/nav_next.gif" alt="Next Page" onclick="addsortiny.move(1)" />
				<img src="../img/nav_end.gif" alt="Last Page" onclick="addsortiny.move(1,true)" />
			</div>
		</div>
  	<div class="search"><input type="text" id="addquery" onkeyup="addsortiny.search('addquery')" /></div>
		<span class="details">
			<div><fmt:message key="tiny.table.record" /> <span id="addstartrecord"></span>-<span id="addendrecord"></span> / <span id="addtotalrecords"></span></div>
			<div class="page"><fmt:message key="tiny.table.page" /> <span id="addcurrentpage"></span> / <span id="addtotalpages"></span></div>
		</span>
	</div>
	<table id="addtable" class="tinytable">
		<thead><tr><th class="nosort"><fmt:message key="common.table.choice" /></th><th class="nosort"><fmt:message key="common.table.scope" /></th></tr></thead>
		<tbody></tbody>
	</table>
</div>
</body></html>
</c:if>
