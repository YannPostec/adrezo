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
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<c:if test="${validUser != null && validUser.read && pageContext.request.method == 'POST' && !empty param.baieid && !empty param.baietype}">
<c:if test="${param.baietype == 'RH'}"><c:set var="txtBaie" value=" Avant Haut"/></c:if>
<c:if test="${param.baietype == 'RB'}"><c:set var="txtBaie" value=" Avant Bas"/></c:if>
<c:if test="${param.baietype == 'VH'}"><c:set var="txtBaie" value=" Arriere Haut"/></c:if>
<c:if test="${param.baietype == 'VB'}"><c:set var="txtBaie" value=" Arriere Bas"/></c:if>
<sql:query var="pics">select id,suf,dir,updt from photo where type=1 and idparent=${param.baieid} and name='${param.baietype}'</sql:query>
<c:forEach items="${pics.rows}" var="pic">
<fmt:formatDate value="${pic.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${pic.dir}/${pic.id}.${pic.suf}" target="_blank"><img id="pic_${pic.id}" src="${adrezo:envEntry('photo_webhost')}${pic.dir}/th_${pic.id}.${pic.suf}" alt="photo"></a></span>
<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${pic.id},'${param.baieid}_${param.baietype}',false)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${pic.id},${pic.dir},'${pic.suf}','${param.baiename}${txtBaie}')" /></div></c:if>
</c:forEach>
</c:if>
