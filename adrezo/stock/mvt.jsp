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
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<c:if test="${validUser.stockAdmin}">
<head>
<title><fmt:message key="stock.mvt.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/stock_mvt.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="ctxs">select id,name from contextes order by name</sql:query>
<h2><fmt:message key="stock.mvt.main" /></h2>

<hr /><fmt:message key="stock.mvt.src" /> :
<table><thead><tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.stock" /></th></tr></thead>
<tbody><tr>
<td><select id="srcctx" onchange="javascript:FillSite(this,'src')">
	<option><fmt:message key="common.select.ctx" /></option>
	<c:forEach items="${ctxs.rows}" var="ctx">
		<c:set var="myid">${ctx.id}</c:set>
		<c:if test="${validUser.stockCtx(myid)}"><option value="${ctx.id}">${ctx.name}</option></c:if>
	</c:forEach>
</select></td>
<td><select id="srcsite" onchange="javascript:FillType(this,'src')">
	<option><fmt:message key="common.select.site" /></option>
</select></td>
<td><select id="srctype" onchange="javascript:FillStock(this,'src')">
	<option><fmt:message key="common.select.type" /></option>
</select></td>
<td id="srcstk"></td>
</tr></tbody></table>

<hr /><fmt:message key="stock.mvt.dst" /> :
<table><thead><tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.stock" /></th></tr></thead>
<tbody><tr>
<td><select id="dstctx" onchange="javascript:FillSite(this,'dst')">
	<option><fmt:message key="common.select.ctx" /></option>
	<c:forEach items="${ctxs.rows}" var="ctx">
		<c:set var="myid">${ctx.id}</c:set>
		<c:if test="${validUser.stockCtx(myid)}"><option value="${ctx.id}">${ctx.name}</option></c:if>
	</c:forEach>
</select></td>
<td><select id="dstsite" onchange="javascript:FillType(this,'dst')">
	<option><fmt:message key="common.select.site" /></option>
</select></td>
<td><select id="dsttype" onchange="javascript:FillStock(this,'dst')">
	<option><fmt:message key="common.select.type" /></option>
</select></td>
<td id="dststk"></td>
</tr></tbody></table>

<hr /><fmt:message key="stock.mvt.qty" /> :
<input type="hidden" value="" id="srcqty" />
<input type="text" value="" id="mvtqty" size="5" />
<span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:MoveStock()" /></span>
</c:if>
<div id="dlgcontent"/>
</body></html>
