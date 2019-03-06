<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<c:choose>
	<c:when test="${pageContext.request.method == 'POST' && fn:contains(header.referer,'update.jsp') }">
		<c:set var="message"><valid>true</valid></c:set>
		<c:catch var="err">
			<sql:transaction>
				<sql:update>create or replace view subnets_display (id,ctx,site,ip,mask,def,gw,bc,cod_site,site_name,vlan,vid,vdef,surnet,ctx_name,surip,surmask,surdef) as select s.id,s.ctx,s.site,s.ip,s.mask,s.def,s.gw,s.bc,a.cod_site,a.name as site_name,s.vlan,v.vid,v.def as vdef,s.surnet,c.name as ctx_name,b.ip as surip,b.mask as surmask,b.def as surdef from subnets s,contextes c,sites a,vlan v,surnets b where s.ctx=c.id and s.site=a.id and s.vlan=v.id and s.surnet=b.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>update usercookie set mail='201' where login='admin'</sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${err != null}">
				<adrezo:fileDB value="${err}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><adrezo:trim value="${err}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:set var="message"><valid>false</valid></c:set>
	</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
