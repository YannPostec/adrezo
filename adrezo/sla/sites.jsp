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
<c:if test="${validUser.rezo}">
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<fmt:message key="sla.planning.anytime" var="lang_slaplanninganytime" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.site.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/infos.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyinfotable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/scrolltable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/sla_sites.js"></script>
<script type="text/javascript" charset="utf-8">
	var langanytime = '${lang_slaplanninganytime}';
</script>
</head>
<body onload='javascript:loadTable()'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="sqs_id" value="17" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="client_name" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sqs_special" value="" />
<input type="hidden" id="sortiny_column" value="2" />
<input type="hidden" id="sortiny_dir" value="1" />
<sql:query var="clients">select id,name from slaclient where id > 0 order by name</sql:query>
<sql:query var="plans">select * from slaplanning order by id</sql:query>
<table id="tableshadow" style="display:none;"><tbody><tr><td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(event)" /></span></td><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td></tr></tbody></table>
<h3><fmt:message key="admin.mgt" /> :</h3>
<table><thead><tr><th /><th /><th><fmt:message key="common.table.client" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.view" /></th><th><fmt:message key="sla.planning.plan" /></th></tr></thead>
<tbody><tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add2.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span></td>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_client"><option><fmt:message key="common.select.client" /></option><c:forEach items="${clients.rows}" var="client"><option value="${client.id}">${client.name}</option></c:forEach></select></td>
	<td><input type="text" size="40" id="add_name" value="" /></td>
	<td style="text-align:center"><input type="checkbox" id="add_disp" checked="checked" /></td>
	<td><select id="add_plan"><option><fmt:message key="common.select.plan" /></option><c:forEach items="${plans.rows}" var="plan"><option value="${plan.id}">${plan.id}-<c:choose><c:when test="${plan.id == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${plan.name}</c:otherwise></c:choose></option></c:forEach></select></td>
</tr></tbody></table>
<h3><fmt:message key="admin.site.list" /> :</h3>
<div id="tablewrapper">
	<div id="tableheader">
		<div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.client" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.view" /></h3></th><th><h3><fmt:message key="sla.planning.plan" /></h3></th></tr></thead>
	</table>
	<table id="tableinfos" class="tinytable">
		<thead><tr><th class="nosort"><h3 /></th><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.client" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.view" /></h3></th><th><h3><fmt:message key="sla.planning.plan" /></h3></th></tr></thead>
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
