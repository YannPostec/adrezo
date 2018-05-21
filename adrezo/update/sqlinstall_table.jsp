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
				<sql:update>create table adresses (name varchar2(20) not null,def varchar2(100),ip varchar2(12) not null,mask number not null,mac varchar2(12),ip_mig varchar2(12),temp number(1,0) default 0,date_temp date,usr_temp varchar2(20),usr_mig varchar2(20),date_mig date,mig number(1,0) default 0,type varchar2(10) default 'static',usr_modif varchar2(20) default 'admin' not null,date_modif date default sysdate not null,mask_mig number,ctx number not null,site number not null,subnet number not null,site_mig number,subnet_mig number,id number not null)</sql:update>
				<sql:update>create table api (id number not null,login varchar2(20) not null,subnets varchar2(200) not null)</sql:update>
				<sql:update>create table api_token (login varchar2(20) not null, token varchar2(32) not null, expiration date not null)</sql:update>
				<sql:update>create table auth_annu (id number not null,name varchar2(40) not null,ordre number(3,0) not null,type number(1,0) not null)</sql:update>
				<sql:update>create table auth_annu_types (id number not null,name varchar2(20) not null)</sql:update>
				<sql:update>create table auth_ldap (id number not null,server varchar2(50) not null,port number default 389,method number(1,0) default 0,binddn varchar2(256) not null,bindpwd varchar2(50) not null,usrdn varchar2(512) not null,usrfilter varchar2(200),usrnameattr varchar2(30) not null,grpdn varchar2(512) not null,grpfilter varchar2(200),grpnameattr varchar2(30) default 'cn',grpmemberattr varchar2(30) default 'member',grpclass varchar2(30) default 'group',usrclass varchar2(30) default 'user',basedn varchar2(256) not null)</sql:update>
				<sql:update>create table auth_rights (ctx number not null,role number not null,rights number default 0)</sql:update>
				<sql:update>create table auth_roles (id number not null,name varchar2(40) not null,new_ctx number default 0,annu number default 0,grp varchar2(40),pref_ctx number,grp_dn varchar2(512))</sql:update>
				<sql:update>create table auth_users (login varchar2(20) not null,pwd varchar2(128),mail varchar2(100),role number default null,auth number(1,0) not null,id number not null)</sql:update>
				<sql:update>create table contextes (id number not null,name varchar2(30) not null,site_main number not null)</sql:update>
				<sql:update>create table ipurl (id number not null,proto varchar2(10) not null,port number default null,uri varchar2(100))</sql:update>
				<sql:update>create table langues (code varchar2(2) not null,name varchar2(50) not null)</sql:update>
				<sql:update>create table mail (id number not null,destinataire varchar2(100) not null,subject varchar2(150) not null,message varchar2(400) not null,location varchar2(20) not null,lang varchar2(2) not null)</sql:update>
				<sql:update>create table photo (id number not null,idparent number not null,type number(1,0) default 0 not null,name varchar2(50),suf varchar2(3),dir number,updt date default sysdate not null)</sql:update>
				<sql:update>create table photo_baie (name varchar2(15) not null,id number not null,idbox number not null,numero number default 1 not null)</sql:update>
				<sql:update>create table photo_box (idsalle number not null,name varchar2(50) not null,id number not null)</sql:update>
				<sql:update>create table redundancy (id number not null,ipid number not null,pid number not null,ptype number not null)</sql:update>
				<sql:update>create table redund_ptype (id number not null,name varchar2(10) not null)</sql:update>
				<sql:update>create table salles (name varchar2(6) not null,idsite number not null,id number not null)</sql:update>
				<sql:update>create table schedulers (id number not null,param number,enabled number(1,0) default 1)</sql:update>
				<sql:update>create table settings (exppref varchar2(20) default null,expsuff varchar2(20) default null)</sql:update>
				<sql:update>create table sites (cod_site varchar2(8) not null,name varchar2(60),id number not null,ctx number not null)</sql:update>
				<sql:update>create table slaclient (id number not null,name varchar2(100) not null,disp number(1,0) default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table sladevice (id number not null,site number not null,cacti number,name varchar2(150) not null,status number default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table slaplanning (id number not null,name varchar2(50) not null,h1 integer,h2 integer,h3 integer,h4 integer,h5 integer,h6 integer,h7 integer)</sql:update>
				<sql:update>create table slasite (id number not null,client number not null,name varchar2(100) not null,disp number(1,0) default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table slastats (device number not null,stamp varchar2(6) not null,availability number(8,5))</sql:update>
				<sql:update>create table slahours (device number not null,stamp varchar2(10) not null,availability number(8,5))</sql:update>
				<sql:update>create table sladays (device number not null,stamp varchar2(8) not null,availability number(8,5))</sql:update>
				<sql:update>create table stock_cat (id number not null,name varchar2(30) not null)</sql:update>
				<sql:update>create table stock_etat (id number(4,0) not null,def varchar2(255) not null,stock number(4,0) default 0,seuil number(4,0) default 0,idx varchar2(8) not null,cat number not null,encours number default 0,ctx number not null,site number not null)</sql:update>
				<sql:update>create table stock_mvt (stamp date not null,usr varchar2(20) not null,mvt number(5,0) not null,invent number(1,0) default 0 not null,seuil number(1,0) default 0,id number (4,0) not null)</sql:update>
				<sql:update>create table subnets (ip varchar2(12) not null,mask number not null,def varchar2(40) not null,gw varchar2(12),bc varchar2(12) not null,id number not null,ctx number not null,site number not null,vlan number not null,surnet number default 0 not null)</sql:update>
				<sql:update>create table surnets (id number not null,ip varchar2(30) not null,mask number not null,infos varchar2(2000),def varchar2(100) not null,parent number not null,calc number (1.0) not null)</sql:update>
				<sql:update>create table usercookie (login varchar2(20) not null,mail varchar2(100),ctx number,lang varchar2(2),last date,url number(1,0) default 1 not null,slidetime number default 2000 not null)</sql:update>
				<sql:update>create table vlan (vid number not null,def varchar2(50) not null,id number not null,site number not null,ctx number not null)</sql:update>
			</sql:transaction>
		</c:catch>
		</c:when>
		<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
		<c:catch var="err">
			<sql:transaction>
				<sql:update>create table adresses (name varchar(20) not null,def varchar(100),ip varchar(12) not null,mask integer not null,mac varchar(12),ip_mig varchar(12),temp integer default 0,date_temp timestamp,usr_temp varchar(20),usr_mig varchar(20),date_mig timestamp,mig integer default 0,type varchar(10) default 'static',usr_modif varchar(20) default 'admin' not null,date_modif timestamp default current_timestamp not null,mask_mig integer,ctx integer not null,site integer not null,subnet integer not null,site_mig integer,subnet_mig integer,id integer not null)</sql:update>
				<sql:update>create table api (id integer not null,login varchar(20) not null,subnets varchar(200) not null)</sql:update>
				<sql:update>create table api_token (login varchar(20) not null, token varchar(32) not null, expiration timestamp not null)</sql:update>
				<sql:update>create table auth_annu (id integer not null,name varchar(40) not null,ordre integer not null,type integer not null)</sql:update>
				<sql:update>create table auth_annu_types (id integer not null,name varchar(20) not null)</sql:update>
				<sql:update>create table auth_ldap (id integer not null,server varchar(50) not null,port integer default 389,method integer default 0,binddn varchar(256) not null,bindpwd varchar(50) not null,usrdn varchar(512) not null,usrfilter varchar(200),usrnameattr varchar(30) not null,grpdn varchar(512) not null,grpfilter varchar(200),grpnameattr varchar(30) default 'cn',grpmemberattr varchar(30) default 'member',grpclass varchar(30) default 'group',usrclass varchar(30) default 'user',basedn varchar(256) not null)</sql:update>
				<sql:update>create table auth_rights (ctx integer not null,role integer not null,rights integer default 0)</sql:update>
				<sql:update>create table auth_roles (id integer not null,name varchar(40) not null,new_ctx integer default 0,annu integer default 0,grp varchar(40),pref_ctx integer,grp_dn varchar(512))</sql:update>
				<sql:update>create table auth_users (login varchar(20) not null,pwd varchar(128),mail varchar(100),role integer default null,auth integer not null,id integer not null)</sql:update>
				<sql:update>create table contextes (id integer not null,name varchar(30) not null,site_main integer not null)</sql:update>
				<sql:update>create table ipurl (id integer not null,proto varchar(10) not null,port integer default null,uri varchar(100))</sql:update>
				<sql:update>create table langues (code varchar(2) not null,name varchar(50) not null)</sql:update>
				<sql:update>create table mail (id integer not null,destinataire varchar(100) not null,subject varchar(150) not null,message varchar(400) not null,location varchar(20) not null,lang varchar(2) not null)</sql:update>
				<sql:update>create table photo (id integer not null,idparent integer not null,type integer default 0 not null,name varchar(50),suf varchar(3),dir integer,updt timestamp default current_timestamp not null)</sql:update>
				<sql:update>create table photo_baie (name varchar(15) not null,id integer not null,idbox integer not null,numero integer default 1 not null)</sql:update>
				<sql:update>create table photo_box (idsalle integer not null,name varchar(50) not null,id integer not null)</sql:update>
				<sql:update>create table redundancy (id integer not null,ipid integer not null,pid integer not null,ptype integer not null)</sql:update>
				<sql:update>create table redund_ptype (id integer not null,name varchar(10) not null)</sql:update>
				<sql:update>create table salles (name varchar(6) not null,idsite integer not null,id integer not null)</sql:update>
				<sql:update>create table schedulers (id integer not null,param integer,enabled integer default 1)</sql:update>
				<sql:update>create table settings (exppref varchar(20) default null,expsuff varchar(20) default null)</sql:update>
				<sql:update>create table sites (cod_site varchar(8) not null,name varchar(60),id integer not null,ctx integer not null)</sql:update>
				<sql:update>create table slaclient (id integer not null,name varchar(100) not null,disp integer default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table sladevice (id integer not null,site integer not null,cacti integer,name varchar(150) not null,status integer default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table slaplanning (id integer not null,name varchar(50) not null,h1 integer,h2 integer,h3 integer,h4 integer,h5 integer,h6 integer,h7 integer)</sql:update>
				<sql:update>create table slasite (id integer not null,client integer not null,name varchar(100) not null,disp integer default 1,plan integer default 0 not null)</sql:update>
				<sql:update>create table slastats (device integer not null,stamp varchar(6) not null,availability numeric(8,5))</sql:update>
				<sql:update>create table slahours (device integer not null,stamp varchar(10) not null,availability numeric(8,5))</sql:update>
				<sql:update>create table sladays (device integer not null,stamp varchar(8) not null,availability numeric(8,5))</sql:update>
				<sql:update>create table stock_cat (id integer not null,name varchar(30) not null)</sql:update>
				<sql:update>create table stock_etat (id integer not null,def varchar(255) not null,stock integer default 0,seuil integer default 0,idx varchar(8) not null,cat integer not null,encours integer default 0,ctx integer not null,site integer not null)</sql:update>
				<sql:update>create table stock_mvt (stamp timestamp not null,usr varchar(20) not null,mvt integer not null,invent integer default 0 not null,seuil integer default 0,id integer not null)</sql:update>
				<sql:update>create table subnets (ip varchar(12) not null,mask integer not null,def varchar(40) not null,gw varchar(12),bc varchar(12) not null,id integer not null,ctx integer not null,site integer not null,vlan integer not null,surnet integer default 0 not null)</sql:update>
				<sql:update>create table surnets (id integer not null,ip varchar(30) not null,mask integer not null,infos varchar(2000),def varchar(100) not null,parent integer not null,calc integer not null)</sql:update>
				<sql:update>create table usercookie (login varchar(20) not null,mail varchar(100),ctx integer,lang varchar(2),last timestamp,url integer default 1 not null,slidetime integer default 2000 not null)</sql:update>
				<sql:update>create table vlan (vid integer not null,def varchar(50) not null,id integer not null,site integer not null,ctx integer not null)</sql:update>
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
