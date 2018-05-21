<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:remove var="validUser" scope="session"/>
<c:if test="${empty param.login}">
	<c:redirect url="/login.jsp">
		<c:param name="errorKey" value="login.nologin" />
	</c:redirect>
</c:if>
<c:if test="${empty param.pwd}">
	<c:redirect url="/login.jsp">
		<c:param name="errorKey" value="login.nopwd" />
	</c:redirect>
</c:if>

<jsp:useBean id="validUser" scope="session" class="ypodev.adrezo.beans.UserInfoBean">
	<c:set target="${validUser}" property="session" value="${applicationScope}" />
	<c:set target="${validUser}" property="login" value="${param.login}" />
	<c:set target="${validUser}" property="pwd" value="${param.pwd}" />
</jsp:useBean>
<c:choose>
	<c:when test="${validUser.erreur}">
		<jsp:forward page="/login.jsp">
			<jsp:param name="errorMsg" value="${validUser.errLog}"/>
		</jsp:forward>
	</c:when>
	<c:otherwise>
		<fmt:setLocale value="${validUser.lang}" scope="session" />
		<c:choose>
			<c:when test="${!empty param.origURL}"><c:redirect url="${param.origURL}" /></c:when>
			<c:otherwise><c:redirect url="/ip/ip.jsp" /></c:otherwise>
		</c:choose>
	</c:otherwise>
</c:choose>
