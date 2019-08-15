//@Author: Yann POSTEC
function CheckDisplay() {
	var cbu = T$("cb_unk");
	var cbd = T$("cb_destroy");
	var tr = T$$("tr",T$("mytbody"));
	for (var i=0;i<tr.length;i++) {
		var site = T$$("td",tr[i])[2].firstChild.nextSibling.value;
		var status = T$$("td",tr[i])[5].firstChild.nextSibling.value;
		if ( (cbu.checked && site>0) || (cbd.checked && status==2) ) {
			tr[i].style.display="none";
		}
		else {
			tr[i].style.display=""
		}
	}
}
function FillSite(node,bModify) {
	var tds = T$$("td",node.parentNode.parentNode);
	var client = node.value;
	var selectsite = tds[2].firstChild;
	EmptySelect(selectsite);
	
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
function modSubmit(e) {
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
		DBAjax("ajax_devices_update.jsp","id="+id+"&site="+site+"&plan="+plan,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
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
	refreshTable(false);	
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
	refreshTable(false);	
}
function ApplyModif(id) {
	var node = T$("mytd"+id);
	var tds = T$$("td",node.parentNode);
	var span = tds[0].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[1].firstChild;
	var hid1 = tds[1].firstChild.nextSibling;
	var hid2 = tds[1].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[1].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	var ipt = tds[2].firstChild;
	var hid1 = tds[2].firstChild.nextSibling;
	var hid2 = tds[2].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[2].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	var ipt = tds[6].firstChild;
	var hid1 = tds[6].firstChild.nextSibling;
	var hid2 = tds[6].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte.substring(texte.indexOf("-")+1,texte.length));
	tds[6].replaceChild(txt,hid2);
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
					if (T$$("client",lines[i])[0].hasChildNodes() && T$$("client_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("tpl_client").cloneNode(true);
						mysel.removeAttribute("id");
						if (T$$("client",lines[i])[0].firstChild.nodeValue>0) {
							mysel.value = T$$("client",lines[i])[0].firstChild.nodeValue;
						}
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("client",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("client_name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }		
					if (T$$("site",lines[i])[0].hasChildNodes() && T$$("site_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("tpl_site").cloneNode(true);
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
					if (T$$("name",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("cacti",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						mytd.appendChild(document.createTextNode(T$$("cacti",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("status",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						switch (T$$("status",lines[i])[0].firstChild.nodeValue) {
						 case '0': mytd.appendChild(document.createTextNode(langinactive));break;
						 case '1': mytd.appendChild(document.createTextNode(langactive));break;
						 case '2': mytd.appendChild(document.createTextNode(langdestroyed));break;
						}
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("status",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
					} else { mytr.insertCell(-1); }					
					if (T$$("plan",lines[i])[0].hasChildNodes() && T$$("plan_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("tpl_plan").cloneNode(true);
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
			case 1: T$("sqs_order").value="client_name";break;
			case 2: T$("sqs_order").value="site_name";break;
			case 3: T$("sqs_order").value="name";break;
			case 4: T$("sqs_order").value="cacti";break;
			case 5: T$("sqs_order").value="status";break;
			case 6: T$("sqs_order").value="plan";break;
		}
}
