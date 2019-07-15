//@Author: Yann POSTEC
var strSearch = new Array();
var openParenthesis = false;
var closeParenthesis = false;
var eltInsert = false;
var nbOpenParenthesis = 0;
var nbCloseParenthesis = 0;
var ipdata;
var xhrdata=new XMLHttpRequest();
xhrdata.onreadystatechange=function(){
	if (xhrdata.readyState==4 && xhrdata.status==200) { ipdata = JSON.parse(xhrdata.responseText); }
};
xhrdata.open("POST","ajax_ipdata.jsp",false);
xhrdata.setRequestHeader('Content-type','application/x-www-form-urlencoded');
xhrdata.send();
function BodyLoad(validUser) {
	selectField("SITE");
	if (validUser) { ConstructRow("","","","","","","","","","",""); }
	ConstructListTable(1,40,"","","");
}
function validateElt(elt) {
	var res = false;
	switch (elt) {
		case '(' :
			if (eltInsert || closeParenthesis) { res = false; }
			else {
				nbOpenParenthesis++;
				openParenthesis = true;
				closeParenthesis = false;
				eltInsert = false;
				res = true;
			}
			break;
		case ')' :
			if ((nbCloseParenthesis < nbOpenParenthesis )&& (eltInsert || closeParenthesis)) {
				closeParenthesis = true;
				openParenthesis = false;
				eltInsert = false;
				nbCloseParenthesis++;
				res = true;
			} else { res = false; }
			break;
		case 'AND' :
			if (eltInsert || closeParenthesis) {
				openParenthesis = false;
				closeParenthesis = false;
				eltInsert = false;
				res = true;
			}
			else { res = false; }
			break;
		case 'OR' :
			if (eltInsert || closeParenthesis) {
				openParenthesis = false;
				closeParenthesis = false;
				eltInsert = false;
				res = true;
			}
			else { res = false; }
			break;
		default :
			if (closeParenthesis || eltInsert) { res = false; }
			else {
				eltInsert = true;
				openParenthesis = false;
				closeParenthesis = false;
				res = true;
			}
			break;
	}
	return res;
}
function populate() {
	T$('mytext').value = strSearch.join(" ");
}
function clearAll() {
	while (strSearch.length != 0) {
		strSearch.pop();
	}
	eltInsert = false;
	openParenthesis = false;
	closeParenthesis = false;
	nbOpenParenthesis = 0;
	nbCloseParenthesis = 0;
	populate();
}
function clearElt() {
	if (strSearch.length != 0) {
		suppElt = strSearch.pop();
		switch (suppElt) {
			case '(' : nbOpenParenthesis--;break;
			case ')' : nbCloseParenthesis--;break;
		}
		if (strSearch.length != 0) {
			elt = strSearch[strSearch.length-1];
			switch (elt) {
				case '(' :
					openParenthesis = true;
					closeParenthesis = false;
					eltInsert = false;
					break;
				case ')' :
					closeParenthesis = true;
					openParenthesis = false;
					eltInsert = false;
					break;
				case 'AND' :
					openParenthesis = false;
					closeParenthesis = false;
					eltInsert = false;
					break;
				case 'OR' :
					openParenthesis = false;
					closeParenthesis = false;
					eltInsert = false;
					break;
				default :
					openParenthesis = false;
					closeParenthesis = false;
					eltInsert = true;
					break;
			}
		} else {
			eltInsert = false;
			openParenthesis = false;
			closeParenthesis = false;
		}
		populate();
	}	
}
function addElt(elt) {
	if (validateElt(elt)) {
		strSearch.push(elt);
		populate();
	}
}
function validateSearch() {
	var strAlert = "";
	if (strSearch.length != 0) {
		if (nbOpenParenthesis != nbCloseParenthesis) { strAlert += "- "+langdata.ipspar+" :<br/>   "+langdata.ipsparo+" : " + nbOpenParenthesis + "<br/>   "+langdata.ipsparf+" : " + nbCloseParenthesis + "<br/>"; }
		if (!eltInsert && !closeParenthesis) { strAlert += " - "+langdata.ipsinvalid; }
	}
	
	if (strAlert != "") {
		showDialog(langdata.ipserr+" :",strAlert,"warning",0,1);
	}
	else {
		Change();
	}
}
function selectField(val) {
	var x = T$("searchDiv");
	var y = T$("btnAjouterSearchDiv");
	if (T$('myOp')) { x.removeChild(T$('myOp')); }
	if (T$('myValue')) { x.removeChild(T$('myValue')); }
	switch (val) {
		case 'SITE' :
			sel = document.createElement("select");
			sel.id = "myOp";
			opt = document.createElement("option");
			opt.value = "8";
			opt.text = langdata.equal;
			opt.selected = true;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "9";
			opt.text = langdata.different;
			sel.add(opt);
			x.insertBefore(sel,y);
			var myvalue = document.createElement("select");
			myvalue.id = "myValue";
			for (var i in ipdata.sites) {
					var opt = document.createElement("option");
					opt.text = ipdata.sites[i].name;
					opt.value = ipdata.sites[i].id;
					myvalue.add(opt);
			}
			x.insertBefore(myvalue,y);
			break;
		case 'SUBNET' :
			var sel = document.createElement("select");
			sel.id = "myOp";
			var opt = document.createElement("option");
			opt.value = "8";
			opt.text = langdata.equal;
			opt.selected = true;
			sel.add(opt);
			var opt = document.createElement("option");
			opt.value = "9";
			opt.text = langdata.different;
			sel.add(opt);
			x.insertBefore(sel,y);
			var sel = document.createElement("select");
			sel.id = "myValue";
			for (var i in ipdata.subnets) {
				var opt = document.createElement("option");
				opt.value = ipdata.subnets[i].id;
				opt.text = ipdata.subnets[i].def;
				sel.add(opt);
			}
			x.insertBefore(sel,y);
			break;
		case 'TYPE' :
			sel = document.createElement("select");
			sel.id = "myOp";
			opt = document.createElement("option");
			opt.value = "10";
			opt.text = langdata.equal;
			opt.selected = true;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "11";
			opt.text = langdata.different;
			sel.add(opt);
			x.insertBefore(sel,y);
			var sel = document.createElement("select");
			sel.id = "myValue";
			for (var i in ipdata.types) {
				var opt = document.createElement("option");
				opt.value = ipdata.types[i].name;
				opt.text = ipdata.types[i].name;
				sel.add(opt);
			}
			x.insertBefore(sel,y);
			break;
		case 'IP' :
			sel = document.createElement("select");
			sel.id = "myOp";
			opt = document.createElement("option");
			opt.value = "0";
			opt.text = langdata.contain;
			opt.selected = true;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "1";
			opt.text = langdata.begin;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "2";
			opt.text = langdata.end;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "4";
			opt.text = langdata.nocontain;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "5";
			opt.text = langdata.nobegin;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "6";
			opt.text = langdata.noend;
			sel.add(opt);
			x.insertBefore(sel,y);
			txt = document.createElement("input");
			txt.type = "text";
			txt.size = "20";
			txt.id = "myValue";
			txt.value = "";
			x.insertBefore(txt,y);
			break;
		case 'MASK' :
			sel = document.createElement("select");
			sel.id = "myOp";
			opt = document.createElement("option");
			opt.value = "8";
			opt.text = langdata.equal;
			opt.selected = true;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "9";
			opt.text = langdata.different;
			sel.add(opt);
			x.insertBefore(sel,y);
			txt = document.createElement("input");
			txt.type = "text";
			txt.size = "20";
			txt.id = "myValue";
			txt.value = "";
			x.insertBefore(txt,y);
			break;
		default :
			sel = document.createElement("select");
			sel.id = "myOp";
			opt = document.createElement("option");
			opt.value = "0";
			opt.text = langdata.contain;
			opt.selected = true;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "1";
			opt.text = langdata.begin;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "2";
			opt.text = langdata.end;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "3";
			opt.text = langdata.isnull;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "4";
			opt.text = langdata.nocontain;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "5";
			opt.text = langdata.nobegin;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "6";
			opt.text = langdata.noend;
			sel.add(opt);
			opt = document.createElement("option");
			opt.value = "7";
			opt.text = langdata.isnotnull;
			sel.add(opt);
			x.insertBefore(sel,y);
			txt = document.createElement("input");
			txt.type = "text";
			txt.size = "20";
			txt.id = "myValue";
			txt.value = "";
			x.insertBefore(txt,y);
	}	
}
function insRow() {
	var txt=T$('myField').value;
	var val=T$('myValue').value;
	val = replaceAll(val,"'","''");
	if (txt == "IP") { val = renderip(val); }
	if (txt == "NAME" || txt == "DEF" || txt == "MAC") { txt = "lower(" + txt + ")"; }
	switch(T$('myOp').value) {
		case '0': txt += " LIKE lower('%" + val + "%')";break;
		case '1': txt += " LIKE lower('" + val + "%')";break;
		case '2': txt += " LIKE lower('%" + val + "')";break;
		case '3': txt += " IS NULL";break;
		case '4': txt += " NOT LIKE lower('%" + val + "%')";break;
		case '5': txt += " LIKE lower('" + val + "%')";break;
		case '6': txt += " LIKE lower('%" + val + "')";break;
		case '7': txt += " IS NOT NULL";break;
		case '8': txt += " = " + val;break;
		case '9': txt += " != " +val;break;
		case '10': txt += " = '" + val + "'";break;
		case '11': txt += " != '" + val + "'";break;
	}
	addElt(txt);
	T$('myField').selectedIndex = 0;
	selectField("SITE");
}
function ChangeCheckboxParity(el) {
	if (el) {
		if (el.length != undefined) {
			for (var i=0; i<el.length; i++) { el[i].checked = !el[i].checked; }
		} else { el.checked = !el.checked; }
	}
}
function AllDel() {
	ChangeCheckboxParity(T$("fList").effac);
}
function AllModify() {
	ChangeCheckboxParity(T$("fList").modify);
}
function AllMig() {
	ChangeCheckboxParity(T$("fList").migra);
}
function ConfirmDlg(f) {
	showDialog(langdata.confirm,langdata.ipconfirm+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:"+f+"();'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function IPAjax(url,listIP) {
	var ctx = T$("myCTX").value;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) {
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
		}
		if (xhr.readyState==4 && xhr.status==200) {
			var response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
				var typedlg = "success";
				var headdlg = langdata.xhrvalid;
				var txtdlg = T$$("msg",response)[0].firstChild.nodeValue + "<br/><br/><input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog();validateSearch();'/>";
				if (erreur == "true") {
					typedlg = "error";
					headdlg = langdata.xhrerror;
				}
				showDialog(headdlg,txtdlg,typedlg,0,0);
			} else {
				hideDialog();
				window.location.reload(true);
			}
		}
	};
	showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
	xhr.open("POST",url,true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("listIP="+listIP+"&ctx="+ctx);
}
function delRecords() {
	var myid = new Array();
	var x = T$("fList");
	var idx = 0;
	var size = x.effac.length?x.effac.length:1;
	for (var i=0; i<size; i++) {
		var box;
		if (size == 1) { box = x.effac; }
		else { box = x.effac[i]; }
		if (box.checked) {
			myid[idx] = box.value;
			idx++;
		}
	}
	if (idx != 0) { IPAjax("ajax_ipdel.jsp",myid.join(",")); }
}
function migRecords() {
	var myid = new Array();
	var x=T$("fList");
	var idx = 0;
	var size = x.migra.length?x.migra.length:1;
	for (var i=0; i<size; i++) {
		var box;
		if (size == 1) { box = x.migra; }
		else { box=x.migra[i]; }
		if (box.checked) {
			myid[idx] = box.value;
			idx++;
		}
	}
	if (idx != 0) { IPAjax("ajax_ipmig.jsp",myid.join(",")); }
}
function modRecords() {
	var regexp_date = /\d{1,2}\/\d{1,2}\/\d{4}/;
	var x=T$("fList");
	var idx = 0;
	var size = x.modify.length?x.modify.length:1;
	for (var i=0;i<size;i++) {
		var box = (size == 1)?x.modify:x.modify[i];
		if (box.checked) { idx ++; }
	}
	if (idx != 0) {
		DelAllRows();
		idx = 1;
		if (T$("addAccordeon").style.height != "auto") { ipaccordion.pr(0,1); }
		for (var c=0;c<size;c++) {
			var box = (size == 1)?x.modify:x.modify[c];
			if (box.checked) {
				var mytr = box.parentNode.parentNode;
				var mytds = T$$("td",mytr);
				var name = mytds[5].firstChild?mytds[5].firstChild.nodeValue:"";
				var def = mytds[6].firstChild?mytds[6].firstChild.nodeValue:"";
				var mac = mytds[9].firstChild?mytds[9].firstChild.nodeValue:"";
				var myip = mytds[7].firstChild.firstChild?mytds[7].firstChild.firstChild.nodeValue:"";
				var ip = myip.substring(0,myip.indexOf("/"));
				var mytemp = mytds[11].firstChild.nodeValue;
				var temp = (mytemp == langdata.dlgno)?"0":"1";
				var tempd = (mytemp == langdata.dlgno)?"":mytemp.substring(mytemp.length-10,mytemp.length);
				var mymig = mytds[12].firstChild.nodeValue;
				var mig = (mymig == langdata.dlgno)?"0":"1";
				var migd = (mymig == langdata.dlgno)?"":mymig.substr(mymig.search(regexp_date),10);
				var migip = (mymig == langdata.dlgno)?"":mymig.substring(mymig.search(regexp_date)+11,mymig.indexOf("/",mymig.search(regexp_date)+11));
				ConstructRow(box.value,idx,name,def,ip,mac,temp,tempd,mig,migd,migip);
				idx++;
			}
		}
	}
}
function SuggestIP(e) {
	var node = e.target;
	var myip = node.value;
	var myid = node.id;
	var cpt = node.parentNode.parentNode.cells[0].firstChild.nodeValue;
	var mymask;
	var mysub;
	var mysite;
	var bMig = false;
	var bFound = false;
	if (myid.indexOf("IPMig") != -1) {
		bMig = true;
		mymask = T$("MaskMig" + cpt);
		mysub = T$("SubnetMig" + cpt);
		mysite = T$("SiteMig" + cpt);
	} else {
		mymask = T$("Mask" + cpt);
		mysub =  T$("Subnet" + cpt);
		mysite =  T$("Site" + cpt);
	}
	var ip = renderip(myip);
	if (verifip(ip)) {
		for (var i in ipdata.subnets) {
			if (in_subnet(ip,ipdata.subnets[i].ip,Number(ipdata.subnets[i].mask))) {
				mymask.value = ipdata.subnets[i].mask;
				mysub.value = ipdata.subnets[i].id;
				if (mysite != null) { mysite.value = ipdata.subnets[i].site; }
				bFound = true;
				break;
			}
		}
	}
	if (bFound && bMig) {
		var xhrsuggest=new XMLHttpRequest();
		xhrsuggest.onreadystatechange=function(){ if (xhrsuggest.readyState==4 && xhrsuggest.status==200) {
			T$("InfosMig"+cpt).innerHTML = '<span class="hotspot" onmouseover="javascript:tooltip.show(' + "'" + xhrsuggest.responseText + "'" + ')" onmouseout="javascript:tooltip.hide()"><img src="../img/icon_help.png" alt="InfosIP" /></span>';
		} };
		xhrsuggest.open("POST","ajax_suggestip.jsp",true);
		xhrsuggest.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhrsuggest.send("subnet="+T$("SubnetMig" + cpt).value+"&ip="+ip);
	}
}
function ConstructRow(ipid,cpt,ipname,ipdef,ip,ipmac,iptmp,ipdtmp,ipmig,ipdmig,ipmip) {
	var r = T$("addTable").tBodies[0].rows;
	if (cpt == "") {
		cpt = 1;
		for (var i=0;i<r.length;i++) { cpt=Math.max(cpt,r[i].cells[0].firstChild.nodeValue) + 1; }
	}
	var mytr = T$("addTable").tBodies[0].insertRow(-1);
	var mytd = mytr.insertCell(-1);
	var txt = document.createTextNode(cpt);
	mytd.align = "center";
	mytd.appendChild(txt);
	var mytd = mytr.insertCell(-1);
	var btn = document.createElement("input");
	btn.type = "button";
	btn.id = "btnDel" + cpt;
	btn.value = langdata.delete;
	btn.addEventListener("click",DelRow,false);
	mytd.appendChild(btn);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "hidden";
	ipt.id = "ipid" + cpt;
	ipt.value = ipid;
	mytd.appendChild(ipt);
	var iptsite = document.createElement("select");
	var opt = document.createElement("option");
	opt.text = langdata.none;
	iptsite.add(opt);
	for (var i in ipdata.sites) {
		var optsite = document.createElement("option");
		optsite.text = ipdata.sites[i].name;
		optsite.value = ipdata.sites[i].id;
		iptsite.add(optsite);
	}
	iptsite.disabled = true;
	iptsite.id = "Site" + cpt;
	mytd.appendChild(iptsite);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 15;
	ipt.id = "Name" + cpt;
	ipt.value = ipname;
	mytd.appendChild(ipt);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 35;
	ipt.id = "Def" + cpt;
	ipt.value = ipdef;
	mytd.appendChild(ipt);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 13;
	ipt.id = "IP" + cpt;
	ipt.value = ip;
	ipt.addEventListener("change",SuggestIP,false);
	var myip = ipt;
	mytd.appendChild(ipt);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 2;
	ipt.id = "Mask" + cpt;
	ipt.value = "";
	ipt.disabled = true;
	mytd.appendChild(ipt);
	var mytd = mytr.insertCell(-1);
	var iptsel = document.createElement("select");
	iptsel.disabled = true;
	iptsel.id = "Subnet" + cpt;
	var opt = document.createElement("option");
	opt.text = langdata.choosesub;
	iptsel.add(opt);
	for (var i in ipdata.subnets) {
		var optsite = document.createElement("option");
		optsite.value = ipdata.subnets[i].id;
		optsite.text = ipdata.subnets[i].def;
		iptsel.add(optsite);
	}
	mytd.appendChild(iptsel);
	var mytd = mytr.insertCell(-1);
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = 12;
	ipt.id = "Mac" + cpt;
	ipt.value = ipmac;
	mytd.appendChild(ipt);
	var mytd = mytr.insertCell(-1);
	mytd.align = "center";
	var ipt = document.createElement("input");
	ipt.type = "checkbox";
	ipt.id = "Temp" + cpt;
	ipt.value = "OUI";
	ipt.addEventListener("click",GenColTemp,false);
	mytd.appendChild(ipt);
	if (T$("addTable").tHead.rows[0].cells[mytd.cellIndex+1].firstChild.nodeValue == langdata.until) { mytr.insertCell(-1); }
	var mytmpbox = ipt;
	var mytd = mytr.insertCell(-1);
	mytd.align = "center";
	var ipt = document.createElement("input");
	ipt.type = "checkbox";
	ipt.id = "Mig" + cpt;
	ipt.value = "OUI";
	ipt.addEventListener("click",GenColMig,false);
	mytd.appendChild(ipt);
	var mymigbox = ipt;
	if (iptmp == "1") {
		var evt = document.createEvent("MouseEvents");
		evt.initEvent ("click",true,false);
		mytmpbox.dispatchEvent(evt);
		T$("DateTemp" + cpt).value = ipdtmp;
	}
	if (ipmig == "1") {
		var evt = document.createEvent("MouseEvents");
		evt.initEvent ("click",true,false);
		mymigbox.dispatchEvent(evt);
		T$("DateMig" + cpt).value = ipdmig;
		T$("IPMig" + cpt).value = ipmip;
		var evt = document.createEvent("HTMLEvents");
		evt.initEvent("change",true,false);
		T$("IPMig" + cpt).dispatchEvent(evt);
	}
	if (ip != "") {
		var evt = document.createEvent("HTMLEvents");
		evt.initEvent ("change",true,false);
		myip.dispatchEvent(evt);
	}
}
function DelRow(e) {
	var node = e.target;
	var mytr = node.parentNode.parentNode.sectionRowIndex;
	var mybody = T$("addTable").tBodies[0];
	var mytmpbox = T$("Temp"+node.parentNode.parentNode.cells[0].firstChild.nodeValue);
	if (mytmpbox.checked) {
		var evt = document.createEvent("MouseEvents");
		evt.initEvent ("click",true,false);
		mytmpbox.dispatchEvent(evt);
	}
	var mymigbox = T$("Mig"+node.parentNode.parentNode.cells[0].firstChild.nodeValue);
	if (mymigbox.checked) {
		var evt = document.createEvent("MouseEvents");
		evt.initEvent ("click",true,false);
		mymigbox.dispatchEvent(evt);
	}
	mybody.deleteRow(mytr);
}
function DelAllRows() {
	var t = T$("addTable").tBodies[0];
	var h = T$("addTable").tHead.rows[0];
	while (t.childNodes.length>0) {t.removeChild(t.firstChild);}
	if (h.lastChild.firstChild.nodeValue != langdata.mig) {
		h.removeChild(h.lastChild);
		h.removeChild(h.lastChild);
	}
	if (h.lastChild.previousSibling.firstChild.nodeValue != langdata.temp) {
		h.removeChild(h.lastChild.previousSibling);
	}
}
function GenColTemp(e) {
	var node = e.target;
	var mytd = node.parentNode;
	var t = T$("addTable");
	var cpt = mytd.parentNode.cells[0].firstChild.nodeValue;
	if (node.checked) {
		if (t.tHead.rows[0].cells[mytd.cellIndex+1].firstChild.nodeValue != langdata.until) {
			var newth = document.createElement("th");
			var thtxt = document.createTextNode(langdata.until);
			newth.appendChild(thtxt);
			t.tHead.rows[0].insertBefore(newth,t.tHead.rows[0].cells[mytd.cellIndex+1]);
			for (var i=0;i<t.tBodies[0].rows.length;i++) { t.tBodies[0].rows[i].insertCell(mytd.cellIndex+1); }
		}
		var newtd = document.createElement("td");
		var iptd = document.createElement("input");
		iptd.type = "text";
		iptd.id = "DateTemp" + cpt;
		iptd.size = 12;
		iptd.maxLength = 10;
		iptd.value = "";
		var img = document.createElement("img");
		img.className = "picker";
		img.src = "../img/calendar.gif";
		img.alt = "OpenCalendar";
		img.width = "13";
		img.height = "12";
		img.addEventListener("click",calCreate,false);
		var div = document.createElement("div");
		div.id = "calTemp" + cpt;
		newtd.appendChild(iptd);
		newtd.appendChild(img);
		newtd.appendChild(div);
		mytd.parentNode.replaceChild(newtd,mytd.parentNode.cells[mytd.cellIndex+1]);
	} else {
		var r = t.tBodies[0].rows;
		var bLast = true;
		var blanktd = document.createElement("td");
		mytd.parentNode.replaceChild(blanktd,mytd.parentNode.cells[mytd.cellIndex+1]);
		for (var i=0;i<r.length;i++) { if (t.tBodies[0].rows[i].cells[mytd.cellIndex].firstChild.checked) { bLast = false; } }
		if (bLast) {
			t.tHead.rows[0].deleteCell(mytd.cellIndex+1);
			for (var i=0;i<t.tBodies[0].rows.length;i++) { t.tBodies[0].rows[i].deleteCell(mytd.cellIndex+1); }
		}
	}
}
function GenColMig(e) {
	var node = e.target;
	var mytd = node.parentNode;
	var t=T$("addTable");
	var cpt = mytd.parentNode.cells[0].firstChild.nodeValue;
	if (node.checked) {
		if (!t.tHead.rows[0].cells[mytd.cellIndex+1] || t.tHead.rows[0].cells[mytd.cellIndex+1].firstChild.nodeValue != langdata.the) {
			var newthd = document.createElement("th");
			var thdtxt = document.createTextNode(langdata.the);
			var newthi = document.createElement("th");
			var thitxt = document.createTextNode(langdata.ipfutur);
			newthd.appendChild(thdtxt);
			newthi.appendChild(thitxt);
			t.tHead.rows[0].appendChild(newthd);
			t.tHead.rows[0].appendChild(newthi);
		}
		var newtdd = mytd.parentNode.insertCell(-1);
		var idd = document.createElement("input");
		idd.type = "text";
		idd.id = "DateMig" + cpt;
		idd.size = 12;
		idd.maxLength = 10;
		idd.value = "";
		var img = document.createElement("img");
		img.className = "picker";
		img.src = "../img/calendar.gif";
		img.alt = "OpenCalendar";
		img.width = "13";
		img.height = "12";
		img.addEventListener("click",calCreate,false);
		var div = document.createElement("div");
		div.id = "calMig" + cpt;
		newtdd.appendChild(idd);
		newtdd.appendChild(img);
		newtdd.appendChild(div);
		var newtdi = mytd.parentNode.insertCell(-1);
		var iim = document.createElement("input");
		iim.type = "hidden";
		iim.id = "MaskMig" + cpt;
		iim.value = "";
		var iis = document.createElement("input");
		iis.type = "hidden";
		iis.id = "SubnetMig" + cpt;
		iis.value = "";
		var iisi = document.createElement("input");
		iisi.type = "hidden";
		iisi.id = "SiteMig" + cpt;
		iisi.value = "";
		var iii = document.createElement("input");
		iii.type = "text";
		iii.size = 17
		iii.id = "IPMig" + cpt;
		iii.value = "";
		iii.addEventListener("change",SuggestIP,false);
		var iid = document.createElement("span");
		iid.id = "InfosMig" + cpt;
		newtdi.appendChild(iim);
		newtdi.appendChild(iis);
		newtdi.appendChild(iisi);
		newtdi.appendChild(iii);
		newtdi.appendChild(iid);
	} else {
		var r = t.tBodies[0].rows;
		var bLast = true;
		for (var i=0;i<r.length;i++) { if (t.tBodies[0].rows[i].cells[mytd.cellIndex].firstChild.checked) { bLast = false; } }
		if (bLast) {
			t.tHead.rows[0].deleteCell(mytd.cellIndex+1);
			t.tHead.rows[0].deleteCell(mytd.cellIndex+1);
		}
		mytd.parentNode.deleteCell(mytd.cellIndex+1);
		mytd.parentNode.deleteCell(mytd.cellIndex+1);
	}
}
function validateChange() {
	var strAlert="";
	var date_re = /^\d{1,2}\/\d{1,2}\/\d{4}$/;
	var r = T$("addTable").tBodies[0].rows;
	var l = r.length;
	if (l!=0) {
		for (var i=0;i<l;i++) {
			var cpt = r[i].cells[0].firstChild.nodeValue;
			if (T$("Site" + cpt).selectedIndex == 0) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.site+": "+langdata.verifchoose+"<br/>"; }
			if (T$("Subnet" + cpt).selectedIndex == 0) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.subnet+": "+langdata.verifchoose+"<br/>"; }
			if (T$("Name" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.name+": "+langdata.verifnotnull+"<br/>"; }
			var ip = renderip(T$("IP" + cpt).value.trim());
			if (ip.length != 12) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.ip+": "+langdata.verifip+"<br/>"; }
			else if (!verifip(ip)) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.ip+": "+langdata.verifippart+"<br/>"; }
			var mask = T$("Mask" + cpt).value;
			if (mask == "" || mask > 32 || mask < 2) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.mask+": "+langdata.verifmask+"<br/>"; }
			if (T$("Temp" + cpt).checked) {
				if (T$("DateTemp" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.date+" "+langdata.temp+": "+langdata.verifrequired+"<br/>"; }
				else if (!T$("DateTemp" + cpt).value.match(date_re)) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.date+" "+langdata.temp+": "+langdata.dateformat+"<br/>"; }
			}
			if (T$("Mig" + cpt).checked) {
				if (T$("DateMig" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.date+" "+langdata.mig+": "+langdata.verifrequired+"<br/>"; }
				else if (!T$("DateMig" + cpt).value.match(date_re)) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.date+" "+langdata.mig+": "+langdata.dateformat+"<br/>"; }
				var ipmig = renderip(T$("IPMig" + cpt).value.trim());
				if (ipmig.length != 12 ) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.ipfutur+": "+langdata.verifip+"<br/>"; }
				else if (!verifip(ipmig)) { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.ipfutur+": "+langdata.verifippart+"<br/>"; }
				if (T$("SiteMig" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.site+" "+langdata.mig+": "+langdata.verifchoose+"<br/>"; }
				if (T$("SubnetMig" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.subnet+" "+langdata.mig+": "+langdata.verifchoose+"<br/>"; }
				if (T$("MaskMig" + cpt).value == "") { strAlert += "- "+langdata.line+" "+cpt+": "+langdata.mask+" "+langdata.mig+": "+langdata.verifchoose+"<br/>"; }
			}
		}
		if (strAlert != "") {
			showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
		} else {
			var mycpt = new Array();
			var aelt = new Array();
			for (var i=0;i<l;i++) {
				var cpt = r[i].cells[0].firstChild.nodeValue;
				var ipid = "ipid" + cpt + "=" + T$("ipid" + cpt).value;
				var site = "&Site" + cpt + "=" + T$("Site" + cpt).value;
				var name = "&Name" + cpt + "=" + T$("Name" + cpt).value.trim();
				var def = "&Def" + cpt + "=" + T$("Def" + cpt).value.trim();
				var ip = "&IP" + cpt + "=" + renderip(T$("IP" + cpt).value.trim());
				var mask = "&Mask" + cpt + "=" + T$("Mask" + cpt).value;
				var subnet = "&Subnet" + cpt + "=" + T$("Subnet" + cpt).value;
				var mac = "&Mac" + cpt + "=" + T$("Mac" + cpt).value.trim();
				var temp = "&Temp" + cpt + "=0";
				var datetemp = "";
				if (T$("Temp" + cpt).checked) {
					datetemp = "&DateTemp" + cpt + "=" + T$("DateTemp" + cpt).value;
					temp = "&Temp" + cpt + "=OUI";
				}
				var mig = "&Mig" + cpt + "=0";
				var ipmig = "";
				var datemig = "";
				var maskmig = "";
				var subnetmig = "";
				var sitemig = "";
				if (T$("Mig" + cpt).checked) {
					ipmig = "&IPMig" + cpt + "=" + renderip(T$("IPMig" + cpt).value.trim());
					datemig = "&DateMig" + cpt + "=" + T$("DateMig" + cpt).value;
					maskmig = "&MaskMig" + cpt + "=" + T$("MaskMig" + cpt).value;
					subnetmig = "&SubnetMig" + cpt + "=" + T$("SubnetMig" + cpt).value;
					sitemig = "&SiteMig" + cpt + "=" + T$("SiteMig" + cpt).value;
					mig = "&Mig" + cpt+ "=OUI";
				}
				mycpt[i] = cpt;
				aelt[i] = ipid+site+name+def+ip+mask+subnet+mac+temp+datetemp+mig+ipmig+datemig+maskmig+subnetmig+sitemig;
			}
			var myelt = "ctx="+T$("myCTX").value+"&listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhraddvalid=new XMLHttpRequest();
			xhraddvalid.onreadystatechange=function(){
				if (xhraddvalid.readyState==4 && xhraddvalid.status!=200) {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhraddvalid.status+"<br/>"+xhraddvalid.statusText,"error",0,1);
				}
				if (xhraddvalid.readyState==4 && xhraddvalid.status==200) {
					var response = xhraddvalid.responseXML.documentElement;
					if (response) { response = cleanXML(response); }
					var valid = T$$("valid",response)[0].firstChild.nodeValue;
					if (valid == "true") {
						var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
						var typedlg = "success";
						var headdlg = langdata.xhrvalid;
						var txtdlg = "";
						if (erreur == "true") {
							typedlg = "error";
							headdlg = langdata.xhrerror;
						}
						var arrErr = new Array();
						var arrOk = new Array();
						var j = 0;
						var k = 0;
						var m = T$$("msg",response);
						for (var i=0;i<m.length;i++) {
							var action = T$$("action",m[i])[0].firstChild.nodeValue;
							var type = T$$("type",m[i])[0].firstChild.nodeValue;
							var cpt = T$$("cpt",m[i])[0].firstChild.nodeValue;
							txtdlg += action + " ligne " + cpt + " : " + type;
							if (type == "Erreur") {
								txtdlg += ", " + T$$("texte",m[i])[0].firstChild.nodeValue;
								arrErr[j] = cpt;
								j++;
							} else {
								arrOk[k] = cpt;
								k++;
							}
							txtdlg += "<br/>";
						}
						if (erreur == "true") {
							var lstErr = arrErr.join(",");
							var lstOk = arrOk.join(",");
							txtdlg += "<input type='checkbox' id='chkdlg' checked> "+langdata.ipremoveok+"<br/><input type='button' value='"+langdata.closedlg+"' onclick='javascript:CleanRows(\""+lstErr+"\",\""+lstOk+"\");'/>";
						} else {
							txtdlg += "<input type='button' value='"+langdata.closedlg+"' onclick='javascript:AfterValidChangeOK()'/>";
						}
						showDialog(headdlg,txtdlg,typedlg,0,0);
					} else {
						hideDialog();
						window.location.reload(true);
					}
				}
			};
			showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
			xhraddvalid.open("POST","ajax_ipstore.jsp",true);
			xhraddvalid.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhraddvalid.send(myelt);
		}
	}
}
function AfterValidChangeOK() {
	DelAllRows();
	ConstructRow("","","","","","","","","","","");
	ipaccordion.pr(0,1);
	if (T$("listAccordeon").style.height != "auto") { listaccordion.pr(0,0); }
	validateSearch();
}
function CleanRows(lstErr,lstOk) {
	var arrErr = lstErr? lstErr.split(",") : null;
	var arrOk = lstOk? lstOk.split(",") : null;
	if (arrOk!=null) {
		if (T$("chkdlg").checked) {
			for (var i=0;i<arrOk.length;i++) {
				var evt = document.createEvent("MouseEvents");
				evt.initEvent ("click",true,false);
				T$("btnDel" + arrOk[i]).dispatchEvent(evt);
			}
		}
	}
	hideDialog();
}
function SendIPDispo(e) {
	var node = e.target;
	var mysend = node.value;
	var bMig = false;
	if (mysend.substring(0,3)=="MIG") { bMig=true; mysend=mysend.substring(3,mysend.length); }
	var ip = node.parentNode.parentNode.firstChild.firstChild.nodeValue;
	var r = T$("addTable").tBodies[0].rows;
	var bFound = false;
	for (var i=0;i<r.length;i++) {
		if (!bFound) {
			var cpt = r[i].cells[0].firstChild.nodeValue;
			if (cpt == mysend) {
				if (bMig) {
					T$("IPMig" + cpt).value = ip;
					var evt = document.createEvent("HTMLEvents");
					evt.initEvent ("change",true,false);
					T$("IPMig" + cpt).dispatchEvent(evt);
				} else {
					T$("IP" + cpt).value = ip;
					var evt = document.createEvent("HTMLEvents");
					evt.initEvent ("change",true,false);
					T$("IP" + cpt).dispatchEvent(evt);
				}
				bFound = true;
			}
		}
	}
	if (T$("addAccordeon").style.height != "auto") { ipaccordion.pr(0,1); }
}
function DeleteIPDispoTable(e) {
	var t=T$("ipdispotable");
	while (t.childNodes.length>0) {t.removeChild(t.firstChild);}
}
function CreateIPDispoRows(e) {
	var t = T$("ipdispotable").tBodies[0].rows;
	var r = T$("addTable").tBodies[0].rows;
	var cpt = 1;
	for (var i=0;i<r.length;i++) { cpt=Math.max(cpt,r[i].cells[0].firstChild.nodeValue) + 1; }
	for (var j=0;j<t.length;j++) {
		ConstructRow("","","","",t[j].cells[0].firstChild.nodeValue,"","","","","","");
		cpt++;
	}
	DeleteIPDispoTable();
	if (T$("addAccordeon").style.height != "auto") { ipaccordion.pr(0,1); }
	setTimeout("ipaccordion.pr(0,0)", 1000);
}
function ReplaceIPDispoRows(e) {
	DelAllRows(e);
	CreateIPDispoRows(e);
}
function IPDispo() {
	var nbip = T$("disponb").value;
	var idsub = T$("disposub").value;
	var start = T$("dispostart").value;
	var strAlert = "";
	var t = T$("ipdispotable");
	var r = T$("addTable").tBodies[0].rows;
	if (T$("disposub").selectedIndex == 0) { strAlert += "- "+langdata.subnet+": "+langdata.verifchoose+"<br/>"; }
	if (nbip == "" || isNaN(nbip) || nbip < 1) { strAlert+="- "+langdata.ipdmoreone+"<br/>"; }
	if (start != "") {
		if (!verifip(renderip(start))) { strAlert+="- "+langdata.ipinvalid+"<br/>"; }
	}
	if (strAlert != "") { showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1); }
	else {
		DeleteIPDispoTable();
		T$("ipdispoempty").style.display="none";
		var xhrdispolist=new XMLHttpRequest();
		xhrdispolist.onreadystatechange=function(){
			if (xhrdispolist.readyState==4 && xhrdispolist.status!=200) {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhrdispolist.status+"<br/>"+xhrdispolist.statusText,"error",0,1);
			}
			if (xhrdispolist.readyState==4 && xhrdispolist.status==200) {	
				var response = xhrdispolist.responseXML.documentElement;
				if (response) { response = cleanXML(response); }
				var valid = T$$("valid",response)[0].firstChild.nodeValue;
				if (valid == "true") {
					var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
					if (erreur == "true") {
						typedlg = "error";
						txtdlg = T$$("msg",response)[0].firstChild.nodeValue + "<br/><br/><input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog()'/>";
						headdlg = langdata.xhrerror;
						showDialog(headdlg,txtdlg,typedlg,0,0);
					} else {
						if (T$$("listeip",response)[0].firstChild) {
							var res = new Array();
							res = T$$("listeip",response)[0].firstChild.nodeValue.split(",");
							t.appendChild(document.createElement("thead"));
							t.appendChild(document.createElement("tbody"));
							t.appendChild(document.createElement("tfoot"));
							var trh = t.tHead.insertRow(-1);
							var th = document.createElement("th");
							var txt = document.createTextNode(langdata.ip);
							th.appendChild(txt);
							trh.appendChild(th);
							var th = document.createElement("th");
							var txt = document.createTextNode(langdata.send);
							th.appendChild(txt);
							trh.appendChild(th);
							for(var i=0;i<res.length;i++) {
								var tr = t.tBodies[0].insertRow(-1);
								var td = tr.insertCell(-1);
								td.align = "center";
								var txt = document.createTextNode(res[i]);
								td.appendChild(txt);
								var td = tr.insertCell(-1);
								var sel = document.createElement("select");
								var opt = document.createElement("option");
								opt.text = langdata.sendto;
								sel.add(opt);
								for (var j=0;j<T$("addTable").tBodies[0].rows.length;j++) {
									var opt = document.createElement("option");
									var cpt = T$("addTable").tBodies[0].rows[j].cells[0].firstChild.nodeValue;
									if (T$("Mig"+cpt).checked) {
										var optmig = document.createElement("option");
										optmig.text = langdata.mig+" "+langdata.line+" "+cpt;
										optmig.value = "MIG"+cpt;
										sel.add(optmig);
									}
									opt.text = langdata.line+" " + cpt;
									opt.value = cpt;
									sel.add(opt);
								}
								sel.addEventListener("change",SendIPDispo,false);
								td.appendChild(sel);
							}
							var tr = t.tFoot.insertRow(-1);
							var td = tr.insertCell(-1);
							var span = document.createElement("span");
							var img = document.createElement("img");
							img.src="../img/icon_replace.png";
							img.alt=langdata.ipdreplace;
							span.addEventListener("mouseover",function(){tooltip.show(langdata.ipdreplace);},false);
							span.addEventListener("mouseout",function(){tooltip.hide();},false);
							img.addEventListener("click",ReplaceIPDispoRows,false);
							span.appendChild(img);
							td.appendChild(span);
							var td = tr.insertCell(-1);
							var span = document.createElement("span");
							var img = document.createElement("img");
							img.src="../img/icon_add.png";
							img.alt=langdata.ipdadd;
							span.addEventListener("mouseover",function(){tooltip.show(langdata.ipdadd);},false);
							span.addEventListener("mouseout",function(){tooltip.hide();},false);
							img.addEventListener("click",CreateIPDispoRows,false);
							span.appendChild(img);
							td.appendChild(span);
							var td = tr.insertCell(-1);
							var span = document.createElement("span");
							var img = document.createElement("img");
							img.src="../img/icon_delete.jpg";
							img.alt=langdata.ipdclear;
							span.addEventListener("mouseover",function(){tooltip.show(langdata.ipdclear);},false);
							span.addEventListener("mouseout",function(){tooltip.hide();},false);
							img.addEventListener("click",DeleteIPDispoTable,false);
							span.appendChild(img);
							td.appendChild(span);
						} else { T$("ipdispoempty").style.display="inline"; }
					}
				} else {
					hideDialog();
					window.location.reload(true);
				}
			}
		};
		xhrdispolist.open("POST","ajax_ipdispo.jsp",true);
		xhrdispolist.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhrdispolist.send("ip="+nbip+"&sub="+idsub+"&start="+renderip(start));
	}
}
function ViewTemp(e) {
	var node = e.target;
	var userlogin = node.previousSibling.value;
	T$('mytext').value="TEMP=1 AND USR_TEMP='"+userlogin+"'";
	validateSearch();
}
function ViewMig(e) {
	var node = e.target;
	var userlogin = node.previousSibling.value;
	T$('mytext').value="MIG=1 AND USR_MIG='"+userlogin+"'";
	validateSearch();
}
function ViewTooltipTemp(e) {
	var node = e.target;
	var txt = node.previousSibling.previousSibling.value;
	tooltip.show(txt);
}
function ViewTooltipMig(e) {
	var node = e.target;
	var txt = node.previousSibling.previousSibling.value;
	tooltip.show(txt);
}
function HideTooltip(e) {
	tooltip.hide();
}
function ConstructListTable(page,limit,sortKey,sortOrder,search) {
	var ctx = T$("myCTX").value;
	var body = T$("listTable").tBodies[0];
	var xhriplist=new XMLHttpRequest();
	xhriplist.onreadystatechange=function(){
		if (xhriplist.readyState==4 && xhriplist.status!=200) {
			showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhriplist.status+"<br/>"+xhriplist.statusText,"error",0,1);
		}
		if (xhriplist.readyState==4 && xhriplist.status==200) {
			hideDialog();
			while(body.childNodes.length>0) { body.removeChild(body.firstChild); }
			var response = xhriplist.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var txt = document.createTextNode(T$$("nbpage",response)[0].firstChild.nodeValue);
				T$("nbPage").replaceChild(txt,T$("nbPage").firstChild);
				var tdinfo = T$("tdInfosUser");
				while (tdinfo.childNodes.length>0) { tdinfo.removeChild(tdinfo.firstChild); }
				var usertemp = T$$("usertemp",response)[0];
				if (T$$("exist",usertemp)[0].firstChild.nodeValue == "1") {
					var userlogin = T$$("userlogin",usertemp)[0].firstChild.nodeValue
					var span = document.createElement("span");
					span.className = "hotspot";
					var txtspan = langdata.iptemp+" :<ul>"
					var lines = T$$("line",usertemp);
					for (var i=0;i<lines.length;i++) {
						txtspan += "<li>"+lines[i].firstChild.nodeValue+"</li>"
					}
					txtspan += "</ul>"
	 				var ipt = document.createElement("input");
	 				ipt.type = "hidden";
	 				ipt.value = txtspan;
	 				span.appendChild(ipt);
	 				var ipt = document.createElement("input");
	 				ipt.type = "hidden";
	 				ipt.value = userlogin;
	 				span.appendChild(ipt);
	 				var ipt = document.createElement("input");
	 				ipt.type = "button";
	 				ipt.value = langdata.ip+" "+langdata.temp;
					ipt.addEventListener("click",ViewTemp,false);
					ipt.addEventListener("mouseout",HideTooltip,false);
					ipt.addEventListener("mouseover",ViewTooltipTemp,false);
	 				span.appendChild(ipt);
	 				tdinfo.appendChild(span);
				}
				var usermig = T$$("usermig",response)[0];
				if (T$$("exist",usermig)[0].firstChild.nodeValue == "1") {
					var userlogin = T$$("userlogin",usermig)[0].firstChild.nodeValue
					var span = document.createElement("span");
					span.className = "hotspot";
					var txtspan = langdata.ipmig+" :<ul>"
					var lines = T$$("line",usermig);
					for (var i=0;i<lines.length;i++) {
						txtspan += "<li>"+lines[i].firstChild.nodeValue+"</li>"
					}
					txtspan += "</ul>"
	 				var ipt = document.createElement("input");
	 				ipt.type = "hidden";
	 				ipt.value = txtspan;
	 				span.appendChild(ipt);
	 				var ipt = document.createElement("input");
	 				ipt.type = "hidden";
	 				ipt.value = userlogin;
	 				span.appendChild(ipt);
	 				var ipt = document.createElement("input");
	 				ipt.type = "button";
	 				ipt.value = langdata.ip+" "+langdata.mig;
					ipt.addEventListener("click",ViewMig,false);
					ipt.addEventListener("mouseout",HideTooltip,false);
					ipt.addEventListener("mouseover",ViewTooltipMig,false);
	 				span.appendChild(ipt);
	 				tdinfo.appendChild(span);
				}
				var pages = T$$("pages",response)[0];
				var first = T$$("first",pages)[0].firstChild.nodeValue;
				var last = T$$("last",pages)[0].firstChild.nodeValue;
				var previous = T$$("previous",pages)[0].firstChild.nodeValue;
				var next = T$$("next",pages)[0].firstChild.nodeValue;
				var numeros = T$$("num",pages);
				var div = T$("pages");
				while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
				var txt = document.createTextNode(langdata.pages+": ");
				div.appendChild(txt);
				if (first == "1") {
					var lk = document.createElement("a");
					lk.href = "#";
					var ipt = document.createElement("input");
					ipt.type = "hidden";
					ipt.value = "1";
					lk.appendChild(ipt);
					var img = document.createElement("img");
					img.src = "../img/nav_first.gif";
					img.alt = "first";
					img.className = "fleche";
					lk.appendChild(img);
					lk.addEventListener("click",ChangePage,false);
					div.appendChild(lk);
				} else {
					var txt = document.createTextNode(".. ");
					div.appendChild(txt);
				}
				if (previous == "0") {
					var txt = document.createTextNode(".. ");
					div.appendChild(txt);
				} else {
					var lk = document.createElement("a");
					lk.href = "#";
					var ipt = document.createElement("input");
					ipt.type = "hidden";
					ipt.value = previous;
					lk.appendChild(ipt);
					var img = document.createElement("img");
					img.src = "../img/nav_previous.gif";
					img.alt = "previous";
					img.className = "fleche";
					lk.appendChild(img);
					lk.addEventListener("click",ChangePage,false);
					div.appendChild(lk);
				}
				for (var i=0;i<numeros.length;i++) {
					var lk = document.createElement("a");
					lk.href = "#";
					if (T$$("current",numeros[i]).length) {
						lk.className = "current";
						T$("fNavi").page.value = numeros[i].firstChild.nodeValue;
					} else {
						var ipt = document.createElement("input");
						ipt.type = "hidden";
						ipt.value = numeros[i].firstChild.nodeValue;
						lk.appendChild(ipt);
						lk.addEventListener("click",ChangePage,false);
					}
					var txt = document.createTextNode(numeros[i].firstChild.nodeValue + " ");
					lk.appendChild(txt);
					div.appendChild(lk);
				}
				if (next == "0") {
					var txt = document.createTextNode(".. ");
					div.appendChild(txt);
				} else {
					var lk = document.createElement("a");
					lk.href = "#";
					var ipt = document.createElement("input");
					ipt.type = "hidden";
					ipt.value = next;
					lk.appendChild(ipt);
					var img = document.createElement("img");
					img.src = "../img/nav_next.gif";
					img.alt = "next";
					img.className = "fleche";
					lk.appendChild(img);
					lk.addEventListener("click",ChangePage,false);
					div.appendChild(lk);
				}
				if (last == "0") {
					var txt = document.createTextNode("..");
					div.appendChild(txt);
				} else {
					var lk = document.createElement("a");
					lk.href = "#";
					var ipt = document.createElement("input");
					ipt.type = "hidden";
					ipt.value = last;
					lk.appendChild(ipt);
					var img = document.createElement("img");
					img.src = "../img/nav_end.gif";
					img.alt = "last";
					img.className = "fleche";
					lk.appendChild(img);
					lk.addEventListener("click",ChangePage,false);
					div.appendChild(lk);
				}
				var rows = T$$("row",response);
				for (var i=0;i<rows.length;i++) {
					var mytr = body.insertRow(-1);
					mytr.className = T$$("colortr",rows[i])[0].firstChild.nodeValue;
					if (T$$("userip",rows[i])[0].firstChild.nodeValue == "true") {
						if (T$$("type",rows[i])[0].firstChild.nodeValue == "static") {
							var mytd = mytr.insertCell(-1);
							mytd.align = "center";
							var ipt = document.createElement("input");
							ipt.type = "checkbox";
							ipt.name = "effac";
							ipt.value = T$$("id",rows[i])[0].firstChild.nodeValue;
							mytd.appendChild(ipt);
							var mytd = mytr.insertCell(-1);
							mytd.align = "center";
							var ipt = document.createElement("input");
							ipt.type = "checkbox";
							ipt.name = "modify";
							ipt.value = T$$("id",rows[i])[0].firstChild.nodeValue;
							mytd.appendChild(ipt);
							if (T$$("mig",rows[i])[0].firstChild.nodeValue == "1") {
								var mytd = mytr.insertCell(-1);
								mytd.align = "center";
								var ipt = document.createElement("input");
								ipt.type = "checkbox";
								ipt.name = "migra";
								ipt.value = T$$("id",rows[i])[0].firstChild.nodeValue;
								mytd.appendChild(ipt);
							} else {
								var mytd = mytr.insertCell(-1);
							}
						} else {
							var mytd = mytr.insertCell(-1);
							var mytd = mytr.insertCell(-1);
							var mytd = mytr.insertCell(-1);
						}
					}
					var mytd = mytr.insertCell(-1);
					var txt = document.createTextNode(T$$("type",rows[i])[0].firstChild.nodeValue);
					mytd.appendChild(txt);
					var mytd = mytr.insertCell(-1);
					mytd.innerHTML = '<span class="hotspot" onmouseover="javascript:tooltip.show(' + "'"+langdata.code+": " + T$$("sitetooltip",rows[i])[0].firstChild.nodeValue + "'" + ')" onmouseout="javascript:tooltip.hide()">' + T$$("site",rows[i])[0].firstChild.nodeValue + '</span>';
					var mytd = mytr.insertCell(-1);
					var txt = document.createTextNode(T$$("name",rows[i])[0].firstChild.nodeValue);
					mytd.appendChild(txt);
					var mytd = mytr.insertCell(-1);
					if (T$$("def",rows[i])[0].firstChild) {
						var txt = document.createTextNode(T$$("def",rows[i])[0].firstChild.nodeValue);
						mytd.appendChild(txt);
					}
					var mytd = mytr.insertCell(-1);
					var urlpref = T$("urlpref").value>0?' onclick="javascript:ClickIP(event)"':'';
					mytd.innerHTML = '<span class="hotspot" onmouseover="javascript:tooltip.show(' + "'"+langdata.mask+" = " + T$$("masktooltip",rows[i])[0].firstChild.nodeValue + "'" + ')" onmouseout="javascript:tooltip.hide()"'+urlpref+'>' + T$$("ip",rows[i])[0].firstChild.nodeValue + '/' + T$$("mask",rows[i])[0].firstChild.nodeValue + '</span>';
					var mytd = mytr.insertCell(-1);
					if (T$$("subnettooltip",rows[i])[0].firstChild) {
						mytd.innerHTML = '<span onmouseover="javascript:tooltip.show(' + "'"+langdata.ipgw+" = " + T$$("subnettooltip",rows[i])[0].firstChild.nodeValue + "'" + ')" onmouseout="javascript:tooltip.hide()">' + T$$("subnet",rows[i])[0].firstChild.nodeValue + '</span>';
					} else {
						mytd.innerHTML = T$$("subnet",rows[i])[0].firstChild.nodeValue;
					}
					var mytd = mytr.insertCell(-1);
					if (T$$("mac",rows[i])[0].firstChild) {
						var txt = document.createTextNode(T$$("mac",rows[i])[0].firstChild.nodeValue);
						mytd.appendChild(txt);
					}
					var mytd = mytr.insertCell(-1);
					var txt = document.createTextNode(T$$("modif",rows[i])[0].firstChild.nodeValue);
					mytd.appendChild(txt);
					var mytd = mytr.insertCell(-1);
					var txt = document.createTextNode(T$$("temp",rows[i])[0].firstChild.nodeValue);
					mytd.appendChild(txt);
					var mytd = mytr.insertCell(-1);
					var txt = document.createTextNode(T$$("migstr",rows[i])[0].firstChild.nodeValue);
					mytd.appendChild(txt);
				}
			} else {
				hideDialog();
				window.location.reload(true);
			}
		}
	}
	showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
	xhriplist.open("POST","ajax_iplist.jsp",true);
	xhriplist.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhriplist.send("ctx="+ctx+"&page="+page+"&limit="+limit+"&sortKey="+sortKey+"&sortOrder="+sortOrder+"&search="+escape(search));
}
function ChangePage(e) {
	var node = e.target;
	T$("fNavi").page.value = node.parentNode.firstChild.value?node.parentNode.firstChild.value:node.firstChild.value;
	validateSearch();
}
function Change() {
	var x = T$("fNavi");
	var n=Number(x.page.value);
	var sortorder = "";
	if (!isNaN(n) && x.page.value > 0) {
		for(var i=0;i<x.sortOrder.length;i++) {
			if (x.sortOrder[i].checked) { sortorder = x.sortOrder[i].value; }
		}
		ConstructListTable(x.page.value,x.limit.value,x.sortKey.value,sortorder,x.search.value);
	} else {
		showDialog(langdata.invalidfield+" :",langdata.pagenum+": "+langdata.verifchoose,"warning",0,1);
	}
}
function ExcelIP(type,ctx) {
	var uri = "ip_excel.jsp?ctx="+ctx+"&type="+type;
	if (type == 'recherche') { uri += "&search="+encodeURIComponent(T$("mytext").value); }
	window.open(uri);
}
function ClickIP(e) {
	var node = e.target;
	var ipfull = node.firstChild.nodeValue;
	var ip = ipfull.substring(0,ipfull.indexOf("/"));
	TINY.box.show({url:'box_ip_url.jsp',post:'ip='+ip});
}
function ClickURL(u) {
	TINY.box.hide();
	window.open(u);
}
