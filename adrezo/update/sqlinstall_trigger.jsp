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
				<adrezo:sqlTrigger>create trigger auth_annu_del after delete on auth_annu referencing new as new old as old for each row begin if :old.type = 1 then delete from auth_ldap where id = :old.id; end if; delete from auth_roles where annu = :old.id; end auth_annu_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger auth_annu_types_del after delete on auth_annu_types referencing new as new old as old for each row begin delete from auth_annu where type = :old.id; end auth_annu_types_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger auth_roles_del after delete on auth_roles referencing new as new old as old for each row begin delete from auth_rights where role = :old.id; update auth_users set role = null where role = :old.id; end auth_roles_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger contextes_del after delete on contextes referencing new as new old as old for each row begin delete from sites where ctx = :old.id; delete from auth_rights where ctx = :old.id; end contextes_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger photo_baie_del after delete on photo_baie referencing new as new old as old for each row begin delete from photo where type = 1 and idparent = :old.id; end photo_baie_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger photo_box_del after delete on photo_box referencing new as new old as old for each row begin delete from photo_baie where idbox = :old.id; end photo_box_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger salles_del after delete on salles referencing new as new old as old for each row begin delete from photo where type = 0 and idparent = :old.id; delete from photo_box where idsalle = :old.id; end salles_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger sites_del after delete on sites referencing new as new old as old for each row begin delete from salles where idsite=:old.id; delete from subnets where site=:old.id; delete from vlan where site=:old.id; end sites_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slaclient_del after delete on slaclient referencing new as new old as old for each row begin delete from slasite where client = :old.id; end slaclient_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slasite_del after delete on slasite referencing new as new old as old for each row begin update sladevice set site = 0,plan = 0 where site = :old.id; end slasite_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slaplanning_del after delete on slaplanning referencing new as new old as old for each row begin update sladevice set plan = 0 where plan = :old.id; update slasite set plan = 0 where plan = :old.id; update slaclient set plan = 0 where plan = :old.id; end slaplanning_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger stock_cat_del after delete on stock_cat referencing new as new old as old for each row begin delete from stock_etat where cat = :old.id; end stock_cat_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger stock_etat_del after delete on stock_etat referencing new as new old as old for each row begin delete from stock_mvt where id = :old.id; end stock_etat_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger subnets_del after delete on subnets referencing new as new old as old for each row begin delete from adresses where ip in (select ip_mig from adresses where subnet = :old.id and mig = 1 and ip_mig is not null and ctx = :old.ctx); update adresses set mig=0,ip_mig=null,site_mig=null,mask_mig=null,date_mig=null,usr_mig=null,subnet_mig=null where ip in (select ip_mig from adresses where subnet = :old.id and type = 'dynamic' and name = 'RESA MIGRATION' and ctx = :old.ctx); delete from adresses where subnet = :old.id; end subnets_del;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger surnets_del after delete on surnets referencing new as new old as old for each row begin update subnets set surnet = 0 where surnet = :old.id; end surnets_del;</adrezo:sqlTrigger>
		</c:catch>
		</c:when>
		<c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
		<c:catch var="err">
				<adrezo:sqlTrigger>create or replace function auth_annu_del() returns trigger as $BODY$ begin if OLD.type = 1 then delete from auth_ldap where id = OLD.id; end if; delete from auth_roles where annu = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function auth_annu_types_del() returns trigger as $BODY$ begin delete from auth_annu where type = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function auth_roles_del() returns trigger as $BODY$ begin delete from auth_rights where role = OLD.id; update auth_users set role = null where role = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function contextes_del() returns trigger as $BODY$ begin delete from sites where ctx = OLD.id; delete from auth_rights where ctx = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function photo_baie_del() returns trigger as $BODY$ begin delete from photo where type = 1 and idparent = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function photo_box_del() returns trigger as $BODY$ begin delete from photo_baie where idbox = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function salles_del() returns trigger as $BODY$ begin delete from photo where type = 0 and idparent = OLD.id; delete from photo_box where idsalle = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function sites_del() returns trigger as $BODY$ begin delete from salles where idsite=OLD.id; delete from subnets where site=OLD.id; delete from vlan where site=OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function slaclient_del() returns trigger as $BODY$ begin delete from slasite where client = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function slasite_del() returns trigger as $BODY$ begin update sladevice set site = 0,plan = 0 where site = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function slaplanning_del() returns trigger as $BODY$ begin update sladevice set plan = 0 where plan = OLD.id; update slasite set plan = 0 where plan = OLD.id; update slaclient set plan = 0 where plan = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function stock_cat_del() returns trigger as $BODY$ begin delete from stock_etat where cat = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function stock_etat_del() returns trigger as $BODY$ begin delete from stock_mvt where id = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function subnets_del() returns trigger as $BODY$ begin delete from adresses where ip in (select ip_mig from adresses where subnet = OLD.id and mig = 1 and ip_mig is not null and ctx = OLD.ctx); update adresses set mig=0,ip_mig=null,site_mig=null,mask_mig=null,date_mig=null,usr_mig=null,subnet_mig=null where ip in (select ip_mig from adresses where subnet = OLD.id and type = 'dynamic' and name = 'RESA MIGRATION' and ctx = OLD.ctx); delete from adresses where subnet = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create or replace function surnets_del() returns trigger as $BODY$ begin update subnets set surnet = 0 where surnet = OLD.id; return OLD; end; $BODY$ LANGUAGE plpgsql;</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger auth_annu_del before delete on auth_annu for each row execute procedure auth_annu_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger auth_annu_types_del before delete on auth_annu_types for each row execute procedure auth_annu_types_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger auth_roles_del before delete on auth_roles for each row execute procedure auth_roles_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger contextes_del before delete on contextes for each row execute procedure contextes_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger photo_baie_del before delete on photo_baie for each row execute procedure photo_baie_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger photo_box_del before delete on photo_box for each row execute procedure photo_box_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger salles_del before delete on salles for each row execute procedure salles_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger sites_del before delete on sites for each row execute procedure sites_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slaclient_del before delete on slaclient for each row execute procedure slaclient_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slasite_del before delete on slasite for each row execute procedure slasite_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger slaplanning_del before delete on slaplanning for each row execute procedure slaplanning_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger stock_cat_del before delete on stock_cat for each row execute procedure stock_cat_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger stock_etat_del before delete on stock_etat for each row execute procedure stock_etat_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger subnets_del before delete on subnets for each row execute procedure subnets_del();</adrezo:sqlTrigger>
				<adrezo:sqlTrigger>create trigger surnets_del before delete on surnets for each row execute procedure surnets_del();</adrezo:sqlTrigger>
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
