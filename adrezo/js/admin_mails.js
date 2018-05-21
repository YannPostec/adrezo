//@Author: Yann POSTEC
function addSubmit(e) {
	var strAlert = "";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[1].firstChild.value;
	var lang = tds[2].firstChild.value;
	var dst = tds[4].firstChild.value;
	var sub = tds[5].firstChild.value;
	var msg = tds[6].firstChild.value;

	if (!dst) { strAlert += "- "+langdata.dest+": "+langdata.verifnotnull+"<br />"; }
	if (!sub) { strAlert += "- "+langdata.subject+": "+langdata.verifnotnull+"<br />"; }
	if (!msg) { strAlert += "- "+langdata.msg+": "+langdata.verifnotnull+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_mails_update.jsp","id="+id+"&lang="+lang+"&dst="+dst+"&sub="+sub+"&msg="+msg);
	}
}
