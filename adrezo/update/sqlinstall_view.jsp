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
				<sql:update>create view adresses_display (id,name,def,ip,mask,mac,ip_mig,temp,date_temp,usr_temp,usr_mig,date_mig,mig,type,usr_modif,date_modif,mask_mig,ctx,site,subnet,site_mig,subnet_mig,ctx_name,site_name,site_code,subnet_name,site_mig_name,subnet_mig_name,subnet_gw) as select a.id,a.name,a.def,a.ip,a.mask,a.mac,a.ip_mig,a.temp,a.date_temp,a.usr_temp,a.usr_mig,a.date_mig,a.mig,a.type,a.usr_modif,a.date_modif,a.mask_mig,a.ctx,a.site,a.subnet,a.site_mig,a.subnet_mig,c.name as ctx_name,s.name as site_name,s.cod_site as site_code,z.def as subnet_name,sm.name as site_mig_name,zm.def as subnet_mig_name,z.gw as subnet_gw from contextes c,sites s,subnets z,adresses a left outer join sites sm on sm.id=a.site_mig left outer join subnets zm on zm.id=a.subnet_mig where a.ctx=c.id and a.site=s.id and a.subnet=z.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view auth_annu_display (id,name,ordre,type,type_name) as select a.id,a.name,a.ordre,a.type,t.name from auth_annu a,auth_annu_types t where a.type = t.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view auth_rights_display (ctx,ctx_name,role,rights) as select r.ctx,c.name,r.role,r.rights from auth_rights r,contextes c where r.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view auth_roles_display (id,name,new_ctx,annu,annu_name,grp,grp_dn,pref_ctx,pref_ctx_name) as select r.id,r.name,r.new_ctx,r.annu,a.name,r.grp,r.grp_dn,r.pref_ctx,c.name from auth_roles r,auth_annu a,contextes c where r.pref_ctx=c.id and r.annu=a.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view auth_users_display (id,login,mail,role,role_name,auth) as select u.id,u.login,u.mail,u.role,r.name,u.auth from auth_users u left outer join auth_roles r on u.role=r.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view photo_baie_display (id,name,numero,idbox,box_name,idsalle,salle_name,idsite,site_name,ctx,ctx_name) as select p.id,p.name,p.numero,p.idbox,b.name as box_name,b.idsalle,s.name,s.idsite,a.name,c.id as ctx,c.name as ctx_name from photo_baie p,photo_box b,salles s,sites a,contextes c where p.idbox=b.id and b.idsalle=s.id and s.idsite=a.id and a.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view photo_box_display (id,name,idsalle,salle_name,idsite,site_name,ctx,ctx_name) as select p.id,p.name,p.idsalle,s.name,s.idsite,a.name,c.id as ctx,c.name as ctx_name from photo_box p,salles s,sites a,contextes c where p.idsalle=s.id and s.idsite=a.id and a.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view redundancy_display (id,ipid,pid,ptype,ptype_name,subnet,subnet_name,ip,mask,ip_name,ctx_name,ctx,site_name) as select r.id,r.ipid,r.pid,r.ptype,p.name as ptype_name,s.id as subnet,s.def as subnet_name,a.ip,a.mask,a.name as ip_name,c.name as ctx_name,c.id as ctx,z.name as site_name from redundancy r,redund_ptype p,adresses a,subnets s,contextes c,sites z where r.ptype=p.id and r.ipid=a.id and a.subnet=s.id and a.ctx=c.id and a.site=z.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view salles_display (id,name,idsite,site_name,ctx,ctx_name) as select s.id,s.name,s.idsite,a.name,c.id as ctx,c.name as ctx_name from salles s,sites a,contextes c where s.idsite=a.id and a.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view sites_display (id,ctx,cod_site,name,ctx_name) as select s.id,s.ctx,s.cod_site,s.name,c.name as ctx_name from sites s,contextes c where s.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view sladevice_display (id,client,client_name,site,site_name,name,cacti,status,plan,plan_name) as select d.id,c.id,c.name,s.id,s.name,d.name,d.cacti,d.status,p.id,p.name from slasite s,slaclient c,sladevice d,slaplanning p where s.id=d.site and s.client=c.id and d.plan=p.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view slasite_display (id,client,client_name,name,disp,plan,plan_name) as select s.id,s.client,c.name,s.name,s.disp,p.id,p.name from slasite s,slaclient c,slaplanning p where s.client=c.id and s.plan=p.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view slaclient_display (id,name,disp,plan,plan_name) as select c.id,c.name,c.disp,p.id,p.name from slaclient c,slaplanning p where c.plan=p.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view slastats_display (device,device_name,client,client_name,site,site_name,stamp,availability) as select d.id,d.name,c.id,c.name,s.id,s.name,m.stamp,m.availability from slasite s,slaclient c,sladevice d,slastats m where m.device=d.id and s.id=d.site and c.id=s.client and c.disp=1 and s.disp=1 and d.status>0<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view stock_etat_display (id,def,stock,seuil,idx,cat,idcat,encours,ctx,ctx_name,site,site_name) as select e.id,e.def,e.stock,e.seuil,e.idx,c.name,c.id,e.encours,x.id,x.name,e.site,s.name from stock_etat e,stock_cat c,contextes x,sites s where e.cat=c.id and e.site=s.id and s.ctx=x.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view subnets_display (id,ctx,site,ip,mask,def,gw,bc,cod_site,site_name,vlan,vid,vdef,surnet,ctx_name) as select s.id,s.ctx,s.site,s.ip,s.mask,s.def,s.gw,s.bc,a.cod_site,a.name as site_name,s.vlan,v.vid,v.def as vdef,s.surnet,c.name as ctx_name from subnets s,contextes c,sites a,vlan v where s.ctx=c.id and s.site=a.id and s.vlan=v.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view vlan_display (id,vid,def,site,ctx,cod_site,site_name,ctx_name) as select v.id,v.vid,v.def,v.site,s.ctx,s.cod_site,s.name as site_name,c.name as ctx_name from vlan v,sites s,contextes c where v.site=s.id and s.ctx=c.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
				<sql:update>create view dhcp_server_display (id,hostname,port,ssl,auth,login,pwd,type,type_name,enable) as select s.id,s.hostname,s.port,s.ssl,s.auth,s.login,s.pwd,s.type,t.name as type_name,s.enable from dhcp_server s, dhcp_type t where s.type=t.id<c:if test="${adrezo:envEntry('db_type') == 'oracle'}"> with read only</c:if></sql:update>
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
