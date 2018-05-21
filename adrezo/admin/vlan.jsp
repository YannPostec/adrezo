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
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.vlan.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_vlan.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytable.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="vlans">SELECT * FROM vlan_display where ctx=${validUser.ctx} and VID != 0 ORDER BY site_name,vid</sql:query>
<sql:query var="sites">SELECT id,name FROM sites where ctx=${validUser.ctx} ORDER BY name</sql:query>
<h3><fmt:message key="admin.mgt" /> :</h3>
<table>
<thead><tr><th /><th><fmt:message key="admin.site" /></th><th><fmt:message key="common.table.vid" /></th><th><fmt:message key="common.table.name" /></th></tr></thead>
<tbody><tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_site"><option><fmt:message key="common.select.site" /></option><c:forEach items="${sites.rows}" var="site"><option value="${site.id}">${site.name}</option></c:forEach></select></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="5" id="add_vid" value="" /></td>
	<td><input type="hidden" id="add_ctx" value="${validUser.ctx}" /><input type="text" size="30" id="add_def" value="" /></td>
</tr></tbody></table>
<h3><fmt:message key="admin.vlan.list" /> :</h3>
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
		<thead><tr><th class="nosort"><h3 class="nosearch" /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="common.table.vid" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th></tr></thead>
		<tbody><c:forEach items="${vlans.rows}" var="vlan"><tr>
			<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${vlan.id})" /></span> <span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:sendModif(event)" /></span></td>
			<td><input type="hidden" value="${vlan.site}" />${vlan.site_name}</td>
			<td><input type="hidden" value="${vlan.id}" />${vlan.vid}</td>
			<td>${vlan.def}</td>
		</tr></c:forEach></tbody>
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
					<option value="15">15</option>
					<option value="30" selected="selected">30</option>
					<option value="50">50</option>
				</select>
				<span><fmt:message key="tiny.table.recordpage" /></span>
			</div>
			<div class="page"><fmt:message key="tiny.table.page" /> <span id="currentpage"></span> / <span id="totalpages"></span></div>
		</div>
	</div>
</div>
<div id="dlgcontent"/>
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
		size:30,
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
