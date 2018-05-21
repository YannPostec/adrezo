//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var name = tds[3].firstChild.value;

	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else {
		if (name.indexOf("/") != -1) { strAlert += "- "+langdata.name+": "+langdata.verifnoslash+"<br />"; }
		if (name.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
	}
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_plannings_store.jsp","id="+id+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_plannings_delete.jsp","id="+id);
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="none";
	span[1].style.display="inline";
	span[2].style.display="inline";
	var txt = tds[3].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 50;
	ipt.value = texte;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);	
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
}
function PlanManage(id,name) {
	TINY.box.show({url:'box_plannings_hours.jsp',post:'id='+id+'&name='+name});
}
function PlanValid(e,id) {
	var node = e.target;
	var trs = T$("plan_table").tBodies[0].rows;
	var myRights = new Array();
	for (i=0;i<7;i++) {
		var tds=T$$("td",trs[i]);
		var day=tds[0].firstChild.value;
		var rights=0;
		if (tds[1].firstChild.checked) { rights += 1; }
		if (tds[2].firstChild.checked) { rights += 2; }
		if (tds[3].firstChild.checked) { rights += 4; }
		if (tds[4].firstChild.checked) { rights += 8; }
		if (tds[5].firstChild.checked) { rights += 16; }
		if (tds[6].firstChild.checked) { rights += 32; }
		if (tds[7].firstChild.checked) { rights += 64; }
		if (tds[8].firstChild.checked) { rights += 128; }
		if (tds[9].firstChild.checked) { rights += 256; }
		if (tds[10].firstChild.checked) { rights += 512; }
		if (tds[11].firstChild.checked) { rights += 1024; }
		if (tds[12].firstChild.checked) { rights += 2048; }
		if (tds[13].firstChild.checked) { rights += 4096; }
		if (tds[14].firstChild.checked) { rights += 8192; }
		if (tds[15].firstChild.checked) { rights += 16384; }
		if (tds[16].firstChild.checked) { rights += 32768; }
		if (tds[17].firstChild.checked) { rights += 65536; }
		if (tds[18].firstChild.checked) { rights += 131072; }
		if (tds[19].firstChild.checked) { rights += 262144; }
		if (tds[20].firstChild.checked) { rights += 524288; }
		if (tds[21].firstChild.checked) { rights += 1048576; }
		if (tds[22].firstChild.checked) { rights += 2097152; }
		if (tds[23].firstChild.checked) { rights += 4194304; }
		if (tds[24].firstChild.checked) { rights += 8388608; }
		myRights[i] = "h"+day+"="+rights;
	}
	TINY.box.hide();
	DBAjax("ajax_box_plannings_store.jsp","id="+id+ "&" + myRights.join("&"));
}
function HoursBox(name,ch,inv) {
	var el = T$("fList")[name];
	if (el) {
		if (el.length != undefined) {
			for (var i=0; i<el.length; i++) {
				if (inv) {el[i].checked = !el[i].checked; }
				else {el[i].checked = ch; }
			}
		} else {
			if (inv) { el.checked = !el.checked; }
			else { el.checked = ch; }
		}
	}
}
function CopyPlan(id,name) {
	TINY.box.show({url:'box_planning_copy.jsp',post:'id='+id+'&name='+name});
}
function CopyPlanValid(id) {
	TINY.box.hide();
	DBAjax("ajax_box_planning_copy.jsp","id="+id+"&name="+T$("copy_name").value);
}
