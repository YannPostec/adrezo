<sql:query var="contextes">select * from contextes order by name</sql:query>
<sql:query var="langues">select * from langues order by code</sql:query>
<fmt:setBundle basename="ypodev.adrezo.props.menu" var="bunmenu"/>
<fmt:message key="menu.button.decnx" bundle="${bunmenu}" var="btnMenuDecnx" />
<fmt:message key="menu.button.aide" bundle="${bunmenu}" var="btnMenuAide" />
<fmt:message key="menu.button.prefs" bundle="${bunmenu}" var="btnMenuPrefs" />
<form method="post" action="${pageContext.request.contextPath}/chg_lang.jsp" id="frmMenuMain"><div><input type="hidden" name="backURL" value="<c:out value='${pageContext.request.requestURL}' escapeXml='true'/>" /><input type="hidden" name="langue" id="txtMenuMain" /></div></form>
<div class="divmenu">
<ul class="menu" id="menu">
	<li class="menulink">${validUser.login}<input type="hidden" value="${validUser.role}"/><a href="${pageContext.request.contextPath}/logout.jsp" class="icon"><img src="${pageContext.request.contextPath}/img/icon_exit.png" title="${btnMenuDecnx}"/></a><a href="${pageContext.request.contextPath}/help/help.jsp" target="adrezo_aide" class="icon"><img src="${pageContext.request.contextPath}/img/icon_help.png" title="${btnMenuAide}" /></a><a href="${pageContext.request.contextPath}/user/user_prefs.jsp" class="icon"><img src="${pageContext.request.contextPath}/img/icon_settings.png" title="${btnMenuPrefs}" /></a>
	<ul><c:forEach items="${langues.rows}" var="lang">
	<li><a <c:if test="${validUser.lang == lang.code}">class="langselect" </c:if>href="javascript:chgLang('${lang.code}');"><img src="${pageContext.request.contextPath}/img/flags/${lang.code}.png" /></a>
	</li></c:forEach></ul></li>
	<li class="menulink"><form method="post" action="${pageContext.request.contextPath}/chg_ctx.jsp"><div><input type="hidden" name="backURL" value="<c:out value='${pageContext.request.requestURL}' escapeXml='true'/>" /><select name="contexte" onchange="javascript:submit()"><c:forEach items="${contextes.rows}" var="ctx"><option value="${ctx.ID}"<c:if test="${validUser.ctx == ctx.ID}"> selected="selected"</c:if>>${ctx.NAME}</option></c:forEach></select></div></form></li>

<c:if test="${validUser.admin}">
	<li><a href="#" class="menulink"><fmt:message key="menu.admin" bundle="${bunmenu}" /></a>
		<ul>
			<li><a href="${pageContext.request.contextPath}/admin/global.jsp"><fmt:message key="menu.admin.global" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/auth_annu.jsp"><fmt:message key="menu.admin.annuaire" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/auth_roles.jsp"><fmt:message key="menu.admin.role" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/auth_users.jsp"><fmt:message key="menu.admin.usr" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/contextes.jsp"><fmt:message key="menu.admin.ctx" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/sites.jsp"><fmt:message key="menu.admin.site" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/mails.jsp"><fmt:message key="menu.admin.mail" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/csv.jsp"><fmt:message key="menu.admin.csv" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/api.jsp"><fmt:message key="menu.admin.api" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/schedulers.jsp"><fmt:message key="menu.admin.schedulers" bundle="${bunmenu}" /></a></li>
			<li>
				<a href="#" class="sub"><fmt:message key="menu.tools" bundle="${bunmenu}" /></a>
				<ul>
					<li class="topline"><a href="${pageContext.request.contextPath}/admin/temporaires.jsp"><fmt:message key="menu.admin.tools.temp" bundle="${bunmenu}" /></a></li>
					<li><a href="${pageContext.request.contextPath}/admin/migrations.jsp"><fmt:message key="menu.admin.tools.mig" bundle="${bunmenu}" /></a></li>
				</ul>
			</li>
		</ul>
	</li>
</c:if>
<c:if test="${validUser.rezo}">
	<li><a href="#" class="menulink"><fmt:message key="menu.rezo" bundle="${bunmenu}" /></a>
		<ul>
			<li><a href="${pageContext.request.contextPath}/admin/subnets.jsp"><fmt:message key="menu.rezo.subnet" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/admin/vlan.jsp"><fmt:message key="menu.rezo.vlan" bundle="${bunmenu}" /></a></li>
			<li>
				<a href="${pageContext.request.contextPath}/admin/redundancy.jsp" class="sub"><fmt:message key="menu.rezo.red" bundle="${bunmenu}" /></a>
				<ul>
					<li class="topline"><a href="${pageContext.request.contextPath}/admin/redund_ptype.jsp"><fmt:message key="menu.rezo.red.proto" bundle="${bunmenu}" /></a></li>
				</ul>
			</li>
			<li>
				<a href="#" class="sub"><fmt:message key="menu.tools" bundle="${bunmenu}" /></a>
				<ul>
					<li><a href="${pageContext.request.contextPath}/admin/subnet_novlan.jsp"><fmt:message key="menu.rezo.tools.novlan" bundle="${bunmenu}" /></a></li>
					<li><a href="${pageContext.request.contextPath}/admin/subnet_nosurnet.jsp"><fmt:message key="menu.rezo.tools.nosurnet" bundle="${bunmenu}" /></a></li>
				</ul>
			</li>
		</ul>
	</li>
</c:if>
	<li><a href="#" class="menulink"><fmt:message key="menu.info" bundle="${bunmenu}" /></a>
		<ul>
			<li><a href="${pageContext.request.contextPath}/infos/info_sites.jsp"><fmt:message key="menu.info.site" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/infos/info_subnets.jsp"><fmt:message key="menu.info.subnet" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/infos/info_vlans.jsp"><fmt:message key="menu.info.vlan" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/infos/info_redundancy.jsp"><fmt:message key="menu.info.red" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/infos/info_mask.jsp"><fmt:message key="menu.info.mask" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/infos/info_subnet_fill.jsp"><fmt:message key="menu.info.fill" bundle="${bunmenu}" /></a></li>
		</ul>
	</li>
	<li><a href="${pageContext.request.contextPath}/norm/norm.jsp" class="menulink"><fmt:message key="menu.norm" bundle="${bunmenu}" /></a></li>
	<li><a href="${pageContext.request.contextPath}/sla/stats.jsp" class="menulink"><fmt:message key="menu.sdr" bundle="${bunmenu}" /></a>
<c:if test="${validUser.rezo}">	
		<ul>
			<li><a href="${pageContext.request.contextPath}/sla/clients.jsp"><fmt:message key="menu.sdr.client" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/sla/sites.jsp"><fmt:message key="menu.sdr.site" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/sla/devices.jsp"><fmt:message key="menu.sdr.device" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/sla/plannings.jsp"><fmt:message key="menu.sdr.planning" bundle="${bunmenu}" /></a></li>
			<c:if test="${validUser.admin}">
				<li><a href="${pageContext.request.contextPath}/sla/purge.jsp"><fmt:message key="menu.sdr.purge" bundle="${bunmenu}" /></a></li>
			</c:if>
		</ul>
</c:if>
	</li>
	<li><a href="${pageContext.request.contextPath}/ip/ip.jsp" class="menulink"><fmt:message key="menu.ip" bundle="${bunmenu}" /></a></li>
	<li><a href="${pageContext.request.contextPath}/photos/album.jsp" class="menulink"><fmt:message key="menu.photo" bundle="${bunmenu}" /></a>
	<c:if test="${validUser.admin}">
		<ul>
			<li><a href="${pageContext.request.contextPath}/photos/salles.jsp"><fmt:message key="menu.photo.salle" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/photos/boxs.jsp"><fmt:message key="menu.photo.box" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/photos/baies.jsp"><fmt:message key="menu.photo.baie" bundle="${bunmenu}" /></a></li>
		</ul>
	</c:if>
	</li>
	<li><a href="${pageContext.request.contextPath}/stock/etat.jsp" class="menulink"><fmt:message key="menu.stock" bundle="${bunmenu}" /></a>
		<ul>
			<c:if test="${validUser.stockAdmin}">
			<li><a href="${pageContext.request.contextPath}/stock/gestion.jsp"><fmt:message key="menu.stock.type" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/stock/categorie.jsp"><fmt:message key="menu.stock.cat" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/stock/main.jsp"><fmt:message key="menu.stock.main" bundle="${bunmenu}" /></a></li>
			<li><a href="${pageContext.request.contextPath}/stock/mvt.jsp"><fmt:message key="menu.stock.mvt" bundle="${bunmenu}" /></a></li>
			</c:if>
		</ul>
	</li>
	<li><a href="${pageContext.request.contextPath}/blank.jsp" class="menulink" target="_blank"><img src="${pageContext.request.contextPath}/img/icon_newtab.jpg" /></a></li>
</ul>
<script type="text/javascript">
	var menu=new menu.dd("menu");
	menu.init("menu");
</script>
</div>
<p style="margin:5px"><br style="clear:left" /></p>
