//@Author: Yann POSTEC
function ResetAdd() {
	var ip = T$("add_ip");
	while (ip.childNodes.length>0) {ip.removeChild(ip.firstChild);}
	T$("add_ipid").value = "";
	T$("add_pid").value = "";
	T$("add_ptype").selectedIndex = 0;
	T$("add_span").style.display="inline";
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[3].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(sel_ptype,pid,ipid) {
	var strAlert="";
	
	if (sel_ptype.selectedIndex == 0) { strAlert += "- "+langdata.proto+": "+langdata.verifchoose+"<br />"; }
	if (!pid) { strAlert += "- ID: "+langdata.verifnotnull+"<br />"; }
	if (pid < 0 || isNaN(pid)) { strAlert += "- ID: "+langdata.verifnumber+"<br />"; }
	if (!ipid) { strAlert += "- "+langdata.ip+": "+langdata.verifchoose+"<br />"; }
		
	return(strAlert);
}
function addSubmit() {
	var sel_ptype = T$("add_ptype");
	var ptype = sel_ptype.value;
	var pid = T$("add_pid").value;
	var ipid = T$("add_ipid").value;

	var strAlert=verifyInput(sel_ptype,pid,ipid);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_redundancy_store.jsp","id=&pid="+pid+"&ipid="+ipid+"&ptype="+ptype);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var sel_ptype = tds[2].firstChild;
	var ptype = sel_ptype.value;
	var id = tds[3].firstChild.value;
	var pid = tds[3].firstChild.nextSibling.value;
	var ipid = tds[4].firstChild.value;

	var strAlert=verifyInput(sel_ptype,pid,ipid);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_redundancy_store.jsp","id="+id+"&pid="+pid+"&ipid="+ipid+"&ptype="+ptype,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_redundancy_delete.jsp","id="+id,true,function callback(result) {
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
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = txt.nodeValue;
	tds[2].replaceChild(hid,txt);
	tds[2].firstChild.style.display = "inline";
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 5;
	ipt.value = texte;
	tds[3].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].appendChild(hid);
	var ipid = tds[4].firstChild.value;
	var div = tds[4].firstChild.nextSibling;
	var texte = div.firstChild.nodeValue;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	div.nextSibling.style.display="inline";
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = ipid;
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
	var ipt = tds[3].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipid = tds[4].firstChild;
	var div = tds[4].firstChild.nextSibling;
	var span = div.nextSibling;
	var hidt = span.nextSibling;
	var hidi = hidt.nextSibling;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	span.style.display="none";
	div.appendChild(document.createTextNode(hidt.value));
	tds[4].removeChild(hidt);
	ipid.value=hidi.value;
	tds[4].removeChild(hidi);
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
	var ipid = tds[4].firstChild;
	var div = tds[4].firstChild.nextSibling;
	var span = div.nextSibling;
	var hidt = span.nextSibling;
	var hidi = hidt.nextSibling;
	if (hidi.value == ipid.value) {
		while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
		div.appendChild(document.createTextNode(hidt.value));
	}
	span.style.display="none";
	tds[4].removeChild(hidt);
	tds[4].removeChild(hidi);
	refreshTable(false);
}
function ChooseIP(e) {
	var node=e.target;
	var elt=node.parentNode.parentNode.firstChild.id;
	TINY.box.show({url:'box_redundancy_ipchoose.jsp',post:'id='+elt});
}
function BoxIP_Search(key,elt) {
	var ctx = T$("myCtx").value;
	var t = T$("boxip_table").tBodies[0];
	while (t.childNodes.length>0) {t.removeChild(t.firstChild);}
	if (key == "ip") { var value = renderip(T$("boxip_ip").value); }
	else if (key == "name") { var value = T$("boxip_name").value; }
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
		if (xhr.readyState==4 && xhr.status==200) {
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
					var rows = T$$("adr",response);
					for (var i=0;i<rows.length;i++) {
						var myid = T$$("id",rows[i])[0].firstChild.nodeValue;
						var myname = T$$("name",rows[i])[0].firstChild.nodeValue;
						var myip = displayip(T$$("ip",rows[i])[0].firstChild.nodeValue);
						var mymask = T$$("mask",rows[i])[0].firstChild.nodeValue;
						var mysubnet = T$$("subnet",rows[i])[0].firstChild.nodeValue;
						var mysite = T$$("site",rows[i])[0].firstChild.nodeValue;
						var mytr = t.insertRow(-1);
						var mytd = mytr.insertCell(-1);
						var ipt = document.createElement("input");
						ipt.type = "hidden";
						ipt.value = myid;
						mytd.appendChild(ipt);
						var ipt = document.createElement("input");
						ipt.type = "hidden";
						ipt.value = elt;
						mytd.appendChild(ipt);
						var img = document.createElement("img");
						img.src = "../img/icon_valid.png";
						img.alt = "Select this IP";
						img.addEventListener("click",BoxIP_SelectIP,false);
						mytd.appendChild(img);
						mytr.insertCell(-1).appendChild(document.createTextNode(myname));
						mytr.insertCell(-1).appendChild(document.createTextNode(myip+'/'+mymask));
						mytr.insertCell(-1).appendChild(document.createTextNode(mysubnet));
						mytr.insertCell(-1).appendChild(document.createTextNode(mysite));
						TINY.box.resize();
						TINY.box.dim();
					}
			} else {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+" BoxIP_Search","error",0,1);
			}
		}
	};
	xhr.open("POST","ajax_box_redundancy_search.jsp",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("ctx="+ctx+"&key="+key+"&value="+value);
}
function BoxIP_SelectIP(e) {
	var node=e.target;
	var tds=T$$("td",node.parentNode.parentNode);
	var id=tds[0].firstChild.value;
	var elt=tds[0].firstChild.nextSibling.value;
	var name=tds[1].firstChild.nodeValue;
	var ipm=tds[2].firstChild.nodeValue;
	var subnet=tds[3].firstChild.nodeValue;
	var site=tds[4].firstChild.nodeValue;
	TINY.box.hide();
	var ipt=T$(elt);
	ipt.value=id;
	var div = ipt.nextSibling;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	var txt = document.createTextNode(ipm+' ('+name+') ['+site+'/'+subnet+']');
	div.appendChild(txt);
	div.nextSibling.style.display = "none";
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
					var myid="BADID";
					if (T$$("id",lines[i])[0].hasChildNodes()) { myid = T$$("id",lines[i])[0].firstChild.nodeValue; }
					if (T$$("ptype",lines[i])[0].hasChildNodes() && T$$("ptype_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_ptype").cloneNode(true);
						mysel.value = T$$("ptype",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ptype",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("ptype_name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("id",lines[i])[0].hasChildNodes() && T$$("pid",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(displayip(T$$("pid",lines[i])[0].firstChild.nodeValue)));
					} else { mytr.insertCell(-1); }
					if (T$$("ipid",lines[i])[0].hasChildNodes() && T$$("ip",lines[i])[0].hasChildNodes() && T$$("mask",lines[i])[0].hasChildNodes() && T$$("ip_name",lines[i])[0].hasChildNodes() && T$$("site_name",lines[i])[0].hasChildNodes() && T$$("subnet_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ipid",lines[i])[0].firstChild.nodeValue;
						hid.id = "ipid_" + myid;
						mytd.appendChild(hid);
						var div = document.createElement("div");
						div.appendChild(document.createTextNode(displayip(T$$("ip",lines[i])[0].firstChild.nodeValue)+"/"+T$$("mask",lines[i])[0].firstChild.nodeValue+" ("+T$$("ip_name",lines[i])[0].firstChild.nodeValue+") ["+T$$("site_name",lines[i])[0].firstChild.nodeValue+"/"+T$$("subnet_name",lines[i])[0].firstChild.nodeValue+"]"));
						mytd.appendChild(div);
						var myspan = T$("spanshadow").cloneNode(true);
						myspan.removeAttribute("id");
						var img = document.createElement("img");
						img.src = "../img/icon_database.png";
						img.alt = "Click to select IP";
						img.addEventListener("click",ChooseIP,false);
						myspan.appendChild(img);
						mytd.appendChild(myspan);
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
			case 2: T$("sqs_order").value="ptype_name";break;
			case 3: T$("sqs_order").value="pid";break;
		}
}
