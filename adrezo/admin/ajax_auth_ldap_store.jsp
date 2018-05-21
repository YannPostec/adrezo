<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && validUser.admin}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose>
	<c:when test="${param.newldap == 0 && !empty param.bindpwd}">
		<c:catch var="errInsert">
			<sql:update>
				insert into auth_ldap (id,server<c:if test="${!empty param.port}">,port</c:if><c:if test="${!empty param.method}">,method</c:if>,basedn,binddn,bindpwd,usrdn,usrfilter,usrnameattr,grpdn,grpfilter<c:if test="${!empty param.grpnameattr}">,grpnameattr</c:if><c:if test="${!empty param.grpmemberattr}">,grpmemberattr</c:if><c:if test="${!empty param.grpclass}">,grpclass</c:if><c:if test="${!empty param.usrclass}">,usrclass</c:if>)
				values (?${adrezo:dbCast('INTEGER')},?<c:if test="${!empty param.port}">,?${adrezo:dbCast('INTEGER')}</c:if><c:if test="${!empty param.method}">,?${adrezo:dbCast('INTEGER')}</c:if>,?,?,?,?,?,?,?,?<c:if test="${!empty param.grpnameattr}">,?</c:if><c:if test="${!empty param.grpmemberattr}">,?</c:if><c:if test="${!empty param.grpclass}">,?</c:if><c:if test="${!empty param.usrclass}">,?</c:if>)
				<sql:param value="${param.id}"/>
				<sql:param value="${param.server}"/>
				<c:if test="${!empty param.port}"><sql:param value="${param.port}"/></c:if>
				<c:if test="${!empty param.method}"><sql:param value="${param.method}"/></c:if>
				<sql:param value="${param.basedn}"/>
				<sql:param value="${param.binddn}"/>
				<sql:param value="${adrezo:encryptLDAPPwd(param.bindpwd)}"/>
				<sql:param value="${param.usrdn}"/>
				<sql:param value="${param.usrfilter}"/>
				<sql:param value="${param.usrnameattr}"/>
				<sql:param value="${param.grpdn}"/>
				<sql:param value="${param.grpfilter}"/>
				<c:if test="${!empty param.grpnameattr}"><sql:param value="${param.grpnameattr}"/></c:if>
				<c:if test="${!empty param.grpmemberattr}"><sql:param value="${param.grpmemberattr}"/></c:if>
				<c:if test="${!empty param.grpclass}"><sql:param value="${param.grpclass}"/></c:if>
				<c:if test="${!empty param.usrclass}"><sql:param value="${param.usrclass}"/></c:if>
			</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authldap" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authldap" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:catch var="errUpdate">
			<sql:update>
				UPDATE auth_ldap
				SET server = ?,
					port = ?,
					method = ?,
					basedn = ?,
					binddn = ?,
					<c:if test="${!empty param.bindpwd}">bindpwd = ?,</c:if>
					usrdn = ?,
					usrfilter = ?,
					usrnameattr = ?,
					usrclass = ?,
					grpdn = ?,
					grpfilter = ?,
					grpnameattr = ?,
					grpmemberattr = ?,
					grpclass= ?
				WHERE id = ?
				<sql:param value="${param.server}"/>
				<sql:param value="${param.port}"/>
				<sql:param value="${param.method}"/>
				<sql:param value="${param.basedn}"/>
				<sql:param value="${param.binddn}"/>
				<c:if test="${!empty param.bindpwd}"><sql:param value="${adrezo:encryptLDAPPwd(param.bindpwd)}"/></c:if>
				<sql:param value="${param.usrdn}"/>
				<sql:param value="${param.usrfilter}"/>
				<sql:param value="${param.usrnameattr}"/>
				<sql:param value="${param.usrclass}"/>
				<sql:param value="${param.grpdn}"/>
				<sql:param value="${param.grpfilter}"/>
				<sql:param value="${param.grpnameattr}"/>
				<sql:param value="${param.grpmemberattr}"/>
				<sql:param value="${param.grpclass}"/>
				<sql:param value="${param.id}"/>
			</sql:update>
		</c:catch>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /> <fmt:message key="admin.authldap" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /> <fmt:message key="admin.authldap" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>	
	</c:otherwise>
</c:choose>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
