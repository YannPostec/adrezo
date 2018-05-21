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
<c:if test="${validUser.admin}">
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="admin.mail.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydropdown.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinydialog.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/tinytooltip.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/common.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/admin_mails.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydropdown.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinytooltip.js"></script>
<script type="text/javascript" charset="utf-8" src="../js/tinydialog.js"></script>
</head>
<body>
<%@ include file="../menu.jsp" %>
<sql:query var="mails">select * from mail order by id</sql:query>
<div><fmt:message key="admin.mail.list" /> :</div>
<table>
<thead><tr><th /><th>ID</th><th><fmt:message key="admin.lang" /></th><th><fmt:message key="common.table.table" /></th><th><fmt:message key="common.table.dest" /></th><th><fmt:message key="common.table.subject" /></th><th><fmt:message key="common.table.msg" /></th></tr></thead>
<tbody>
<c:forEach items="${mails.rows}" var="mail">
<tr style="text-align:center">
<td><span onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickmod}" onclick="javascript:addSubmit(event)" /></span></td>
<td><input type="hidden" value="${mail.id}" />${mail.id}</td>
<td><input type="hidden" value="${mail.lang}" /><img src="../img/flags/${mail.lang}.png" alt="flag" /></td>
<td>${mail.location}</td>
<td><input type="text" size="20" value="${mail.destinataire}"></td>
<td><input type="text" size="40" value="${mail.subject}"></td>
<td><input type="text" size="120" value="${mail.message}"></td>
</tr>
</c:forEach>
</tbody>
</table>
<div id="dlgcontent"/>
</body></html>
</c:if>
