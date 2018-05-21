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
<c:if test="${validUser != null && pageContext.request.method == 'POST' && !empty param.subnet && !empty param.ip}">
<sql:query var="subs">select def,ip,mask,site_name from subnets_display where ctx=${validUser.ctx} and id=${param.subnet}</sql:query>
<sql:query var="ips">select ip from adresses where ctx=${validUser.ctx} and subnet=${param.subnet} and ip='${param.ip}'</sql:query>
<c:forEach items="${subs.rows}" var="sub">${sub.site_name}, ${sub.def} (<adrezo:displayIP value="${sub.ip}" />/${sub.mask})</c:forEach>
<fmt:message key="common.space" />
<c:choose>
<c:when test="${ips.rowCount != 0}"><fmt:message key="ip.suggest.ko" /></c:when>
<c:otherwise><fmt:message key="ip.suggest.ok" /></c:otherwise>
</c:choose>
</c:if>
