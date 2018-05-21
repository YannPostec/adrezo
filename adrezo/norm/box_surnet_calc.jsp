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
<c:if test="${validUser.rezo && !empty param.id}">
<fmt:message key="common.click.valid" var="lang_commonclickvalid" />
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="norm.box.calc.title" /></title>
<meta http-equiv="Pragma" content="no-cache" />
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8" />
</head>
<body>
<sql:query var="surnets">select * from surnets where id=${param.id}</sql:query>
<c:forEach items="${surnets.rows}" var="surnet"><c:set var="surtxt"><adrezo:displayIP value="${surnet.ip}" />/${surnet.mask} (${surnet.def})</c:set><c:set var="surmask">${surnet.mask}</c:set></c:forEach>
<div><fmt:message key="norm.box.calc.txt" />${surtxt}</div>
<hr />
<input type="hidden" id="calc_surmask" value="${surmask}" />
<fmt:message key="norm.box.calc.mask" /> <input type="text" value="" size="3" id="calc_mask" />
<img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:calcLoad(${param.id})" /><br />
<span style="color:red;display:none" id="calc_invalid"><fmt:message key="norm.box.calc.invalid" /></span>
<hr />
<div id="calc_err" style="color:red"></div>
<div id="calc_wait"></div>
<div id="tablewrapper">
	<div id="tableheader">
		<div id="tablenav">
			<div>
				<img src="../img/nav_first.gif" alt="First Page" onclick="sortiny.move(-1,true)" />
				<img src="../img/nav_previous.gif" alt="Previous Page" onclick="sortiny.move(-1)" />
				<img src="../img/nav_next.gif" alt="Next Page" onclick="sortiny.move(1)" />
				<img src="../img/nav_end.gif" alt="Last Page" onclick="sortiny.move(1,true)" />
			</div>
		</div>
		<span class="details">
			<div><fmt:message key="tiny.table.record" /> <span id="startrecord"></span>-<span id="endrecord"></span> / <span id="totalrecords"></span></div>
			<div class="page"><fmt:message key="tiny.table.page" /> <span id="currentpage"></span> / <span id="totalpages"></span></div>
		</span>
	</div>
	<table id="table" class="tinytable">
		<thead><tr><th class="nosort"><fmt:message key="admin.subnet" /></th></tr></thead>
		<tbody></tbody>
	</table>
</div>
</body>
</html>
</c:if>
