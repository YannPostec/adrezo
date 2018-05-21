//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
	T$("add_site").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit() {
	var strAlert="";
	var selectsite = T$("add_site");
	var id = T$("add_id").value;
	var name = T$("add_name").value;

	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (name.length > 6) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 6<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_salles_store.jsp","site="+selectsite.value+"&id="+id+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_salles_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_id").value = tds[2].firstChild.value;
	T$("add_name").value = tds[2].firstChild.nextSibling.nodeValue;
	T$("add_site").value = tds[1].firstChild.value;
}
