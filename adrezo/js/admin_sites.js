//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_cod").value = "";
	T$("add_name").value = "";
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(cod,name) {
	var strAlert="";
	
	if (!cod) {	strAlert += "- "+langdata.code+": "+langdata.verifnotnull+"<br />"; }
	else if (cod.length > 8) { strAlert += "- "+langdata.code+": "+langdata.verifsize+" : 8<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	
	return(strAlert);
}
function addSubmit() {
	var cod = T$("add_cod").value;
	var ctx = T$("add_ctx").value;
	var name = T$("add_name").value;
	var tpl = T$("add_tpl").value;

	var strAlert = verifyInput(cod,name);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		if (tpl==0) {
			DBAjax("ajax_sites_store.jsp","id=&ctx="+ctx+"&cod="+cod+"&name="+name);
		} else {
			var mytpl = tpl.substring(0,tpl.indexOf('#'));
			var mask = tpl.substring(tpl.indexOf('#')+1,tpl.length);
			if (mask>0) {
				TINY.box.show({url:'box_tpl_sites_store.jsp',post:'ctx='+ctx+'&cod='+cod+'&name='+name+'&tpl='+mytpl});
			} else {
				TINY.box.show({url:'box_tpl_nonstd_sites_store.jsp',post:'ctx='+ctx+'&cod='+cod+'&name='+name+'&tpl='+mytpl,openjs:function(){NSLoad()}});
			}
		}
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var cod = tds[2].firstChild.nextSibling.value;
	var ctx = tds[3].firstChild.value;
	var name = tds[3].firstChild.nextSibling.value;

	var strAlert = verifyInput(cod,name);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_sites_store.jsp","id="+id+"&ctx="+ctx+"&cod="+cod+"&name="+name,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_sites_delete.jsp","id="+id,true,function callback(result) {
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
	ipt.size = 8;
	ipt.value = texte;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);
	var txt = tds[3].firstChild.nextSibling;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 50;
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
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
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
	var ipt = tds[2].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[2].removeChild(hid);
	tds[2].replaceChild(txt,ipt);
	var ipt = tds[3].firstChild.nextSibling;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
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
					if (T$$("cod_site",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("cod_site",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("name",lines[i])[0].hasChildNodes() && T$$("ctx",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ctx",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("name",lines[i])[0].firstChild.nodeValue));
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
			case 2: T$("sqs_order").value="cod_site";break;
			case 3: T$("sqs_order").value="name";break;
		}
}
function BoxValid() {
	var myip=T$("addtpl_ip").value;
	var ip = renderip(myip);
	var mask=T$("addtpl_mask").value;
	var selparent=T$("addtpl_parent");
	var strAlert = "";
	
	if (ip.length != 12) { strAlert += "- "+langdata.ip+": "+langdata.verifip+"<br />"; }
	else if (!verifip(ip)) { strAlert += "- "+langdata.ip+": "+langdata.verifippart+"<br />"; }
	if (mask&&myip) {
		var zeIP = new IPv4_Address(myip,mask);
		if (myip != zeIP.netaddressDotQuad) { strAlert += "- "+langdata.ip+": "+langdata.verifnet+" : "+zeIP.netaddressDotQuad+"<br />"; }
	}
	if (selparent.selectedIndex == 0) { strAlert += "- "+langdata.surnet+": "+langdata.verifchoose+"<br />"; }
	
	if (strAlert != "") {
		T$("tplsites_err").innerHTML = strAlert;
		TINY.box.dim();
	} else {	
		TINY.box.hide();
		DBAjax("ajax_tpl_sites_store.jsp","ctx="+T$("addtpl_ctx").value+"&cod="+T$("addtpl_cod").value+"&name="+T$("addtpl_name").value+"&tpl="+T$("addtpl_tpl").value+"&surnet="+ip+"&mask="+mask+"&parent="+selparent.value,false,function callback(result) {
			if (result) { SJob(); }
		});
	}
}
function SJob() {
	var xhr=new XMLHttpRequest();
	xhr.open("POST","../firejob",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("name=NormAddSubnetJob");
}
function NSLoad() {
	var divstate = T$("tplsites_state");
	var divwait = T$("tplsites_wait");
	var diverr = T$("tplsites_err");
	var divres = T$("tplsites_res");
	var lang_nothing = T$("addtpl_nothing").value;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) {
			TINY.box.hide();
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
		}
		if (xhr.readyState==4 && xhr.status==200) {
			while (divwait.childNodes.length > 0) { divwait.removeChild(divwait.lastChild); }
			while (diverr.childNodes.length > 0) { diverr.removeChild(diverr.lastChild); }
			var response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
				if (erreur == "true") {
					var error = T$$("msg",response)[0].firstChild.nodeValue;
					diverr.innerHTML = langdata.error+" : "+error;
					divres.innerHTML = lang_nothing;
					T$("addtpl_valid").style.display="inline";
				} else {
					divstate.innerHTML = T$$("msg",response)[0].firstChild.nodeValue + "<br/>";
					NSSearch(T$$("siteid",response)[0].firstChild.nodeValue);
				}
			} else {
				diverr.innerHTML = langdata.xhrerror;
			}
			TINY.box.dim();			
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","ajax_tpl_nonstd_sites_store.jsp",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("ctx="+T$("addtpl_ctx").value+"&cod="+T$("addtpl_cod").value+"&tpl="+T$("addtpl_tpl").value+"&name="+T$("addtpl_name").value);
}
function NSSearch(id) {
	var divstate = T$("tplsites_state");
	var divwait = T$("tplsites_wait");
	var diverr = T$("tplsites_err");
	var divres = T$("tplsites_res");
	var lang_created = T$("addtpl_created").value;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) {
			TINY.box.hide();
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
		}
		if (xhr.readyState==4 && xhr.status==200) {
			while (divwait.childNodes.length > 0) { divwait.removeChild(divwait.lastChild); }
			var response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var erreur = T$$("err",response)[0].firstChild.nodeValue;
			if (erreur == "true") {
				var error = T$$("msg",response)[0].firstChild.nodeValue;
				diverr.innerHTML = langdata.error+" : "+error;
				if (T$$("result",response)[0].hasChildNodes()) {
					divstate.innerHTML += T$$("result",response)[0].firstChild.nodeValue;
				}
				divres.innerHTML = lang_created;
				T$("addtpl_valid").style.display="inline";
			} else {
				divstate.innerHTML += T$$("msg",response)[0].firstChild.nodeValue;
				NSJob();
			}
			TINY.box.dim();			
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","../findnonstdsite",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("id="+id+"&ctx="+T$("addtpl_ctx").value+"&cod="+T$("addtpl_cod").value+"&tpl="+T$("addtpl_tpl").value+"&name="+T$("addtpl_name").value);
}
function NSJob() {
	var divstate = T$("tplsites_state");
	var divwait = T$("tplsites_wait");
	var diverr = T$("tplsites_err");
	var divres = T$("tplsites_res");
	var lang_created = T$("addtpl_allcreated").value;
	var lang_createdbut = T$("addtpl_allcreatedbut").value;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) {
			TINY.box.hide();
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
		}
		if (xhr.readyState==4 && xhr.status==200) {
			while (divwait.childNodes.length > 0) { divwait.removeChild(divwait.lastChild); }
			var response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
				if (erreur == "true") {
					var error = T$$("msg",response)[0].firstChild.nodeValue;
					diverr.innerHTML = langdata.error+" : "+error;
					divres.innerHTML = lang_createdbut;
					T$("addtpl_valid").style.display="inline";
				} else {
					divstate.innerHTML += T$$("msg",response)[0].firstChild.nodeValue + "<br/>";
					divres.innerHTML = lang_created;
					T$("addtpl_valid").style.display="inline";
				}
			} else {
				diverr.innerHTML = langdata.xhrerror;
			}
			TINY.box.dim();
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","../firejob",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("name="+T$("addtpl_job").value);	
}
function NSValid() {
	TINY.box.hide();
	window.location.reload(true);
}
