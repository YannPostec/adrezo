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
<c:when test="${validUser != null && validUser.read && pageContext.request.method == 'POST'}">
<c:set var="message"><valid>true</valid></c:set>
<c:choose><c:when test="${empty param.limit}"><c:set var="limit" value="40"/></c:when><c:otherwise><c:set var="limit" value="${param.limit}"/></c:otherwise></c:choose>
<c:choose><c:when test="${empty param.page}"><c:set var="page" value="1"/></c:when><c:otherwise><c:set var="page" value="${param.page}"/></c:otherwise></c:choose>
<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
	<sql:query var="count">
		SELECT ceil(COUNT(*)/${limit}) FROM ADRESSES WHERE CTX = ${param.ctx}	
		<c:if test="${!empty param.search}"> AND ${param.search}</c:if>
	</sql:query>
</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
	<sql:query var="count">
		SELECT ceil(COUNT(*)/${limit}.0) FROM ADRESSES WHERE CTX = ${param.ctx}	
		<c:if test="${!empty param.search}"> AND ${param.search}</c:if>
	</sql:query>
</c:when></c:choose>
<c:set var="nbPage" value="${count.rowsByIndex[0][0]}" />
<c:if test="${nbPage > 0 && page > nbPage}"><c:set var="page" value="${nbPage}" /></c:if>
<c:set var="lowLimit" value="${(page-1) * limit}" />
<c:set var="highLimit" value="${page * limit}" />
<c:choose>
	<c:when test="${page > 1}"><c:set var="pages"><first>1</first><previous>${page - 1}</previous></c:set></c:when>
	<c:otherwise><c:set var="pages"><first>0</first><previous>0</previous></c:set></c:otherwise>
</c:choose>
<c:choose>
	<c:when test="${nbPage < 9}">
		<c:forEach begin="1" end="${nbPage}" step="1" var="numPage">
			<c:set var="pages">${pages}<num>${numPage}</c:set>
			<c:if test="${numPage == page}"><c:set var="pages">${pages}<current>1</current></c:set></c:if>
			<c:set var="pages">${pages}</num></c:set>
		</c:forEach>
	</c:when>
	<c:otherwise>
		<c:choose>
			<c:when test="${page < 5}">
				<c:forEach begin="1" end="9" step="1" var="numPage">
					<c:set var="pages">${pages}<num>${numPage}</c:set>
					<c:if test="${numPage == page}"><c:set var="pages">${pages}<current>1</current></c:set></c:if>
					<c:set var="pages">${pages}</num></c:set>
				</c:forEach>
			</c:when>
			<c:otherwise>
				<c:choose>
					<c:when test="${page > nbPage - 4}">
						<c:forEach begin="${nbPage -8}" end="${nbPage}" step="1" var="numPage">
							<c:set var="pages">${pages}<num>${numPage}</c:set>
							<c:if test="${numPage == page}"><c:set var="pages">${pages}<current>1</current></c:set></c:if>
							<c:set var="pages">${pages}</num></c:set>
						</c:forEach>
					</c:when>
					<c:otherwise>
						<c:forEach begin="${page - 4}" end="${page + 4}" step="1" var="numPage">
							<c:set var="pages">${pages}<num>${numPage}</c:set>
							<c:if test="${numPage == page}"><c:set var="pages">${pages}<current>1</current></c:set></c:if>
							<c:set var="pages">${pages}</num></c:set>
						</c:forEach>
					</c:otherwise>
				</c:choose>
			</c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>
<c:choose>
	<c:when test="${page < nbPage}"><c:set var="pages">${pages}<next>${page + 1}</next><last>${nbPage}</last></c:set></c:when>
	<c:otherwise><c:set var="pages">${pages}<next>0</next><last>0</last></c:set></c:otherwise>
</c:choose>
<c:set var="message">${message}<nbpage>${nbPage}</nbpage></c:set>
<c:set var="message">${message}<pages>${pages}</pages></c:set>
<sql:query var="iptemp">
	SELECT IP,DATE_TEMP FROM adresses
	WHERE TEMP = 1 AND USR_TEMP = ? AND CTX = ?${adrezo:dbCast('INTEGER')}
	ORDER BY DATE_TEMP
	<sql:param value="${validUser.login}" />
	<sql:param value="${param.ctx}" />
</sql:query>
<c:choose>
	<c:when test="${validUser.ip && iptemp.rowCount != 0}">
		<c:forEach items="${iptemp.rows}" var="temp">
			<fmt:formatDate value="${temp.DATE_TEMP}" type="date" pattern="dd/MM/yyyy" var="fmtDateTemp" scope="page" />
			<c:set var="tempinfo">${tempinfo}<line><adrezo:displayIP value="${temp.IP}"/><fmt:message key="common.space" /><fmt:message key="ip.endvalid" /> : ${fmtDateTemp}</line></c:set>
		</c:forEach>
		<c:set var="message">${message}<usertemp><exist>1</exist><userlogin>${validUser.login}</userlogin>${tempinfo}</usertemp></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message">${message}<usertemp><exist>0</exist></usertemp></c:set>
	</c:otherwise>
</c:choose>
<sql:query var="ipmig">
	SELECT IP,DATE_MIG,IP_MIG FROM adresses
	WHERE MIG = 1 AND USR_MIG = ? AND CTX = ?${adrezo:dbCast('INTEGER')}
	ORDER BY DATE_MIG
	<sql:param value="${validUser.login}" />
	<sql:param value="${param.ctx}" />
</sql:query>
<c:choose>
	<c:when test="${validUser.ip && ipmig.rowCount != 0}">
		<c:forEach items="${ipmig.rows}" var="mig">
			<fmt:formatDate value="${mig.DATE_MIG}" type="date" pattern="dd/MM/yyyy" var="fmtDateMig" scope="page" />
			<c:set var="miginfo">${miginfo}<line><adrezo:displayIP value="${mig.IP}" /><fmt:message key="common.space" /><fmt:message key="ip.migto" /><fmt:message key="common.space" /><adrezo:displayIP value="${mig.IP_MIG}" /><fmt:message key="common.space" /><fmt:message key="ip.endvalid" /> : ${fmtDateMig}</line></c:set>
		</c:forEach>
		<c:set var="message">${message}<usermig><exist>1</exist><userlogin>${validUser.login}</userlogin>${miginfo}</usermig></c:set>
	</c:when>
	<c:otherwise>
		<c:set var="message">${message}<usermig><exist>0</exist></usermig></c:set>
	</c:otherwise>
</c:choose>
<c:choose><c:when test="${adrezo:envEntry('db_type') == 'oracle'}">
	<sql:query var="adr">
		select * from (
		select ID,SITE_NAME,SITE_CODE,SUBNET_NAME,SITE_MIG_NAME,SUBNET_MIG_NAME,SUBNET_GW,SITE,NAME,DEF,IP,MASK,MAC,IP_MIG,SUBNET,TEMP,DATE_TEMP,USR_TEMP,USR_MIG,DATE_MIG,MIG,TYPE,USR_MODIF,DATE_MODIF,MASK_MIG,SUBNET_MIG,SITE_MIG,rownum n from (
		select * from adresses_display where ctx = ${param.ctx}	
		<c:if test="${!empty param.search}"> AND ${param.search}</c:if>
		<c:choose><c:when test="${!empty param.sortKey && !empty param.sortOrder}"> ORDER BY ${param.sortKey}<c:if test="${param.sortOrder == 'DESC'}"> DESC</c:if></c:when><c:otherwise> ORDER BY IP</c:otherwise></c:choose>
		)) where n >= ${lowLimit} and n <= ${highLimit}
	</sql:query>
</c:when><c:when test="${adrezo:envEntry('db_type') == 'postgresql'}">
	<sql:query var="adr">
		select * from adresses_display where ctx = ${param.ctx}	
		<c:if test="${!empty param.search}"> and ${param.search}</c:if>
		<c:choose><c:when test="${!empty param.sortKey && !empty param.sortOrder}"> order by ${param.sortKey}<c:if test="${param.sortOrder == 'DESC'}"> desc</c:if></c:when><c:otherwise> order by ip</c:otherwise></c:choose>
		limit ${limit}
		offset ${lowLimit}
	</sql:query>
</c:when></c:choose>
<c:set var="colortr" value="sideB" />
<c:forEach items="${adr.rows}" var="row">
	<c:choose>
		<c:when test="${colortr == 'sideA'}">
			<c:set var="colortr" value="sideB" />
		</c:when>
		<c:otherwise>
			<c:set var="colortr" value="sideA" />
		</c:otherwise>
	</c:choose>
	<fmt:formatDate value="${row.DATE_MODIF}" type="both" pattern="dd/MM/yyyy HH:mm:ss" var="fmtDateModif" scope="page" />
	<c:choose>
		<c:when test="${row.TEMP == 1}">
			<fmt:formatDate value="${row.DATE_TEMP}" type="date" pattern="dd/MM/yyyy" var="fmtDateTemp" scope="page" />
			<c:set var="fmtTemp"><fmt:message key="common.yes" /> (${row.USR_TEMP}) <fmt:message key="common.space" />${fmtDateTemp}</c:set>
		</c:when>
		<c:otherwise>
			<c:set var="fmtTemp"><fmt:message key="common.no" /></c:set>
		</c:otherwise>
	</c:choose>
	<c:choose>
		<c:when test="${row.MIG == 1}">
			<fmt:formatDate value="${row.DATE_MIG}" type="date" pattern="dd/MM/yyyy" var="fmtDateMig" scope="page" />
			<c:set var="fmtMigstr"><fmt:message key="common.yes" /> (${row.USR_MIG}) <fmt:message key="common.space" />${fmtDateMig}<fmt:message key="common.space" /><adrezo:displayIP value="${row.IP_MIG}"/>/${row.MASK_MIG} (${row.SITE_MIG_NAME}/${row.SUBNET_MIG_NAME})</c:set>
		</c:when>
		<c:otherwise>
			<c:set var="fmtMigstr"><fmt:message key="common.no" /></c:set>
		</c:otherwise>
	</c:choose>
	<c:set var="message">${message}<row></c:set>
	<c:set var="message">${message}<colortr>${colortr}</colortr></c:set>
	<c:set var="message">${message}<id>${row.ID}</id></c:set>
	<c:set var="message">${message}<userip>${validUser.ip}</userip></c:set>
	<c:set var="message">${message}<type>${row.TYPE}</type></c:set>
	<c:set var="message">${message}<site>${row.SITE_NAME}</site></c:set>
	<c:set var="message">${message}<sitetooltip>${row.SITE_CODE}</sitetooltip></c:set>
	<c:set var="message">${message}<name><c:out value="${row.NAME}" escapeXml="true" /></name></c:set>
	<c:set var="message">${message}<def><c:out value="${row.DEF}" escapeXml="true" /></def></c:set>
	<c:set var="message">${message}<ip><adrezo:displayIP value="${row.IP}" /></ip></c:set>
	<c:set var="message">${message}<mask>${row.MASK}</mask></c:set>
	<c:set var="message">${message}<masktooltip><adrezo:displayMask value="${row.MASK}" /></masktooltip></c:set>
	<c:set var="message">${message}<subnet>${row.SUBNET_NAME}</subnet></c:set>
	<c:set var="message">${message}<subnettooltip><adrezo:displayIP value="${row.SUBNET_GW}" /></subnettooltip></c:set>
	<c:set var="message">${message}<mac>${row.MAC}</mac></c:set>
	<c:set var="message">${message}<modif>${row.USR_MODIF}, ${fmtDateModif}</modif></c:set>
	<c:set var="message">${message}<temp>${fmtTemp}</temp></c:set>
	<c:set var="message">${message}<mig>${row.MIG}</mig></c:set>
	<c:set var="message">${message}<migstr>${fmtMigstr}</migstr></c:set>
	<c:set var="message">${message}</row></c:set>
</c:forEach>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse>${message}</reponse>" escapeXml="false"/>
