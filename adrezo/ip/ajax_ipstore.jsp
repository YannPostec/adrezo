<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<fmt:requestEncoding value="UTF-8" />
<fmt:setBundle basename="ypodev.adrezo.props.lang" />
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:choose>
<c:when test="${validUser != null && pageContext.request.method == 'POST' && !empty param.listCpt && validUser.ip && !empty param.ctx}">
<c:set var="message"><valid>true</valid></c:set>
<jsp:useBean id="now" class="java.util.Date" />
<c:set var="erreur" scope="page" value="0"/>
<c:forEach items="${param.listCpt}" var="cpt">
	<c:set var="id" scope="page">ipid${cpt}</c:set>
	<c:set var="site" scope="page">Site${cpt}</c:set>
	<c:set var="name" scope="page">Name${cpt}</c:set>
	<c:set var="def" scope="page">Def${cpt}</c:set>
	<c:set var="ip" scope="page">IP${cpt}</c:set>
	<c:set var="mask" scope="page">Mask${cpt}</c:set>
	<c:set var="subnet" scope="page">Subnet${cpt}</c:set>
	<c:set var="mac" scope="page">Mac${cpt}</c:set>
	<c:set var="temp" scope="page">Temp${cpt}</c:set>
	<c:if test="${param[temp] == 'OUI'}">
		<c:set var="dtemp" scope="page">DateTemp${cpt}</c:set>
	</c:if>
	<c:set var="mig" scope="page">Mig${cpt}</c:set>
	<c:if test="${param[mig] == 'OUI'}">
		<c:set var="dmig" scope="page">DateMig${cpt}</c:set>
		<c:set var="maskmig" scope="page">MaskMig${cpt}</c:set>
		<c:set var="subnetmig" scope="page">SubnetMig${cpt}</c:set>
		<c:set var="sitemig" scope="page">SiteMig${cpt}</c:set>
		<c:set var="ipmig" scope="page">IPMig${cpt}</c:set>
	</c:if>
	<c:choose>
	<c:when test="${empty param[id]}">
		<%-- Ajout enregistrement --%>
		<c:catch var="errInsert">
			<sql:transaction>
				<sql:update>
					INSERT INTO adresses (ID,CTX,SITE,NAME,DEF,IP,MASK,MAC,SUBNET,USR_MODIF,DATE_MODIF<c:if test="${param[temp] == 'OUI'}">,TEMP,DATE_TEMP,USR_TEMP<fmt:parseDate value="${param[dtemp]}" var="parsedDateTemp" pattern="dd/MM/yyyy" /></c:if><c:if test="${param[mig] == 'OUI'}">,MIG,DATE_MIG,USR_MIG,IP_MIG,SUBNET_MIG,MASK_MIG,SITE_MIG<fmt:parseDate value="${param[dmig]}" var="parsedDateMig" pattern="dd/MM/yyyy" /></c:if>)
					VALUES (${adrezo:dbSeqNextval('adresses_seq')},?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},?,?,?,?${adrezo:dbCast('INTEGER')},?,?${adrezo:dbCast('INTEGER')},?,?<c:if test="${param[temp] == 'OUI'}">,1,?${adrezo:dbCast('TIMESTAMP')},?</c:if><c:if test="${param[mig] == 'OUI'}">,1,?${adrezo:dbCast('TIMESTAMP')},?,?,?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')}</c:if>)
					<sql:param value="${param.ctx}"/>
					<sql:param value="${param[site]}"/>
					<sql:param value="${param[name]}"/>
					<sql:param value="${param[def]}"/>
					<sql:param value="${param[ip]}"/>
					<sql:param value="${param[mask]}"/>
					<sql:param value="${param[mac]}"/>
					<sql:param value="${param[subnet]}"/>
					<sql:param value="${validUser.login}"/>
					<sql:dateParam value="${now}" />
					<c:if test="${param[temp] == 'OUI'}">
						<sql:dateParam value="${parsedDateTemp}" type="date" />
						<sql:param value="${validUser.login}"/>
					</c:if>
					<c:if test="${param[mig] == 'OUI'}">
						<sql:dateParam value="${parsedDateMig}" type="date" />
						<sql:param value="${validUser.login}"/>
						<sql:param value="${param[ipmig]}" />
						<sql:param value="${param[subnetmig]}" />
						<sql:param value="${param[maskmig]}" />
						<sql:param value="${param[sitemig]}" />
					</c:if>
				</sql:update>
				<c:if test="${param[mig] == 'OUI'}">
					<sql:update>
						INSERT INTO adresses (TYPE,ID,CTX,SITE,NAME,DEF,IP,MASK,SUBNET,USR_MODIF,DATE_MODIF,IP_MIG)
						VALUES ('dynamic',${adrezo:dbSeqNextval('adresses_seq')},?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},'RESA MIGRATION','Migration de <adrezo:displayIP value="${param[ip]}"/>',?,?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},?,?${adrezo:dbCast('TIMESTAMP')},?)
						<sql:param value="${param.ctx}"/>
						<sql:param value="${param[sitemig]}" />
						<sql:param value="${param[ipmig]}" />
						<sql:param value="${param[maskmig]}" />
						<sql:param value="${param[subnetmig]}" />
						<sql:param value="${validUser.login}"/>
						<sql:dateParam value="${now}" />
						<sql:param value="${param[ip]}" />
					</sql:update>
				</c:if>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errInsert != null}">
				<adrezo:fileDB value="${errInsert}"/>
				<c:set var="message" scope="page">${message}<msg><action>Ajout</action><type>Erreur</type><cpt>${cpt}</cpt><texte></c:set>
				<c:choose>
				<c:when test="${fn:containsIgnoreCase(errInsert,'violation de contrainte unique')}"><c:set var="message" scope="page">${message}<fmt:message key="ip.exist" /></c:set></c:when>
				<c:otherwise><c:set var="message" scope="page">${message}<adrezo:trim value="${errInsert}"/></c:set>
				</c:otherwise>
				</c:choose>
				<c:set var="message" scope="page">${message}</texte></msg></c:set>
				<c:set var="erreur" scope="page" value="1"/>
			</c:when>
			<c:otherwise><c:set var="message" scope="page">${message}<msg><action>Ajout</action><type>OK</type><cpt>${cpt}</cpt></msg></c:set></c:otherwise>
		</c:choose>
	</c:when>
	<c:otherwise>
		<%-- Modification enregistrement --%>
		<c:catch var="errUpdate">
			<sql:query var="migration">
				SELECT IP,MIG,IP_MIG,MASK_MIG FROM adresses
				WHERE ID = ?${adrezo:dbCast('INTEGER')}
				<sql:param value="${param[id]}"/>
			</sql:query>
			<sql:transaction>
				<sql:update>
					UPDATE adresses
					SET	CTX = ?${adrezo:dbCast('INTEGER')},
						SITE = ?${adrezo:dbCast('INTEGER')},
						NAME = ?,
						DEF = ?,
						IP = ?,
						MASK = ?${adrezo:dbCast('INTEGER')},
						MAC = ?,
						SUBNET = ?${adrezo:dbCast('INTEGER')},
						USR_MODIF = ?,
						DATE_MODIF = ?${adrezo:dbCast('TIMESTAMP')}
					<c:choose>
						<c:when test="${param[temp] == 'OUI'}">,TEMP = 1,DATE_TEMP = ?${adrezo:dbCast('TIMESTAMP')},USR_TEMP = ?<fmt:parseDate value="${param[dtemp]}" var="parsedDateTemp" pattern="dd/MM/yyyy" /></c:when>
						<c:otherwise>,TEMP = 0,DATE_TEMP = NULL,USR_TEMP = NULL</c:otherwise>
					</c:choose>
					<c:choose>
						<c:when test="${param[mig] == 'OUI'}">,MIG = 1,DATE_MIG = ?${adrezo:dbCast('TIMESTAMP')},USR_MIG = ?,IP_MIG = ?,MASK_MIG = ?${adrezo:dbCast('INTEGER')},SUBNET_MIG = ?${adrezo:dbCast('INTEGER')},SITE_MIG = ?${adrezo:dbCast('INTEGER')}<fmt:parseDate value="${param[dmig]}" var="parsedDateMig" pattern="dd/MM/yyyy" /></c:when>
						<c:otherwise>,MIG = 0,DATE_MIG = NULL,USR_MIG = NULL,IP_MIG = NULL,MASK_MIG = NULL,SUBNET_MIG = NULL,SITE_MIG = NULL</c:otherwise>
					</c:choose>
					WHERE ID = ?${adrezo:dbCast('INTEGER')}
					<sql:param value="${param.ctx}"/>
					<sql:param value="${param[site]}"/>
					<sql:param value="${param[name]}"/>
					<sql:param value="${param[def]}"/>
					<sql:param value="${param[ip]}"/>
					<sql:param value="${param[mask]}"/>
					<sql:param value="${param[mac]}"/>
					<sql:param value="${param[subnet]}"/>
					<sql:param value="${validUser.login}"/>
					<sql:dateParam value="${now}" />
					<c:if test="${param[temp] == 'OUI'}">
						<sql:dateParam value="${parsedDateTemp}" type="date" />
						<sql:param value="${validUser.login}"/>
					</c:if>
					<c:if test="${param[mig] == 'OUI'}">
						<sql:dateParam value="${parsedDateMig}" type="date" />
						<sql:param value="${validUser.login}"/>
						<sql:param value="${param[ipmig]}" />
						<sql:param value="${param[maskmig]}" />
						<sql:param value="${param[subnetmig]}" />
						<sql:param value="${param[sitemig]}" />
					</c:if>
					<sql:param value="${param[id]}"/>
				</sql:update>
				<c:if test="${migration.rows[0].MIG == 1 && (param[mig] != 'OUI' || (param[mig] == 'OUI' && migration.rows[0].IP_MIG != param[ipmig]))}">
					<sql:update>
						DELETE FROM adresses
						WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND IP = ? AND MASK = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${param.ctx}"/>
						<sql:param value="${migration.rows[0].IP_MIG}" />
						<sql:param value="${migration.rows[0].MASK_MIG}" />
					</sql:update>
				</c:if>
				<c:if test="${param[mig] == 'OUI' && (migration.rows[0].MIG == 0 || (migration.rows[0].MIG == 1 && migration.rows[0].IP_MIG != param[ipmig]))}">
					<sql:update>
						INSERT INTO adresses (TYPE,ID,CTX,SITE,NAME,DEF,IP,MASK,SUBNET,USR_MODIF,DATE_MODIF,IP_MIG)
						VALUES ('dynamic',${adrezo:dbSeqNextval('adresses_seq')},?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},'RESA MIGRATION','Migration de <adrezo:displayIP value="${param[ip]}"/>',?,?${adrezo:dbCast('INTEGER')},?${adrezo:dbCast('INTEGER')},?,?${adrezo:dbCast('TIMESTAMP')},?)
						<sql:param value="${param.ctx}"/>
						<sql:param value="${param[sitemig]}" />
						<sql:param value="${param[ipmig]}" />
						<sql:param value="${param[maskmig]}" />
						<sql:param value="${param[subnetmig]}" />
						<sql:param value="${validUser.login}"/>
						<sql:dateParam value="${now}" />
						<sql:param value="${param[ip]}" />
					</sql:update>
				</c:if>
				<c:if test="${migration.rows[0].MIG == 1 && param[mig] == 'OUI' && migration.rows[0].IP != param[ip]}">
					<sql:update>
						UPDATE ADRESSES
						SET DEF = 'Migration de <adrezo:displayIP value="${param[ip]}"/>'
						WHERE CTX = ?${adrezo:dbCast('INTEGER')} AND IP = ? AND MASK = ?${adrezo:dbCast('INTEGER')}
						<sql:param value="${param.ctx}"/>
						<sql:param value="${param[ipmig]}"/>
						<sql:param value="${param[maskmig]}"/>
					</sql:update>
				</c:if>
			</sql:transaction>
		</c:catch>
		<c:choose>
			<c:when test="${errUpdate != null}">
				<adrezo:fileDB value="${errUpdate}"/>
				<c:set var="message" scope="page">${message}<msg><action>Modification</action><type>Erreur</type><cpt>${cpt}</cpt><texte></c:set>
				<c:choose>
				<c:when test="${fn:containsIgnoreCase(errUpdate,'violation de contrainte unique')}"><c:set var="message" scope="page">${message}<fmt:message key="ip.exist" /></c:set></c:when>
				<c:otherwise><c:set var="message" scope="page">${message}<adrezo:trim value="${errUpdate}"/></c:set>
				</c:otherwise>
				</c:choose>
				<c:set var="message" scope="page">${message}</texte></msg></c:set>
				<c:set var="erreur" scope="page" value="1"/>
			</c:when>
			<c:otherwise><c:set var="message" scope="page">${message}<msg><action>Modification</action><type>OK</type><cpt>${cpt}</cpt></msg></c:set></c:otherwise>
		</c:choose>
	</c:otherwise>
	</c:choose>
</c:forEach>
</c:when>
<c:otherwise>
	<c:set var="message"><valid>false</valid></c:set>
</c:otherwise>
</c:choose>
<c:out value="<?xml version=\"1.0\" encoding=\"UTF-8\"?><reponse><erreur>" escapeXml="false"/>
<c:choose>
	<c:when test="${erreur == 1}"><c:out value="true" escapeXml="false"/></c:when>
	<c:otherwise><c:out value="false" escapeXml="false"/></c:otherwise>
</c:choose>
<c:out value="</erreur>${message}</reponse>" escapeXml="false"/>
