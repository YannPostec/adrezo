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
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="admin.dhcp.addexclu" var="lang_addexclu" />
<fmt:message key="admin.dhcp.listexclu" var="lang_listexclu" />
<fmt:message key="admin.dhcp.test" var="lang_testdhcp" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.dhcp.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/infos.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/admin_dhcp.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyinfotable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/scrolltable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_dhcp.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body onload='javascript:loadTable()'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="sqs_id" value="15" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="hostname" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sqs_special" value="" />
<input type="hidden" id="sortiny_column" value="3" />
<input type="hidden" id="sortiny_dir" value="1" />
<table id="tableshadow" style="display:none;"><tbody><tr><td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(event)" /></span></td><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td></tr></tbody></table>
<table id="tableicons" style="display:none;"><tbody><tr><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_addexclu}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add2.png" alt="${lang_addexclu}" /></span> <span onmouseover="javascript:tooltip.show('${lang_listexclu}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_listexclu}" /></span></td><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_testdhcp}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_info.png" alt="${lang_testdhcp}" /></span></td></tr></tbody></table>
<sql:query var="types">select * from dhcp_type order by name</sql:query>
<script type="text/javascript" charset="utf-8">
 var typedefaultport = new Array();
 <c:forEach items="${types.rows}" var="type">
 typedefaultport[${type.id}] = ${type.port};
 </c:forEach>
</script>
<h3><fmt:message key="admin.mgt" /> :</h3>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.type" /></th><th><fmt:message key="common.table.hostname" /></th><th><fmt:message key="common.table.port" /></th><th><fmt:message key="common.table.ssl" /></th><th><fmt:message key="common.table.authentication" /></th><th><fmt:message key="common.table.login" /></th><th><fmt:message key="common.table.pwd" /></th><th><fmt:message key="sla.active" /></th></tr></thead>
<tbody><tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add2.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span></td>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_type" onchange="javascript:defaultTypePort(this)"><option><fmt:message key="common.select.type" /></option><c:forEach items="${types.rows}" var="type"><option value="${type.id}">${type.name}</option></c:forEach></select></td>
	<td><input type="text" size="50" id="add_hostname" value="" /></td>
	<td><input type="text" size="5" id="add_port" /></td>
	<td><select id="add_ssl"><option value="0" selected="selected"><fmt:message key="common.no" /></option><option value="1"><fmt:message key="common.yes" /></option></select></td>
	<td><select id="add_auth"><option value="0" selected="selected"><fmt:message key="common.no" /></option><option value="1"><fmt:message key="common.yes" /></option></select></td>
	<td><input type="text" size="30" id="add_login" value="" /></td>
	<td><input type="password" size="30" id="add_pwd" value="" /></td>
	<td><select id="add_enable"><option value="1" selected="selected"><fmt:message key="common.yes" /></option><option value="0"><fmt:message key="common.no" /></option></select></td>
</tr></tbody></table>
<h3><fmt:message key="admin.dhcp.list" /> :</h3>
<div id="tablewrapper">
	<div id="tableheader">
		<div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.type" /></h3></th><th><h3><fmt:message key="common.table.hostname" /></h3></th><th><h3><fmt:message key="common.table.port" /></h3></th><th><h3><fmt:message key="common.table.ssl" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="common.table.authentication" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="common.table.login" /></h3></th><th class="nosort"><h3><fmt:message key="common.table.pwd" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="sla.active" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th class="nosort"><h3><fmt:message key="common.table.exclu" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th class="nosort"><h3><fmt:message key="common.table.test" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th></tr></thead>
	</table>	
	<table id="tableinfos" class="tinytable">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.type" /></h3></th><th><h3><fmt:message key="common.table.hostname" /></h3></th><th><h3><fmt:message key="common.table.port" /></h3></th><th><h3><fmt:message key="common.table.ssl" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="common.table.authentication" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="common.table.login" /></h3></th><th class="nosort"><h3><fmt:message key="common.table.pwd" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th><h3><fmt:message key="sla.active" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th class="nosort"><h3><fmt:message key="common.table.exclu" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th><th class="nosort"><h3><fmt:message key="common.table.test" />&nbsp;<img src="../img/tinytable_nosearch.png"></h3></th></tr></thead>
		<tbody></tbody>
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
</body></html>
</c:if>
