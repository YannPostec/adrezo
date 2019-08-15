//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_name").value = "";
	T$("add_disp").checked = true;
	T$("add_plan").selectedIndex = 0;
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/>"+langdata.sladefault+"<br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(name,selplan) {
	var strAlert="";
	
	if (selplan.selectedIndex == 0) { strAlert += "- "+langdata.planning+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
		
	return(strAlert);
}
function addSubmit() {
	var name = T$("add_name").value;
	var disp = T$("add_disp").checked?1:0;
	var selplan = T$("add_plan");
	var plan = selplan.value;
	
	var strAlert = verifyInput(name,selplan);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_clients_store.jsp","id=&name="+name+"&disp="+disp+"&plan="+plan);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var name = tds[2].firstChild.nextSibling.value;
	var disp = tds[3].firstChild.checked?1:0;
	var selplan = tds[4].firstChild;
	var plan = selplan.value;

	var strAlert = verifyInput(name,selplan);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_clients_store.jsp","id="+id+"&name="+name+"&disp="+disp+"&plan="+plan,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_clients_delete.jsp","id="+id,true,function callback(result) {
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
	var txt = tds[2].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.value = texte;
	ipt.size = 40;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var txt = tds[3].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "checkbox";
	if (texte == langdata.dlgyes) { ipt.checked = true; } else { ipt.checked = false; }
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].replaceChild(hid,txt);
	tds[4].firstChild.style.display = "inline";
	refreshTable(false);
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var hid = tds[4].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].replaceChild(txt,hid);
	tds[4].firstChild.value = tds[4].firstChild.nextSibling.value;
	tds[4].firstChild.style.display = "none";
	refreshTable(false);
}
function ApplyModif(id) {
	var node = T$("mytd"+id);
	var tds = T$$("td",node.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.checked?langdata.dlgyes:langdata.dlgno);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipt = tds[4].firstChild
	var hid1 = tds[4].firstChild.nextSibling
	var hid2 = tds[4].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte.substring(texte.indexOf("-")+1,texte.length));
	tds[4].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
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
					if (T$$("name",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("disp",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var texte = "";
						if (T$$("disp",lines[i])[0].firstChild.nodeValue==0) { texte = langdata.dlgno; } else { texte = langdata.dlgyes; }
						mytd.appendChild(document.createTextNode(texte));
					} else { mytr.insertCell(-1); }
					if (T$$("plan",lines[i])[0].hasChildNodes() && T$$("plan_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_plan").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("plan",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("plan",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						var texte = mysel.value>0?T$$("plan_name",lines[i])[0].firstChild.nodeValue:langanytime;
						mytd.appendChild(document.createTextNode(texte));
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
			case 2: T$("sqs_order").value="name";break;
			case 3: T$("sqs_order").value="disp";break;
			case 4: T$("sqs_order").value="plan";break;
		}
}
