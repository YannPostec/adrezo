//@Author: Yann POSTEC
function chgAppLang(lang) {
	DBAjax("ajax_global_lang.jsp","lang="+lang);
}
function chgAppCtx(ctx) {
	DBAjax("ajax_global_ctx.jsp","ctx="+ctx);
}
function modSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var pwd = tds[1].firstChild.value;
	var mail = tds[2].firstChild.value;
	if (pwd.length > 128) { strAlert += "- "+langdata.pwd+": "+langdata.verifsize+" : 128<br />"; }
	if (!mail) {	strAlert += "- "+langdata.mail+": "+langdata.verifnotnull+"<br />"; }
	else if (mail.length > 100) { strAlert += "- "+langdata.mail+": "+langdata.verifsize+" : 100<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_global_admin.jsp","mail="+mail+"&pwd="+encodeURIComponent(pwd));
	}
}
function expaccSubmit() {
	DBAjax("ajax_global_expacc.jsp","pref="+T$("adm_exppref").value+"&suff="+T$("adm_expsuff").value);
}
function getPhotoLog() {
	window.open("../log/photo.log");
}
function getDbLog() {
	window.open("../log/database.log");
}
function getQuartzLog() {
	window.open("../log/quartz.log");
}
function getQuartzJobsLog() {
	window.open("../log/quartz-jobs.log");
}
function getDefaultLog() {
	window.open("../log/adrezo-default.log");
}
function getApiLog() {
	window.open("../log/adrezo-api.log");
}
function getBeansLog() {
	window.open("../log/adrezo-beans.log");
}
function getJspLog() {
	window.open("../log/adrezo-jsp.log");
}
function getServletsLog() {
	window.open("../log/adrezo-servlets.log");
}
function getListenerLog() {
	window.open("../log/adrezo-listener.log");
}
function ResetAdd() {
	T$("add_proto").value = "";
	T$("add_id").value = "";
	T$("add_port").value = "";
	T$("add_uri").value = "";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert = "";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var proto = tds[2].firstChild.nextSibling.value;
	var port = tds[3].firstChild.value;
	var uri = tds[4].firstChild.value;

	if (!proto) { strAlert += "- "+langdata.proto+": "+langdata.verifnotnull+"<br />"; }
	else if (proto.length > 10) { strAlert += "- "+langdata.proto+": "+langdata.verifsize+" : 10<br />"; }
	if (uri.length > 100) { strAlert += "- "+langdata.uri+": "+langdata.verifsize+" : 100<br />"; }
	if (port) {
		if (isNaN(port) || port < 1) { strAlert += "- "+langdata.port+": "+langdata.verifnumber+"<br />"; }
	}
	
	if (proto == "http" && port == 80) { port = ""; }
	if (proto == "https" && port == 443) { port = ""; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_global_url_store.jsp","id="+id+"&proto="+proto+"&port="+port+"&uri="+uri);
	}
}
function delSubmit(id) {
	DBAjax("ajax_global_url_delete.jsp","id="+id);
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="none";
	span[1].style.display="inline";
	span[2].style.display="inline";
	var txt = tds[2].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 10;
	ipt.value = texte;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var txt = tds[3].firstChild;
	var texte = txt?txt.nodeValue:"";
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 10;
	ipt.value = texte;
	txt?tds[3].replaceChild(ipt,txt):tds[3].appendChild(ipt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild;
	var texte = txt?txt.nodeValue:"";
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 100;
	ipt.value = texte;
	txt?tds[4].replaceChild(ipt,txt):tds[4].appendChild(ipt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipt = tds[4].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
}
function progressHandler(event){
	var percent = (event.loaded / event.total) * 50;
	T$("upProgress").value = Math.round(percent);
	T$("upStatus").innerHTML = langdata.upload+" : "+Math.round(percent)+"%";
	if (percent==50) { T$("upStatus").innerHTML = langdata.upend; }
}
function errorHandler(event){
	T$("upStatus").innerHTML = langdata.uperr;
	T$("upError").innerHTML = event.target.status+" : "+event.target.statusText;
	T$("upBtnReset").style.display = "inline";
}
function abortHandler(event){
	T$("upStatus").innerHTML = langdata.upcancel;
	T$("upBtnReset").style.display = "inline";
}
function completeUploadHandler(event) {
	var response = event.target.responseXML.documentElement;
	if (response) { response = cleanXML(response); }
	var erreur = T$$("err",response)[0].firstChild.nodeValue;
	var msg = T$$("msg",response)[0].firstChild.nodeValue;
	if (erreur == "true") {
		T$("upStatus").innerHTML = langdata.analyserr;
		T$("upError").innerHTML = msg;
		T$("upBtnReset").style.display = "inline";
	} else {
		T$("upStatus").innerHTML = langdata.analysend;
		T$("upProgress").value += 25;
		var myimg = T$("logoimg");
		myimg.src=myimg.src+'?'+Math.random();
		T$("upProgress").value += 25;
		T$("upStatus").innerHTML = langdata.processend;
		T$("upBtnReset").style.display = "inline";
	}
}
function submitUpload() {	
	var f = T$("fUpload");
	if (f.file.value != "") {
		T$("upType").value="new";
		T$("upBtnUpload").style.display = "none";
		T$("upBtnBack").style.display = "none";
		T$("upFile").style.display = "none";
		T$("upProgress").style.display = "inline";
		T$("upStatus").innerHTML = langdata.upbegin;
		var formdata = new FormData();
		formdata.append("type",T$("upType").value);
		formdata.append("file", T$("upFile").files[0]);
		var ajax = new XMLHttpRequest();
		ajax.upload.addEventListener("progress", progressHandler, false);
		ajax.addEventListener("load", completeUploadHandler, false);
		ajax.addEventListener("error", errorHandler, false);
		ajax.addEventListener("abort", abortHandler, false);
		ajax.open("POST", "../uploadlogo");
		ajax.send(formdata);
	}
}
function resetUpload() {
	T$("upBtnUpload").style.display = "inline";
	T$("upBtnBack").style.display = "inline";
	T$("upFile").style.display = "inline";
	T$("upProgress").style.display = "none";
	T$("upProgress").value = 0;
	T$("upStatus").innerHTML = "";
	T$("upError").innerHTML = "";
	T$("upBtnReset").style.display = "none";
	T$("upType").value = "new";
}
function backUpload() {
	T$("upType").value="back";
	T$("upBtnUpload").style.display = "none";
	T$("upBtnBack").style.display = "none";
	T$("upFile").style.display = "none";
	T$("upProgress").style.display = "inline";
	T$("upStatus").innerHTML = langdata.upbegin;
	var formdata = new FormData();
	formdata.append("type",T$("upType").value);
	var ajax = new XMLHttpRequest();
	ajax.upload.addEventListener("progress", progressHandler, false);
	ajax.addEventListener("load", completeUploadHandler, false);
	ajax.addEventListener("error", errorHandler, false);
	ajax.addEventListener("abort", abortHandler, false);
	ajax.open("POST", "../uploadlogo");
	ajax.send(formdata);
}
function TestMySQL() {
	TINY.box.show({url:'box_global_mysql.jsp',openjs:function(){opensql()}});
}
function opensql() {
	TINY.box.dim();
}
