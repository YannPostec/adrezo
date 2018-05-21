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
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.subnet.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/ip_calc.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_subnets.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytable.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="subnets">select * from subnets_display where ctx=${validUser.ctx} order by ip</sql:query>
<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<h3><fmt:message key="admin.mgt" /> :</h3>
<table><thead><tr><th /><th><fmt:message key="admin.site" /></th><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.ipgw" /></th><th><fmt:message key="common.table.ipbc" /></th><th><fmt:message key="admin.vlan" /></th></tr></thead>
<tbody><tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit()" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_site" onchange="javascript:FillVlan(0)"><option><fmt:message key="common.select.site" /></option><c:forEach items="${sites.rows}" var="site"><option value="${site.ID}">${site.name}</option></c:forEach></select></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="16" id="add_ip" value="" onkeyup="javascript:calcBC()" /></td>
	<td><input type="hidden" id="add_ctx" value="${validUser.ctx}" /><input type="text" size="2" id="add_mask" value="" onkeyup="javascript:calcBC()" /></td>
	<td><input type="text" size="20" id="add_def" value="" /></td>
	<td><input type="text" size="16" id="add_gw" value="" /></td>
	<td><input type="text" size="16" id="add_bc" value="" /></td>
	<td><select id="add_vlan"><option><fmt:message key="common.select.vlan" /></option></select></td>
</tr></tbody></table>
<h3><fmt:message key="admin.subnet.list" /> :</h3>
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
		<thead><tr><th class="nosort"><h3 class="nosearch" /></th><th><h3><fmt:message key="admin.site" /></h3></th><th><h3><fmt:message key="admin.subnet" /></h3></th><th><h3><fmt:message key="common.table.mask" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th><th><h3><fmt:message key="common.table.ipgw" /></h3></th><th><h3><fmt:message key="common.table.ipbc" /></h3></th><th><h3><fmt:message key="admin.vlan" /></h3></th></tr></thead>
		<tbody><c:forEach items="${subnets.rows}" var="subnet"><tr>
			<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${subnet.id})" /></span> <span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:sendModif(event)" /></span></td>
			<td><input type="hidden" value="${subnet.site}" />${subnet.site_name}</td>
			<td><input type="hidden" value="${subnet.id}" /><adrezo:displayIP value="${subnet.ip}"/></td>
			<td>${subnet.mask}</td>
			<td>${subnet.def}</td>
			<td><adrezo:displayIP value="${subnet.gw}"/></td>
			<td><adrezo:displayIP value="${subnet.bc}"/></td>
			<td><input type="hidden" value="${subnet.vlan}" />${subnet.vid} : ${subnet.vdef}</td>
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
		sortcolumn:2,
		sortdir:1,
		init:true
	});
</script>
</body>
</html>
</c:if>
