<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.rezo && !empty param.cod && !empty param.ctx && !empty param.tpl && !empty param.surnet && !empty param.mask && !empty param.parent}">
	<c:set var="message"><valid>true</valid></c:set>
	<sql:query var="vlans">select * from tpl_vlan where tpl=${param.tpl}</sql:query>
	<c:catch var="errInsert">
		<sql:transaction>
			<sql:update>
				insert into sites (id,ctx,cod_site,name)
				values (${adrezo:dbSeqNextval('sites_seq')}, ?${adrezo:dbCast('INTEGER')}, ?, ?)
				<sql:param value="${param.ctx}"/>
				<sql:param value="${param.cod}"/>
				<sql:param value="${param.name}"/>
			</sql:update>
			<sql:query var="siteid">select ${adrezo:dbSeqCurrval('sites_seq')} as seq<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> from dual</c:if></sql:query>
			<c:set var="mysite" value="${siteid.rows[0].seq}" />
			<c:forEach items="${vlans.rows}" var="vlan">
				<c:set var="myvdef" value="${fn:replace(vlan.def,'#CODE#',param.cod)}" />
				<c:set var="myvdef" value="${fn:replace(myvdef,'#SITE#',param.name)}" />
				<sql:update>
					insert into vlan (id,vid,def,site)
					values (${adrezo:dbSeqNextval('vlan_seq')}, ?${adrezo:dbCast('INTEGER')}, ?, ${mysite})
					<sql:param value="${vlan.vid}"/>
					<sql:param value="${myvdef}"/>
				</sql:update>
				<sql:query var="vlanid">select ${adrezo:dbSeqCurrval('vlan_seq')} as seq<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> from dual</c:if></sql:query>
				<c:set var="myvlan" value="${vlanid.rows[0].seq}" />
				<sql:query var="subnets">select * from tpl_subnet where tpl=${param.tpl} and vlan=${vlan.id}</sql:query>
				<c:forEach items="${subnets.rows}" var="subnet">
					<c:set var="mysdef" value="${fn:replace(subnet.def,'#CODE#',param.cod)}" />
					<c:set var="mysdef" value="${fn:replace(mysdef,'#SITE#',param.name)}" />
					<sql:update>
						insert into subnets (id,ctx,site,ip,mask,def,gw,bc,vlan)
						values (${adrezo:dbSeqNextval('subnets_seq')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?, ?${adrezo:dbCast('INTEGER')}, ?, ?, ?, ?${adrezo:dbCast('INTEGER')})
						<sql:param value="${param.ctx}"/>
						<sql:param value="${mysite}"/>
						<sql:param value="${adrezo:templateIP(param.surnet,subnet.ip)}"/>
						<sql:param value="${subnet.mask}"/>
						<sql:param value="${mysdef}"/>
						<sql:param value="${adrezo:templateIP(param.surnet,subnet.gw)}"/>
						<sql:param value="${adrezo:templateIP(param.surnet,subnet.bc)}"/>
						<sql:param value="${myvlan}"/>
					</sql:update>
				</c:forEach>
			</c:forEach>
			<sql:update>
				insert into surnets (id,ip,mask,def,infos,parent,calc)
				values (${adrezo:dbSeqNextval('surnets_seq')}, ?, ?${adrezo:dbCast('INTEGER')}, ?, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
				<sql:param value="${param.surnet}"/>
				<sql:param value="${param.mask}"/>
				<sql:param value="${param.name}"/>
				<sql:param value=""/>
				<sql:param value="${param.parent}"/>
				<sql:param value="1"/>
			</sql:update>
		</sql:transaction>			
	</c:catch>
	<c:choose>
		<c:when test="${errInsert != null}">
			<adrezo:fileDB value="${errInsert}"/>
			<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.site" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
		</c:when>
		<c:otherwise>
			<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.site" /> : <fmt:message key="common.ok" /></msg></c:set>
		</c:otherwise>
	</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
