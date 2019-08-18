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
<c:if test="${validUser.template && !empty param.id}">
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="norm.box.lst.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<c:choose><c:when test="${empty param.list}"><c:set var="mylist" value="-1" /></c:when><c:otherwise><c:set var="mylist" value="${param.list}" /></c:otherwise></c:choose>
<sql:query var="surnets">select id,ip,mask,def from surnets where id>0 order by ip</sql:query>
<sql:query var="selections">select id,ip,mask,def from surnets where id in (${mylist})</sql:query>
<table style="text-align:center">
<tr>
<td><select id="sel_lst_sub_dispo" size="30" multiple="multiple"><c:forEach items="${surnets.rows}" var="surnet"><option value="${surnet.id}"><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} (${surnet.def})</option></c:forEach></select></td>
<td><img src="../img/choice_right.png" class="pic" alt="${lang_commonclickadd}" onclick="javascript:addLstSub()" /><img src="../img/choice_left.png" alt="${lang_commonclickdel}" onclick="javascript:delLstSub()" /></td>
<td><select id="sel_lst_sub_choisi" size="30" multiple="multiple"><c:forEach items="${selections.rows}" var="selection"><option value="${selection.id}"><adrezo:displayIP value="${selection.ip}" />/${selection.mask} (${selection.def})</option></c:forEach></select></td>
<td><img src="../img/choice_up.png" class="pic" alt="${lang_commonclickadd}" onclick="javascript:moveUpLst()" /><img src="../img/choice_down.png" alt="${lang_commonclickdel}" onclick="javascript:moveDownLst()" /></td>
</tr>
<tr><td colspan="4" align="center"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:lstValid('${param.id}')" /></td></tr>
</table>
</body>
</html>
</c:if>
