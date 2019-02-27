//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_name").value = "";
	T$("add_site").selectedIndex = 0;
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[3].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(selectsite,name) {
	var strAlert="";
	
	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (name.length > 6) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 6<br />"; }
		
	return(strAlert);
}
function addSubmit() {
	var selectsite = T$("add_site");
	var name = T$("add_name").value;

	var strAlert=verifyInput(selectsite,name);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_salles_store.jsp","site="+selectsite.value+"&id=&name="+name);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selectsite = tds[2].firstChild;
	var site = selectsite.value;
	var id = tds[3].firstChild.value;
	var name = tds[3].firstChild.nextSibling.value;

	var strAlert=verifyInput(selectsite,name);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_salles_store.jsp","site="+selectsite.value+"&id="+id+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_salles_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var mytd = T$("mytd"+id);
			if (mytd) {
				T$("tableinfos").tBodies[0].removeChild(mytd.parentNode);
				refreshTable(true);
			}
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
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 6;
	ipt.value = texte;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
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
	var ipt = tds[3].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	refreshTable(false);
}
function ApplyModif(id) {
	var node = T$("mytd"+id);
	var tds = T$$("td",node.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var hid = tds[2].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[2].firstChild.options[tds[2].firstChild.selectedIndex].text);
	tds[2].replaceChild(txt,hid);
	tds[2].firstChild.nextSibling.value = tds[2].firstChild.value;
	tds[2].firstChild.style.display = "none";
	var ipt = tds[3].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
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
					if (T$$("idsite",lines[i])[0].hasChildNodes() && T$$("site_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_site").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("idsite",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("idsite",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("site_name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("id",lines[i])[0].hasChildNodes() && T$$("name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(displayip(T$$("name",lines[i])[0].firstChild.nodeValue)));
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
			case 3: T$("sqs_order").value="name";break;
		}
}
