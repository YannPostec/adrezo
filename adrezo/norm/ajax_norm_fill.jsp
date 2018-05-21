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
<c:if test="${validUser != null && pageContext.request.method == 'POST' && !empty param.id}">
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="admin.subnet.list" var="lang_commonclicksub" />
<fmt:message key="admin.subnet.calc" var="lang_commonclickcalc" />
<sql:query var="surnets">select 'r' as type,id,ip,mask,def,infos,calc from surnets where parent=${param.id} union select 'b' as type,id,ip,mask,def,'Contexte: '||ctx_name||', Site: '||site_name||', Vlan: '||vid as infos,0 as calc from subnets_display where surnet=${param.id} order by ip,mask</sql:query>
<c:forEach items="${surnets.rows}" var="surnet">
<c:if test="${surnet.type == 'r'}">
	<li id="surli${surnet.id}" onclick="javascript:fillSurnet(${surnet.id})" data-filled="0">
		<h3 data-style="surnet" id="surh${surnet.id}"><c:if test="${validUser.rezo}"><span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickdel}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_delete.jpg" alt="${lang_commonclickdel}" onclick="javascript:delConfirm(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickadd}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_commonclickadd}" onclick="javascript:addSubmit(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickmod}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_modify.jpg" alt="${lang_commonclickmod}" onclick="javascript:modSubmit(event,${surnet.id})" /></span> <span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclicksub}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_database.png" alt="${lang_commonclicksub}" onclick="javascript:lstSubmit(event,${surnet.id})" /></span> <c:if test="${surnet.calc > 0}"><span class="admin" onmouseover="javascript:tooltip.show('${lang_commonclickcalc}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_calc.png" alt="${lang_commonclickcalc}" onclick="javascript:calcSubmit(event,${surnet.id})" /></span> </c:if></c:if><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} (${surnet.def})</h3>
		<div class="acc-section"><div class="acc-content" id="surcontent${surnet.id}"><div id="surinfos${surnet.id}">${surnet.infos}</div></div></div>
	</li>
</c:if>
<c:if test="${surnet.type == 'b'}">
<sql:query var="reds">select ptype_name,pid,ip_name,ip from redundancy_display where subnet=${surnet.id}</sql:query>
	<li>
		<h3 data-style="subnet"><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} : ${surnet.def}</h3>
		<div class="acc-section"><div class="acc-content"><div>${surnet.infos}<c:forEach items="${reds.rows}" var="red"><br />${red.ptype_name} ID ${red.pid}: ${red.ip_name} (<adrezo:displayIP value="${red.ip}" />)</c:forEach></div></div></div>
	</li>
</c:if>
</c:forEach>
</c:if>
