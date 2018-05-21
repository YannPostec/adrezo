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
<c:if test="${validUser.rezo && !empty param.parent}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="norm.root" var="lang_normroot" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="norm.box.add.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<c:choose><c:when test="${param.parent == 0}"><c:set var="surparent" value="${lang_normroot}" /></c:when>
<c:otherwise><sql:query var="surnets">select * from surnets where id=${param.parent}</sql:query>
<c:forEach items="${surnets.rows}" var="surnet"><c:set var="surparent"><adrezo:displayIP value="${surnet.IP}" />/${surnet.MASK} (${surnet.DEF})</c:set></c:forEach>
</c:otherwise></c:choose>
<div><fmt:message key="norm.box.add.txt" />${surparent}</div>
<hr />
<table>
<thead><tr><th><fmt:message key="common.table.ipshort" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="common.table.def" /></th><th><fmt:message key="common.table.infos" /></th><th><fmt:message key="common.table.calc" /></th></tr></thead>
<tbody>
<tr id="addRow">
<td><input type="hidden" value="${param.parent}" /><input type="text" value="" size="15" id="box_surnet_ip" onkeyup="javascript:verifNet()" /></td>
<td><input type="text" value="" size="3" id="box_surnet_mask" onkeyup="javascript:verifNet()" /></td>
<td><input type="text" value="" size="30" /></td>
<td><textarea rows="6" cols="80" id="tinyeditor"></textarea></td>
<td><input type="checkbox" checked="checked" /></td>
</tr>
<tr><td colspan="5" align="center"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:addValid(event)" /></td></tr>
<tr><td colspan="5" style="color:red" id="boxerror"></td></tr>
<tr><td colspan="5" style="color:orange;display:none;" id="boxwarn"><fmt:message key="norm.box.verifnet" /></td></tr>
</tbody></table>
</body>
</html>
</c:if>
