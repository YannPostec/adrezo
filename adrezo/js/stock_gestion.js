//@Author: Yann POSTEC
function EmptySelect(mysel) {
	mysel.selectedIndex = 0;
	var options = T$$("option",mysel);
	while (mysel.options.length > 1) {
		mysel.removeChild(mysel.lastChild);
	}
}
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_idx").value = "";
	T$("add_def").value = "";
	T$("add_seuil").value = "";
	T$("add_encours").value = "";
	T$("add_cat").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillCat(s,v) {
	EmptySelect(s);
	for (i=1;i<T$("add_cat").options.length;i++) {
		var opt = document.createElement("option");
		opt.value = T$("add_cat").options[i].value;
		opt.text = T$("add_cat").options[i].text;
		if (opt.value == v) { opt.selected = true; }
		s.add(opt);
	}
}
function addSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[3].firstChild.value;
	var idx = tds[3].firstChild.nextSibling.value;
	var def = tds[4].firstChild.value;
	var seuil = tds[5].firstChild.value;
	var encours = tds[6].firstChild.value;
	var select = tds[2].firstChild;
	var cat = select.value;
	var site = T$("selSite").value;

	if (!encours || encours < 0 || isNaN(encours)) { strAlert += "- "+langdata.ongoing+": "+langdata.verifnumber+"<br />"; }
	if (!seuil || seuil < 0 || isNaN(seuil)) { strAlert += "- "+langdata.threshold+": "+langdata.verifnumber+"<br />"; }
	if (!idx) { strAlert += "- "+langdata.idx+": "+langdata.verifnotnull+"<br />"; }
	if (!def) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (select.selectedIndex == 0) { strAlert += "- "+langdata.cat+": "+langdata.verifchoose+"<br />"; }
	if (idx.length>8) {strAlert += "- "+langdata.idx+": "+langdata.verifsize+" : 8<br />"; }
	if (def.length>255) {strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 255<br />"; }
	if (seuil.length>4) {strAlert += "- "+langdata.threshold+": "+langdata.verifmin+" 10 000<br />"; }
	if (encours.length>4) {strAlert += "- "+langdata.ongoing+": "+langdata.verifmin+" 10 000<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		def=encodeURIComponent(def);
		DBAjax("ajax_gestion_store.jsp","id="+id+"&idx="+idx+"&def="+def+"&seuil="+seuil+"&cat="+cat+"&encours="+encours+"&site="+site);
	}
}
function delSubmit(id) {
	DBAjax("ajax_gestion_delete.jsp","id="+id);
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="none";
	span[1].style.display="inline";
	span[2].style.display="inline";
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 9;
	ipt.value = texte;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 80;
	ipt.value = texte;
	tds[4].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var txt = tds[5].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 6;
	ipt.value = texte;
	tds[5].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[5].appendChild(hid);
	var txt = tds[6].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 6;
	ipt.value = texte;
	tds[6].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[6].appendChild(hid);
	var txt = tds[2].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].replaceChild(hid,txt);
	FillCat(tds[2].firstChild,tds[2].firstChild.nextSibling.value);
	tds[2].firstChild.style.display = "inline";
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
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
	var ipt = tds[5].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[5].removeChild(hid);
	tds[5].replaceChild(txt,ipt);
	var ipt = tds[6].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[6].removeChild(hid);
	tds[6].replaceChild(txt,ipt);
	var hid = tds[2].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].replaceChild(txt,hid);
	tds[2].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[2].firstChild.style.display = "none";
}
function goMainSite(site) {
	T$("selSite").value=site;
	T$("f_gestion").submit();
}
function changeStock() {
	T$("f_gestion").submit();
}
