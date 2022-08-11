<%-- @Author: Yann POSTEC --%>
<%@ page contentType="text/xml; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page isELIgnored="false" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sql" uri="http://java.sun.com/jsp/jstl/sql" %>
<%@ taglib prefix="adrezo" uri="adrezotaglib" %>
<%request.setCharacterEncoding("UTF-8");%>
<c:if test="${validUser != null && pageContext.request.method == 'POST' && !empty param.type && validUser.stockAdmin}">
<sql:query var="stks">select stock from stock_etat where id=${param.type}</sql:query>
<c:forEach items="${stks.rows}" var="stk">${stk.stock}</c:forEach>
</c:if>
