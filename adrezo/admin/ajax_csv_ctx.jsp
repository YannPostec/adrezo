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
<c:if test="${validUser != null && pageContext.request.method == 'POST' && validUser.admin && !empty param.listCpt}">
<c:set var="erreur" scope="page" value="0"/>
<c:set var="cptInsert" scope="page" value="0"/>
<c:set var="cptUpdate" scope="page" value="0"/>
<c:forEach items="${param.listCpt}" var="cpt">
	<c:set var="id" scope="page">id${cpt}</c:set>
	<c:set var="name" scope="page">name${cpt}</c:set>
	<c:choose>
		<c:when test="${param[id] == 0}">
			<c:catch var="errInsert">
				<sql:transaction>
					<sql:update>
						INSERT INTO contextes (id,name,site_main)
						VALUES (${adrezo:dbSeqNextval('contextes_seq')}, ?,0)
						<sql:param value="${param[name]}"/>
					</sql:update>
					<sql:query var="roles">select id,new_ctx from auth_roles</sql:query>
					<c:forEach items="${roles.rows}" var="role">
						<sql:update>
							insert into auth_rights (ctx,role,rights)
							values (${adrezo:dbSeqCurrval('contextes_seq')}, ?${adrezo:dbCast('INTEGER')}, ?${adrezo:dbCast('INTEGER')})
							<sql:param value="${role.id}" />
							<sql:param value="${role.new_ctx}" />
						</sql:update>
					</c:forEach>
				</sql:transaction>
			</c:catch>
			<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="erreur" scope="page" value="${erreur+1}"/>
				<c:set var="message" scope="page">${message}<fmt:message key="common.add" /> ${param[name]} : <fmt:message key="common.error" />, <adrezo:trim value="${errInsert}"/><br /></c:set>
			</c:when>
			<c:otherwise>
				<c:set var="cptInsert" scope="page" value="${cptInsert+1}"/>
			</c:otherwise>
			</c:choose>
		</c:when>
		<c:otherwise>
			<c:catch var="errUpdate">
				<sql:update>
					UPDATE contextes
					SET name = ?
					WHERE id = ?${adrezo:dbCast('INTEGER')}
  	 		   		<sql:param value="${param[name]}" />
    	  			<sql:param value="${param[id]}" />
				</sql:update>
			</c:catch>
			<c:choose>
				<c:when test="${errUpdate != null}">
					<adrezo:fileDB value="${errUpdate}"/>
					<c:set var="erreur" scope="page" value="${erreur+1}"/>
					<c:set var="message" scope="page">${message}<fmt:message key="common.modify" /> ${param[id]} : <fmt:message key="common.error" />, <adrezo:trim value="${errUpdate}"/><br /></c:set>
				</c:when>
				<c:otherwise>
					<c:set var="cptUpdate" scope="page" value="${cptUpdate+1}"/>
				</c:otherwise>
			</c:choose>	
		</c:otherwise>
	</c:choose>
</c:forEach>
<fmt:message key="admin.csv.ctx" /> : ${cptInsert}<fmt:message key="admin.csv.added" />, ${cptUpdate}<fmt:message key="admin.csv.modified" />, ${erreur}<fmt:message key="admin.csv.errors" />.<br /><c:if test="${erreur > 0}">${message}<br /></c:if>
</c:if>
