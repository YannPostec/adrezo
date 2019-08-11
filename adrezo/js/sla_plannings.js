//@Author: Yann POSTEC
function ResetAdd() {
	T$("add_name").value = "";
}
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function verifyInput(name) {
	var strAlert="";
	
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else {
		if (name.indexOf("/") != -1) { strAlert += "- "+langdata.name+": "+langdata.verifnoslash+"<br />"; }
		if (name.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
	}
		
	return(strAlert);
}
function addSubmit() {
	var name = T$("add_name").value;

	var strAlert = verifyInput(name);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_plannings_store.jsp","id=&name="+name);
	}
}
function modSubmit(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var name = tds[3].firstChild.value;

	var strAlert = verifyInput(name);
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_plannings_store.jsp","id="+id+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_plannings_delete.jsp","id="+id,true,function callback(result) {
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
	var txt = tds[3].firstChild;
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
	tds[4].firstChild.style.display="none";
	tds[5].firstChild.style.display="none";
	refreshTable(false);	
}
function CancelModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	tds[4].firstChild.style.display="inline";
	tds[5].firstChild.style.display="inline";
	refreshTable(false);	
}
function ApplyModif(id) {
	var node = T$("mytd"+id);
	var tds = T$$("td",node.parentNode);
	var span = tds[1].childNodes;
	span[0].style.display="inline";
	span[1].style.display="none";
	span[2].style.display="none";
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(ipt.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	tds[4].firstChild.style.display="inline";
	tds[5].firstChild.style.display="inline";
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
					if (T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.id = "mytd" + hid.value;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("id",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("name",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("name",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("name",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var myspan = T$("spanshadowmanage").cloneNode(true);
						myspan.removeAttribute("id");
						var img = document.createElement("img");
						img.src = "../img/icon_database.png";
						img.alt = "Click to choose planning";
						img.addEventListener("click",PlanManage,false);
						myspan.appendChild(img);
						myspan.style.display="inline";
						mytd.appendChild(myspan);
					} else { mytr.insertCell(-1); }
					if (T$$("name",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var myspan = T$("spanshadowcopy").cloneNode(true);
						myspan.removeAttribute("id");
						var img = document.createElement("img");
						img.src = "../img/icon_copy.png";
						img.alt = "Click to copy planning";
						img.addEventListener("click",CopyPlan,false);
						myspan.appendChild(img);
						myspan.style.display="inline";
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
			case 2: T$("sqs_order").value="id";break;
			case 3: T$("sqs_order").value="name";break;
		}
}
function PlanManage(e) {
	var node=e.target;
	var id=node.parentNode.parentNode.previousSibling.previousSibling.firstChild.value;
	var name=node.parentNode.parentNode.previousSibling.firstChild.nodeValue;
	TINY.box.show({url:'box_plannings_hours.jsp',post:'id='+id+'&name='+name});
}
function PlanValid(e,id) {
	var node = e.target;
	var trs = T$("plan_table").tBodies[0].rows;
	var myRights = new Array();
	for (i=0;i<7;i++) {
		var tds=T$$("td",trs[i]);
		var day=tds[0].firstChild.value;
		var rights=0;
		if (tds[1].firstChild.checked) { rights += 1; }
		if (tds[2].firstChild.checked) { rights += 2; }
		if (tds[3].firstChild.checked) { rights += 4; }
		if (tds[4].firstChild.checked) { rights += 8; }
		if (tds[5].firstChild.checked) { rights += 16; }
		if (tds[6].firstChild.checked) { rights += 32; }
		if (tds[7].firstChild.checked) { rights += 64; }
		if (tds[8].firstChild.checked) { rights += 128; }
		if (tds[9].firstChild.checked) { rights += 256; }
		if (tds[10].firstChild.checked) { rights += 512; }
		if (tds[11].firstChild.checked) { rights += 1024; }
		if (tds[12].firstChild.checked) { rights += 2048; }
		if (tds[13].firstChild.checked) { rights += 4096; }
		if (tds[14].firstChild.checked) { rights += 8192; }
		if (tds[15].firstChild.checked) { rights += 16384; }
		if (tds[16].firstChild.checked) { rights += 32768; }
		if (tds[17].firstChild.checked) { rights += 65536; }
		if (tds[18].firstChild.checked) { rights += 131072; }
		if (tds[19].firstChild.checked) { rights += 262144; }
		if (tds[20].firstChild.checked) { rights += 524288; }
		if (tds[21].firstChild.checked) { rights += 1048576; }
		if (tds[22].firstChild.checked) { rights += 2097152; }
		if (tds[23].firstChild.checked) { rights += 4194304; }
		if (tds[24].firstChild.checked) { rights += 8388608; }
		myRights[i] = "h"+day+"="+rights;
	}
	TINY.box.hide();
	DBAjax("ajax_box_plannings_store.jsp","id="+id+ "&" + myRights.join("&"));
}
function HoursBox(name,ch,inv) {
	var el = T$("fList")[name];
	if (el) {
		if (el.length != undefined) {
			for (var i=0; i<el.length; i++) {
				if (inv) {el[i].checked = !el[i].checked; }
				else {el[i].checked = ch; }
			}
		} else {
			if (inv) { el.checked = !el.checked; }
			else { el.checked = ch; }
		}
	}
}
function CopyPlan(e) {
	var node=e.target;
	var id=node.parentNode.parentNode.previousSibling.previousSibling.previousSibling.firstChild.value;
	var name=node.parentNode.parentNode.previousSibling.previousSibling.firstChild.nodeValue;
	TINY.box.show({url:'box_planning_copy.jsp',post:'id='+id+'&name='+name});
}
function CopyPlanValid(id) {
	TINY.box.hide();
	DBAjax("ajax_box_planning_copy.jsp","id="+id+"&name="+T$("copy_name").value);
}
