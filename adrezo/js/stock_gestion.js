//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_idx").value = "";
	T$("add_def").value = "";
	T$("add_seuil").value = "";
	T$("add_encours").value = "";
	T$("add_cat").selectedIndex = 0;
	T$("add_site").selectedIndex = 0;
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[4].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(encours,seuil,idx,def,select,selsite) {
	var strAlert="";
	
	if (!encours || encours < 0 || isNaN(encours)) { strAlert += "- "+langdata.ongoing+": "+langdata.verifnumber+"<br />"; }
	if (!seuil || seuil < 0 || isNaN(seuil)) { strAlert += "- "+langdata.threshold+": "+langdata.verifnumber+"<br />"; }
	if (!idx) { strAlert += "- "+langdata.idx+": "+langdata.verifnotnull+"<br />"; }
	if (!def) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (select.selectedIndex == 0) { strAlert += "- "+langdata.cat+": "+langdata.verifchoose+"<br />"; }
	if (selsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (idx.length>8) {strAlert += "- "+langdata.idx+": "+langdata.verifsize+" : 8<br />"; }
	if (def.length>255) {strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 255<br />"; }
	if (seuil.length>4) {strAlert += "- "+langdata.threshold+": "+langdata.verifmin+" 10 000<br />"; }
	if (encours.length>4) {strAlert += "- "+langdata.ongoing+": "+langdata.verifmin+" 10 000<br />"; }
		
	return(strAlert);
}
function addSubmit() {
	var idx = T$("add_idx").value;
	var def = T$("add_def").value;
	var seuil = T$("add_seuil").value;
	var encours = T$("add_encours").value;
	var select = T$("add_cat");
	var selsite = T$("add_site");
	var cat = select.value;
	var site = selsite.value;

	var strAlert = verifyInput(encours,seuil,idx,def,select,selsite);	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		def=encodeURIComponent(def);
		DBAjax("ajax_gestion_store.jsp","id=&idx="+idx+"&def="+def+"&seuil="+seuil+"&cat="+cat+"&encours="+encours+"&site="+site);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selsite = tds[2].firstChild;
	var site = selsite.value;
	var select = tds[3].firstChild;
	var cat = select.value;
	var id = tds[4].firstChild.value;
	var idx = tds[4].firstChild.nextSibling.value;
	var def = tds[5].firstChild.value;
	var seuil = tds[6].firstChild.value;
	var encours = tds[7].firstChild.value;

	var strAlert = verifyInput(encours,seuil,idx,def,select,selsite);	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		def=encodeURIComponent(def);
		DBAjax("ajax_gestion_store.jsp","id="+id+"&idx="+idx+"&def="+def+"&seuil="+seuil+"&cat="+cat+"&encours="+encours+"&site="+site,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_gestion_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var mytd = T$("mytd"+id);
			if (mytd) { T$("tableinfos").tBodies[0].removeChild(mytd.parentNode); }
			refreshTable(true);
		}
	});
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
	var txt = tds[3].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].replaceChild(hid,txt);
	tds[3].firstChild.style.display = "inline";
	var txt = tds[4].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 9;
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
	ipt.size = 80;
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
	var txt = tds[7].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 6;
	ipt.value = texte;
	tds[7].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[7].appendChild(hid);
	refreshTable(false);	
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var hid = tds[2].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].replaceChild(txt,hid);
	tds[2].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[2].firstChild.style.display = "none";
	var hid = tds[3].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].replaceChild(txt,hid);
	tds[3].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[3].firstChild.style.display = "none";
	var ipt = tds[4].firstChild.nextSibling;
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
	var ipt = tds[7].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[7].removeChild(hid);
	tds[7].replaceChild(txt,ipt);
	refreshTable(false);	
}
function ApplyModif(id) {
	var node = T$("mytd"+id);
	var tds = T$$("td",node.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[2].firstChild
	var hid1 = tds[2].firstChild.nextSibling
	var hid2 = tds[2].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[2].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	var ipt = tds[3].firstChild
	var hid1 = tds[3].firstChild.nextSibling
	var hid2 = tds[3].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[3].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	var ipt = tds[4].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	var ipt = tds[5].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[5].removeChild(hid);
	tds[5].replaceChild(txt,ipt);
	var ipt = tds[6].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[6].removeChild(hid);
	tds[6].replaceChild(txt,ipt);
	var ipt = tds[7].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[7].removeChild(hid);
	tds[7].replaceChild(txt,ipt);
	refreshTable(false);	
}
function fillTable(sqlid,limit,offset,search,searchip,order,sqlsort) {
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { createP(xhr.status+", "+xhr.statusText); }
		if (xhr.readyState==4 && xhr.status==200) {
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var erreur = T$$("err",response)[0].firstChild.nodeValue;
			var msg = T$$("msg",response)[0].firstChild.nodeValue;
			if (erreur == "true") { createP(msg); }
			else {
				var lines = T$$("line",response);
				var cpt=0;
				for (var i=0;i<lines.length;i++) {
					cpt++;
					var shadowtr = T$("tableshadow").firstChild.firstChild;
					var mytr = shadowtr.cloneNode(true);
					T$("tableinfos").tBodies[0].appendChild(mytr);
					if (T$$("site",lines[i])[0].hasChildNodes() && T$$("site_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_site").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("site",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("site",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("site_name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }					
					if (T$$("cat",lines[i])[0].hasChildNodes() && T$$("idcat",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var mysel = T$("add_cat").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("idcat",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("idcat",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("cat",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("idx",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("idx",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("def",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("def",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("seuil",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						mytd.appendChild(document.createTextNode(T$$("seuil",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("encours",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						mytd.appendChild(document.createTextNode(T$$("encours",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
				}
				if (cpt==limit) { createNext(limit); } else { cleanFoot(); }
			}
		}
	};
	cleanFoot();
	var img=document.createElement("img");
	img.id = "waitBar";
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	T$("tablefooter").appendChild(img);
	xhr.open("POST","../sqs",false);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("id="+sqlid+"&limit="+limit+"&offset="+offset+"&search="+search+"&searchip="+searchip+"&order="+order+"&sort="+sqlsort);
}
function SwitchSearch(i) {
		switch(i) {
			case 2: T$("sqs_order").value="site_name";break;
			case 3: T$("sqs_order").value="cat";break;
			case 4: T$("sqs_order").value="idx";break;
			case 5: T$("sqs_order").value="def";break;
			case 6: T$("sqs_order").value="seuil";break;
			case 7: T$("sqs_order").value="encours";break;
		}
}
