//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_mask").value = "";
	T$("add_name").value = "";
	T$("add_gw").value = "";
	T$("add_vlan").selectedIndex = 0;
	selectip = T$("add_ip");
	EmptySelect(selectip);
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(selectvlan,selectip,mask,mygw,name,mybc) {
	var strAlert="";
	var gw = renderip(mygw);
	var bc = renderip(mybc);
	
	if (selectip.selectedIndex == 0) { strAlert += "- "+langdata.ip+": "+langdata.verifchoose+"<br />"; }
	if (selectvlan.selectedIndex == 0) { strAlert += "- "+langdata.vlan+": "+langdata.verifchoose+"<br />"; }
	if (mask == "" || isNaN(mask) || mask > 32 || mask < 2) { strAlert += "- "+langdata.mask+": "+langdata.verifmask+"<br />"; }
	if (gw) {
		if (gw.length != 12) { strAlert += "- "+langdata.ipgw+": "+langdata.verifip+"<br />"; }
		else if (!verifip(gw)) { strAlert += "- "+langdata.ipgw+": "+langdata.verifippart+"<br />"; }
		if (selectip.selectedIndex > 0) {
			if (!in_subnet(gw,selectip.value,Number(mask))) { strAlert += "- "+langdata.ipgw+": "+langdata.verifothersubnet+"<br />"; }
		}
	}
	if (bc.length != 12) { strAlert += "- "+langdata.ipbc+": "+langdata.verifip+"<br />"; }
	else if (!verifip(bc)) { strAlert += "- "+langdata.ipbc+": "+langdata.verifippart+"<br />"; }
	if (selectip.selectedIndex > 0&&mask&&mybc) {
		var zeIP = new IPv4_Address(mybc,mask);
		if (selectip.value != renderip(zeIP.netaddressDotQuad)) { strAlert += "- "+langdata.ipbc+": "+langdata.verifothersubnet+"<br />"; }
	}
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else if (name.length > 40) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 40<br />"; }

	return(strAlert);
}
function addSubmit() {
	var mask = T$("add_mask").value;
	var name = T$("add_name").value;
	var mygw = T$("add_gw").value;
	var mybc = T$("add_bc").value;
	var tpl = T$("add_tpl").value;
	var selectip = T$("add_ip");
	var selectvlan = T$("add_vlan");
	var ip = selectip.value;
	var vlan = selectvlan.value;

	var strAlert = verifyInput(selectvlan,selectip,mask,mygw,name,mybc);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		var gw = renderip(mygw);
		var bc = renderip(mybc);
		DBAjax("ajax_subnets_store.jsp","id=&ip="+ip+"&mask="+mask+"&def="+name+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&tpl="+tpl);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var mask = tds[2].firstChild.nextSibling.value;
	var name = tds[3].firstChild.value;
	var selectip = tds[4].firstChild;
	var mygw = tds[5].firstChild.value;
	var selectvlan = tds[6].firstChild;
	var mybc = tds[7].firstChild.value;
	var tpl = T$("add_tpl").value;
	var ip = selectip.value;
	var vlan = selectvlan.value;

	var strAlert = verifyInput(selectvlan,selectip,mask,mygw,name,mybc);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		var gw = renderip(mygw);
		var bc = renderip(mybc);
		DBAjax("ajax_subnets_store.jsp","id="+id+"&ip="+ip+"&mask="+mask+"&def="+name+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&tpl="+tpl,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_subnets_delete.jsp","id="+id,true,function callback(result) {
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
	ipt.size = 3;
	ipt.value = texte;
	ipt.addEventListener("change",fillSubnetList,false);
	ipt.addEventListener("change",calcBC,false);
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var txt = tds[3].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 40;
	ipt.value = texte;
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
	var sel = tds[4].firstChild.cloneNode(true);
	tds[4].appendChild(sel);
	tds[4].firstChild.addEventListener("change",calcBC,false);
	tds[4].firstChild.style.display = "inline";
	var txt = tds[5].firstChild;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 16;
	if (txt) {
		var texte = txt.nodeValue;
		ipt.value = texte;
		tds[5].replaceChild(ipt,txt);
	} else {
		tds[5].appendChild(ipt);
	}
	var hid = document.createElement("input");
	hid.type = "hidden";
	if (txt) { hid.value = texte; }
	tds[5].appendChild(hid);
	var txt = tds[6].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[6].replaceChild(hid,txt);
	tds[6].firstChild.style.display = "inline";	
	var txt = tds[7].firstChild;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 16;
	if (txt) {
		var texte = txt.nodeValue;
		ipt.value = texte;
		tds[7].replaceChild(ipt,txt);
	} else {
		tds[7].appendChild(ipt);
	}
	var hid = document.createElement("input");
	hid.type = "hidden";
	if (txt) { hid.value = texte; }
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
	var hid = tds[4].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].replaceChild(txt,hid);
	var sel = tds[4].firstChild.nextSibling.nextSibling.nextSibling;
	sel.value = tds[4].firstChild.nextSibling.value;
	tds[4].replaceChild(sel,tds[4].firstChild);
	tds[4].firstChild.style.display = "none";
	var ipt = tds[5].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[5].removeChild(hid);
	tds[5].replaceChild(txt,ipt);
	var hid = tds[6].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[6].replaceChild(txt,hid);
	tds[6].firstChild.value = tds[6].firstChild.nextSibling.value;
	tds[6].firstChild.style.display = "none";	
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
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipt = tds[4].firstChild
	var hid1 = tds[4].firstChild.nextSibling
	var hid2 = tds[4].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[4].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	tds[4].removeChild(tds[4].firstChild.nextSibling.nextSibling.nextSibling);
	var ipt = tds[5].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[5].removeChild(hid);
	tds[5].replaceChild(txt,ipt);
	var ipt = tds[6].firstChild
	var hid1 = tds[6].firstChild.nextSibling
	var hid2 = tds[6].firstChild.nextSibling.nextSibling;
	var texte = ipt.options[ipt.selectedIndex].text;
	var txt = document.createTextNode(texte);
	tds[6].replaceChild(txt,hid2);
	hid1.value=ipt.value;
	ipt.style.display = "none";
	var ipt = tds[7].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[7].removeChild(hid);
	tds[7].replaceChild(txt,ipt);
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
					if (T$$("mask",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("mask",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("def",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("def",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("ip",lines[i])[0].hasChildNodes() && T$$("mask",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_ip").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.style.display="none";
						mytd.appendChild(mysel);
						fillIP(mysel,T$$("mask",lines[i])[0].firstChild.nodeValue);
						mysel.value = T$$("ip",lines[i])[0].firstChild.nodeValue;
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ip",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(displayip(T$$("ip",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("gw",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(displayip(T$$("gw",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("vlan",lines[i])[0].hasChildNodes() && T$$("vid",lines[i])[0].hasChildNodes() && T$$("vname",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_vlan").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("vlan",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("vlan",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("vid",lines[i])[0].firstChild.nodeValue+" : "+T$$("vname",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("bc",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(displayip(T$$("bc",lines[i])[0].firstChild.nodeValue)));
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
			case 2: T$("sqs_order").value="mask";break;
			case 3: T$("sqs_order").value="def";break;
			case 4: T$("sqs_order").value="ip";break;
			case 5: T$("sqs_order").value="gw";break;
			case 6: T$("sqs_order").value="vid";break;
			case 7: T$("sqs_order").value="bc";break;
		}
}
function ReturnTemplate() {
	window.location.assign("sites.jsp");
}
function fillIP(sel,mask) {	
	var tplmask = T$("tpl_mask").value;
	if (mask != "" && !isNaN(mask) && mask < 33 && mask > 1 && mask>=tplmask) {
		EmptySelect(sel);
		var lst = SplitSubnet(tplmask,mask);
		for (i=0;i<lst.length;i++) {
			var opt = document.createElement("option");
			opt.value = renderip(lst[i]);
			opt.text = lst[i];
			sel.add(opt);
		}
	}
}
function fillSubnetList(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var mask = tds[2].firstChild.nextSibling.value;
	var sel = tds[4].firstChild
	fillIP(sel,mask);
}
function SplitSubnet(masksub,newmask) {
	var initmask = mask_bits(Number(masksub));
	var splitmask = mask_bits(Number(newmask));
	var a = Number(splitmask.substring(0,3)) - Number(initmask.substring(0,3));
	var b = Number(splitmask.substring(3,6)) - Number(initmask.substring(3,6));
	var c = Number(splitmask.substring(6,9)) - Number(initmask.substring(6,9));
	var d = Number(splitmask.substring(9,12)) - Number(initmask.substring(9,12));
	var na = 256 - Number(splitmask.substring(0,3));
	var nb = 256 - Number(splitmask.substring(3,6));
	var nc = 256 - Number(splitmask.substring(6,9));
	var nd = 256 - Number(splitmask.substring(9,12));
	var res = new Array();
	var idx=0;
	for (i=0;i<a+1;i=i+na) {
		for (j=0;j<b+1;j=j+nb) {
			for (k=0;k<c+1;k=k+nc) {
				for (l=0;l<d+1;l=l+nd) {
					res[idx] = i+"."+j+"."+k+"."+l;
					idx++;
				}
			}
		}
	}
	return res;
}
function calcBC(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode);
	var myip = displayip(tds[4].firstChild.value);
	var mymask = tds[2].firstChild.nextSibling.value;
	var mybc = tds[7].firstChild;
	if (mymask && myip) {
		var zeIP = new IPv4_Address(myip,mymask);
		mybc.value = zeIP.netbcastDotQuad;
	}
}
