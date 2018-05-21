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
<jsp:useBean id="now" class="java.util.Date" />
<c:forEach items="${param.listCpt}" var="cpt">
	<c:set var="id" scope="page">id${cpt}</c:set>
	<c:set var="ctx" scope="page">ctx${cpt}</c:set>
	<c:set var="site" scope="page">site${cpt}</c:set>
	<c:set var="subnet" scope="page">subnet${cpt}</c:set>
	<c:set var="ip" scope="page">ip${cpt}</c:set>
	<c:set var="mask" scope="page">mask${cpt}</c:set>
	<c:set var="def" scope="page">def${cpt}</c:set>
	<c:set var="name" scope="page">name${cpt}</c:set>
	<c:set var="mac" scope="page">mac${cpt}</c:set>
	<c:choose>
		<c:when test="${param[id] == 0}">
			<c:catch var="errInsert">
				<sql:update>
					INSERT INTO adresses (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,USR_MODIF,DATE_MODIF)
					VALUES (${adrezo:dbSeqNextval('adresses_seq')},?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},?,?,?,?${adrezo:dbCast('INTEGER')},?,?${adrezo:dbCast('INTEGER')},?,?${adrezo:dbCast('TIMESTAMP')})
					<sql:param value="${param[ctx]}"/>
					<sql:param value="${param[site]}"/>
					<sql:param value="${param[name]}"/>
					<sql:param value="${param[def]}"/>
					<sql:param value="${param[ip]}"/>
					<sql:param value="${param[mask]}"/>
					<sql:param value="${param[mac]}"/>
					<sql:param value="${param[subnet]}"/>
					<sql:param value="${validUser.login}"/>
					<sql:dateParam value="${now}" />
				</sql:update>
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
					UPDATE adresses
					SET	NAME = ?,
						DEF = ?,
						MAC = ?,
						USR_MODIF = ?,
						DATE_MODIF = ?${adrezo:dbCast('TIMESTAMP')}
					WHERE ID = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param[name]}"/>
					<sql:param value="${param[def]}"/>
					<sql:param value="${param[mac]}"/>
					<sql:param value="${validUser.login}"/>
					<sql:dateParam value="${now}" />
					<sql:param value="${param[id]}"/>
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
<fmt:message key="admin.csv.ip" /> : ${cptInsert}<fmt:message key="admin.csv.added" />, ${cptUpdate}<fmt:message key="admin.csv.modified" />, ${erreur}<fmt:message key="admin.csv.errors" />.<br /><c:if test="${erreur > 0}">${message}<br /></c:if>
</c:if>
