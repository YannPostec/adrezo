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
				<c:choose>
				<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
					<sql:update>create table dhcp_server (id number not null,hostname varchar2(50) not null,port number not null,ssl number(1,0) default 0,auth number(1,0) not null,login varchar2(64),pwd varchar2(64),type number not null)</sql:update>
					<sql:update>create table dhcp_type (id number not null, name varchar2(100) not null)</sql:update>
					<sql:update>create table dhcp_exclu (id number not null,srv number not null, scope varchar2(15) not null)</sql:update>
					<sql:update>create sequence dhcp_server_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
					<sql:update>create sequence dhcp_exclu_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<sql:update>create table dhcp_server (id integer not null,hostname varchar(50) not null,port integer not null,ssl integer default 0,auth integer not null,login varchar(64),pwd varchar(64),type integer not null)</sql:update>
					<sql:update>create table dhcp_type (id integer not null, name varchar(100) not null)</sql:update>
					<sql:update>create table dhcp_exclu (id integer not null,srv integer not null, scope varchar(15) not null)</sql:update>
					<sql:update>create sequence dhcp_server_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
					<sql:update>create sequence dhcp_exclu_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
				</c:when>
				</c:choose>
				<sql:update>alter table dhcp_server add constraint pk_dhcpserver primary key (id)</sql:update>
				<sql:update>alter table dhcp_type add constraint pk_dhcptype primary key (id)</sql:update>
				<sql:update>alter table dhcp_exclu add constraint pk_dhcpexclu primary key (id)</sql:update>
				<sql:update>insert into dhcp_type (id,name) values (1,'MS Windows DHCP Server')</sql:update>
				<sql:update>create view dhcp_server_display (id,hostname,port,ssl,auth,login,pwd,type,type_name) as select s.id,s.hostname,s.port,s.ssl,s.auth,s.login,s.pwd,s.type,t.name as type_name from dhcp_server s, dhcp_type t where s.type=t.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>alter table dhcp_server add constraint fgn_dhcpserver_type foreign key (type) references dhcp_type (id)</sql:update>
				<sql:update>insert into schedulers (id,param,enabled) values (11,0,0)</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (8,'USERDEF','[DHCP] Erreur','Erreur dans la collecte des informations DHCP. Veuillez consulter le log des tâches planifiées','DHCP_SERVER','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (8,'USERDEF','[DHCP] Error','Error in gathering DHCP informations. Please review scheduled tasks log','DHCP_SERVER','en')</sql:update>
				<sql:update>update usercookie set mail='197' where login='admin'</sql:update>
			</sql:transaction>
			<c:choose>
			<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
				<adrezo:sqlTrigger>create trigger dhcp_server_del after delete on dhcp_server referencing new as new old as old for each row begin delete from dhcp_exclu where srv = :old.id; end dhcp_server_del;</adrezo:sqlTrigger>
			</c:when>
			<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
				<adrezo:sqlTrigger>create or replace function dhcp_server_del() returns trigger as $BODY$ begin delete from dhcp_exclu where srv = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger dhcp_server_del before delete on dhcp_server for each row execute procedure dhcp_server_del();</adrezo:sqlTrigger>
			</c:when>
			</c:choose>
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
