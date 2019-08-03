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
<fmt:message key="ip.click.search" var="lang_ipclicksearch" />
<fmt:message key="ip.click.addline" var="lang_ipclickaddline" />
<fmt:message key="ip.click.delallline" var="lang_ipclickdelallline" />
<fmt:message key="ip.click.validate" var="lang_ipclickvalidate" />
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.mig" var="lang_commonclickmig" />
<fmt:message key="common.all" var="lang_commonall" />
<fmt:message key="common.and" var="lang_commonand" />
<fmt:message key="common.or" var="lang_commonor" />
<fmt:message key="ip.navi.last" var="lang_ipnavilast" />
<fmt:message key="ip.navi.go" var="lang_ipnavigo" />
<fmt:message key="ip.excel.global" var="lang_ipxlsglobal" />
<fmt:message key="ip.excel.ctx" var="lang_ipxlsctx" />
<fmt:message key="ip.excel.search" var="lang_ipxlssearch" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="ip.title" /></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="Pragma" content="no-cache" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/calendar.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/ip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/sorttable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyaccordion.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinyaccordion.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/calendar.css" type="text/css" />
</head>
<body onload='javascript:BodyLoad(<c:if test="${validUser.ip}">true</c:if>)'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="myCTX" value="${validUser.ctx}">
<input type="hidden" id="urlpref" value="${validUser.url}">
<input type="hidden" id="macpref" value="${validUser.macsearch}">
<c:if test="${validUser.ip}">
<ul class="acc" id="ipacc">
<li><h3><fmt:message key="ip.section.dispo" /></h3><div class="acc-section" id="ipdispoAccordeon"><div class="acc-content">
<sql:query var="subnets">SELECT ID,DEF FROM subnets where ctx=${validUser.ctx} ORDER by def</sql:query>
<fmt:message key="ip.dispo.searchfor" /> <input type="text" size="3" id="disponb" value="1"/> <fmt:message key="ip.dispo.ipin" />
<select id="disposub"><option><fmt:message key="common.select.subnet" /></option>
<c:forEach items="${subnets.rows}" var="row"><option value="${row.ID}">${row.DEF}</option></c:forEach>
</select> <fmt:message key="ip.dispo.startafter" /> <input type="text" id="dispostart" value=""/>
<span onmouseover="javascript:tooltip.show('${lang_ipclicksearch}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_ipclicksearch}" onclick="javascript:IPDispo()"/></span>
<table id="ipdispotable"></table>
<h2 id="ipdispoempty" style="display:none;"><fmt:message key="ip.dispo.empty" /></h2>
</div></div></li>
<li><h3><fmt:message key="ip.section.mgt" /></h3><div class="acc-section" id="addAccordeon"><div class="acc-content">
<span onmouseover="javascript:tooltip.show('${lang_ipclickaddline}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_ipclickaddline}" onclick="javascript:ConstructRow('','','','','','','','','','','')"/></span>
<span onmouseover="javascript:tooltip.show('${lang_ipclickdelallline}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_ipclickdelallline}" onclick="javascript:DelAllRows()" /></span>
<span onmouseover="javascript:tooltip.show('${lang_ipclickvalidate}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_ipclickvalidate}" onclick="javascript:validateChange()" /></span>
<table id="addTable">
<thead>
<tr><th/><th/><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.ip" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="common.table.mac" /></th><th><fmt:message key="common.table.temp" /></th><th><fmt:message key="common.table.mig" /></th></tr>
</thead>
<tbody />
</table>
</div></div></li></ul>
</c:if>
<ul class="acc" id="naviacc">
<li><h3><fmt:message key="ip.section.navi" /></h3><div class="acc-section"><div class="acc-content">
<form action="" id="fNavi">
<table>
<tbody><tr>
<td class="naviBord"><p><fmt:message key="tiny.table.recordpage" /> : <select name="limit" onchange="javascript:validateSearch()"><option value="20">20</option><option value="40" selected="selected">40</option><option value="75">75</option><option value="100">100</option></select></p>
<fmt:message key="ip.navi.goto" /> <input type="text" size="3" name="page" value="1" onchange="javascript:validateSearch()" /> / <span id="nbPage">1</span><br />
<div id="pages" />
</td>
<td><p><fmt:message key="ip.navi.sort" /> : <select name="sortKey" onchange="javascript:validateSearch()">
	<option value="SITE"><fmt:message key="admin.site" /></option>
	<option value="NAME"><fmt:message key="common.table.name" /></option>
	<option value="DEF"><fmt:message key="common.table.def" /></option>
	<option value="IP" selected="selected"><fmt:message key="common.table.ip" /></option>
	<option value="SUBNET"><fmt:message key="admin.subnet" /></option>
	<option value="TYPE"><fmt:message key="common.table.type" /></option>
	</select></p>
<input type="radio" name="sortOrder" value="NODESC" checked="checked" onchange="javascript:validateSearch()" /><fmt:message key="ip.navi.sortc" /> <input type="radio" name="sortOrder" value="DESC" onchange="javascript:validateSearch()" /><fmt:message key="ip.navi.sortd" />
</td>
<td class="naviBord">
<p><div id="searchDiv"><select id="myField" onchange="javascript:selectField(this.value)">
<option value="SITE"><fmt:message key="admin.site" /></option>
<option value="NAME"><fmt:message key="common.table.name" /></option>
<option value="DEF"><fmt:message key="common.table.def" /></option>
<option value="IP"><fmt:message key="common.table.ip" /></option>
<option value="MASK"><fmt:message key="common.table.mask" /></option>
<option value="SUBNET"><fmt:message key="admin.subnet" /></option>
<option value="MAC"><fmt:message key="common.table.mac" /></option>
<option value="TYPE"><fmt:message key="common.table.type" /></option>
</select>
<input type="button" value="${lang_commonclickadd}" id="btnAjouterSearchDiv" onclick="javascript:insRow()" />
</div></p>
<input type="button" value="(" onclick="javascript:addElt('(')" />
<input type="button" value=")" onclick="javascript:addElt(')')" />
<input type="button" value="${lang_commonand}" onclick="javascript:addElt('AND')" />
<input type="button" value="${lang_commonor}" onclick="javascript:addElt('OR')" /> <fmt:message key="ip.navi.delete" /> <input type="button" value="${lang_commonall}" onclick="javascript:clearAll()" />
<input type="button" value="${lang_ipnavilast}" onclick="javascript:clearElt()" />
<input type="button" value="${lang_ipnavigo}" onclick="javascript:validateSearch()" /><br />
<p><textarea name="search" id="mytext" rows="2" cols="60" disabled="disabled">${param.search}</textarea></p>
</td>
<td class="naviBordRight"><span onmouseover="javascript:tooltip.show('${lang_ipxlsglobal}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:ExcelIP('global',${validUser.ctx})"><img src="../img/icon_excel.jpg" alt="${lang_ipxlsglobal}" /> <fmt:message key="ip.excel.global.click" /></span>
<br /><br /><span onmouseover="javascript:tooltip.show('${lang_ipxlsctx}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:ExcelIP('ctx',${validUser.ctx})"><img src="../img/icon_excel.jpg" alt="${lang_ipxlsctx}" /> <fmt:message key="ip.excel.ctx.click" /></span>
<br /><br /><span onmouseover="javascript:tooltip.show('${lang_ipxlssearch}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:ExcelIP('search',${validUser.ctx})"><img src="../img/icon_excel.jpg" alt="${lang_ipxlssearch}" /> <fmt:message key="ip.excel.search.click" /></span></td>
<td id="tdInfosUser" />
</tr></tbody></table></form>
</div></div></li></ul>
<ul class="acc" id="listacc">
<li><h3><fmt:message key="ip.section.list" /></h3><div class="acc-section" id="listAccordeon"><div class="acc-content">
<form action="" id="fList">
<table class="sortable" id="listTable">
<thead>
<tr>
<c:if test="${validUser.ip}">
<th valign="top" class="sorttable_nosort"><input type="button" value="${lang_commonclickdel}" onclick="javascript:ConfirmDlg('delRecords');" /><br/><a href="javascript:AllDel()"><fmt:message key="common.all" /></a></th>
<th valign="top" class="sorttable_nosort"><input type="button" value="${lang_commonclickmod}" onclick="javascript:modRecords()" /><br/><a href="javascript:AllModify()"><fmt:message key="common.all" /></a></th>
<th valign="top" class="sorttable_nosort"><input type="button" value="${lang_commonclickmig}" onclick="javascript:ConfirmDlg('migRecords');" /><br/><a href="javascript:AllMig()"><fmt:message key="common.all" /></a></th>
</c:if>
<th class="sorttable_alpha"><fmt:message key="common.table.type" /></th><th class="sorttable_alpha"><fmt:message key="admin.site" /></th><th class="sorttable_alpha"><fmt:message key="common.table.name" /></th><th class="sorttable_alpha"><fmt:message key="common.table.def" /></th><th class="sorttable_ip"><fmt:message key="common.table.ip" /></th><th class="sorttable_alpha"><fmt:message key="admin.subnet" /></th><th class="sorttable_alpha"><fmt:message key="common.table.mac" /></th><th class="sorttable_nosort"><fmt:message key="common.table.lastmodif" /></th><th class="sorttable_nosort"><fmt:message key="common.table.temp" /></th><th class="sorttable_nosort"><fmt:message key="common.table.mig" /></th></tr>
</thead>
<tbody />
</table>
</form>
</div></div></li></ul>
<div id="dlgcontent"/>
<script type="text/javascript" charset="utf-8">
var naviaccordion=new TINY.accordion.slider("naviaccordion");
var listaccordion=new TINY.accordion.slider("listaccordion");
naviaccordion.init("naviacc","h3",0,0);
listaccordion.init("listacc","h3",0,0);
<c:if test="${validUser.ip}">
var ipaccordion=new TINY.accordion.slider("ipaccordion");
ipaccordion.init("ipacc","h3",0);
</c:if>
</script>
</body>
</html>
