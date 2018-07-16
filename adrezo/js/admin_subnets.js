//@Author: Yann POSTEC
function EmptySelect(sel) {
	sel.selectedIndex = 0;
	var options = T$$("option",sel);
	while (sel.options.length > 1) {
		sel.removeChild(sel.lastChild);
	}
}
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_ip").value = "";
	T$("add_mask").value = "";
	T$("add_def").value = "";
	T$("add_gw").value = "";
	T$("add_bc").value = "";
	T$("add_site").selectedIndex = 0;
	selectvlan = T$("add_vlan");
	EmptySelect(selectvlan);
	T$("init_ip").value = "";
	T$("init_mask").value = "";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillVlan(vlan) {
	EmptySelect(T$("add_vlan"));
	if (T$("add_site").selectedIndex > 0) {
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
						if (vlan>0) {
							if (opt.value == vlan) { opt.selected = true; }
						}
						T$("add_vlan").add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillVlan","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_subnets_fillvlan.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("site="+T$("add_site").value);
	}
}
function addSubmit() {
	var strAlert="";
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
	if (T$("add_mask").value&&T$("add_ip").value) {
		var myIP = new IPv4_Address(T$("add_ip").value,T$("add_mask").value);
		if (T$("add_ip").value != myIP.netaddressDotQuad) { strAlert += "- "+langdata.ip+": "+langdata.verifnet+" : "+myIP.netaddressDotQuad+"<br />"; }
	}
	if (T$("add_mask").value&&T$("add_ip").value&&T$("add_bc").value) {
		var myIP = new IPv4_Address(T$("add_bc").value,T$("add_mask").value);
		if (T$("add_ip").value != myIP.netaddressDotQuad) { strAlert += "- "+langdata.ipbc+": "+langdata.verifothersubnet+"<br />"; }
	}
	if (T$("add_mask").value&&T$("add_ip").value&&T$("add_gw").value) {
		var myIP = new IPv4_Address(T$("add_gw").value,T$("add_mask").value);
		if (T$("add_ip").value != myIP.netaddressDotQuad) { strAlert += "- "+langdata.ipgw+": "+langdata.verifothersubnet+"<br />"; }
	}

	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		if ( (T$("add_mask").value!=T$("init_mask").value) || (T$("add_ip").value!=T$("init_ip").value)) {
			showDialog(langdata.confirm,langdata.subnetchange+"<br/><br/><input type='button' value='"+langdata.dlgyes+'\' onclick="javascript:addAjaxSubmit('+site+','+id+',\''+ip+'\','+mask+',\''+def+'\',\''+gw+'\',\''+bc+'\','+vlan+','+ctx+');"/>'+"  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","warning",0,1);
		} else {
			addAjaxSubmit(site,id,ip,mask,def,gw,bc,vlan,ctx);
		}		
	}
}
function addAjaxSubmit(site,id,ip,mask,def,gw,bc,vlan,ctx) {
	DBAjax("ajax_subnets_store.jsp","site="+site+"&id="+id+"&ip="+ip+"&mask="+mask+"&def="+def+"&gw="+gw+"&bc="+bc+"&vlan="+vlan+"&ctx="+ctx);
}
function delSubmit(id) {
	DBAjax("ajax_subnets_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_id").value = tds[2].firstChild.value;
	T$("add_ip").value = tds[2].firstChild.nextSibling.nodeValue;
	T$("init_ip").value = tds[2].firstChild.nextSibling.nodeValue;
	T$("add_mask").value = tds[3].firstChild.nodeValue;
	T$("init_mask").value = tds[3].firstChild.nodeValue;
	T$("add_def").value = tds[4].firstChild.nodeValue;
	T$("add_gw").value = tds[5].firstChild?tds[5].firstChild.nodeValue:"";
	T$("add_bc").value = tds[6].firstChild.nodeValue;
	T$("add_site").value = tds[1].firstChild.value;
	FillVlan(tds[7].firstChild.value);
}
function calcBC() {
	if (T$("add_mask").value&&T$("add_ip").value) {
		var myIP = new IPv4_Address(T$("add_ip").value,T$("add_mask").value);
		T$("add_bc").value = myIP.netbcastDotQuad;
	}
}
