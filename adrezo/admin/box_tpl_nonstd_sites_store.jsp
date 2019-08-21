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
<c:if test="${validUser.rezo && !empty param.cod && !empty param.ctx && !empty param.tpl}">
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head><title><fmt:message key="admin.boxsitetpl.title" /> ${param.id}</title>
<meta http-equiv="Pragma" content="no-cache" />
</head>
<body>
<fmt:message key="template.site.nonstd.nothing" var="lang_resnothing" />
<fmt:message key="template.site.nonstd.created" var="lang_rescreated" />
<fmt:message key="template.site.nonstd.allcreated" var="lang_resallcreated" />
<fmt:message key="template.site.nonstd.allcreatedbut" var="lang_resallcreatedbut" />
<input type="hidden" id="addtpl_tpl" value="${param.tpl}" />
<input type="hidden" id="addtpl_ctx" value="${param.ctx}" />
<input type="hidden" id="addtpl_cod" value="${param.cod}" />
<input type="hidden" id="addtpl_name" value="${param.name}" />
<input type="hidden" id="addtpl_nothing" value="${lang_resnothing}" />
<input type="hidden" id="addtpl_created" value="${lang_rescreated}" />
<input type="hidden" id="addtpl_allcreated" value="${lang_resallcreated}" />
<input type="hidden" id="addtpl_allcreatedbut" value="${lang_resallcreatedbut}" />
<sql:query var="sites">select name from tpl_site where id = ${param.tpl}</sql:query>
<sql:query var="NormAddSubnetJobs">select * from schedulers where id=6</sql:query>
<c:forEach items="${NormAddSubnetJobs.rows}" var="nasJob"><input type="hidden" id="addtpl_job" value="${nasJob.jobname}" /></c:forEach>
<c:forEach items="${sites.rows}" var="site">
<h2><fmt:message key="template.site.add" />${site.name}&nbsp;</h2>
</c:forEach>
<hr />
<div id="tplsites_state"></div>
<div id="tplsites_wait"></div>
<div id="tplsites_err" style="color:red"></div>
<div id="tplsites_res" style="font-weight:bold"></div>
<p style="text-align:center"><span id="addtpl_valid" style="display:none;" onmouseover="javascript:tooltip.show('${lang_commonclickvalid}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_valid.png" alt="${lang_commonclickvalid}" onclick="javascript:NSValid()" /></span></p>
</body></html>
</c:if>
