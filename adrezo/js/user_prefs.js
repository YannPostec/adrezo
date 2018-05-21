//@Author: Yann POSTEC
function chgUsrLang(lang) {
	DBAjax("ajax_userlang_update.jsp","lang="+lang);
}
function chgUsrCtx(ctx) {
	DBAjax("ajax_userctx_update.jsp","ctx="+ctx);
}
function chgUsrUrl(url) {
	DBAjax("ajax_userurl_update.jsp","url="+url);
}
function chgUsrSlideTime() {
	var st = T$("slidetime").value;
	DBAjax("ajax_userslidetime_update.jsp","st="+st);
}

function modSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var pwd = tds[1].firstChild.value;
	if (pwd.length > 128) { strAlert += "- "+langdata.pwd+": "+langdata.verifsize+" : 128<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_userpwd_update.jsp","pwd="+encodeURIComponent(pwd));
	}
}
