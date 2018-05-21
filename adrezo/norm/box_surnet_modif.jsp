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
<head><title><fmt:message key="norm.box.modif.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<sql:query var="surnets">select * from surnets where id=${param.id}</sql:query>
<c:forEach items="${surnets.rows}" var="surnet">
<div><fmt:message key="norm.box.modif.title" />${surnet.ID} : <adrezo:displayIP value="${surnet.IP}" />/${surnet.MASK} (${surnet.DEF})</div>
<hr />
<table>
<thead><tr><th><fmt:message key="common.table.ipshort" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.infos" /></th><th><fmt:message key="common.table.calc" /></th></tr></thead>
<tbody><tr id="modRow">
<td><input type="hidden" value="${param.id}" /><input type="text" value='<adrezo:displayIP value="${surnet.IP}" />' size="15" id="box_surnet_ip" onkeyup="javascript:verifNet()" /></td>
<td><input type="text" value="${surnet.MASK}" size="3" id="box_surnet_mask" onkeyup="javascript:verifNet()" /></td>
<td><input type="text" value="${surnet.DEF}" size="30" /></td>
<td><textarea rows="6" cols="80" id="tinyeditor">${surnet.INFOS}</textarea></td>
<td><input type="checkbox" <c:if test="${surnet.calc > 0}"> checked="checked"</c:if> /></td>
</tr>
<tr><td colspan="5" align="center"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:modValid(event)" /></td></tr>
<tr><td colspan="5" style="color:red" id="boxerror"></td></tr>
<tr><td colspan="5" style="color:orange;display:none;" id="boxwarn"><fmt:message key="norm.box.verifnet" /></td></tr>
</tbody></table>
</c:forEach>
</body>
</html>
</c:if>
