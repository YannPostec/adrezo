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
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.cancel" var="lang_commonclickcancel" />
<fmt:message key="common.click.reset" var="lang_commonclickreset" />
<fmt:message key="admin.red.ip" var="lang_redclickip" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.red.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_redundancy.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="reds">select * from redundancy_display where ctx=${validUser.ctx} order by ptype,pid</sql:query>
<sql:query var="ptypes">select * from redund_ptype order by name</sql:query>
<input type="hidden" id="myCtx" value="${validUser.ctx}" />
<div><fmt:message key="admin.red.list" /> :</div>
<table>
<thead>
<tr><th /><th /><th><fmt:message key="common.table.type" /></th><th>ID</th><th><fmt:message key="common.table.ip" /></th></tr>
<tr><td /><td><span onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickreset}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_refuse.png" alt="${lang_commonclickreset}" onclick="javascript:ResetAdd()" /></span></td>
<td><select id="add_ptype"><option><fmt:message key="common.select.proto" /></option><c:forEach items="${ptypes.rows}" var="ptype"><option value="${ptype.id}">${ptype.name}</option></c:forEach></select></td>
<td><input type="text" size="5" id="add_pid" value="" /></td>
<td style="text-align:center"><input type="hidden" id="add_id" value="" /><input type="hidden" id="add_ipid" value="" /><div id="add_ip"></div><span onmouseover="javascript:tooltip.show('${lang_redclickip}')" onmouseout="javascript:tooltip.hide()" id="add_span"><img src="../img/icon_database.png" alt="${lang_redclickip}" onclick="javascript:ChooseIP(event,'add_ipid')" /></span></td></tr>
</thead>
<tbody>
<c:forEach items="${reds.rows}" var="red">
<tr>
<td><span onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:ConfirmDlg(${red.id})" /></span></td>
<td style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:CreateModif(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addSubmit(event)" /></span><span onmouseover="javascript:tooltip.show('${lang_commonclickcancel}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_refuse.png" alt="${lang_commonclickcancel}" onclick="javascript:CancelModif(event)" /></span></td>
<td><select style="display:none"><option><fmt:message key="common.select.proto" /></option><c:forEach items="${ptypes.rows}" var="ptype"><option value="${ptype.id}"<c:if test="${ptype.id == red.ptype}"> selected="selected"</c:if>>${ptype.name}</option></c:forEach></select><input type="hidden" value="${red.ptype}" />${red.ptype_name}</td>
<td>${red.pid}</td>
<td style="text-align:center"><input type="hidden" value="${red.id}" /><input type="hidden" id="ipid_${red.id}" value="${red.ipid}" /><div><adrezo:displayIP value="${red.ip}"/>/${red.mask} (${red.ip_name}) [${red.site_name}/${red.subnet_name}]</div><span onmouseover="javascript:tooltip.show('${lang_redclickip}')" onmouseout="javascript:tooltip.hide()" style="display:none;"><img src="../img/icon_database.png" alt="${lang_redclickip}" onclick="javascript:ChooseIP(event,'ipid_${red.id}')" /></span></td>
</tr>
</c:forEach>
</tbody>
</table>
<div id="dlgcontent"/>
</body></html>
</c:if>
