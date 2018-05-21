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
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.api.box.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<div><fmt:message key="admin.api.box.title" /></div>
<hr />
<div id="box_api_wait"></div>
<sql:query var="apis">select * from api where id=${param.id}</sql:query>
<c:if test="${!empty apis.rows}">
	<sql:query var="subnets">select id,ip,mask,def from subnets where id in (${apis.rows[0].subnets})</sql:query>
</c:if>
<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
<sql:query var="contextes">select id,name from contextes where id in (select ctx from auth_rights where role in (select role from auth_users where id=${param.id}) and BITAND(rights,64)=64) order by name</sql:query>
</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
<sql:query var="contextes">select id,name from contextes where id in (select ctx from auth_rights where role in (select role from auth_users where id=${param.id}) and rights & 64 = 64) order by name</sql:query>
</c:when></c:choose>
<table style="text-align:center">
<tr>
<td><select id="sel_lst_ctx" onchange="javascript:FillSite(this)"><option><fmt:message key="common.select.ctx" /></option><c:forEach items="${contextes.rows}" var="contexte"><option value="${contexte.id}">${contexte.name}</option></c:forEach></select></td>
<td />
<td><select id="sel_lst_site" onchange="javascript:FillSub(this,true)"><option value="all"><fmt:message key="norm.box.lst.all" /></option></select></td>
</tr>
<tr>
<td><select id="sel_lst_sub_dispo" size="30" multiple="multiple"></select></td>
<td><img src="../img/choice_right.png" class="pic" alt="${lang_commonclickadd}" onclick="javascript:addLstSub()" /><img src="../img/choice_left.png" alt="${lang_commonclickdel}" onclick="javascript:delLstSub()" /></td>
<td><select id="sel_lst_sub_choisi" size="30" multiple="multiple"><c:if test="${!empty apis.rows}"><c:forEach items="${subnets.rows}" var="subnet"><option value="${subnet.id}">${subnet.def} (<adrezo:displayIP value="${subnet.ip}" />/${subnet.mask})</option></c:forEach></c:if></select></td>
</tr>
<tr><td colspan="3" align="center"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:lstValid()" /></td></tr>
</table>
</body>
</html>
</c:if>
