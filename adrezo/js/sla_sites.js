//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_client").selectedIndex = 0;
	T$("add_name").value = "";
	T$("add_id").value = "";
	T$("add_disp").checked = true;
	T$("add_plan").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/>"+langdata.sladefault+"<br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert = "";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selclient = tds[2].firstChild;
	var client = selclient.value;
	var id = tds[3].firstChild.value;
	var name = tds[3].firstChild.nextSibling.value;
	var disp = tds[4].firstChild.checked?1:0;
	var selplan = tds[5].firstChild;
	var plan = selplan.value;

	if (selclient.selectedIndex == 0) { strAlert += "- "+langdata.client+": "+langdata.verifchoose+"<br />"; }
	if (selplan.selectedIndex == 0) { strAlert += "- "+langdata.planning+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_sites_store.jsp","id="+id+"&client="+client+"&name="+name+"&disp="+disp+"&plan="+plan);
	}
}
function delSubmit(id) {
	DBAjax("ajax_sites_delete.jsp","id="+id);
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="none";
	span[1].style.display="inline";
	span[2].style.display="inline";
	var txt = tds[2].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].replaceChild(hid,txt);
	tds[2].firstChild.style.display = "inline";
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.value = texte;
	ipt.size = 40;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "checkbox";
	if (texte == langdata.dlgyes) { ipt.checked = true; } else { ipt.checked = false; }
	tds[4].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var txt = tds[5].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[5].replaceChild(hid,txt);
	tds[5].firstChild.style.display = "inline";
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	var hid = tds[2].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].replaceChild(txt,hid);
	tds[2].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[2].firstChild.style.display = "none";
	var ipt = tds[3].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipt = tds[4].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var hid = tds[5].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[5].replaceChild(txt,hid);
	tds[5].firstChild.value = tds[5].firstChild.nextSibling.value;
	tds[5].firstChild.style.display = "none";
}
