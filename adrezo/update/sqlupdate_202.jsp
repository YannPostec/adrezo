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
					<sql:update>alter table usercookie add macsearch number(1,0) default 1</sql:update>
					<sql:update>create table tpl_site (id number not null,name varchar2(50) not null,mask number not null)</sql:update>
					<sql:update>create table tpl_vlan (id number not null,vid number not null,def varchar2(50) not null,tpl number not null)</sql:update>
					<sql:update>create table tpl_subnet (id number not null,tpl number not null,vlan number not null,mask number not null,def varchar2(40) not null,ip varchar2(12) not null,gw varchar2(12),bc varchar2(12),surnet varchar2(100))</sql:update>
					<sql:update>create sequence tpl_site_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
					<sql:update>create sequence tpl_vlan_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
					<sql:update>create sequence tpl_subnet_seq start with 1 increment by 1 minvalue 1 nomaxvalue nocache nocycle noorder</sql:update>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<sql:update>alter table usercookie add column macsearch integer default 1</sql:update>
					<sql:update>create table tpl_site (id integer not null,name varchar(50) not null,mask integer not null)</sql:update>
					<sql:update>create table tpl_vlan (id integer not null,vid integer not null,def varchar(50) not null,tpl integer not null)</sql:update>
					<sql:update>create table tpl_subnet (id integer not null,tpl integer not null,vlan integer not null,mask integer not null,def varchar(40) not null,ip varchar(12) not null,gw varchar(12),bc varchar(12),surnet varchar(100))</sql:update>
					<sql:update>create sequence tpl_site_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
					<sql:update>create sequence tpl_vlan_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
					<sql:update>create sequence tpl_subnet_seq start with 1 increment by 1 minvalue 1 no maxvalue no cycle</sql:update>
				</c:when>
				</c:choose>
				<sql:update>alter table tpl_site add constraint pk_tplsite primary key (id)</sql:update>
				<sql:update>alter table tpl_vlan add constraint pk_tplvlan primary key (id)</sql:update>
				<sql:update>alter table tpl_subnet add constraint pk_tplsubnet primary key (id)</sql:update>
				<sql:update>alter table tpl_vlan add constraint fgn_tpl_vlan_tpl foreign key (tpl) references tpl_site (id)</sql:update>
				<sql:update>alter table tpl_subnet add constraint fgn_tpl_subnet_tpl foreign key (tpl) references tpl_site (id)</sql:update>
				<sql:update>create view tpl_site_display (id,name,mask,nbvlan,nbsubnet) as select s.id,s.name,s.mask,(select count(id) from tpl_vlan v where v.tpl=s.id) as nbvlan,(select count(id) from tpl_subnet t where t.tpl=s.id) as nbsubnet from tpl_site s<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view tpl_subnet_display (id,ip,mask,def,gw,bc,surnet,vlan,tpl,vid,vname) as select s.id,s.ip,s.mask,s.def,s.gw,s.bc,s.surnet,s.vlan,s.tpl,v.vid,v.def as vname from tpl_subnet s, tpl_vlan v where s.vlan=v.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>update usercookie set mail='210' where login='admin'</sql:update>
			</sql:transaction>
			<c:choose>
				<c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
					<adrezo:sqlTrigger>create trigger tpl_site_del after delete on tpl_site referencing new as new old as old for each row begin delete from tpl_vlan where tpl = :old.id; delete from tpl_subnet where tpl = :old.id; end tpl_site_del;</adrezo:sqlTrigger>
				</c:when>
				<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
					<adrezo:sqlTrigger>create or replace function tpl_site_del() returns trigger as $BODY$ begin delete from tpl_vlan where tpl = OLD.id; delete from tpl_subnet where tpl = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
					<adrezo:sqlTrigger>create trigger tpl_site_del before delete on tpl_site for each row execute procedure tpl_site_del();</adrezo:sqlTrigger>
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
