//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_login").value = "";
	T$("add_pwd").value = "";
	T$("add_mail").value = "";
	T$("add_role").selectedIndex = 0;
	T$("add_auth").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit(\""+id+"\");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var login = tds[2].firstChild.nextSibling.value;
	var pwdnew = tds[3].firstChild.value;
	var pwd = tds[3].firstChild.nextSibling.value;
	var mail = tds[4].firstChild.value;
	var selectrole = tds[5].firstChild;
	var role = selectrole.value;
	var selectauth = tds[6].firstChild;
	var auth = selectauth.value;
	if (selectauth.selectedIndex == 0) { strAlert += "- "+langdata.auth+": "+langdata.verifchoose+"<br />"; }
	if (selectrole.selectedIndex == 0) { strAlert += "- "+langdata.role+": "+langdata.verifchoose+"<br />"; }
	if (pwdnew > 0 && !pwd) {	strAlert += "- "+langdata.pwd+": "+langdata.verifnotnull+"<br />"; }
	if (!login) {	strAlert += "- "+langdata.login+": "+langdata.verifnotnull+"<br />"; }
	else if (login.length > 20) { strAlert += "- "+langdata.login+": "+langdata.verifsize+" : 20<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_auth_users_store.jsp","login="+login+"&mail="+mail+"&pwd="+encodeURIComponent(pwd)+"&role="+role+"&auth="+auth+"&id="+id);
	}
}
function delSubmit(id) {
	DBAjax("ajax_auth_users_delete.jsp","id="+id);
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
	ipt.size = 20;
	ipt.value = texte;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var ipt = document.createElement("input");
	ipt.type = "password";
	ipt.size = 20;
	ipt.value = "";
	tds[3].appendChild(ipt);
	var txt = tds[4].firstChild;
	var texte = txt?txt.nodeValue:"";
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 40;
	ipt.value = texte;
	txt?tds[4].replaceChild(ipt,txt):tds[4].appendChild(ipt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var txt = tds[5].firstChild.nextSibling.nextSibling;
	var texte = txt?txt.nodeValue:"";
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	txt?tds[5].replaceChild(hid,txt):tds[5].appendChild(hid);
	tds[5].firstChild.style.display = "inline";
	var txt = tds[6].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[6].replaceChild(hid,txt);
	tds[6].firstChild.style.display = "inline";
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
	var ipt = tds[3].firstChild.nextSibling;
	tds[3].removeChild(ipt);
	var ipt = tds[4].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	var hid = tds[5].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[5].replaceChild(txt,hid);
	tds[5].firstChild.value = tds[5].firstChild.nextSibling.value;
	tds[5].firstChild.style.display = "none";
	var hid = tds[6].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[6].replaceChild(txt,hid);
	tds[6].firstChild.value = tds[6].firstChild.nextSibling.value;
	tds[6].firstChild.style.display = "none";
}
