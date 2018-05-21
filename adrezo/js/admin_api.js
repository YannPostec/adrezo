//@Author : Yann POSTEC
function ResetAdd() {
	T$("add_usr").selectedIndex = 0;
	T$("add_sub").value = "";
	T$("add_update").value = "";
}
function ResetMod() {
	T$("add_sub").value = "";
	T$("add_update").value = "";
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit(\""+id+"\");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit() {
	var strAlert="";
	var selectusr = T$("add_usr");
	var id = selectusr.value;
	var login = selectusr.options[selectusr.selectedIndex].text;
	var subnets = T$("add_sub").value;
	var update = T$("add_update").value;
	if (selectusr.selectedIndex == 0) { strAlert += "- "+langdata.login+": "+langdata.verifchoose+"<br />"; }
	if (!subnets) {	strAlert += "- "+langdata.subnet+": "+langdata.verifnotnull+"<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_api_store.jsp","id="+id+"&login="+login+"&subnets="+subnets+"&update="+update);
	}
}
function delSubmit(id) {
	DBAjax("ajax_api_delete.jsp","id="+id);
}
function CreateModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_update").value = tds[4].firstChild.value;
	T$("add_sub").value = tds[3].firstChild.nodeValue;
	T$("add_usr").value = tds[4].firstChild.value;
}
function subChange() {
	var strAlert="";
	var selectusr = T$("add_usr");
	if (selectusr.selectedIndex == 0) { strAlert += "- "+langdata.login+": "+langdata.verifchoose+"<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		TINY.box.show({url:'box_api_subnets.jsp',post:'id='+selectusr.value});
	}
}
function lstValid() {
	var sellist = T$("sel_lst_sub_choisi");
	var list="";
	for (var i=0;i<sellist.options.length;i++) {
		list+=sellist.options[i].value;
		if (i<sellist.options.length-1) { list+=","; }
	}
	T$("add_sub").value = list;
	TINY.box.hide();
}
function FillSite(node) {
	var ctx = node.value;
	var selectsite = T$("sel_lst_site");
	selectsite.selectedIndex = 0;
	var options = T$$("option",selectsite);
	while (selectsite.options.length > 1) {
		selectsite.removeChild(selectsite.lastChild);
	}
	var selectsubd = T$("sel_lst_sub_dispo");
	var options = T$$("option",selectsubd);
	while (selectsubd.options.length > 0) {
		selectsubd.removeChild(selectsubd.lastChild);
	}
	if (node.selectedIndex > 0) {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				var divwait=T$("box_api_wait");
				while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
				response = xhr.responseXML.documentElement;
				if (response) { response = cleanXML(response); }
				var valid = T$$("valid",response)[0].firstChild.nodeValue;
				if (valid == "true") {
					var rows = T$$("option",response);
					for (var i=0;i<rows.length;i++) {
						var opt = document.createElement("option");
						opt.value = T$$("value",rows[i])[0].firstChild.nodeValue;
						opt.text = T$$("texte",rows[i])[0].firstChild.nodeValue;
						selectsite.add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSite","error",0,1);
				}
			}
		};
		var divwait=T$("box_api_wait");
		while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
		var img=document.createElement("img");
		img.src = "../img/wait_bar.gif";
		img.alt = "WaitBar";
		img.width = 345;
		img.heigth = 21;
		divwait.appendChild(img);
		xhr.open("POST","ajax_api_lst_fillsite.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("ctx="+ctx);
		TINY.box.dim();
		FillSub(node,false);
	}
}
function FillSub(node,type) {
	var id = node.value;
	if (id=='all') {
		type=false;
		id=T$("sel_lst_ctx").value;
	}
	var selectsubd = T$("sel_lst_sub_dispo");
	var options = T$$("option",selectsubd);
	while (selectsubd.options.length > 0) {
		selectsubd.removeChild(selectsubd.lastChild);
	}
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
		if (xhr.readyState==4 && xhr.status==200) {
			var divwait=T$("box_api_wait");
			while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var rows = T$$("option",response);
				for (var i=0;i<rows.length;i++) {
					var opt = document.createElement("option");
					opt.value = T$$("value",rows[i])[0].firstChild.nodeValue;
					opt.text = T$$("texte",rows[i])[0].firstChild.nodeValue;
					selectsubd.add(opt);
				}
			} else {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillVlan","error",0,1);
			}
		}
	};
	var divwait=T$("box_api_wait");
	while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	xhr.open("POST","ajax_api_lst_fillsub.jsp",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	if (type) { xhr.send("type=site&id="+id); }
	else { xhr.send("type=ctx&id="+id); }
	TINY.box.dim();
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
		selsubc.add(res[i]);
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
		selsubd.add(res[i]);
	}
	for (var i=0;i<del.length;i++) {
		selsubc.removeChild(del[i]);
	}
	TINY.box.dim();
}
