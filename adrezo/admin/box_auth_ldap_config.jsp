<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser == null}"><jsp:forward page="../login.jsp"><jsp:param name="origURL" value="${pageContext.request.requestURL}" /><jsp:param name="errorKey" value="login.err" /></jsp:forward></c:if>
<c:if test="${validUser.admin && !empty param.id && !empty param.name}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxldap.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<h2><fmt:message key="admin.boxldap.title" /> : ${param.name}</h2>
<sql:query var="ldaps">select server,port,method,basedn,binddn,usrdn,usrclass,usrfilter,usrnameattr,grpdn,grpclass,grpfilter,grpnameattr,grpmemberattr from auth_ldap where id = ${param.id}</sql:query>
<c:set scope="page" var="ldap" value="${ldaps.rows[0]}" />
<input type="hidden" id="ldap_id" value="${param.id}" />
<input type="hidden" id="ldap_new" value="<c:choose><c:when test="${empty ldap}">0</c:when><c:otherwise>1</c:otherwise></c:choose>" />
<p><b><i>* : <fmt:message key="admin.boxldap.mandatoryfield" /></i></b></p>
<p><b>* Server : </b><input type="text" size="50" id="ldap_server" value="${ldap.server}" /><br /><i><fmt:message key="admin.boxldap.server" /></i></p>
<p>Port : <input type="text" size="5" id="ldap_port" value="${ldap.port}" /><br /><i><fmt:message key="admin.boxldap.port" /></i></p>
<p>SSL : <input type="checkbox" id="ldap_method" <c:if test="${ldap.method > 0}"> checked="checked"</c:if> /><br /><i><fmt:message key="admin.boxldap.ssl" /></i></p>
<p><b>* Base DN : </b><input type="text" size="100" id="ldap_basedn" value="${ldap.basedn}" /><br /><i><fmt:message key="admin.boxldap.basedn" /></i></p>
<p><b>* Bind DN : </b><input type="text" size="100" id="ldap_binddn" value="${ldap.binddn}" /><br /><i><fmt:message key="admin.boxldap.binddn" /></i></p>
<p><b>* Bind Password : </b><input type="password" size="30" id="ldap_bindpwd" value="" /><br /><i><fmt:message key="admin.boxldap.bindpwd" /></i></p>
<p><b>* Confirm Bind Password : </b><input type="password" size="30" id="ldap_bindpwd_confirm" value="" /><br /><i><fmt:message key="admin.boxldap.confirmpwd" /></i></p>
<p><b>* User Search Base DN : </b><input type="text" size="150" id="ldap_usrdn" value="${ldap.usrdn}" /><br /><i><fmt:message key="admin.boxldap.userdn" /></i></p>
<p>User Class : <input type="text" size="20" id="ldap_usrclass" value="${ldap.usrclass}" /><br /><i><fmt:message key="admin.boxldap.userclass" /></i></p>
<p>User Search Filter : <input type="text" size="80" id="ldap_usrfilter" value="${ldap.usrfilter}" /><br /><i><fmt:message key="admin.boxldap.userfilter" /></i></p>
<p><b>* User Name Attribute : </b><input type="text" size="20" id="ldap_usrnameattr" value="${ldap.usrnameattr}" /><br /><i><fmt:message key="admin.boxldap.userattr" /></i></p>
<p><b>* Group Search Base DN : </b><input type="text" size="150" id="ldap_grpdn" value="${ldap.grpdn}" /><br /><i><fmt:message key="admin.boxldap.groupdn" /></i></p>
<p>Group Class : <input type="text" size="20" id="ldap_grpclass" value="${ldap.grpclass}" /><br /><i><fmt:message key="admin.boxldap.groupclass" /></i></p>
<p>Group Search Filter : <input type="text" size="80" id="ldap_grpfilter" value="${ldap.grpfilter}" /><br /><i><fmt:message key="admin.boxldap.groupfilter" /></i></p>
<p>Group Name Attribute : <input type="text" size="20" id="ldap_grpnameattr" value="${ldap.grpnameattr}" /><br /><i><fmt:message key="admin.boxldap.groupattr" /></i></p>
<p>Group Member Attribute : <input type="radio" id="ldap_grpmemberattr_m" name="ldap_grpmemberattr" <c:if test="${ldap.grpmemberattr == 'member'}"> checked="checked"</c:if> value="member" /><label for="ldap_grpmemberattr_m">Member</label> <input type="radio" id="ldap_grpmemberattr_mo" name="ldap_grpmemberattr" <c:if test="${ldap.grpmemberattr == 'memberof'}"> checked="checked"</c:if> value="memberof" /><label for="ldap_grpmemberattr_mo">MemberOf</label> <input type="radio" id="ldap_grpmemberattr_mon" name="ldap_grpmemberattr" <c:if test="${ldap.grpmemberattr == 'memberofnested'}"> checked="checked"</c:if> value="memberofnested" /><label for="ldap_grpmemberattr_mon">MemberOf with Nested Groups</label><br /><i><fmt:message key="admin.boxldap.member" /></i></p>

<div id="ldapconfig_err" style="color:red"></div>
<p style="text-align:center"><span onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:ConfigSave()" /></span></p>
</body></html>
</c:if>
