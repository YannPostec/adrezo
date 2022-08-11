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
				<sql:update>insert into auth_annu_types (id,name) values (0,'Local')</sql:update>
				<sql:update>insert into auth_annu_types (id,name) values (1,'LDAP')</sql:update>
				<sql:update>insert into auth_annu (id,name,ordre,type) values (0,'Local',0,0)</sql:update>
				<sql:update>insert into contextes (id,name,site_main) values (1,'Default',0)</sql:update>
				<sql:update>insert into auth_roles (id,name,new_ctx,annu,grp,pref_ctx,grp_dn) values (0,'NoAccess',0,0,null,1,null)</sql:update>
				<sql:update>insert into auth_roles (id,name,new_ctx,annu,grp,pref_ctx,grp_dn) values (1,'AdminLocal',511,0,null,1,null)</sql:update>
				<sql:update>insert into auth_rights (ctx,role,rights) values (1,0,0)</sql:update>
				<sql:update>insert into auth_rights (ctx,role,rights) values (1,1,255)</sql:update>
				<sql:update>insert into auth_users (login,pwd,mail,role,auth,id) values ('admin','hjK/szAmjNFtn2V7UktrRkjwXaCqXslE','root@adrezo',1,0,0)</sql:update>
				<sql:update>insert into dhcp_type (id,name,port) values (1,'MS Windows DHCP Server',6660)</sql:update>
				<sql:update>insert into ipurl (id,proto,port,uri) values (1,'http',null,'')</sql:update>
				<sql:update>insert into ipurl (id,proto,port,uri) values (2,'https',null,'')</sql:update>
				<sql:update>insert into langues (code,name) values ('fr','Francais')</sql:update>
				<sql:update>insert into langues (code,name) values ('en','English')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (1,'root@adrezo','[Stock] Depassement du seuil pour #IDX#','Depassement du seuil pour le consommable #IDX#, #DEF#. Le seuil est a #SEUIL#, le stock actuel est de #STOCK#, Commande #ENCOURS#','STOCK_ETAT','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (1,'root@adrezo','[Supply] Threshold alert for #IDX#','Exceeding threshold for item #IDX#, #DEF#. Threshold is fixed at #SEUIL#, actual supply is at #STOCK#, with order #ENCOURS#','STOCK_ETAT','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (2,'USERDEF','[IP Temporaire] Date dépassée','Des adresses IP temporaires ont une date dépassée, merci de corriger ou de les supprimer :','ADRESSES','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (2,'USERDEF','[Temporary IP] Date exceeded','Some temporary IP addresses have exceeded date, please correct or delete them :','ADRESSES','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (3,'USERDEF','[IP Migration] Date dépassée','Des adresses IP en migration ont une date dépassée, merci de corriger ou de les supprimer :','ADRESSES','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (3,'USERDEF','[Migrating IP] Date exceeded','Some migrating IP addresses have exceeded date, please correct or delete them :','ADRESSES','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (4,'USERDEF','[Cacti Devices] Nouveaux équipements','Des nouveaux équipements Cacti ont été ajoutés dans Adrezo pour les statistiques. Nombre: ','SLADEVICE','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (4,'USERDEF','[Cacti Devices] New Devices','New Cacti devices have been added in Adrezo NAS database. Count: ','SLADEVICE','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (5,'USERDEF','[Cacti Stats] Erreur','Erreur dans la recuperation des données de Cacti. Statistiques non mises à zéro dans Cacti.','SLASTATS','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (5,'USERDEF','[Cacti Stats] Error','Error in gathering data from Cacti. No zeroize of statistics peformed in Cacti database.','SLASTATS','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (6,'USERDEF','[Cacti Aggrégation Heures] Erreur','Erreur dans la consolidation des statistiques horaires de Cacti. Veuillez consulter le log des tâches planifiées','SLAHOURS','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (6,'USERDEF','[Cacti Aggregate Hours] Error','Error in aggregation of Cacti hourly statistics. Please review scheduled tasks log','SLAHOURS','en')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (7,'USERDEF','[Cacti Aggrégation Jours] Erreur','Erreur dans la consolidation des statistiques quotidiennes de Cacti. Veuillez consulter le log des tâches planifiées','SLADAYS','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (7,'USERDEF','[Cacti Aggregate Days] Error','Error in aggregation of Cacti daily statistics. Please review scheduled tasks log','SLADAYS','en')</sql:update>				
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (8,'USERDEF','[DHCP] Erreur','Erreur dans la collecte des informations DHCP. Veuillez consulter le log des tâches planifiées','DHCP_SERVER','fr')</sql:update>
				<sql:update>insert into mail (id,destinataire,subject,message,location,lang) values (8,'USERDEF','[DHCP] Error','Error in gathering DHCP informations. Please review scheduled tasks log','DHCP_SERVER','en')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (1,750,1,'PurgeUsersJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (2,1830,1,'PurgeSupplyMvtJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (3,0,1,'PurgePhotosJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (4,0,0,'MailTempIPJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (5,0,0,'MailMigIPJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (6,0,1,'NormAddSubnetJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (7,0,0,'CactiDevicesJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (8,1,0,'CactiStatsJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (9,0,0,'CactiAggregateHoursJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (10,0,0,'CactiAggregateDaysJob')</sql:update>
				<sql:update>insert into schedulers (id,param,enabled,jobname) values (11,0,0,'DHCPJob')</sql:update>
				<sql:update>insert into settings (exppref,expsuff) values (null,null)</sql:update>
				<sql:update>insert into slaplanning (id,name,h1,h2,h3,h4,h5,h6,h7) values (0,'Anytime',16777215,16777215,16777215,16777215,16777215,16777215,16777215)</sql:update>
				<sql:update>insert into slaclient (id,name,disp) values (0,'Unknown',0)</sql:update>
				<sql:update>insert into slasite (id,client,name,disp) values (0,0,'Unknown',0)</sql:update>
				<sql:update>insert into surnets (id,ip,mask,infos,def,parent,calc) values (0,000000000000,0,null,'Root',-1,0)</sql:update>
				<sql:update>insert into usercookie (login,mail,ctx,lang,last) values ('admin',?,null,'fr',null)<sql:param>${adrezoVersion}</sql:param></sql:update>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${err != null}">
				<adrezo:fileDB value="${err}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><adrezo:trim value="${err}"/></msg></c:set>
				<c:remove var="adrezoVersion" scope="application" />
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
