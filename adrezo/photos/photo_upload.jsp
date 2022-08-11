<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.photo}">
<fmt:message key="common.close" var="lang_commonclose" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="photo.addphoto" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<c:if test="${validUser.photo && !empty param.type && !empty param.idparent}">
<h3><fmt:message key="photo.addphoto" /><fmt:message key="common.space" />${param.name}</h3>
<input type="hidden" id="upBaieName" value="${param.name}" />
<hr />
<form method="POST" enctype="multipart/form-data" id="fUpload">
	<input type="hidden" name="type" id="upType" value="${param.type}" />
	<input type="hidden" name="idparent" id="upIdParent" value="${param.idparent}" />
	<c:if test="${param.type == 0}">
		<p><fmt:message key="common.table.name" />: <input type="text" size="30" maxlength="50" name="name" id="upName" value="" /></p>
	</c:if>
	<c:if test="${param.type == 1}">
		<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
			<sql:query var="pics">select listagg(name,',') within group(order by name) as liste from photo where type=1 and idparent=${param.idparent}</sql:query>
		</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
			<sql:query var="pics">select string_agg(name,',') as liste from (select name from photo where type=1 and idparent=${param.idparent} order by name) as photonames</sql:query>
		</c:when></c:choose>
		<p><fmt:message key="common.table.position" />: <select name="name" id="upName">
		<c:if test="${pics.rowCount == 0 || !fn:contains(pics.rows[0].liste,'RH')}"><option value="RH"><fmt:message key="photo.upload.RH" /></option></c:if>
		<c:if test="${pics.rowCount == 0 || !fn:contains(pics.rows[0].liste,'RB')}"><option value="RB"><fmt:message key="photo.upload.RB" /></option></c:if>
		<c:if test="${pics.rowCount == 0 || !fn:contains(pics.rows[0].liste,'VH')}"><option value="VH"><fmt:message key="photo.upload.VH" /></option></c:if>
		<c:if test="${pics.rowCount == 0 || !fn:contains(pics.rows[0].liste,'VB')}"><option value="VB"><fmt:message key="photo.upload.VB" /></option></c:if>
		</select></p>
	</c:if>
	<p><input type="file" size="40" name="file" id="upFile" /></p>
	<p class="upp"><input id="upBtnUpload" type="button" value="Upload" onclick="javascript:submitUpload()" /></p>
	<progress class="progress" id="upProgress" value="0" max="100"></progress>
	<h3 id="upStatus"></h3>
	<p class="upresult" id="upResult"></p>
	<input class="upclose" id="upBtnClose" type="button" value="${lang_commonclose}" onclick="javascript:TINY.box.hide()" />
</form>
</c:if>
</body>
</html>
</c:if>
