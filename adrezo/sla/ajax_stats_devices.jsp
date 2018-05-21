<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser != null && pageContext.request.method == 'POST' && !empty param.stamp1 && !empty param.stamp2 && !empty param.comp && !empty param.id && !empty param.digit}">
<sql:query var="devices">select device,device_name,avg(case when stamp like '${param.stamp1}%' then availability else null end) as dispo1,avg(case when stamp like '${param.stamp2}%' then availability else null end) as dispo2 from slastats_display where site=${param.id} group by device,device_name order by device_name</sql:query>
<c:forEach items="${devices.rows}" var="device">
	<fmt:formatNumber value="${device.dispo1}" maxFractionDigits="${param.digit}" type="number" var="fmtDispo1" />
	<fmt:formatNumber value="${device.dispo2}" maxFractionDigits="${param.digit}" type="number" var="fmtDispo2" />
	<c:set var="fmtDiff" value="${device.dispo1 - device.dispo2}" />
	<c:if test="${fmtDispo1 != null}">
		<li>${device.device_name} : ${fmtDispo1} %<c:if test="${param.comp>0}"> ( <fmt:message key="sla.compare" />: <c:choose><c:when test="${fmtDispo2 != null}">${fmtDispo2} % <c:choose><c:when test="${fmtDiff < 0}"><img src="../img/icon_down.png" alt="Down" /></c:when><c:when test="${fmtDiff > 0}"><img src="../img/icon_up.png" alt="Up" /></c:when><c:when test="${fmtDiff == 0}"><img src="../img/icon_equal.png" alt="Equal" /></c:when></c:choose></c:when><c:otherwise><fmt:message key="sla.nostat" /></c:otherwise></c:choose> )</c:if></li>
	</c:if>
</c:forEach>
</c:if>
