<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<fmt:requestEncoding value="UTF-8" />
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${pageContext.request.method == 'POST' && !empty param.pwd}">
<adrezo:updatePwd value="${param.pwd}" />
</c:if>
