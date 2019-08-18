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
<c:if test="${validUser.rezo && !empty param.cod && !empty param.ctx && !empty param.tpl}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxsitetpl.title" /> ${param.id}</title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<input type="hidden" id="addtpl_tpl" value="${param.tpl}" />
<input type="hidden" id="addtpl_ctx" value="${param.ctx}" />
<input type="hidden" id="addtpl_cod" value="${param.cod}" />
<input type="hidden" id="addtpl_name" value="${param.name}" />
<sql:query var="sites">select name,mask from tpl_site where id = ${param.tpl}</sql:query>
<sql:query var="surnets">select id,ip,mask,def from surnets where id>0 order by ip</sql:query>
<c:forEach items="${sites.rows}" var="site">
<h2>Ajouter un site suivant le modèle ${site.name}&nbsp;</h2>
<table><thead><tr><th><fmt:message key="admin.subnet" /></th><th><fmt:message key="common.table.mask" /></th><th><fmt:message key="template.site.parent" /></th></tr></thead>
<tbody><tr><td><input id="addtpl_ip" type="text" size="20" value="" /></td>
<td><input type="hidden" id="addtpl_mask" value="${site.mask}" />${site.mask}</td>
<td><select id="addtpl_parent">
	<option><fmt:message key="common.select.surnet" /></option>
	<option value="0"><fmt:message key="template.site.root" /></option>
	<c:forEach items="${surnets.rows}" var="surnet">
		<option value="${surnet.id}"><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} (${surnet.def})</option>
	</c:forEach>
</select></td>
</tr></tbody></table>
</c:forEach>
<hr />
<div id="tplsites_err" style="color:red"></div>
<p style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:BoxValid()" /></span></p>
</body></html>
</c:if>
