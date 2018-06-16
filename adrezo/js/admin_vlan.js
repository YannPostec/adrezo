//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_def").value = "";
	T$("add_id").value = "";
	T$("add_vid").value = "";
	T$("add_site").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit() {
	var strAlert="";
	var selectsite = T$("add_site");
	var site = selectsite.value;
	var id = T$("add_id").value;
	var vid = T$("add_vid").value;
	var ctx = T$("add_ctx").value;
	var def = T$("add_def").value;

	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }	
	if (!vid || isNaN(vid) || vid < 0) { strAlert += "- "+langdata.vid+": "+langdata.verifnumber+"<br />"; }
	if (!def) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else if (def.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_vlan_store.jsp","id="+id+"&vid="+vid+"&def="+def+"&site="+site+"&ctx="+ctx);
	}
}
function delSubmit(id) {
	DBAjax("ajax_vlan_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_def").value = tds[3].firstChild.nodeValue;
	T$("add_id").value = tds[2].firstChild.value;
	T$("add_vid").value = tds[2].firstChild.nextSibling.nodeValue;
	T$("add_site").value = tds[1].firstChild.value;
}
