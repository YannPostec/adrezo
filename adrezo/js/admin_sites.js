//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_cod").value = "";
	T$("add_id").value = "";
	T$("add_name").value = "";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit() {
	var strAlert="";
	var id = T$("add_id").value;
	var cod = T$("add_cod").value;
	var ctx = T$("add_ctx").value;
	var name = T$("add_name").value;

	if (!cod) {	strAlert += "- "+langdata.code+": "+langdata.verifnotnull+"<br />"; }
	else if (cod.length > 8) { strAlert += "- "+langdata.code+": "+langdata.verifsize+" : 8<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_sites_store.jsp","id="+id+"&ctx="+ctx+"&cod="+cod+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_sites_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_id").value = tds[1].firstChild.value;
	T$("add_cod").value = tds[1].firstChild.nextSibling.nodeValue;
	T$("add_name").value = tds[2].firstChild.nodeValue;
}
