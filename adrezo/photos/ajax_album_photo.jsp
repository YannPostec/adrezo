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
<c:if test="${validUser != null && pageContext.request.method == 'POST' && !empty param.salle}">
<fmt:message key="common.click.del" var="lang_commonclickdel" />
<fmt:message key="common.click.mod" var="lang_commonclickmod" />
<fmt:message key="photo.addphoto" var="lang_addphoto" />
<sql:query var="imgs">select id,name,dir,suf,updt from photo where type = 0 and idparent = ${param.salle} order by name</sql:query>
<c:forEach items="${imgs.rows}" var="img">
	<div class="photos" id="photo_${img.id}">
		<fmt:formatDate value="${img.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
		<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${img.dir}/${img.id}.${img.suf}" target="_blank"><img id="pic_${img.id}" src="${adrezo:envEntry('photo_webhost')}${img.dir}/th_${img.id}.${img.suf}" alt="photo"></a></span>
		<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${img.id},'photo_${img.id}',true)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${img.id},${img.dir},'${img.suf}','${img.name}')" /></div></c:if>
		<div class="caption">
			<p class="text" id="photoname_${img.id}">${img.name}</p>
			<c:if test="${validUser.photo}"><div class="admin"><img class="text" src="../img/icon_text_modify.png" alt="${lang_commonclickmod}" onclick="javascript:ModifyPhotoNameConfirm(${img.id})" /></div></c:if>
		</div>
	</div>
</c:forEach>
<c:if test="${validUser.photo}"><span class="admin photo" onmouseover="javascript:tooltip.show('${lang_addphoto}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_addphoto}" onclick="javascript:OpenUpload(event,0,${param.salle},'')" /></span></c:if>
</c:if>
