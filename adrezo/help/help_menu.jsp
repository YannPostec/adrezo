<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.help" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<fmt:message key="common.close" var="lang_commonclose" />
<html>
<head><title><fmt:message key="help.menu.title" /></title>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
<link rel="stylesheet" href="../stylesheet/dtree.css" type="text/css" />
<link rel="stylesheet" href="../stylesheet/common.css" type="text/css" />
<script type="text/javascript" charset="utf-8" src="../js/dtree.js"></script>
</head>
<body>
<p><a href="javascript:d.openAll();"><fmt:message key="tiny.acc.unfold" /></a> | <a href="javascript:d.closeAll();"><fmt:message key="tiny.acc.fold" /></a></p>
<script type="text/javascript">
d = new dTree('d');
d.config.target = 'hMain';
d.config.folderLinks = true;
d.config.useSelection = true;
d.config.useCookies = false;
d.config.useLines = true;
d.config.useIcons = true;
d.config.useStatusText = false;
d.config.closeSameLevel = false;
d.config.inOrder = true;
d.add(0,-1,'<fmt:message key="root" />');
d.add(1,0,'<fmt:message key="ip" />','','','','ressource/FlecheRouge_F.gif','ressource/FlecheRouge_O.gif',false);
d.add(11,1,'<fmt:message key="ip.navi" />','${validUser.lang}/ip_navi.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(12,1,'<fmt:message key="ip.list" />','${validUser.lang}/ip_liste.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(13,1,'<fmt:message key="ip.csv" />','${validUser.lang}/ip_csv.html','','','ressource/page.gif','ressource/page.gif',false);
<c:if test="${validUser.ip}">
d.add(14,1,'<fmt:message key="ip.mgt" />','','','','ressource/folder.gif','ressource/folderopen.gif',false);
d.add(141,14,'<fmt:message key="ip.addr.add" />','${validUser.lang}/ip_gestion_ajout.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(142,14,'<fmt:message key="ip.addr.mod" />','${validUser.lang}/ip_gestion_modif.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(143,14,'<fmt:message key="ip.addr.del" />','${validUser.lang}/ip_gestion_del.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(144,14,'<fmt:message key="ip.addr.mig" />','${validUser.lang}/ip_gestion_mig.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(145,14,'<fmt:message key="ip.addr.dispo" />','${validUser.lang}/ip_gestion_ipdispo.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
d.add(2,0,'<fmt:message key="photo" />','','','','ressource/FlecheTurquoise_F.gif','ressource/FlecheTurquoise_O.gif',false);
d.add(20,2,'<fmt:message key="photo.album" />','${validUser.lang}/photo_album.html','','','ressource/page.gif','ressource/page.gif',false);
<c:if test="${validUser.admin}">
d.add(21,2,'<fmt:message key="photo.room" />','${validUser.lang}/photo_gsalle.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(22,2,'<fmt:message key="photo.set" />','${validUser.lang}/photo_gbox.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(23,2,'<fmt:message key="photo.rack" />','${validUser.lang}/photo_gbaie.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
<c:if test="${validUser.photo}">
d.add(24,2,'<fmt:message key="photo.mgt" />','','','','ressource/folder.gif','ressource/folderopen.gif',false);
d.add(240,24,'<fmt:message key="photo.mgt.del" />','${validUser.lang}/photo_gp_del.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(241,24,'<fmt:message key="photo.mgt.replace" />','${validUser.lang}/photo_gp_replace.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(242,24,'<fmt:message key="photo.mgt.add" />','${validUser.lang}/photo_gp_add.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(243,24,'<fmt:message key="photo.mgt.name" />','${validUser.lang}/photo_gp_name.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
d.add(3,0,'<fmt:message key="stock" />','','','','ressource/FlecheJaune_F.gif','ressource/FlecheJaune_O.gif',false);
d.add(31,3,'<fmt:message key="stock.view" />','${validUser.lang}/stock_display.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(32,3,'<fmt:message key="stock.xls" />','${validUser.lang}/stock_excel.html','','','ressource/page.gif','ressource/page.gif',false);
<c:if test="${validUser.stock}">
d.add(33,3,'<fmt:message key="stock.mgt" />','${validUser.lang}/stock_gestion.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
<c:if test="${validUser.stockAdmin}">
d.add(34,3,'<fmt:message key="stock.type" />','${validUser.lang}/stock_type.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(35,3,'<fmt:message key="stock.cat" />','${validUser.lang}/stock_cat.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(36,3,'<fmt:message key="stock.main" />','${validUser.lang}/stock_main.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(37,3,'<fmt:message key="stock.move" />','${validUser.lang}/stock_move.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
<c:if test="${validUser.admin}">
d.add(4,0,'<fmt:message key="admin" />','','','','ressource/FlecheBleu_F.gif','ressource/FlecheBleu_O.gif',false);
d.add(41,4,'<fmt:message key="admin.obj" />','${validUser.lang}/admin_objets.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(42,4,'<fmt:message key="admin.dir" />','${validUser.lang}/admin_annu.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(43,4,'<fmt:message key="admin.role" />','${validUser.lang}/admin_role.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(44,4,'<fmt:message key="admin.user" />','${validUser.lang}/admin_user.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(45,4,'<fmt:message key="admin.ctx" />','${validUser.lang}/admin_ctx.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(46,4,'<fmt:message key="admin.mail" />','${validUser.lang}/admin_mail.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(47,4,'<fmt:message key="admin.csv" />','${validUser.lang}/admin_csv.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(48,4,'<fmt:message key="admin.tools" />','${validUser.lang}/admin_tools.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(49,4,'<fmt:message key="admin.global" />','${validUser.lang}/admin_global.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(410,4,'<fmt:message key="admin.api" />','${validUser.lang}/admin_api.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(411,4,'<fmt:message key="admin.schedulers" />','${validUser.lang}/admin_schedulers.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(412,4,'<fmt:message key="admin.dhcp" />','${validUser.lang}/admin_dhcp.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
<c:if test="${validUser.rezo}">
d.add(5,0,'<fmt:message key="rezo" />','','','','ressource/FlecheVert_F.gif','ressource/FlecheVert_O.gif',false);
d.add(51,5,'<fmt:message key="rezo.site" />','${validUser.lang}/rezo_site.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(52,5,'<fmt:message key="rezo.subnet" />','${validUser.lang}/rezo_subnet.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(53,5,'<fmt:message key="rezo.vlan" />','${validUser.lang}/rezo_vlan.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(54,5,'<fmt:message key="rezo.red" />','${validUser.lang}/rezo_redundancy.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(55,5,'<fmt:message key="rezo.tools" />','${validUser.lang}/rezo_tools.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
d.add(6,0,'<fmt:message key="norm" />','','','','ressource/FlecheRouge_F.gif','ressource/FlecheRouge_O.gif',false);
d.add(61,6,'<fmt:message key="norm.use" />','${validUser.lang}/norme.html','','','ressource/page.gif','ressource/page.gif',false);
<c:if test="${validUser.rezo}">
d.add(62,6,'<fmt:message key="norm.mgt" />','${validUser.lang}/norme_admin.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
d.add(7,0,'<fmt:message key="sla" />','','','','ressource/FlecheJaune_F.gif','ressource/FlecheJaune_O.gif',false);
d.add(71,7,'<fmt:message key="sla.use" />','${validUser.lang}/sla.html','','','ressource/page.gif','ressource/page.gif',false);
<c:if test="${validUser.rezo}">
d.add(72,7,'<fmt:message key="sla.mgt" />','${validUser.lang}/sla_admin.html','','','ressource/page.gif','ressource/page.gif',false);
</c:if>
d.add(8,0,'<fmt:message key="api" />','','','','ressource/FlecheBleu_F.gif','ressource/FlecheBleu_O.gif',false);
d.add(81,8,'<fmt:message key="api.general" />','${validUser.lang}/api_general.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(82,8,'<fmt:message key="api.ip" />','${validUser.lang}/api_ip.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(83,8,'<fmt:message key="api.network" />','${validUser.lang}/api_network.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(84,8,'<fmt:message key="api.admin" />','${validUser.lang}/api_admin.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(85,8,'<fmt:message key="api.photo" />','${validUser.lang}/api_photo.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(86,8,'<fmt:message key="api.stock" />','${validUser.lang}/api_stock.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(87,8,'<fmt:message key="api.stkadmin" />','${validUser.lang}/api_stkadmin.html','','','ressource/page.gif','ressource/page.gif',false);
d.add(1000,0,'<fmt:message key="infos" />','${validUser.lang}/infos.html','','','ressource/FlecheVert_F.gif','ressource/FlecheVert_O.gif',false);
d.add(1001,0,'<fmt:message key="userprefs" />','${validUser.lang}/user_prefs.html','','','ressource/prefs.png','ressource/prefs.png',false);
d.add(1002,0,'<fmt:message key="chglog" />','${validUser.lang}/Versions.html','','','ressource/changelog.png','ressource/changelog.png',false);
d.add(1003,0,'<fmt:message key="about" />','${validUser.lang}/about.html','','','ressource/yellow_star.gif','ressource/yellow_star.gif',false);
document.write(d);
</script>
<hr/>
<p align="center"><input type="button" value="${lang_commonclose}" onclick="javascript:window.top.close();" /></p>
</body>
</html>
