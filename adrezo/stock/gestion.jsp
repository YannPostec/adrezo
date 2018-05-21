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
<c:if test="${validUser.stockAdmin}">
<fmt:message key="stock.mgt.gomain" var="lang_stkgomain" />
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="stock.type.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/stock_gestion.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="mains">select site_main from contextes where id=${validUser.ctx}</sql:query>
<c:choose><c:when test="${mains.rows[0].site_main == 0}"><h2><fmt:message key="stock.mgt.undefined" /></h2></c:when>
<c:otherwise>
<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<c:choose><c:when test="${empty param.site}"><c:set var="stocksite" scope="page" value="${mains.rows[0].site_main}" /></c:when><c:otherwise><c:set var="stocksite" scope="page" value="${param.site}" /></c:otherwise></c:choose>
<form id="f_gestion" method="post"><div><fmt:message key="stock.type.list" /> <select id="selSite" name="site" onchange="javascript:changeStock()"><c:forEach items="${sites.rows}" var="site"><option value="${site.id}"<c:if test="${stocksite == site.id}"> selected="selected"</c:if>>${site.name}</option></c:forEach></select><input type="button" value="${lang_stkgomain}" onclick="javascript:goMainSite(${mains.rows[0].site_main})" /></div></form>
<sql:query var="types">select id,def,stock,seuil,idx,cat,idcat,encours,ctx,site from stock_etat_display where ctx=${validUser.ctx} and site=${stocksite} order by idx</sql:query>
<sql:query var="cats">select * from stock_cat order by name</sql:query>
<table>
<thead><tr><th /><th /><th><fmt:message key="common.table.cat" /></th><th><fmt:message key="common.table.idx" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.threshold" /></th><th><fmt:message key="common.table.ongoing" /></th></tr>
<tr>
	<td />
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
	<td><select id="add_cat"><option><fmt:message key="common.select.cat" /></option><c:forEach items="${cats.rows}" var="cat"><option value="${cat.ID}">${cat.NAME}</option></c:forEach></select></td>
	<td><input type="hidden" id="add_id" value="" /><input type="text" size="9" id="add_idx" value="" /></td>
	<td><input type="text" size="80" id="add_def" value="" /></td>
	<td><input type="text" size="6" id="add_seuil" value="0" /></td>
	<td><input type="text" size="6" id="add_encours" value="0" /></td>
</tr>
</thead>
<tbody>
<c:forEach items="${types.rows}" var="type">
<tr>
	<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${type.ID})" /></span></td>
	<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
	<td><select style="display:none"><option><fmt:message key="common.select.cat" /></option></select><input type="hidden" value="${type.idcat}" />${type.cat}</td>
	<td><input type="hidden" value="${type.id}" />${type.idx}</td>
	<td>${type.def}</td>
	<td>${type.seuil}</td>
	<td>${type.encours}</td>
</tr>
</c:forEach>
</tbody></table>
<div id="dlgcontent"/>
</c:otherwise></c:choose>
</body></html>
</c:if>
