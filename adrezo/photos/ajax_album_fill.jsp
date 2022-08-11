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
<fmt:message key="common.click.add" var="lang_commonclickadd" />
<fmt:message key="common.click.slide" var="lang_commonclickslide" />
<fmt:message key="photo.addphoto" var="lang_addphoto" />
<fmt:message key="photo.mod.RH" var="lang_photomodRH" />
<fmt:message key="photo.mod.RB" var="lang_photomodRB" />
<fmt:message key="photo.mod.VH" var="lang_photomodVH" />
<fmt:message key="photo.mod.VB" var="lang_photomodVB" />
<c:if test="${validUser != null && validUser.read && pageContext.request.method == 'POST' && !empty param.salle}">
<jsp:useBean id="today" scope="page" class="java.util.Date" />
<jsp:useBean id="olddate" scope="page" class="java.util.Date">
	<c:set target="${olddate}" property="time" value="0" />
</jsp:useBean>
<c:set var="OldestPhoto" scope="page" value="${today}" />
<c:set var="NewestPhoto" scope="page" value="${olddate}" />
<ul class="acc" id="acc">
	<li>
		<h3><fmt:message key="photo.roompic" /><fmt:message key="common.space" /><span onmouseover="javascript:tooltip.show('${lang_commonclickslide}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_slide.png" alt="${lang_commonclickslide}" onclick="javascript:slideShowSalle(event,${param.salle})" /></span></h3>
		<div class="acc-section">
			<div class="album acc-content" id="containPhotos">
				<sql:query var="imgs">select id,name,dir,suf,updt from photo where type = 0 and idparent = ${param.salle} order by name</sql:query>
				<c:forEach items="${imgs.rows}" var="img">
					<div class="photos" id="photo_${img.id}">
						<fmt:formatDate value="${img.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
						<c:if test="${img.updt<OldestPhoto}"><c:set var="OldestPhoto" scope="page" value="${img.updt}" /></c:if>
						<c:if test="${img.updt>NewestPhoto}"><c:set var="NewestPhoto" scope="page" value="${img.updt}" /></c:if>
						<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${img.dir}/${img.id}.${img.suf}" target="_blank"><img id="pic_${img.id}" src="${adrezo:envEntry('photo_webhost')}${img.dir}/th_${img.id}.${img.suf}" alt="photo" /></a></span>
						<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${img.id},'photo_${img.id}',true)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${img.id},${img.dir},'${img.suf}','${img.name}')" /></div></c:if>
						<div class="caption">
							<p class="text" id="photoname_${img.id}">${img.name}</p>
							<c:if test="${validUser.photo}"><div class="admin"><img class="text" src="../img/icon_text_modify.png" alt="${lang_commonclickmod}" onclick="javascript:ModifyPhotoNameConfirm(${img.id})" /></div></c:if>
						</div>
					</div>
				</c:forEach>
				<c:if test="${validUser.photo}"><span class="admin photo" onmouseover="javascript:tooltip.show('${lang_addphoto}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_add.png" alt="${lang_addphoto}" onclick="javascript:OpenUpload(event,0,${param.salle},'')" /></span></c:if>
			</div>
		</div>
	</li>
	<sql:query var="boxs">select id,name from photo_box where idsalle = ${param.salle} order by name</sql:query>
	<c:forEach items="${boxs.rows}" var="box">
		<li>
			<h3><fmt:message key="common.table.set" /><fmt:message key="common.space" />${box.name}<fmt:message key="common.space" /><span onmouseover="javascript:tooltip.show('${lang_commonclickslide}')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_slide.png" alt="${lang_commonclickslide}" onclick="javascript:slideShowBox(event,${box.id},'${box.name}')" /></span></h3>
			<div class="acc-section">
				<div class="album acc-content">
					<sql:query var="baies">select id,name from photo_baie where idbox = ${box.id} order by numero</sql:query>
					<c:forEach items="${baies.rows}" var="baie">
						<div class="photos">
							<sql:query var="verso">select id from photo where type=1 and idparent=${baie.id} and (name='VH' or name='VB')</sql:query> 
							<div class="caption" id="caption_${baie.id}">
								<p class="text" id="baiename_${baie.id}">${baie.name}</p>
								<c:if test="${verso.rowCount != 0}">
									<p class="text" id="sens_${baie.id}" onclick="javascript:SwitchView(event,${baie.id})"> (<fmt:message key="photo.recto" />)</p>
								</c:if>
								<c:if test="${validUser.photo}"><div class="admin">
									<img class="text" src="../img/icon_text_modify.png" alt="${lang_commonclickmod}" onclick="javascript:ModifyBaieNameConfirm(${baie.id})" />
									<sql:query var="countpics">select count(*) as cnt from photo where type=1 and idparent = ${baie.id}</sql:query>
									<c:if test="${countpics.rows[0].cnt < 4}">
										<img class="add" src="../img/icon_photo_add.png" alt="${lang_commonclickadd}" onclick="javascript:OpenUpload(event,1,${baie.id},'${baie.name}')" />
									</c:if>
								</div></c:if>
							</div>
							<div class="pic" id="${baie.id}_RH">
								<sql:query var="rhpics">select id,suf,dir,updt from photo where type=1 and idparent=${baie.id} and name='RH'</sql:query>
								<c:forEach items="${rhpics.rows}" var="rhpic">
									<fmt:formatDate value="${rhpic.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
									<c:if test="${rhpic.updt<OldestPhoto}"><c:set var="OldestPhoto" scope="page" value="${rhpic.updt}" /></c:if>
									<c:if test="${rhpic.updt>NewestPhoto}"><c:set var="NewestPhoto" scope="page" value="${rhpic.updt}" /></c:if>
									<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${rhpic.dir}/${rhpic.id}.${rhpic.suf}" target="_blank"><img id="pic_${rhpic.id}" src="${adrezo:envEntry('photo_webhost')}${rhpic.dir}/th_${rhpic.id}.${rhpic.suf}" alt="photo"></a></span>
									<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${rhpic.id},'${baie.id}_RH',false)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${rhpic.id},${rhpic.dir},'${rhpic.suf}','${baie.name} - ${lang_photomodRH}')" /></div></c:if>
								</c:forEach>
							</div>
							<div class="pic" id="${baie.id}_RB">
								<sql:query var="rbpics">select id,suf,dir,updt from photo where type=1 and idparent=${baie.id} and name='RB'</sql:query>
								<c:forEach items="${rbpics.rows}" var="rbpic">
									<fmt:formatDate value="${rbpic.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
									<c:if test="${rbpic.updt<OldestPhoto}"><c:set var="OldestPhoto" scope="page" value="${rbpic.updt}" /></c:if>
									<c:if test="${rbpic.updt>NewestPhoto}"><c:set var="NewestPhoto" scope="page" value="${rbpic.updt}" /></c:if>
									<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${rbpic.dir}/${rbpic.id}.${rbpic.suf}" target="_blank"><img id="pic_${rbpic.id}" src="${adrezo:envEntry('photo_webhost')}${rbpic.dir}/th_${rbpic.id}.${rbpic.suf}" alt="photo"></a></span>
									<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${rbpic.id},'${baie.id}_RB',false)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${rbpic.id},${rbpic.dir},'${rbpic.suf}','${baie.name} - ${lang_photomodRB}')" /></div></c:if>
								</c:forEach>
							</div>
							<div class="pic" id="${baie.id}_VH" style="display:none">
								<sql:query var="vhpics">select id,suf,dir,updt from photo where type=1 and idparent=${baie.id} and name='VH'</sql:query>
								<c:forEach items="${vhpics.rows}" var="vhpic">
									<fmt:formatDate value="${vhpic.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
									<c:if test="${vhpic.updt<OldestPhoto}"><c:set var="OldestPhoto" scope="page" value="${vhpic.updt}" /></c:if>
									<c:if test="${vhpic.updt>NewestPhoto}"><c:set var="NewestPhoto" scope="page" value="${vhpic.updt}" /></c:if>
									<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${vhpic.dir}/${vhpic.id}.${vhpic.suf}" target="_blank"><img id="pic_${vhpic.id}" src="${adrezo:envEntry('photo_webhost')}${vhpic.dir}/th_${vhpic.id}.${vhpic.suf}" alt="photo"></a></span>
									<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${vhpic.id},'${baie.id}_VH',false)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${vhpic.id},${vhpic.dir},'${vhpic.suf}','${baie.name} - ${lang_photomodVH}')" /></div></c:if>
								</c:forEach>
							</div>
							<div class="pic" id="${baie.id}_VB" style="display:none">
								<sql:query var="vbpics">select id,suf,dir,updt from photo where type=1 and idparent=${baie.id} and name='VB'</sql:query>
								<c:forEach items="${vbpics.rows}" var="vbpic">
									<fmt:formatDate value="${vbpic.updt}" type="both" pattern="dd/MM/yyyy" var="fmtDatePhoto" scope="page" />
									<c:if test="${vbpic.updt<OldestPhoto}"><c:set var="OldestPhoto" scope="page" value="${vbpic.updt}" /></c:if>
									<c:if test="${vbpic.updt>NewestPhoto}"><c:set var="NewestPhoto" scope="page" value="${vbpic.updt}" /></c:if>
									<span onmouseover="javascript:tooltip.show('${fmtDatePhoto}')" onmouseout="javascript:tooltip.hide()"><a href="${adrezo:envEntry('photo_webhost')}${vbpic.dir}/${vbpic.id}.${vbpic.suf}" target="_blank"><img id="pic_${vbpic.id}" src="${adrezo:envEntry('photo_webhost')}${vbpic.dir}/th_${vbpic.id}.${vbpic.suf}" alt="photo"></a></span>
									<c:if test="${validUser.photo}"><div class="admin"><img class="del" src="../img/icon_photo_delete.png" alt="${lang_commonclickdel}" onclick="javascript:DeletePhotoConfirm(${vbpic.id},'${baie.id}_VB',false)" /><img class="mod" src="../img/icon_photo_modify.png" alt="${lang_commonclickmod}" onclick="javascript:OpenReplace(event,${vbpic.id},${vbpic.dir},'${vbpic.suf}','${baie.name} - ${lang_photomodVB}')" /></div></c:if>
								</c:forEach>
							</div>
						</div>
					</c:forEach>
				</div>
			</div>
		</li>
	</c:forEach>
</ul>
<c:choose>
	<c:when test="${NewestPhoto == olddate}">
		<fmt:message key="photo.nophoto" var="nophoto" />
		<input type="hidden" id="OldestPicture" value="${nophoto}"/>
		<input type="hidden" id="NewestPicture" value="${nophoto}"/>
	</c:when>
	<c:otherwise>
		<fmt:formatDate value="${OldestPhoto}" type="both" pattern="dd/MM/yyyy" var="fmtOldestPhoto" scope="page" />
		<fmt:formatDate value="${NewestPhoto}" type="both" pattern="dd/MM/yyyy" var="fmtNewestPhoto" scope="page" />
		<input type="hidden" id="OldestPicture" value="${fmtOldestPhoto}" />
		<input type="hidden" id="NewestPicture" value="${fmtNewestPhoto}" />
	</c:otherwise>
</c:choose>
</c:if>
