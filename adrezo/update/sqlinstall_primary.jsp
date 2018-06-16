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
				<sql:update>alter table adresses add constraint pk_adresses primary key (ctx,ip,mask)</sql:update>
				<sql:update>alter table api add constraint pk_api primary key (id)</sql:update>
				<sql:update>alter table auth_annu add constraint pk_auth_annu primary key (id)</sql:update>
				<sql:update>alter table auth_annu_types add constraint pk_auth_annu_types primary key (id)</sql:update>
				<sql:update>alter table auth_ldap add constraint pk_auth_ldap primary key (id)</sql:update>
				<sql:update>alter table auth_rights add constraint pk_auth_rights primary key (ctx,role)</sql:update>
				<sql:update>alter table auth_roles add constraint pk_auth_roles primary key (id)</sql:update>
				<sql:update>alter table auth_users add constraint pk_auth_users primary key (id)</sql:update>
				<sql:update>alter table contextes add constraint pk_contextes primary key (id)</sql:update>
				<sql:update>alter table dhcp_server add constraint pk_dhcpserver primary key (id)</sql:update>
				<sql:update>alter table dhcp_type add constraint pk_dhcptype primary key (id)</sql:update>
				<sql:update>alter table dhcp_exclu add constraint pk_dhcpexclu primary key (id)</sql:update>
				<sql:update>alter table ipurl add constraint pk_ipurl primary key (id)</sql:update>
				<sql:update>alter table langues add constraint pk_langues primary key (code)</sql:update>
				<sql:update>alter table mail add constraint pk_mail primary key (id,lang)</sql:update>
				<sql:update>alter table photo add constraint pk_photo primary key (id)</sql:update>
				<sql:update>alter table photo_baie add constraint pk_photo_baie primary key (id)</sql:update>
				<sql:update>alter table photo_box add constraint pk_photo_box primary key (id)</sql:update>
				<sql:update>alter table redundancy add constraint pk_redundancy primary key (id)</sql:update>
				<sql:update>alter table redund_ptype add constraint pk_redund_ptype primary key (id)</sql:update>
				<sql:update>alter table salles add constraint pk_salles primary key (id)</sql:update>
				<sql:update>alter table schedulers add constraint pk_schedulers primary key (id)</sql:update>
				<sql:update>alter table sites add constraint pk_sites primary key (id)</sql:update>
				<sql:update>alter table slaclient add constraint pk_slaclient primary key (id)</sql:update>
				<sql:update>alter table sladevice add constraint pk_sladevice primary key (id)</sql:update>
				<sql:update>alter table slaplanning add constraint pk_slaplanning primary key (id)</sql:update>
				<sql:update>alter table slasite add constraint pk_slasite primary key (id)</sql:update>
				<sql:update>alter table slastats add constraint pk_slastats primary key (device,stamp)</sql:update>
				<sql:update>alter table sladays add constraint pk_sladays primary key (device,stamp)</sql:update>
				<sql:update>alter table slahours add constraint pk_slahours primary key (device,stamp)</sql:update>
				<sql:update>alter table stock_cat add constraint pk_stock_cat primary key (id)</sql:update>
				<sql:update>alter table stock_etat add constraint pk_stock_etat primary key (id)</sql:update>
				<sql:update>alter table subnets add constraint pk_subnets primary key (id)</sql:update>
				<sql:update>alter table surnets add constraint pk_surnets primary key (id)</sql:update>
				<sql:update>alter table usercookie add constraint pk_usercookie primary key (login)</sql:update>
				<sql:update>alter table vlan add constraint pk_vlan primary key (id)</sql:update>
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
