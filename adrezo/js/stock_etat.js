//@Author: Yann POSTEC
function ConfirmDlg(id,ec) {
	showDialog(langdata.confirm,langdata.stkrecep+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:ReceptionCommande("+id+","+ec+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function ChangeEtat() {
	var t = T$("tableStock").tBodies[0].rows;
	var invent = T$("chkInventaire")?T$("chkInventaire").checked:false;
	var variations = "";
	var strAlert = "";
	
	for (var i=0;i<t.length;i++) {
		var variation = t[i].cells[5].firstChild.value;
		if (variation != "" && (isNaN(variation) || variation == 0)) { strAlert += variation+": "+langdata.verifvariation+"<br />"; }
	}
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		for (var i=0;i<t.length;i++) {
			var id = t[i].cells[1].firstChild.value;
			var variation = t[i].cells[5].firstChild.value;
			if (variation != "" && !isNaN(variation) && variation != 0) {
				if (variations != "") { variations += "&"; }
				variations += "var" + id + "=" + variation;
			}
		}
		var myelt = "inv=" + invent;
		if (variations != "") { myelt += "&" + variations; }
		DBAjax("ajax_stock_change.jsp",myelt);
	}
}
function ReceptionCommande(id,ec) {
	if (id) {
		DBAjax("ajax_stock_reception.jsp","id="+id+"&ec="+ec);
	}	
}
function ShowBox(e) {
	var node = e.target;
	var id = node.parentNode.parentNode.nextSibling.firstChild.value;
	var limit = T$("limit").value;
	if (isNaN(limit)) { showDialog(langdata.processerr+": ",langdata.stklimit,"error",0,1); }
	else {
		TINY.box.show({url:'stock_mvt.jsp',post:'type='+id+'&limit='+limit});
	}
}
function goMainSite(site) {
	T$("selSite").value=site;
	T$("f_etat_stock").submit();
}
function changeStock() {
	T$("f_etat_stock").submit();
}
