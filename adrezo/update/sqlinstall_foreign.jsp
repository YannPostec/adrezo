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
	<c:when test="${pageContext.request.method == 'POST' && fn:contains(header.referer,'install.jsp') }">
		<c:set var="message"><valid>true</valid></c:set>
		<c:catch var="err">
			<sql:transaction>
				<sql:update>alter table adresses add constraint fgn_adresses_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table api add constraint fgn_api_id foreign key (id) references auth_users(id)</sql:update>
				<sql:update>alter table auth_annu add constraint fgn_auth_annu_type foreign key (type) references auth_annu_types (id)</sql:update>
				<sql:update>alter table auth_ldap add constraint fgn_auth_ldap_id foreign key (id) references auth_annu (id)</sql:update>
				<sql:update>alter table auth_rights add constraint fgn_auth_rights_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table auth_rights add constraint fgn_auth_rights_role foreign key (role) references auth_roles (id)</sql:update>
				<sql:update>alter table auth_roles add constraint fgn_auth_roles_annu foreign key (annu) references auth_annu (id)</sql:update>
				<sql:update>alter table auth_roles add constraint fgn_auth_roles_pref foreign key (pref_ctx) references contextes (id)</sql:update>
				<sql:update>alter table dhcp_server add constraint fgn_dhcpserver_type foreign key (type) references dhcp_type (id)</sql:update>
				<sql:update>alter table photo_baie add constraint fgn_photobaie_box foreign key (idbox) references photo_box (id)</sql:update>
				<sql:update>alter table photo_box add constraint fgn_photobox_salle foreign key (idsalle) references salles (id)</sql:update>
				<sql:update>alter table salles add constraint fgn_salles_site foreign key (idsite) references sites (id)</sql:update>
				<sql:update>alter table sites add constraint fgn_sites_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table sladevice add constraint fgn_sladevice_site foreign key (site) references slasite (id)</sql:update>
				<sql:update>alter table slasite add constraint fgn_slasite_client foreign key (client) references slaclient (id)</sql:update>
				<sql:update>alter table slastats add constraint fgn_slastats_device foreign key (device) references sladevice (id)</sql:update>
				<sql:update>alter table sladays add constraint fgn_sladays_device foreign key (device) references sladevice (id)</sql:update>
				<sql:update>alter table slahours add constraint fgn_slahours_device foreign key (device) references sladevice (id)</sql:update>
				<sql:update>alter table stock_etat add constraint fgn_stock_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table stock_etat add constraint fgn_stock_etat_cat foreign key (cat) references stock_cat (id)</sql:update>
				<sql:update>alter table stock_mvt add constraint fgn_stock_id foreign key (id) references stock_etat (id)</sql:update>
				<sql:update>alter table subnets add constraint fgn_subnets_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table subnets add constraint fgn_subnets_site foreign key (site) references sites (id)</sql:update>
				<sql:update>alter table subnets add constraint fgn_subnets_vlan foreign key (vlan) references vlan (id)</sql:update>
				<sql:update>alter table subnets add constraint fgn_surnet_id foreign key (surnet) references surnets (id)</sql:update>
				<sql:update>alter table usercookie add constraint fgn_usercookie_lang foreign key (lang) references langues (code)</sql:update>
				<sql:update>alter table vlan add constraint fgn_vlan_ctx foreign key (ctx) references contextes (id)</sql:update>
				<sql:update>alter table vlan add constraint fgn_vlan_site foreign key (site) references sites (id)</sql:update>
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
