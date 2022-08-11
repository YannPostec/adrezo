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
<c:if test="${validUser.admin && !empty param.id}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxroleright.title" /> ${param.id}</title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<jsp:useBean id="testRoles" scope="page" class="ypodev.adrezo.beans.TestRolesBean" />
<sql:query var="rights">select * from auth_rights_display where role = ${param.id}</sql:query>
<h2><fmt:message key="admin.boxroleright.text" /><fmt:message key="common.space" />${param.name}</h2>
<div><fmt:message key="admin.right.reminder" /> :
<ul>
<li>0)   <fmt:message key="admin.right.noaccess.txt" /></li>
<li>1)   <fmt:message key="admin.right.ip.txt" /></li>
<li>2)   <fmt:message key="admin.right.photo.txt" /></li>
<li>4)   <fmt:message key="admin.right.stock.txt" /></li>
<li>8)   <fmt:message key="admin.right.stockadm.txt" /></li>
<li>16)  <fmt:message key="admin.right.adm.txt" /></li>
<li>32)  <fmt:message key="admin.right.rezo.txt" /></li>
<li>64)  <fmt:message key="admin.right.api.txt" /></li>
<li>128)  <fmt:message key="admin.right.template.txt" /></li>
<li>256)  <fmt:message key="admin.right.read.txt" /></li>
</ul>
</div>
<hr />
<table id="right_table">
<thead><tr><th><fmt:message key="admin.ctx" /></th><th><fmt:message key="admin.right.ip" /></th><th><fmt:message key="admin.right.photo" /></th><th><fmt:message key="admin.right.stock" /></th><th><fmt:message key="admin.right.stockadm" /></th><th><fmt:message key="admin.right.adm" /></th><th><fmt:message key="admin.right.rezo" /></th><th><fmt:message key="admin.right.api" /></th><th><fmt:message key="admin.right.template" /></th><th><fmt:message key="admin.right.read" /></th></tr></thead>
<tbody>
<c:forEach items="${rights.rows}" var="right">
<c:set target="${testRoles}" property="roles" value="${right.rights}" />
<tr>
<td style="text-align:center"><input type="hidden" value="${right.ctx}" />${right.ctx_name}</td>
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
</c:forEach>
<tr><td colspan="10" style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:RightsValid(event,${param.id})" /></span></td></tr>
</tbody></table>
</body></html>
<c:remove var="testRoles" scope="page"/>
</c:if>
