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
				<sql:update>alter table vlan drop constraint fgn_vlan_ctx</sql:update>
				<sql:update>create or replace view vlan_display (id,vid,def,site,ctx,cod_site,site_name,ctx_name) as select v.id,v.vid,v.def,v.site,s.ctx,s.cod_site,s.name as site_name,c.name as ctx_name from vlan v,sites s,contextes c where v.site=s.id and s.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>alter table vlan drop column ctx</sql:update>
				<sql:update>alter table stock_etat drop constraint fgn_stock_ctx</sql:update>
				<sql:update>create or replace view stock_etat_display (id,def,stock,seuil,idx,cat,idcat,encours,ctx,ctx_name,site,site_name) as select e.id,e.def,e.stock,e.seuil,e.idx,c.name,c.id,e.encours,x.id,x.name,e.site,s.name from stock_etat e,stock_cat c,contextes x,sites s where e.cat=c.id and e.site=s.id and s.ctx=x.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>alter table stock_etat drop column ctx</sql:update>
				<sql:update>alter table stock_etat add constraint fgn_stock_site foreign key (site) references sites (id)</sql:update>
				<c:choose>
				<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
					<sql:update>alter table dhcp_type add port number</sql:update>
					<sql:update>alter table dhcp_server add enable number(1,0) default 1</sql:update>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<sql:update>alter table dhcp_type add column port integer</sql:update>
					<sql:update>alter table dhcp_server add column enable integer default 1</sql:update>
				</c:when>
				</c:choose>
				<sql:update>update dhcp_type set port=6660 where id=1</sql:update>
				<sql:update>create or replace view dhcp_server_display (id,hostname,port,ssl,auth,login,pwd,type,type_name,enable) as select s.id,s.hostname,s.port,s.ssl,s.auth,s.login,s.pwd,s.type,t.name as type_name,s.enable from dhcp_server s, dhcp_type t where s.type=t.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>update usercookie set mail='198' where login='admin'</sql:update>
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
