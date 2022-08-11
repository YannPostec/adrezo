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
<c:if test="${validUser.admin && !empty param.role && !empty param.elt}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxrolenewctx.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<jsp:useBean id="testRoles" scope="page" class="ypodev.adrezo.beans.TestRolesBean" />
<c:set target="${testRoles}" property="roles" value="${param.role}" />
<table>
<thead><tr><th><fmt:message key="admin.right.ip" /></th><th><fmt:message key="admin.right.photo" /></th><th><fmt:message key="admin.right.stock" /></th><th><fmt:message key="admin.right.stockadm" /></th><th><fmt:message key="admin.right.adm" /></th><th><fmt:message key="admin.right.rezo" /></th><th><fmt:message key="admin.right.api" /></th><th><fmt:message key="admin.right.template" /></th><th><fmt:message key="admin.right.read" /></th></tr></thead>
<tbody>
<tr id="newctx_tr">
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.ip}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.photo}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.stock}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.stockAdmin}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.admin}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.rezo}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.api}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.template}'> checked="true"</c:if> /></td>
<td style="text-align:center"><input type="checkbox" value="true" <c:if test='${testRoles.read}'> checked="true"</c:if> /></td>
</tr>
<tr><td colspan="9" style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:NewCtxValid('${param.elt}')" /></span></td></tr>
</tbody></table>
</body></html>
<c:remove var="testRoles" scope="page"/>
</c:if>
