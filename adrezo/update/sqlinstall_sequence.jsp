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
		<c:choose>
			<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
				<c:catch var="err">
					<sql:transaction>
						<sql:update>create sequence adresses_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence auth_annu_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence contextes_seq start with 2 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence auth_roles_seq start with 2 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence auth_users_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence dhcp_server_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence dhcp_exclu_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence ipurl_seq start with 3 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence photo_baie_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence photo_box_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence photo_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence redundancy_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence redund_ptype_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence salles_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence sites_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence slaclient_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence sladevice_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence slaplanning_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence slasite_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence stock_cat_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence stock_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence subnets_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence surnets_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
						<sql:update>create sequence vlan_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
					</sql:transaction>
				</c:catch>
			</c:when>
			<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
				<c:catch var="err">
					<sql:transaction>
						<sql:update>create sequence adresses_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence auth_annu_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence contextes_seq start with 2 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence auth_roles_seq start with 2 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence auth_users_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence dhcp_server_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence dhcp_exclu_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence ipurl_seq start with 3 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence photo_baie_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence photo_box_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence photo_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence redundancy_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence redund_ptype_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence salles_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence sites_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence slaclient_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence sladevice_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence slaplanning_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence slasite_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence stock_cat_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence stock_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence subnets_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence surnets_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
						<sql:update>create sequence vlan_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
					</sql:transaction>
				</c:catch>
			</c:when>
		</c:choose>		
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
