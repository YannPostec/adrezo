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
<fmt:message key="common.click.admin" var="lang_commonclickadmin" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="photo.album.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="expires" content="0" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinyaccordion.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinybox.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/photo_album.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinyaccordion.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinybox.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/photo_album.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="sites">select id,name from sites where ctx = ${validUser.ctx} order by name</sql:query>
<fmt:message key="photo.album.display" /> : <select id="selsite" onchange="javascript:FillSalle(this,'selsalle')"><option><fmt:message key="common.select.site" /></option><c:forEach items="${sites.rows}" var="site"><option value="${site.id}">${site.name}</option></c:forEach></select>, <fmt:message key="common.table.room" /> : <select id="selsalle" onchange="javascript:FillBody(this)"><option><fmt:message key="common.select.room" /></option></select>
<c:if test="${validUser.photo}"><span id="adminspan" onmouseover="javascript:tooltip.show('${lang_commonclickadmin}')" onmouseout="javascript:tooltip.hide()"><img id="adminchoice" src="../img/button_admin_red.png" alt="${lang_commonclickadmin}" onclick="javascript:showAdmin(true)" data-choice="no"/></span></c:if>
<hr />
<div id="InfosDatesPhotos" style="display:none;"><fmt:message key="photo.newest" /><span id="NewestPic"></span>, <fmt:message key="photo.oldest" /><span id="OldestPic"></span><hr /></div>
<div id="album"></div>
<div id="dlgcontent"></div>
</body>
</html>
