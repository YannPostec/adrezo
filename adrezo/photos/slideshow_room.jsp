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
<c:if test="${!empty param.salle}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="photo.slide.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<meta http-equiv="expires" content="0" />
<link rel="stylesheet" href="../stylesheet/photo_slideshow.css" type="text/css" />
<sql:query var="imgs">select id,name,dir,suf,updt from photo where type = 0 and idparent = ${param.salle} order by name</sql:query>
<style>
<c:forEach items="${imgs.rows}" var="img" varStatus="cpt">
.slide:nth-of-type(${cpt.count}){
  background-image: url('${adrezo:envEntry('photo_webhost')}${img.dir}/${img.id}.${img.suf}');
}
</c:forEach>
</style>
</head>
<body>
<div class="container">
	<ul id="slides">
	<c:forEach items="${imgs.rows}" var="img" varStatus="cpt">
		<li class="slide<c:if test="${cpt.count == 1}"> showing</c:if>">
			<fmt:formatDate value="${img.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
			<p>${img.name}</p>
			<p>${fmtDatePhoto}</p>
		</li>
	</c:forEach>
	</ul>
	<div class="buttons">
		<button class="controls" id="previous">&lt;</button>

		<button class="controls" id="pause">&#10074;&#10074;</button>

		<button class="controls" id="next">&gt;</button>
	</div>
</div>
<script type="text/javascript">var SlideTime = ${validUser.slidetime}</script>
<script type="text/javascript" charset="utf-8" src="../js/photo_slideshow.js"></script>
</body>
</html>
</c:if>
