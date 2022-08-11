<%-- @Author: Yann POSTEC --%>
<%@ page contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%@ taglib prefix="json" uri="http://www.atg.com/taglibs/json" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && validUser.read && pageContext.request.method == 'POST'}">
<sql:query var="sites">select id,name from sites where ctx=${validUser.ctx} order by name</sql:query>
<sql:query var="subs">select id,def,ip,mask,site from subnets where ctx=${validUser.ctx} order by def</sql:query>
<sql:query var="types">select distinct type from adresses where ctx=${validUser.ctx} order by type</sql:query>
<json:object>
	<json:array name="sites" var="site" items="${sites.rows}">
		<json:object escapeXml="false">
			<json:property name="id" value="${site.id}" />
			<json:property name="name" value="${site.name}" />
		</json:object>
	</json:array>
	<json:array name="subnets" var="subnet" items="${subs.rows}">
		<json:object escapeXml="false">
			<json:property name="id" value="${subnet.id}" />
			<json:property name="def" value="${subnet.def}" />
			<json:property name="ip" value="${subnet.ip}" />
			<json:property name="mask" value="${subnet.mask}" />
			<json:property name="site" value="${subnet.site}" />
		</json:object>
	</json:array>
	<json:array name="types" var="type" items="${types.rows}">
		<json:object>
			<json:property name="name" value="${type.type}" />
		</json:object>
	</json:array>
</json:object>	
</c:when>
<c:otherwise>
<json:object>
	<json:array name="sites" />
	<json:array name="subnets" />
	<json:array name="types" />
</json:object>	
</c:otherwise>
</c:choose>
