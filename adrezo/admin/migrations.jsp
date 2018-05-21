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
<c:if test="${validUser.admin}">
<jsp:useBean id="today" class="java.util.Date" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.ipmig.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytable.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="admin.ipmig.list" /></h2>
<sql:query var="migs">
	select ctx_name,subnet_name,site_name,name,def,ip,mask,usr_mig,date_mig,ip_mig,mask_mig,site_mig_name,subnet_mig_name
	from adresses_display
	where mig = 1
	order by date_mig
</sql:query>
<div id="tablewrapper">
	<div id="tableheader">
  	<div class="search">
			<select id="columns" onchange="sortiny.search('query')"></select>
			<input type="text" id="query" onkeyup="sortiny.search('query')" />
		</div>
		<span class="details">
			<div><fmt:message key="tiny.table.record" /> <span id="startrecord"></span>-<span id="endrecord"></span> / <span id="totalrecords"></span></div>
			<div><a href="javascript:sortiny.showall()"><fmt:message key="tiny.table.showall" /></a></div>
			<div><a href="javascript:sortiny.reset()"><fmt:message key="common.click.reset" /></a></div>
		</span>
	</div>
	<table id="table" class="tinytable">
		<thead><tr><th><h3><fmt:message key="admin.user" /></h3></th><th><h3><fmt:message key="common.table.date" /></h3></th><th><h3><fmt:message key="admin.ctx" /></h3></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="admin.subnet" /></h3></th><th><h3><fmt:message key="common.table.ipmask" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.def" /></h3></th><th><h3><fmt:message key="common.table.ipfutur" /></h3></th></tr></thead>
		<tbody>
		<c:forEach items="${migs.rows}" var="mig">
			<tr>
				<td>${mig.usr_mig}</td>
				<fmt:formatDate value="${mig.date_mig}" type="both" pattern="dd/MM/yyyy" var="fmtDateMig" scope="page" />
				<c:choose><c:when test="${mig.date_mig < today}"><c:set var="dateColor" value="#f00" /></c:when><c:otherwise><c:set var="dateColor" value="#000" /></c:otherwise></c:choose>
				<td style="color:${dateColor}">${fmtDateMig}</td>
				<td>${mig.ctx_name}</td>
				<td>${mig.site_name}</td>
				<td>${mig.subnet_name}</td>
				<td><adrezo:displayIP value="${mig.ip}"/>/${mig.mask}</td>
				<td>${mig.name}</td>
				<td>${mig.def}</td>
				<td><adrezo:displayIP value="${mig.ip_mig}"/>/${mig.mask_mig} (${mig.site_mig_name}, ${mig.subnet_mig_name})</td>
			</tr>
		</c:forEach>
		</tbody>
	</table>
	<div id="tablefooter">
		<div id="tablenav">
			<div>
				<img src="../img/nav_first.gif" alt="First Page" onclick="sortiny.move(-1,true)" />
				<img src="../img/nav_previous.gif" alt="Previous Page" onclick="sortiny.move(-1)" />
				<img src="../img/nav_next.gif" alt="Next Page" onclick="sortiny.move(1)" />
				<img src="../img/nav_end.gif" alt="Last Page" onclick="sortiny.move(1,true)" />
			</div>
		</div>
		<div id="tablelocation">
			<div>
				<select onchange="sortiny.size(this.value)">
					<option value="10">10</option>
					<option value="20" selected="selected">20</option>
					<option value="50">50</option>
				</select>
				<span><fmt:message key="tiny.table.recordpage" /></span>
			</div>
			<div class="page"><fmt:message key="tiny.table.page" /> <span id="currentpage"></span> / <span id="totalpages"></span></div>
		</div>
	</div>
</div>
<script type="text/javascript" charset="utf-8">
	var sortiny = new TINY.table.sorter('sortiny','table',{
		headclass:'head',
		ascclass:'asc',
		descclass:'desc',
		evenclass:'evenrow',
		oddclass:'oddrow',
		evenselclass:'evenselected',
		oddselclass:'oddselected',
		paginate:true	,
		size:20,
		colddid:'columns',
		currentid:'currentpage',
		totalid:'totalpages',
		startingrecid:'startrecord',
		endingrecid:'endrecord',
		totalrecid:'totalrecords',
		hoverid:'selectedrow',
		navid:'tablenav',
		sortcolumn:1,
		sortdir:1,
		init:true
	});
</script>
</body></html>
</c:if>
