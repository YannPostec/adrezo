//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_name").value = "";
	T$("add_site").selectedIndex = 0;
	EmptySelect(T$("add_salle"));
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[4].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillSalle(node,bModify) {
	var tds = T$$("td",node.parentNode.parentNode);
	var selectsite = tds[2].firstChild;
	var selectsalle = tds[3].firstChild;
	EmptySelect(selectsalle);	
	if (selectsite.selectedIndex > 0) {
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
							var idsalle = tds[3].firstChild.nextSibling.value;
							if (opt.value == idsalle) { opt.selected = true; }
						}
						selectsalle.add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSalle","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_photo_fillsalle.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("site="+selectsite.value);
	}
}
function verifyInput(selectsite,selectsalle,name) {
	var strAlert="";
	
	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (selectsalle.selectedIndex == 0) { strAlert += "- "+langdata.room+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (name.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
		
	return(strAlert);
}
function addSubmit() {
	var selectsite = T$("add_site");
	var selectsalle = T$("add_salle");
	var name = T$("add_name").value;
	
	var strAlert=verifyInput(selectsite,selectsalle,name);

	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_boxs_store.jsp","salle="+selectsalle.value+"&id=&name="+name);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selectsite = tds[2].firstChild;
	var selectsalle = tds[3].firstChild;
	var id = tds[4].firstChild.value;
	var name = tds[4].firstChild.nextSibling.value;

	var strAlert=verifyInput(selectsite,selectsalle,name);

	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_boxs_store.jsp","salle="+selectsalle.value+"&id="+id+"&name="+name,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_boxs_delete.jsp","id="+id,true,function callback(result) {
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
	FillSalle(tds[2].firstChild,true);
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
	ipt.size = 50;
	ipt.value = texte;
	tds[4].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
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
	tds[3].firstChild.value = tds[3].firstChild.nextSibling.value;
	tds[3].firstChild.style.display = "none";	
	var ipt = tds[4].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
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
	var hid = tds[3].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[3].firstChild.options[tds[3].firstChild.selectedIndex].text);
	tds[3].replaceChild(txt,hid);
	tds[3].firstChild.nextSibling.value = tds[3].firstChild.value;
	tds[3].firstChild.style.display = "none";
	var ipt = tds[4].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	refreshTable(false);
}
function fillTable(sqlid,limit,offset,search,searchip,order,sqlsort,special) {
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
					if (T$$("idsalle",lines[i])[0].hasChildNodes() && T$$("salle_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_salle").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("idsalle",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("idsalle",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("salle_name",lines[i])[0].firstChild.nodeValue));
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
	xhr.send("id="+sqlid+"&limit="+limit+"&offset="+offset+"&search="+search+"&searchip="+searchip+"&order="+order+"&sort="+sqlsort+"&special="+special);
}
function SwitchSearch(i) {
		switch(i) {
			case 2: T$("sqs_order").value="site_name";break;
			case 3: T$("sqs_order").value="salle_name";break;
			case 4: T$("sqs_order").value="name";break;
		}
}
