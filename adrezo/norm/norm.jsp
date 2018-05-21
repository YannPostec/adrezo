<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<fmt:requestEncoding value="UTF-8" />
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="admin.subnet.list" var="lang_commonclicksub" />
<fmt:message key="admin.subnet.calc" var="lang_commonclickcalc" />
<fmt:message key="common.click.admin" var="lang_commonclickadmin" />
<fmt:message key="norm.click.root" var="lang_normclickroot" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="norm.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/ip_calc.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytable.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyaccordion.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyeditor.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/norm.js"></script>
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinyaccordion.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinyeditor.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytable.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/norm.css" type="text/css" />
</head>
<body>
<%@ include file="../menu.jsp" %>
<h2><fmt:message key="norm.title" /></h2>
<c:if test="${validUser.rezo}">
<span id="adminspan" onmouseover="javascript:tooltip.show('${lang_commonclickadmin}')" onmouseout="javascript:tooltip.hide()"><img id="adminchoice" src="../img/button_admin_red.png" alt="${lang_commonclickadmin}" onclick="javascript:showAdmin(true)" data-choice="no"/></span>
<span class="admin" onmouseover="javascript:tooltip.show('${lang_normclickroot}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_normclickroot}" onclick="javascript:addRoot(event)" /></span>
</c:if>
<div id="options"><a href="javascript:accroot.pr(1)"><fmt:message key="tiny.acc.unfold" /></a> | <a href="javascript:accroot.pr(-1)"><fmt:message key="tiny.acc.fold" /></a></div>
<hr />
<sql:query var="surnets">select * from surnets where parent=0 order by ip</sql:query>
<ul class="acc" id="acc0">
<c:forEach items="${surnets.rows}" var="surnet">
	<li id="surli${surnet.id}" onclick="javascript:fillSurnet(${surnet.id})" data-filled="0">
		<h3 data-style="surnet" id="surh${surnet.id}"><c:if test="${validUser.rezo}"><span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:delConfirm(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:modSubmit(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclicksub}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_commonclicksub}" onclick="javascript:lstSubmit(event,${surnet.id})" /></span> <c:if test="${surnet.calc > 0}"><span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickcalc}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_calc.png" alt="${lang_commonclickcalc}" onclick="javascript:calcSubmit(event,${surnet.id})" /></span> </c:if></c:if><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} (${surnet.def})</h3>
		<div class="acc-section"><div class="acc-content" id="surcontent${surnet.id}"><div id="surinfos${surnet.id}">${surnet.infos}</div></div></div>
	</li>
</c:forEach>
</ul>
<script type="text/javascript" charset="utf-8">
var accroot=new TINY.accordion.slider("accroot");
accroot.init("acc0","h3",0,-1);
</script>
<div id="dlgcontent"/>
</body>
</html>
