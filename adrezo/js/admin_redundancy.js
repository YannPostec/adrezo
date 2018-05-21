//@Author: Yann POSTEC
function ResetAdd() {
	var ip = T$("add_ip");
	while (ip.childNodes.length>0) {ip.removeChild(ip.firstChild);}
	T$("add_id").value = "";
	T$("add_ipid").value = "";
	T$("add_pid").value = "";
	T$("add_ptype").selectedIndex = 0;
	T$("add_span").style.display="inline";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert = "";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var sel_ptype = tds[2].firstChild;
	var ptype = sel_ptype.value;
	var pid = tds[3].firstChild.value;
	var id = tds[4].firstChild.value;
	var ipid = tds[4].firstChild.nextSibling.value;

	if (sel_ptype.selectedIndex == 0) { strAlert += "- "+langdata.proto+": "+langdata.verifchoose+"<br />"; }
	if (!pid) { strAlert += "- ID: "+langdata.verifnotnull+"<br />"; }
	if (pid < 0 || isNaN(pid)) { strAlert += "- ID: "+langdata.verifnumber+"<br />"; }
	if (!ipid) { strAlert += "- "+langdata.ip+": "+langdata.verifchoose+"<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_redundancy_store.jsp","id="+id+"&pid="+pid+"&ipid="+ipid+"&ptype="+ptype);
	}
}
function delSubmit(id) {
	DBAjax("ajax_redundancy_delete.jsp","id="+id);
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
	var txt = tds[3].firstChild;
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
	var ipid = tds[4].firstChild.nextSibling.value;
	var div = tds[4].firstChild.nextSibling.nextSibling;
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
	var ipt = tds[3].firstChild;
	var hid = ipt.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].removeChild(hid);
	tds[3].replaceChild(txt,ipt);
	var ipid = tds[4].firstChild.nextSibling;
	var div = tds[4].firstChild.nextSibling.nextSibling;
	var span = div.nextSibling;
	var hidt = span.nextSibling;
	var hidi = hidt.nextSibling;
	while (div.childNodes.length>0) {div.removeChild(div.firstChild);}
	span.style.display="none";
	div.appendChild(document.createTextNode(hidt.value));
	tds[4].removeChild(hidt);
	ipid.value=hidi.value;
	tds[4].removeChild(hidi);
}
function ChooseIP(e,elt) {
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
