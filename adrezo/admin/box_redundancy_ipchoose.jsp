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
<c:if test="${validUser.rezo && !empty param.id}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxredip.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<table><tbody><tr><td><fmt:message key="admin.boxredip.txtip" /> :</td><td><input type="text" size="20" value="" id="boxip_ip" /><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:BoxIP_Search('ip','${param.id}')" /></td></tr>
<tr><td><fmt:message key="admin.boxredip.txtname" /> :</td><td><input type="text" size="20" value="" id="boxip_name" /><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:BoxIP_Search('name','${param.id}')" /></td></tr></table>
<hr>
<table id="boxip_table">
<thead><tr><th /><th><fmt:message key="common.table.name" /></th><th><fmt:message key="common.table.ipmask" /></th><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="admin.site" /></th></tr></thead>
<tbody></tbody>
</table>
</body>
</html>
</c:if>
