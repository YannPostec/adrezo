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
<c:if test="${validUser.rezo}">
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.subnet.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/infos.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/ip_calc.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyinfotable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/scrolltable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_subnets.js"></script>
</head>
<body onload='javascript:loadTable()'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="sqs_id" value="7" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="ip" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sqs_special" value="" />
<input type="hidden" id="sortiny_column" value="3" />
<input type="hidden" id="sortiny_dir" value="1" />
<table id="tableshadow" style="display:none;"><tbody><tr><td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(event)" /></span></td><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td></tr></tbody></table>
<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<h3><fmt:message key="admin.mgt" /> :</h3>
<table><thead><tr><th /><th /><th><fmt:message key="admin.site" /></th><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.ipgw" /></th><th><fmt:message key="common.table.ipbc" /></th><th><fmt:message key="admin.vlan" /></th></tr></thead>
<tbody><tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add2.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span></td>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_site" onchange="javascript:FillVlan(this,false)"><option><fmt:message key="common.select.site" /></option><c:forEach items="${sites.rows}" var="site"><option value="${site.ID}">${site.name}</option></c:forEach></select></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="16" id="add_ip" value="" onkeyup="javascript:calcBC(event)" /></td>
	<td><input type="hidden" id="add_ctx" value="${validUser.ctx}" /><input type="text" size="2" id="add_mask" value="" onkeyup="javascript:calcBC(event)" /></td>
	<td><input type="text" size="20" id="add_def" value="" /></td>
	<td><input type="text" size="16" id="add_gw" value="" /></td>
	<td><input type="text" size="16" id="add_bc" value="" /></td>
	<td><select id="add_vlan"><option><fmt:message key="common.select.vlan" /></option></select></td>
</tr></tbody></table>
<h3><fmt:message key="admin.subnet.list" /> :</h3>
<div id="tablewrapper">
	<div id="tableheader">
		<div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="admin.subnet" /></h3></th><th><h3><fmt:message key="common.table.mask" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.ipgw" /></h3></th><th><h3><fmt:message key="common.table.ipbc" /></h3></th><th><h3><fmt:message key="admin.vlan" /></h3></th></tr></thead>
	</table>
	<table id="tableinfos" class="tinytable">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="admin.subnet" /></h3></th><th><h3><fmt:message key="common.table.mask" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.ipgw" /></h3></th><th><h3><fmt:message key="common.table.ipbc" /></h3></th><th><h3><fmt:message key="admin.vlan" /></h3></th></tr></thead>
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
</body>
</html>
</c:if>
