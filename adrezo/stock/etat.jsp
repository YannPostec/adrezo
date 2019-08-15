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
<fmt:message key="stock.mgt.gomain" var="lang_stkgomain" />
<fmt:message key="stock.xls.click.stock" var="lang_stkclickstock" />
<fmt:message key="stock.xls.click.mvt" var="lang_stkclickmvt" />
<fmt:message key="common.click.history" var="lang_commonclickhistory" />
<fmt:message key="common.click.reception" var="lang_commonclickreception" />
<fmt:message key="common.click.validateall" var="lang_commonclickvalidall" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="stock.mgt.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/stock.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyinfotable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/scrolltable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/stock_etat.js"></script>
</head>
<body onload='javascript:loadTable();'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="sqs_id" value="21" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="idx" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sqs_special" value="" />
<input type="hidden" id="sortiny_column" value="4" />
<input type="hidden" id="sortiny_dir" value="1" />
<sql:query var="mains">select site_main from contextes where id=${validUser.ctx}</sql:query>
<c:choose><c:when test="${mains.rows[0].site_main == 0}"><h2><fmt:message key="stock.mgt.undefined" /></h2></c:when>
<c:otherwise>

<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<sql:query var="cats">select * from stock_cat order by name</sql:query>
<table id="tableshadow" style="display:none;"><tbody><tr><td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(event)" /></span></td><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td></tr></tbody></table>


<h3><fmt:message key="stock.type.list" /> :</h3>
<div id="tablewrapper">
	<div id="tableheader">
		<div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="common.table.cat" /></h3></th><th><h3><fmt:message key="common.table.idx" /></h3></th><th><h3><fmt:message key="common.table.def" /></h3></th><th><h3><fmt:message key="common.table.threshold" /></h3></th><th><h3><fmt:message key="common.table.ongoing" /></h3></th></tr></thead>
	</table>
	<table id="tableinfos" class="tinytable">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="common.table.cat" /></h3></th><th><h3><fmt:message key="common.table.idx" /></h3></th><th><h3><fmt:message key="common.table.def" /></h3></th><th><h3><fmt:message key="common.table.threshold" /></h3></th><th><h3><fmt:message key="common.table.ongoing" /></h3></th></tr></thead>
		<tbody id="mytbody"></tbody>
	</table>
</div>
<div id="tablefooter"></div>
<div id="dlgcontent"/>
<script type="text/javascript" charset="utf-8">
	var sortiny = new TINY.table.sorter('sortiny','tableinfos',{
		headclass:'head',
		ascclass:'asc',
		descclass:'desc',
		evenclass:'evenrow',
		oddclass:'oddrow',
		evenselclass:'evenselected',
		oddselclass:'oddselected',
		hoverid:'selectedrow'
	});
</script>
<a href="#" id="upscroll" class="scrollup" onclick="javascript:ScrollUp()">Scroll</a>

<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<c:choose><c:when test="${empty param.site}"><c:set var="stocksite" scope="page" value="${mains.rows[0].site_main}" /></c:when><c:otherwise><c:set var="stocksite" scope="page" value="${param.site}" /></c:otherwise></c:choose>
<form id="f_etat_stock" method="post"><div><fmt:message key="stock.mgt.state" /> <select id="selSite" name="site" onchange="javascript:changeStock()"><c:forEach items="${sites.rows}" var="site"><option value="${site.id}"<c:if test="${stocksite == site.id}"> selected="selected"</c:if>>${site.name}</option></c:forEach></select><input type="button" value="${lang_stkgomain}" onclick="javascript:goMainSite(${mains.rows[0].site_main})" /></div></form>

<div id="wrapper">
<div class="fl"><fmt:message key="stock.mgt.history" /> : <input type="text" size="2" maxlength="2" id="limit" value="20" /></div>
<c:if test="${validUser.stockAdmin}"><div class="fl"><fmt:message key="common.table.inventory" /> : <input type="checkbox" id="chkInventaire" /></div></c:if>
<span class="fl" onmouseover="javascript:tooltip.show('${lang_stkclickstock}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:window.open('${pageContext.request.contextPath}/excelstock?type=stock')"><img class="excel" src="../img/icon_excel.jpg" alt="${lang_stkclickstock}" /><div class="lettrine">S</div></span>
<span class="fl" onmouseover="javascript:tooltip.show('${lang_stkclickmvt}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:window.open('${pageContext.request.contextPath}/excelstock?type=mvt')"><img class="excel" src="../img/icon_excel.jpg" alt="${lang_stkclickmvt}" /><div class="lettrine">M</div></span>
</div>
<table class="sortable" id="tableStock">
<thead>
<tr><th class="sorttable_nosort" /><th class="sorttable_alpha"><fmt:message key="common.table.cat" /></th><th class="sorttable_alpha"><fmt:message key="common.table.idx" /></th><th class="sorttable_alpha"><fmt:message key="common.table.def" /></th><th class="sorttable_numeric"><fmt:message key="common.table.stock" /></th><c:if test="${validUser.stock}"><th class="sorttable_nosort"><fmt:message key="common.table.variation" /></th></c:if><th class="sorttable_nosort"><fmt:message key="common.table.threshold" /></th><th class="sorttable_nosort"><fmt:message key="common.table.ongoing" /></th><c:if test="${validUser.stock}"><th class="sorttable_nosort" /></c:if></tr>
</thead>
<tbody>
<sql:query var="types">select * from stock_etat_display where ctx=${validUser.ctx} and site=${stocksite} order by IDX</sql:query>
<c:forEach items="${types.rows}" var="type">
	<tr>
		<td><span onmouseover="javascript:tooltip.show('${lang_commonclickhistory}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_commonclickhistory}" onclick="javascript:ShowBox(event)" /></span></td><td><input type="hidden" value="${type.ID}" />${type.CAT}</td>
		<td>${type.IDX}</td>
		<td>${type.DEF}</td>
		<td style="text-align:center<c:if test="${(type.STOCK+type.ENCOURS) < type.SEUIL}">; color:#f00; font-weight:bold</c:if>">${type.STOCK}</td>
		<c:if test="${validUser.stock}"><td><input type="text" size="5" value="" /></td></c:if>
		<td align="center">${type.SEUIL}</td>
		<td align="center"><c:if test="${type.ENCOURS != 0}">${type.ENCOURS}<c:if test="${validUser.stockAdmin}">&nbsp;<span onmouseover="javascript:tooltip.show('${lang_commonclickreception}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_package.png" alt="${lang_commonclickreception}" onclick="javascript:ConfirmDlg(${type.ID},${type.ENCOURS})" /></span></c:if></c:if></td>
		<c:if test="${validUser.stock}"><td><span onmouseover="javascript:tooltip.show('${lang_commonclickvalidall}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalidall}" onclick="javascript:ChangeEtat()" /></span></td></c:if>
	</tr>
</c:forEach>
</tbody>
</table>
<div id="dlgcontent"/>



</c:otherwise></c:choose>
</body>
</html>
