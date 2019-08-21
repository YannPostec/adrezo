//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_mask").value = "";
	T$("add_name").value = "";
	T$("add_gw").value = "";
	T$("add_bc").value = "";
	T$("add_vlan").selectedIndex = 0;
	T$("add_surnetlist").value = "";
	var div = T$("add_surnet");
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(selectvlan,mask,mygw,name,mybc,surnet) {
	var strAlert="";
	var gw = renderip(mygw);
	var bc = renderip(mybc);
	
	if (selectvlan.selectedIndex == 0) { strAlert += "- "+langdata.vlan+": "+langdata.verifchoose+"<br />"; }
	if (mask == "" || isNaN(mask) || mask > 32 || mask < 2) { strAlert += "- "+langdata.mask+": "+langdata.verifmask+"<br />"; }
	if (gw) {
		if (gw.length != 12) { strAlert += "- "+langdata.ipgw+": "+langdata.verifip+"<br />"; }
		else if (!verifip(gw)) { strAlert += "- "+langdata.ipgw+": "+langdata.verifippart+"<br />"; }
		if (!in_subnet(gw,"000000000000",Number(mask))) { strAlert += "- "+langdata.ipgw+": "+langdata.verifothersubnet+"<br />"; }
	}
	if (bc.length != 12) { strAlert += "- "+langdata.ipbc+": "+langdata.verifip+"<br />"; }
	else if (!verifip(bc)) { strAlert += "- "+langdata.ipbc+": "+langdata.verifippart+"<br />"; }
	if (mask&&mybc) {
		var zeIP = new IPv4_Address(mybc,mask);
		if (renderip(zeIP.netaddressDotQuad) != "000000000000") { strAlert += "- "+langdata.ipbc+": "+langdata.verifothersubnet+"<br />"; }
	}
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else if (name.length > 40) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 40<br />"; }
	if (!surnet) { strAlert += "- "+langdata.surnet+": "+langdata.verifnotnull+"<br />"; }

	return(strAlert);
}
function addSubmit() {
	var mask = T$("add_mask").value;
	var name = T$("add_name").value;
	var mygw = T$("add_gw").value;
	var mybc = T$("add_bc").value;
	var tpl = T$("add_tpl").value;
	var ip = "000000000000";
	var surnet = T$("add_surnetlist").value;
	var selectvlan = T$("add_vlan");
	var vlan = selectvlan.value;

	var strAlert = verifyInput(selectvlan,mask,mygw,name,mybc,surnet);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		var gw = renderip(mygw);
		var bc = renderip(mybc);
		DBAjax("ajax_subnets_store.jsp","id=&ip="+ip+"&mask="+mask+"&def="+name+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&tpl="+tpl+"&surnet="+surnet);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var mask = tds[2].firstChild.nextSibling.value;
	var name = tds[3].firstChild.value;
	var mygw = tds[5].firstChild.value;
	var selectvlan = tds[6].firstChild;
	var mybc = tds[7].firstChild.value;
	var surnet = tds[8].firstChild.value;
	var tpl = T$("add_tpl").value;
	var ip = "000000000000";
	var vlan = selectvlan.value;

	var strAlert = verifyInput(selectvlan,mask,mygw,name,mybc,surnet);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		var gw = renderip(mygw);
		var bc = renderip(mybc);
		DBAjax("ajax_subnets_store.jsp","id="+id+"&ip="+ip+"&mask="+mask+"&def="+name+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&tpl="+tpl+"&surnet="+surnet,true,function callback(result) {
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
	var ipt = tds[8].firstChild;
	var texte = ipt.value;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[8].appendChild(hid);
	ipt.nextSibling.nextSibling.style.display="inline";
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
	var ipt = tds[8].firstChild;
	var hid = ipt.nextSibling.nextSibling.nextSibling;
	var txt = hid.value;
	tds[8].removeChild(hid);
	ipt.value=txt;
	var div=ipt.nextSibling;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	div.appendChild(document.createTextNode(txt));
	ipt.nextSibling.nextSibling.style.display="none";
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
	var ipt = tds[8].firstChild;
	var hid = ipt.nextSibling.nextSibling.nextSibling;
	tds[8].removeChild(hid);
	ipt.nextSibling.nextSibling.style.display="none";
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
					if (T$$("ip",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(displayip(T$$("ip",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("gw",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mygw = T$$("gw",lines[i])[0].firstChild.nodeValue=="null"?"":displayip(T$$("gw",lines[i])[0].firstChild.nodeValue);
						mytd.appendChild(document.createTextNode(mygw));
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
					if (T$$("surnet",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.id = "slist_" + T$$("id",lines[i])[0].firstChild.nodeValue;
						hid.value = T$$("surnet",lines[i])[0].firstChild.nodeValue
						mytd.appendChild(hid);
						var div = document.createElement("span");
						div.appendChild(document.createTextNode(T$$("surnet",lines[i])[0].firstChild.nodeValue));
						mytd.appendChild(div);
						var span = T$("spanshadow").firstChild.cloneNode(true);
						span.style.display="none";
						mytd.appendChild(span);
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
function calcBC(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode);
	var myip = "0.0.0.0";
	var mymask = tds[2].firstChild.nextSibling.value;
	var mybc = tds[7].firstChild;
	if (mymask && myip) {
		var zeIP = new IPv4_Address(myip,mymask);
		mybc.value = zeIP.netbcastDotQuad;
	}
}
function ChooseSurnet(e) {
	var node=e.target;
	var ipt=node.parentNode.parentNode.firstChild;
	var listid=ipt.id;
	var list=ipt.value;
	TINY.box.show({url:'box_tpl_nonstd_surnetchoose.jsp',post:'list='+list+'&id='+listid});
}
function addLstSub() {
	var selsubd = T$("sel_lst_sub_dispo");
	var selsubc = T$("sel_lst_sub_choisi");
	var res=[];
	var del=[];
	for (var i=0;i<selsubd.options.length;i++) {
		if (selsubd.options[i].selected) {
			var opt = document.createElement("option");
			opt.value = selsubd.options[i].value;
			opt.text = selsubd.options[i].text;
			res.push(opt);
			del.push(selsubd.options[i]);
		}
	}
	for (var i=0;i<res.length;i++) {
		var pos=null;
		for (var j=0;j<selsubc.options.length;j++) {
			if (res[i].text < selsubc.options[j].text) { pos=j; break;}
		}
		selsubc.add(res[i],j);
	}
	for (var i=0;i<del.length;i++) {
		selsubd.removeChild(del[i]);
	}
	TINY.box.dim();
}
function delLstSub() {
	var selsubd = T$("sel_lst_sub_dispo");
	var selsubc = T$("sel_lst_sub_choisi");
	var res=[];
	var del=[];
	for (var i=0;i<selsubc.options.length;i++) {
		if (selsubc.options[i].selected) {
			var opt = document.createElement("option");
			opt.value = selsubc.options[i].value;
			opt.text = selsubc.options[i].text;
			res.push(opt);
			del.push(selsubc.options[i]);
		}
	}
	for (var i=0;i<res.length;i++) {
		var pos=null;
		for (var j=0;j<selsubd.options.length;j++) {
			if (res[i].text < selsubd.options[j].text) { pos=j; break;}
		}
		selsubd.add(res[i],j);
	}
	for (var i=0;i<del.length;i++) {
		selsubc.removeChild(del[i]);
	}
	TINY.box.dim();
}
function lstValid(id) {
	var sellist = T$("sel_lst_sub_choisi");
	var list="";
	for (var i=0;i<sellist.options.length;i++) {
		list+=sellist.options[i].value;
		if (i<sellist.options.length-1) { list+=","; }
	}
	TINY.box.hide();
	var ipt = T$(id);
	ipt.value=list;
	var div = ipt.nextSibling;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	var txt = document.createTextNode(list);
	div.appendChild(txt);
}
function moveUpLst() {
	var sel = T$("sel_lst_sub_choisi");
	for (var i=0;i<sel.options.length;i++) {
		if (sel.options[i].selected) {
			var tmp = sel.options[i];
			sel.removeChild(sel.options[i]);
			var idx = i==0?0:i-1;
			sel.add(tmp,idx);
		}
	}
}
function moveDownLst() {
	var sel = T$("sel_lst_sub_choisi");
	for (var i=sel.options.length-1;i>-1;i--) {
		if (sel.options[i].selected) {
			var tmp = sel.options[i];
			sel.removeChild(sel.options[i]);
			sel.add(tmp,i+1);
		}
	}
}
