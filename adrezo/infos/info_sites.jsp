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
<c:choose><c:when test="${validUser.read}">
<fmt:message key="common.click.xls" var="lang_commonclickxls" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="info.site.title" /></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/infos.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyinfotable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/scrolltable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/info_sites.js"></script>
</head>
<body onload='javascript:loadTable()'>
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="info.site.list" /> <span class="xls" onmouseover="javascript:tooltip.show('${lang_commonclickxls}')" onmouseout="javascript:tooltip.hide()" onclick="javascript:window.open('${pageContext.request.contextPath}/excelinfos?type=site')"><img class="image" src="../img/icon_excel.jpg" alt="${lang_commonclickxls}" /></span></h2>
<input type="hidden" id="sqs_id" value="2" />
<input type="hidden" id="sqs_limit" value="32" />
<input type="hidden" id="sqs_offset" value="0" />
<input type="hidden" id="sqs_order" value="cod_site" />
<input type="hidden" id="sqs_sort" value="asc" />
<input type="hidden" id="sqs_special" value="" />
<input type="hidden" id="sortiny_column" value="2" />
<input type="hidden" id="sortiny_dir" value="1" />
<div id="tablewrapper">
	<div id="tableheader">
	  <div class="search">
	  	<div class="searchtext"><fmt:message key="ip.click.search" /></div>
			<input type="text" id="sqs_search" oninput="searchTable()" value="" />
		</div>
	</div>
	<table id="tableheaders" class="overheaders">
		<thead><tr><th><h3>ID</h3></th><th><h3><fmt:message key="admin.ctx" /></h3></th><th><h3><fmt:message key="common.table.codesite" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th></tr></thead>
	</table>
	<table id="tableinfos" class="tinytable">
		<thead><tr><th><h3>ID</h3></th><th><h3><fmt:message key="admin.ctx" /></h3></th><th><h3><fmt:message key="common.table.codesite" /></h3></th><th><h3><fmt:message key="common.table.name" /></h3></th></tr></thead>
		<tbody></tbody>
	</table>
</div>
<div id="tablefooter"></div>
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
</c:when><c:otherwise><html><body><fmt:message key="common.noaccess" /></body></html></c:otherwise></c:choose>
