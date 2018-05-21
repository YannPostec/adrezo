<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<fmt:message key="common.close" var="lang_commonclose" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<title><fmt:message key="photo.replace.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<c:if test="${validUser.photo && !empty param.id && !empty param.suf && !empty param.dir}">
<h3><fmt:message key="photo.replace.title" /><fmt:message key="common.space" />${param.name}</h3>
<hr />
<form method="POST" enctype="multipart/form-data" id="fReplaceUpload">
<input type="hidden" name="dir" id="upDir" value="${param.dir}" />
<input type="hidden" name="suf" id="upSuf" value="${param.suf}" />
<input type="hidden" name="id" id="upId" value="${param.id}" />
<input type="file" size="40" name="file" id="upFile" /><br />
<p class="upp"><input id="upBtnUpload" type="button" value="Upload" onclick="javascript:submitReplaceUpload()" /></p>
<progress class="progress" id="upProgress" value="0" max="100"></progress>
<h3 id="upStatus"></h3>
<p class="upresult" id="upResult"></p>
<input class="upclose" id="upBtnClose" type="button" value="${lang_commonclose}" onclick="javascript:TINY.box.hide()" />
</form>
</c:if>
</body>
</html>
