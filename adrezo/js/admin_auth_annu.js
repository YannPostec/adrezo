//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
	T$("add_ordre").value = "";
	T$("add_type").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var name = tds[2].firstChild.nextSibling.value;
	var ordre = tds[3].firstChild.value;
	var selecttype = tds[4].firstChild;
	var type = selecttype.value;

	if (selecttype.selectedIndex == 0) { strAlert += "- "+langdata.type+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else {
		if (name.indexOf("/") != -1) { strAlert += "- "+langdata.annunameslash+"<br />"; }
		if (name.length > 40) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 40<br />"; }
	}
	if (!ordre || isNaN(ordre) || ordre < 1) { strAlert += "- "+langdata.order+": "+langdata.verifnumber+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_auth_annu_store.jsp","id="+id+"&type="+type+"&name="+name+"&ordre="+ordre);
	}
}
function delSubmit(id) {
	DBAjax("ajax_auth_annu_delete.jsp","id="+id);
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
	ipt.size = 40;
	ipt.value = texte;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var txt = tds[3].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 3;
	ipt.value = texte;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].replaceChild(hid,txt);
	tds[4].firstChild.style.display = "inline";
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
	var hid = tds[4].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].replaceChild(txt,hid);
	tds[4].firstChild.value = tds[4].firstChild.nextSibling.value;
	tds[4].firstChild.style.display = "none";
}
function AnnuConfig(id,type,name) {
	if (type==1) {
		TINY.box.show({url:'box_auth_ldap_config.jsp',post:'id='+id+'&name='+name});
	}
}
function ConfigSave() {
	var id = T$("ldap_id").value;
	var newldap = T$("ldap_new").value;
	var ldap_server = T$("ldap_server").value;
	var ldap_port = T$("ldap_port").value;
	var ldap_method = T$("ldap_method").checked?1:0
	var ldap_basedn = T$("ldap_basedn").value;
	var ldap_binddn = T$("ldap_binddn").value;
	var ldap_bindpwd = T$("ldap_bindpwd").value;
	var ldap_bindpwd_confirm = T$("ldap_bindpwd_confirm").value;
	var ldap_usrdn = T$("ldap_usrdn").value;
	var ldap_usrfilter = T$("ldap_usrfilter").value;
	var ldap_usrnameattr = T$("ldap_usrnameattr").value;
	var ldap_usrclass = T$("ldap_usrclass").value;
	var ldap_grpdn = T$("ldap_grpdn").value;
	var ldap_grpfilter = T$("ldap_grpfilter").value;
	var ldap_grpclass = T$("ldap_grpclass").value;
	var ldap_grpnameattr = T$("ldap_grpnameattr").value;
	var ldap_grpmemberattr = "member";
	if (T$("ldap_grpmemberattr_m").checked) { ldap_grpmemberattr = T$("ldap_grpmemberattr_m").value; }
	if (T$("ldap_grpmemberattr_mo").checked) { ldap_grpmemberattr = T$("ldap_grpmemberattr_mo").value; }
	if (T$("ldap_grpmemberattr_mon").checked) { ldap_grpmemberattr = T$("ldap_grpmemberattr_mon").value; }
	var StrAlert="";
	
	if (newldap == "0") {
		if (ldap_bindpwd != ldap_bindpwd_confirm) { StrAlert += "- "+langdata.pwdmatch+"<br />"; }
		if (!ldap_bindpwd) { StrAlert += "- Bind Password: "+langdata.verifnotnull+"<br />"; }
	} else {
		if ((ldap_bindpwd || ldap_bindpwd_confirm) && ldap_bindpwd != ldap_bindpwd_confirm) { StrAlert += "- "+langdata.pwdmatch+"<br />"; }
	}
	if (!ldap_server) { StrAlert += "- Server: "+langdata.verifnotnull+"<br />"; }
	if (!ldap_binddn) { StrAlert += "- Bind DN: "+langdata.verifnotnull+"<br />"; } 
	if (!ldap_usrdn) { StrAlert += "- User Search Base DN: "+langdata.verifnotnull+"<br />"; }
	if (!ldap_basedn) { StrAlert += "- Base DN: "+langdata.verifnotnull+"<br />"; }
	if (!ldap_usrnameattr) { StrAlert += "- User Name Attribute: "+langdata.verifnotnull+"<br />"; }
	if (!ldap_grpdn) { StrAlert += "- Group Search Base DN: "+langdata.verifnotnull+"<br />"; }
	if (!ldap_port) { ldap_port = "389"; }
	if (!ldap_usrclass) { ldap_usrclass = "user"; }
	if (!ldap_grpnameattr) { ldap_grpnameattr = "cn"; }
	if (!ldap_grpclass) { ldap_grpclass = "group"; }
	if (StrAlert) {
		T$("ldapconfig_err").innerHTML = StrAlert;
		TINY.box.dim();
	} else {
		TINY.box.hide();
		DBAjax("ajax_auth_ldap_store.jsp","id="+id+"&newldap="+newldap+"&server="+ldap_server+"&port="+ldap_port+"&method="+ldap_method+"&binddn="+ldap_binddn+"&bindpwd="+encodeURIComponent(ldap_bindpwd)+"&usrdn="+ldap_usrdn+"&usrfilter="+ldap_usrfilter+"&usrnameattr="+ldap_usrnameattr+"&grpdn="+ldap_grpdn+"&grpfilter="+ldap_grpfilter+"&grpnameattr="+ldap_grpnameattr+"&grpmemberattr="+ldap_grpmemberattr+"&grpclass="+ldap_grpclass+"&usrclass="+ldap_usrclass+"&basedn="+ldap_basedn);
	}
}
