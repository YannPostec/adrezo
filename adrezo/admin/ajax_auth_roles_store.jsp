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
	<c:when test="${empty param.id}">
		<c:catch var="errInsert">
			<sql:transaction>
				<sql:update>
					insert into auth_roles (id,name,new_ctx,pref_ctx,annu)
					values (${adrezo:dbSeqNextval('auth_roles_seq')}, ?, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
					<sql:param value="${param.name}"/>
					<sql:param value="${param.newctx}"/>
					<sql:param value="${param.ctx}"/>
					<sql:param value="${param.annu}"/>
				</sql:update>
				<sql:query var="contextes">select id from contextes</sql:query>
				<c:forEach items="${contextes.rows}" var="ctx">
					<sql:update>
						insert into auth_rights (ctx,role,rights)
						values (?${adrezo:dbCast('INTEGER')},${adrezo:dbSeqCurrval('auth_roles_seq')},0)
						<sql:param value="${ctx.id}" />
					</sql:update>
				</c:forEach>
			</sql:transaction>			
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authrole" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/></msg></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.add" /><fmt:message key="admin.authrole" /> : <fmt:message key="common.ok" /></msg></c:set>
			</c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${param.id > 1}">
				<c:catch var="errUpdate">
					<sql:update>
						UPDATE auth_roles
						SET name = ?,
							new_ctx = ?${adrezo:dbCast('INTEGER')},
							annu = ?${adrezo:dbCast('INTEGER')},
							pref_ctx = ?${adrezo:dbCast('INTEGER')}
						WHERE id = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${param.name}"/>
						<sql:param value="${param.newctx}"/>
						<sql:param value="${param.annu}"/>
						<sql:param value="${param.ctx}"/>
						<sql:param value="${param.id}"/>
					</sql:update>
				</c:catch>
				<c:choose>
					<c:when test="${errUpdate != null}">
						<adrezo:fileDB value="${errUpdate}"/>
						<c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.authrole" /> : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/></msg></c:set>
					</c:when>
					<c:otherwise>
						<c:set var="message" scope="page">${message}<erreur>false</erreur><msg><fmt:message key="common.modify" /><fmt:message key="admin.authrole" /> : <fmt:message key="common.ok" /></msg></c:set>
					</c:otherwise>
				</c:choose>	
			</c:when>
			<c:otherwise>
				<c:if test="${param.id == 0}"><c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="admin.authrole.ro" /> !</msg></c:set></c:if>
				<c:if test="${param.id == 1}"><c:set var="message" scope="page">${message}<erreur>true</erreur><msg><fmt:message key="admin.authrole.local" /> !</msg></c:set></c:if>
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
