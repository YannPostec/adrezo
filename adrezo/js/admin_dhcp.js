//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_hostname").value = "";
	T$("add_port").value = "";
	T$("add_login").value = "";
	T$("add_pwd").value = "";
	T$("add_type").selectedIndex = 0;
	T$("add_ssl").selectedIndex = 0;
	T$("add_auth").selectedIndex = 0;
	T$("add_enable").selectedIndex = 0;
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[3].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(selecttype,port,hostname,selectauth,login,pwd) {
	var strAlert="";
	
	if (selecttype.selectedIndex == 0) { strAlert += "- "+langdata.type+": "+langdata.verifchoose+"<br />"; }	
	if (!port || isNaN(port) || port < 0) { strAlert += "- "+langdata.port+": "+langdata.verifnumber+"<br />"; }
	if (!hostname) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else if (hostname.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
	if (selectauth.selectedIndex == 1) {
		if (!login) { strAlert += "- "+langdata.login+": "+langdata.verifnotnull+"<br />"; }
		else if (login.length > 64) { strAlert += "- "+langdata.login+": "+langdata.verifsize+" : 64<br />"; }
		if (pwd && pwd.length > 64) { strAlert += "- "+langdata.pwd+": "+langdata.verifsize+" : 64<br />"; }
	}	

	return(strAlert);
}
function addSubmit() {
	var selecttype = T$("add_type");
	var selectssl = T$("add_ssl");
	var selectauth = T$("add_auth");
	var selectenable = T$("add_enable");
	var type = selecttype.value;
	var ssl = selectssl.value;
	var auth = selectauth.value;
	var hostname = T$("add_hostname").value;
	var port = T$("add_port").value;
	var login = T$("add_login").value;
	var pwd = T$("add_pwd").value;
	var enable = selectenable.value;

	var strAlert = verifyInput(selecttype,port,hostname,selectauth,login,pwd);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_dhcp_store.jsp","id=&hostname="+hostname+"&port="+port+"&login="+login+"&pwd="+pwd+"&type="+type+"&ssl="+ssl+"&auth="+auth+"&enable="+enable);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);	
	var selecttype = tds[2].firstChild;
	var selectssl = tds[5].firstChild;
	var selectauth = tds[6].firstChild;
	var selectenable = tds[9].firstChild;
	var type = selecttype.value;
	var ssl = selectssl.value;
	var auth = selectauth.value;
	var id = tds[3].firstChild.value;
	var hostname = tds[3].firstChild.nextSibling.value;
	var port = tds[4].firstChild.value;
	var login = tds[7].firstChild.value;
	var pwd = tds[8].firstChild.value;
	var enable = selectenable.value;

	var strAlert = verifyInput(selecttype,port,hostname,selectauth,login,pwd);
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_dhcp_store.jsp","id="+id+"&hostname="+hostname+"&port="+port+"&login="+login+"&pwd="+pwd+"&type="+type+"&ssl="+ssl+"&auth="+auth+"&enable="+enable,true,function callback(result) {
			if (result) { ApplyModif(id); }
		});
	}
}
function delSubmit(id) {
	DBAjax("ajax_dhcp_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var mytd = T$("mytd"+id);
			if (mytd) {
				T$("tableinfos").tBodies[0].removeChild(mytd.parentNode);
				refreshTable(true);
			}
		}
	});
}
function defaultTypePort(sel) {
	var tds = T$$("td",sel.parentNode.parentNode);
	if (sel.selectedIndex > 0) {
		tds[4].firstChild.value = typedefaultport[sel.value];
	}
}
function addExclu(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);	
	var id = tds[3].firstChild.value;
	var hostname = tds[3].firstChild.nextSibling.nodeValue;
	TINY.box.show({url:'box_dhcp_addexclu.jsp',openjs:function(){ExcluLoad(id)},post:'id='+id+'&name='+hostname});
}
function listExclu(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);	
	var id = tds[3].firstChild.value;
	var hostname = tds[3].firstChild.nextSibling.nodeValue;	
	TINY.box.show({url:'box_dhcp_listexclu.jsp',openjs:function(){TINY.box.dim()},post:'id='+id+'&name='+hostname});
}
function listValid(id) {
	TINY.box.hide();
	DBAjax("ajax_dhcp_listexclu.jsp","id="+id);
}
function addValid(e) {
	var node=e.target;
	var srv=node.parentNode.firstChild.value;
	var scope=node.parentNode.firstChild.nextSibling.value;
	TINY.box.hide();
	DBAjax("ajax_dhcp_addexclu.jsp","srv="+srv+"&scope="+scope);
}
function ExcluLoad(id) {
	var divwait = T$("addexclu_wait");
	var diverr = T$("addexclu_err");
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) {
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
		}
		if (xhr.readyState==4 && xhr.status==200) {
			while (divwait.childNodes.length > 0) { divwait.removeChild(divwait.lastChild); }
			var response = xhr.responseXML.documentElement;
			if (response) {
				response = cleanXML(response);
				var err = T$$("err",response)[0].firstChild.nodeValue;
				if (err == "false") {
					var m = T$$("scope",response);
					if (m.length) {
						for (var i=0;i<m.length;i++) {
							var scope = m[i].firstChild.nodeValue;
							var mytr = T$("addtable").tBodies[0].insertRow(-1);
							var mytd = mytr.insertCell(-1);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = id;
							mytd.appendChild(ipt);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = scope;
							mytd.appendChild(ipt);
							var img = document.createElement("img");
							img.src = "../img/icon_valid.png";
							img.alt = "Select Scope";
							img.addEventListener("click",addValid,false);
							mytd.appendChild(img);
							var mytd = mytr.insertCell(-1);
							mytd.appendChild(document.createTextNode(scope));
						}
						addsortiny.init();
					} else {
						diverr.innerHTML = langdata.dhcpscopeno;
					}
				} else {
					var erreur = T$$("msg",response)[0].firstChild.nodeValue;
					diverr.innerHTML = langdata.dhcpscopeerror+" : "+erreur;
				}
			} else {
				diverr.innerHTML = langdata.dhcpscopeerror;
			}
			TINY.box.dim();
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	var txt = document.createTextNode(langdata.dhcpscopewait);
	divwait.appendChild(txt);
	divwait.appendChild(document.createElement("br"));
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","../dhcpscope",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("id="+id);
}
function testServer(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);	
	var id = tds[3].firstChild.value;	
	TINY.box.show({url:'box_dhcp_test.jsp',post:'id='+id,openjs:function(){TINY.box.dim()}});
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
	defaultTypePort(tds[2].firstChild);
	tds[2].firstChild.style.display = "inline";
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
	var txt = tds[4].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 5;
	ipt.value = texte;
	tds[4].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].appendChild(hid);
	var txt = tds[5].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[5].replaceChild(hid,txt);
	tds[5].firstChild.style.display = "inline";	
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
	ipt.size = 30;
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
	var txt = tds[8].firstChild;
	var ipt = document.createElement("input");
	ipt.type = "password";
	ipt.size = 30;
	if (txt) {
		var texte = txt.nodeValue;
		tds[8].replaceChild(ipt,txt);
	} else {
		tds[8].appendChild(ipt);
	}
	var hid = document.createElement("input");
	hid.type = "hidden";
	if (txt) { hid.value = texte; }
	tds[8].appendChild(hid);
	var txt = tds[9].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[9].replaceChild(hid,txt);
	tds[9].firstChild.style.display = "inline";	
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
	var ipt = tds[4].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	var hid = tds[5].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[5].replaceChild(txt,hid);
	tds[5].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[5].firstChild.style.display = "none";
	var hid = tds[6].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[6].replaceChild(txt,hid);
	tds[6].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[6].firstChild.style.display = "none";
	var ipt = tds[7].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[7].removeChild(hid);
	tds[7].replaceChild(txt,ipt);
	var ipt = tds[8].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[8].removeChild(hid);
	tds[8].replaceChild(txt,ipt);
	var hid = tds[9].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[9].replaceChild(txt,hid);
	tds[9].firstChild.value = tds[2].firstChild.nextSibling.value;
	tds[9].firstChild.style.display = "none";
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
	var ipt = tds[4].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[4].removeChild(hid);
	tds[4].replaceChild(txt,ipt);
	var hid = tds[5].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[5].firstChild.options[tds[5].firstChild.selectedIndex].text);
	tds[5].replaceChild(txt,hid);
	tds[5].firstChild.nextSibling.value = tds[5].firstChild.value;
	tds[5].firstChild.style.display = "none";
	var hid = tds[6].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[6].firstChild.options[tds[6].firstChild.selectedIndex].text);
	tds[6].replaceChild(txt,hid);
	tds[6].firstChild.nextSibling.value = tds[6].firstChild.value;
	tds[6].firstChild.style.display = "none";
	var ipt = tds[7].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[7].removeChild(hid);
	tds[7].replaceChild(txt,ipt);
	var ipt = tds[8].firstChild;
	var hid = ipt.nextSibling;
	if (hid.value=="" && ipt.value!="") {
		var txt = document.createTextNode("*****");
	} else {
		var txt = document.createTextNode(hid.value);
	}
	tds[8].removeChild(hid);
	tds[8].replaceChild(txt,ipt);
	var hid = tds[9].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(tds[9].firstChild.options[tds[9].firstChild.selectedIndex].text);
	tds[9].replaceChild(txt,hid);
	tds[9].firstChild.nextSibling.value = tds[9].firstChild.value;
	tds[9].firstChild.style.display = "none";	
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
					if (T$$("type",lines[i])[0].hasChildNodes() && T$$("type_name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_type").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("type",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("type",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("type_name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("id",lines[i])[0].hasChildNodes() && T$$("hostname",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("hostname",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("port",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("port",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("ssl",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_ssl").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("ssl",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("ssl",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(mysel.options[mysel.selectedIndex].text));
					} else { mytr.insertCell(-1); }
					if (T$$("auth",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_auth").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("auth",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("auth",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(mysel.options[mysel.selectedIndex].text));
					} else { mytr.insertCell(-1); }
					if (T$$("login",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("login",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("pwd",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						if (T$$("pwd",lines[i])[0].firstChild.nodeValue!="") {
							mytd.appendChild(document.createTextNode("*****"));
						}
					} else { mytr.insertCell(-1); }
					if (T$$("enable",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var mysel = T$("add_enable").cloneNode(true);
						mysel.removeAttribute("id");
						mysel.value = T$$("enable",lines[i])[0].firstChild.nodeValue;
						mysel.style.display="none";
						mytd.appendChild(mysel);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("enable",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(mysel.options[mysel.selectedIndex].text));
					} else { mytr.insertCell(-1); }
					var iconstr = T$("tableicons").firstChild.firstChild;
					var tdexclu = iconstr.firstChild.cloneNode(true);
					var tdtest = iconstr.firstChild.nextSibling.cloneNode(true);
					tdexclu.firstChild.firstChild.addEventListener("click",addExclu,false);
					tdexclu.firstChild.nextSibling.nextSibling.firstChild.addEventListener("click",listExclu,false);
					mytr.appendChild(tdexclu);
					tdtest.firstChild.firstChild.addEventListener("click",testServer,false);
					mytr.appendChild(tdtest);
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
			case 2: T$("sqs_order").value="type_name";break;
			case 3: T$("sqs_order").value="hostname";break;
			case 4: T$("sqs_order").value="port";break;
			case 5: T$("sqs_order").value="ssl";break;
			case 6: T$("sqs_order").value="auth";break;
			case 7: T$("sqs_order").value="login";break;
			case 9: T$("sqs_order").value="enable";break;
		}
}
