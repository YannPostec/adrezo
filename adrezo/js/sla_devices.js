//@Author: Yann POSTEC
function EmptySite(selectsite) {
	selectsite.selectedIndex = 0;
	var options = T$$("option",selectsite);
	while (selectsite.options.length > 1) {
		selectsite.removeChild(selectsite.lastChild);
	}
}
function SearchUnknown() {
	var cb = T$("cb_unk");
	var tr = T$$("tr",T$("mytable"));
	if (!cb.checked) {
		for (var i=0;i<tr.length;i++) {tr[i].style.display="";}
	} else {
		for (var i=0;i<tr.length;i++) {
			T$$("td",tr[i])[2].firstChild.nextSibling.value == 0?tr[i].style.display="":tr[i].style.display="none";
		}
	}
}
function FillSite(node,bModify) {
	var tds = T$$("td",node.parentNode.parentNode);
	var client = node.value;
	var selectsite = tds[2].firstChild;
	EmptySite(selectsite);
	
	if (node.selectedIndex > 0) {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				response = xhr.responseXML.documentElement;
				if (response) { response = cleanXML(response); }
				var valid = T$$("valid",response)[0].firstChild.nodeValue;
				if (valid == "true") {
					var rows = T$$("option",response);
					for (var i=0;i<rows.length;i++) {
						var opt = document.createElement("option");
						opt.value = T$$("value",rows[i])[0].firstChild.nodeValue;
						opt.text = T$$("texte",rows[i])[0].firstChild.nodeValue;
						if (bModify) {
							var idsite = selectsite.nextSibling.value;
							if (opt.value == idsite) { opt.selected = true; }
						}
						selectsite.add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSite","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_devices_fillsite.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("client="+client);
	}
}
function addSubmit(e) {
	var strAlert = "";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selclient = tds[1].firstChild;
	var selsite = tds[2].firstChild;
	var site = selsite.value;
	var id = tds[3].firstChild.value;
	var selplan = tds[6].firstChild;
	var plan = selplan.value;

	if (selclient.selectedIndex == 0) { strAlert += "- "+langdata.client+": "+langdata.verifchoose+"<br />"; }
	if (selsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (selplan.selectedIndex == 0) { strAlert += "- "+langdata.planning+": "+langdata.verifchoose+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_devices_update.jsp","id="+id+"&site="+site+"&plan="+plan);
	}
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[0].childNodes;
	span[0].style.display="none";
	span[1].style.display="inline";
	span[2].style.display="inline";
	var txt = tds[1].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[1].replaceChild(hid,txt);
	tds[1].firstChild.style.display = "inline";
	FillSite(tds[1].firstChild,true);
	var txt = tds[2].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].replaceChild(hid,txt);
	tds[2].firstChild.style.display = "inline";
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
	var span = tds[0].childNodes;
	var hid = tds[1].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[1].replaceChild(txt,hid);
	if (tds[1].firstChild.nextSibling.value>0) { tds[1].firstChild.value = tds[1].firstChild.nextSibling.value; }
	else { tds[1].firstChild.index = 0; }
	tds[1].firstChild.style.display = "none";
	var hid = tds[2].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].replaceChild(txt,hid);
	tds[2].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[2].firstChild.style.display = "none";
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var hid = tds[6].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[6].replaceChild(txt,hid);
	tds[6].firstChild.value = tds[6].firstChild.nextSibling.value;
	tds[6].firstChild.style.display = "none";
}
