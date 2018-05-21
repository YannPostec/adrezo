//@Author: Yann POSTEC
var sortiny = new TINY.table.sorter('sortiny','table',{
		headclass:'head',
		ascclass:'asc',
		descclass:'desc',
		evenclass:'evenrow',
		oddclass:'oddrow',
		evenselclass:'evenselected',
		oddselclass:'oddselected',
		paginate:true	,
		size:10,
		currentid:'currentpage',
		totalid:'totalpages',
		startingrecid:'startrecord',
		endingrecid:'endrecord',
		totalrecid:'totalrecords',
		hoverid:'selectedrow',
		navid:'tablenav',
		init:false
	});
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
	T$("add_annu").selectedIndex = 0;
	T$("add_ctx").selectedIndex = 0;
	T$("add_new").value = "0";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit(e) {
	var strAlert="";
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[2].firstChild.value;
	var name = tds[2].firstChild.nextSibling.value;
	var selectannu = tds[3].firstChild;
	var annu = selectannu.value;
	var selectctx = tds[4].firstChild;
	var ctx = selectctx.value;
	var newctx = tds[5].firstChild.value;

	if (selectannu.selectedIndex == 0) { strAlert += "- "+langdata.annu+": "+langdata.verifchoose+"<br />"; }
	if (selectctx.selectedIndex == 0) { strAlert += "- "+langdata.initialctx+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else {
		if (name.indexOf("/") != -1) { strAlert += "- "+langdata.name+": "+langdata.verifnoslash+"<br />"; }
		if (name.length > 40) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 40<br />"; }
	}
	if (!newctx || isNaN(newctx) || newctx < 0 || newctx > 255) { strAlert += "- "+langdata.newctx+": "+langdata.verifnumber+" < 256<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_auth_roles_store.jsp","id="+id+"&newctx="+newctx+"&annu="+annu+"&name="+name+"&ctx="+ctx);
	}
}
function delSubmit(id) {
	DBAjax("ajax_auth_roles_delete.jsp","id="+id);
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
	ipt.size = 40;
	ipt.value = texte;
	tds[2].replaceChild(ipt,txt);
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[2].appendChild(hid);	
	var txt = tds[3].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[3].replaceChild(hid,txt);
	tds[3].firstChild.style.display = "inline";
	var txt = tds[4].firstChild.nextSibling.nextSibling;
	var texte = txt.nodeValue;
	var hid = document.createElement("input");
	hid.type = "hidden";
	hid.value = texte;
	tds[4].replaceChild(hid,txt);
	tds[4].firstChild.style.display = "inline";
	var txt = tds[5].firstChild;
	var texte = txt.nodeValue;
	var ipt = document.createElement("input");
	ipt.type = "text";
	ipt.size = "3";
	ipt.id = "newctx_" + tds[2].firstChild.value;
	ipt.value = texte;
	tds[5].replaceChild(ipt,txt);
	tds[5].firstChild.nextSibling.style.display = "inline";
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
	var hid = tds[3].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[3].replaceChild(txt,hid);
	tds[3].firstChild.value = tds[3].firstChild.nextSibling.value;
	tds[3].firstChild.style.display = "none";
	var hid = tds[4].firstChild.nextSibling.nextSibling;
	var txt = document.createTextNode(hid.value);
	tds[4].replaceChild(txt,hid);
	tds[4].firstChild.value = tds[4].firstChild.nextSibling.value;
	tds[4].firstChild.style.display = "none";
	var ipt = tds[5].firstChild;
	var txt = document.createTextNode(ipt.value);
	tds[5].replaceChild(txt,ipt);
	tds[5].firstChild.nextSibling.style.display = "none";
}
function NewCtx(e,role,elt) {
	var node = e.target;
	var elt = node.parentNode.parentNode.firstChild.id;
	TINY.box.show({url:'box_auth_roles_newctx.jsp',post:'role='+role+'&elt='+elt});
}
function NewCtxValid(elt) {
	var tds=T$$("td",T$("newctx_tr"));
	var roles=0;
	if (tds[0].firstChild.checked) { roles += 1; }
	if (tds[1].firstChild.checked) { roles += 2; }
	if (tds[2].firstChild.checked) { roles += 4; }
	if (tds[3].firstChild.checked) { roles += 8; }
	if (tds[4].firstChild.checked) { roles += 16; }
	if (tds[5].firstChild.checked) { roles += 32; }
	if (tds[6].firstChild.checked) { roles += 64; }
	TINY.box.hide();
	T$(elt).value = roles;
}
function RightsManage(id,name) {
	TINY.box.show({url:'box_auth_roles_rights.jsp',post:'id='+id+'&name='+name});
}
function RightsValid(e,id) {
	var node = e.target;
	var trs = T$("right_table").tBodies[0].rows;
	var l = trs.length;
	var myCtx = new Array();
	var myRights = new Array();
	for (i=0;i<l-1;i++) {
		var tds=T$$("td",trs[i]);
		var ctx=tds[0].firstChild.value;
		var rights=0;
		if (tds[1].firstChild.checked) { rights += 1; }
		if (tds[2].firstChild.checked) { rights += 2; }
		if (tds[3].firstChild.checked) { rights += 4; }
		if (tds[4].firstChild.checked) { rights += 8; }
		if (tds[5].firstChild.checked) { rights += 16; }
		if (tds[6].firstChild.checked) { rights += 32; }
		if (tds[7].firstChild.checked) { rights += 64; }
		myCtx[i] = ctx;
		myRights[i] = "r"+ctx+"="+rights;
	}
	TINY.box.hide();
	DBAjax("ajax_auth_rights_store.jsp","role="+id+"&ctx=" + myCtx.join(",") + "&" + myRights.join("&"));
}
function GroupMap(id,name,annu) {
	TINY.box.show({url:'box_auth_ldap_groupmap.jsp',openjs:function(){GroupLoad(id)},post:'id='+id+'&name='+name+"&annu="+annu});
}
function GroupValid(e) {
	var node=e.target;
	var id=node.parentNode.firstChild.value;
	var cn=node.parentNode.firstChild.nextSibling.value;
	var dn=node.parentNode.firstChild.nextSibling.nextSibling.value;
	TINY.box.hide();
	DBAjax("ajax_auth_ldap_grp.jsp","id="+id+"&grp="+cn+"&grpdn="+dn);
}
function GroupLoad(id) {
	var divwait = T$("ldapmap_wait");
	var diverr = T$("ldapmap_err");
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
					var m = T$$("group",response);
					if (m.length) {
						for (var i=0;i<m.length;i++) {
							var cn = T$$("cn",m[i])[0].firstChild.nodeValue;
							var dn = T$$("dn",m[i])[0].firstChild.nodeValue;
							var mytr = T$("table").tBodies[0].insertRow(-1);
							var mytd = mytr.insertCell(-1);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = id;
							mytd.appendChild(ipt);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = cn;
							mytd.appendChild(ipt);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = dn;
							mytd.appendChild(ipt);
							var img = document.createElement("img");
							img.src = "../img/icon_valid.png";
							img.alt = "Select Group";
							img.addEventListener("click",GroupValid,false);
							mytd.appendChild(img);
							var mytd = mytr.insertCell(-1);
							mytd.appendChild(document.createTextNode(cn));
						}
						sortiny.init();
					} else {
						diverr.innerHTML = langdata.rolenogrp;
					}
				} else {
					var erreur = T$$("msg",response)[0].firstChild.nodeValue;
					diverr.innerHTML = langdata.roleerror+" : "+erreur;
				}
			} else {
				diverr.innerHTML = langdata.rolenoanswer;
			}
			TINY.box.dim();
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	var txt = document.createTextNode(langdata.rolewait);
	divwait.appendChild(txt);
	divwait.appendChild(document.createElement("br"));
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","../ldapgroup",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("id="+id);
}
