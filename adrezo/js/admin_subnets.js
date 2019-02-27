//@Author: Yann POSTEC
function EmptySelect(sel) {
	sel.selectedIndex = 0;
	var options = T$$("option",sel);
	while (sel.options.length > 1) {
		sel.removeChild(sel.lastChild);
	}
}
function ResetAdd() {
	T$("add_ip").value = "";
	T$("add_mask").value = "";
	T$("add_def").value = "";
	T$("add_gw").value = "";
	T$("add_bc").value = "";
	T$("add_site").selectedIndex = 0;
	selectvlan = T$("add_vlan");
	EmptySelect(selectvlan);
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[3].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillVlan(node,bModify) {
	var tds = T$$("td",node.parentNode.parentNode);
	var selectsite = tds[2].firstChild;
	var selectvlan = tds[8].firstChild;
	EmptySelect(selectvlan);
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
							var idvlan = tds[8].firstChild.nextSibling.value
							if (opt.value == idvlan) { opt.selected = true; }
						}
						selectvlan.add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillVlan","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_subnets_fillvlan.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("site="+selectsite.value);
	}
}
function verifyInput(selectsite,selectvlan,myip,mask,mygw,mybc,def) {
	var strAlert="";
	
	var ip = renderip(myip);
	var gw = renderip(mygw);
	var bc = renderip(mybc);
	
	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (selectvlan.selectedIndex == 0) { strAlert += "- "+langdata.vlan+": "+langdata.verifchoose+"<br />"; }
	if (ip.length != 12) { strAlert += "- "+langdata.ip+": "+langdata.verifip+"<br />"; }
	else if (!verifip(ip)) { strAlert += "- "+langdata.ip+": "+langdata.verifippart+"<br />"; }
	if (mask == "" || isNaN(mask) || mask > 32 || mask < 2) { strAlert += "- "+langdata.mask+": "+langdata.verifmask+"<br />"; }
	if (gw) {
		if (gw.length != 12) { strAlert += "- "+langdata.ipgw+": "+langdata.verifip+"<br />"; }
		else if (!verifip(gw)) { strAlert += "- "+langdata.ipgw+": "+langdata.verifippart+"<br />"; }
	}
	if (bc.length != 12) { strAlert += "- "+langdata.ipbc+": "+langdata.verifip+"<br />"; }
	else if (!verifip(bc)) { strAlert += "- "+langdata.ipbc+": "+langdata.verifippart+"<br />"; }
	if (!def) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else {
		if (def.indexOf("/") != -1) { strAlert += "- "+langdata.name+": "+langdata.verifnoslash+"<br />"; }
		if (def.length > 40) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 40<br />"; }
	}
	if (mask&&myip) {
		var zeIP = new IPv4_Address(myip,mask);
		if (myip != zeIP.netaddressDotQuad) { strAlert += "- "+langdata.ip+": "+langdata.verifnet+" : "+zeIP.netaddressDotQuad+"<br />"; }
	}
	if (mask&&myip&&mybc) {
		var zeIP = new IPv4_Address(mybc,mask);
		if (myip != zeIP.netaddressDotQuad) { strAlert += "- "+langdata.ipbc+": "+langdata.verifothersubnet+"<br />"; }
	}
	if (mask&&myip&&mygw) {
		var zeIP = new IPv4_Address(mygw,mask);
		if (myip != zeIP.netaddressDotQuad) { strAlert += "- "+langdata.ipgw+": "+langdata.verifothersubnet+"<br />"; }
	}

	return(strAlert);
}
function addSubmit() {
	var selectsite = T$("add_site");
	var site = selectsite.value;
	var id = T$("add_id").value;
	var ip = renderip(T$("add_ip").value);
	var ctx = T$("add_ctx").value;
	var mask = T$("add_mask").value;
	var def = T$("add_def").value;
	var gw = renderip(T$("add_gw").value);
	var bc = renderip(T$("add_bc").value);
	var selectvlan = T$("add_vlan");
	var vlan = selectvlan.value;
	
	var strAlert = verifyInput(selectsite,selectvlan,T$("add_ip").value,mask,T$("add_gw").value,T$("add_bc").value,def);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
			addAjaxSubmit(true,site,id,ip,mask,def,gw,bc,vlan,ctx);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var selectsite = tds[2].firstChild;
	var site = selectsite.value;
	var id = tds[3].firstChild.value;
	var myip = tds[3].firstChild.nextSibling.value;
	var init_ip = tds[3].firstChild.nextSibling.nextSibling.value;
	var ip = renderip(myip);
	var ctx = tds[4].firstChild.value;
	var mask = tds[4].firstChild.nextSibling.value;
	var init_mask = tds[4].firstChild.nextSibling.nextSibling.value;
	var def = tds[5].firstChild.value;
	var mygw = tds[6].firstChild.value;
	var gw = renderip(mygw);
	var mybc = tds[7].firstChild.value;
	var bc = renderip(mybc);
	var selectvlan = tds[8].firstChild;
	var vlan = selectvlan.value;
	
	var strAlert = verifyInput(selectsite,selectvlan,myip,mask,mygw,mybc,def);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		if ( (mask != init_mask) || (myip != init_ip)) {
			showDialog(langdata.confirm,langdata.subnetchange+"<br/><br/><input type='button' value='"+langdata.dlgyes+'\' onclick="javascript:addAjaxSubmit('+site+','+id+',\''+ip+'\','+mask+',\''+def+'\',\''+gw+'\',\''+bc+'\','+vlan+','+ctx+');"/>'+"  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","warning",0,1);
		} else {
			addAjaxSubmit(false,site,id,ip,mask,def,gw,bc,vlan,ctx);
		}
	}
}
function addAjaxSubmit(reload,site,id,ip,mask,def,gw,bc,vlan,ctx) {
	if (reload) {
		DBAjax("ajax_subnets_store.jsp","site="+site+"&id="+id+"&ip="+ip+"&mask="+mask+"&def="+def+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&ctx="+ctx);
	} else {
		DBAjax("ajax_subnets_store.jsp","site="+site+"&id="+id+"&ip="+ip+"&mask="+mask+"&def="+def+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&ctx="+ctx,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_subnets_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var mytd = T$("mytd"+id);
			if (mytd) {
				T$("tableinfos").tBodies[0].removeChild(mytd.parentNode);
				refreshTable(true);
			}
		}
	});
}
function calcBC(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode);
	var myip = tds[3].firstChild.nextSibling.value;
	var mymask = tds[4].firstChild.nextSibling.value;
	var mybc = tds[7].firstChild;
	if (mymask && myip) {
		var zeIP = new IPv4_Address(myip,mymask);
		mybc.value = zeIP.netbcastDotQuad;
	}
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
	FillVlan(tds[2].firstChild,true);
	tds[2].firstChild.style.display = "inline";
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 16;
	ipt.value = texte;
	ipt.addEventListener("keyup",calcBC,false);
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var txt = tds[4].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 2;
	ipt.value = texte;
	ipt.addEventListener("keyup",calcBC,false);
	tds[4].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var txt = tds[5].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 20;
	ipt.value = texte;
	tds[5].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[5].appendChild(hid);
	var txt = tds[6].firstChild;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 16;
	if (txt) {
		var texte = txt.nodeValue
		ipt.value = texte;
		tds[6].replaceChild(ipt,txt);
	} else {
		tds[6].appendChild(ipt);
	}
	var hid = document.createElement("input");
	hid.type = "hidden";
	if (txt) { hid.value = texte; }
	tds[6].appendChild(hid);
	var txt = tds[7].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 16;
	ipt.value = texte;
	tds[7].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[7].appendChild(hid);
	var txt = tds[8].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[8].replaceChild(hid,txt);
	tds[8].firstChild.style.display = "inline";
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
	var hid = tds[8].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[8].replaceChild(txt,hid);
	tds[8].firstChild.value = tds[8].firstChild.nextSibling.value;
	tds[8].firstChild.style.display = "none";
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
	var hid = tds[8].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[8].firstChild.options[tds[8].firstChild.selectedIndex].text);
	tds[8].replaceChild(txt,hid);
	tds[8].firstChild.nextSibling.value = tds[8].firstChild.value;
	tds[8].firstChild.style.display = "none";
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
					if (T$$("id",lines[i])[0].hasChildNodes() && T$$("ip",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(displayip(T$$("ip",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("ctx",lines[i])[0].hasChildNodes() && T$$("mask",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ctx",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("mask",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("def",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("def",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("gw",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(displayip(T$$("gw",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("bc",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(displayip(T$$("bc",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("vlan",lines[i])[0].hasChildNodes() && T$$("vid",lines[i])[0].hasChildNodes() && T$$("vdef",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_vlan").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.style.display="none";
						mytd.appendChild(mysel);						
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("vlan",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("vid",lines[i])[0].firstChild.nodeValue+" : "+T$$("vdef",lines[i])[0].firstChild.nodeValue));
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
			case 3: T$("sqs_order").value="ip";break;
			case 4: T$("sqs_order").value="mask";break;
			case 5: T$("sqs_order").value="def";break;
			case 6: T$("sqs_order").value="gw";break;
			case 7: T$("sqs_order").value="bc";break;
			case 8: T$("sqs_order").value="vid";break;
		}
}
