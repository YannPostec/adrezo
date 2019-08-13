<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.rezo}">
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="sla.planning.anytime" var="lang_slaplanninganytime" />
<fmt:message key="sla.inactive" var="lang_slainactive" />
<fmt:message key="sla.active" var="lang_slaactive" />
<fmt:message key="sla.destroyed" var="lang_sladestroyed" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="sla.device.title" /></title>
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
<script type="text/javascript" charset="utf-8" src="../js/sla_devices.js"></script>
<script type="text/javascript" charset="utf-8">
	var langinactive = '${lang_slainactive}';
	var langactive = '${lang_slaactive}';
	var langdestroyed = '${lang_sladestroyed}';
	var langanytime = '${lang_slaplanninganytime}';	
</script>
</head>
<body>
<body onload='javascript:loadTable()'>
<%@ include file="../menu.jsp" %>
<input type="hidden" id="sqs_id" value="18" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="name" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sortiny_column" value="3" />
<input type="hidden" id="sortiny_dir" value="1" />
<sql:query var="clients">select id,name from slaclient where id > 0 order by name</sql:query>
<sql:query var="plans">select * from slaplanning order by id</sql:query>
<select id="tpl_client" style="display:none" onchange="javascript:FillSite(this,false)"><option><fmt:message key="common.select.client" /></option><c:forEach items="${clients.rows}" var="client"><option value="${client.ID}">${client.name}</option></c:forEach></select>
<select id="tpl_site" style="display:none"><option><fmt:message key="common.select.site" /></option></select>
<select id="tpl_plan" style="display:none"><option><fmt:message key="common.select.plan" /></option><c:forEach items="${plans.rows}" var="plan"><option value="${plan.id}">${plan.id}-<c:choose><c:when test="${plan.id == 0}"><fmt:message key="sla.planning.anytime" /></c:when><c:otherwise>${plan.name}</c:otherwise></c:choose></option></c:forEach></select>
<table id="tableshadow" style="display:none;"><tbody><tr><td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td></tr></tbody></table>
<p><fmt:message key="sla.device.list" /> :<br />
<input type="checkbox" id="cb_unk" onchange="javascript:CheckDisplay()" /> <fmt:message key="sla.device.unaffect" /><br />
<input type="checkbox" id="cb_destroy" onchange="javascript:CheckDisplay()" /> <fmt:message key="sla.device.dispdestroyed" /></p>
<div id="tablewrapper">
	<div id="tableheader">
		<div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.client" /></th></h3><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.cacti" /></h3></th><th><h3><fmt:message key="common.table.status" /></h3></th><th><h3><fmt:message key="sla.planning.plan" /></h3></th></tr></thead>
	</table>
	<table id="tableinfos" class="tinytable">
		<thead><tr><th class="nosort"><h3 /></th><th><h3><fmt:message key="common.table.client" /></th></h3><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.cacti" /></h3></th><th><h3><fmt:message key="common.table.status" /></h3></th><th><h3><fmt:message key="sla.planning.plan" /></h3></th></tr></thead>
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
</body></html>
</c:if>
