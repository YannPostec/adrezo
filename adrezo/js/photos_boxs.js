//@Author: Yann POSTEC
function EmptySalle(selectsalle) {
	selectsalle.selectedIndex = 0;
	var options = T$$("option",selectsalle);
	while (selectsalle.options.length > 1) {
		selectsalle.removeChild(selectsalle.lastChild);
	}
}
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
	T$("add_site").selectedIndex = 0;
	EmptySalle(T$("add_salle"));
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillSalle(bModify,salle) {
	EmptySalle(T$("add_salle"));	
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
						if (bModify) {
							if (opt.value == salle) { opt.selected = true; }
						}
						T$("add_salle").add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSalle","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_photo_fillsalle.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("site="+T$("add_site").value);
	}
}
function addSubmit() {
	var strAlert="";
	var selectsite = T$("add_site");
	var selectsalle = T$("add_salle");
	var id = T$("add_id").value;
	var name = T$("add_name").value;
	
	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	if (selectsalle.selectedIndex == 0) { strAlert += "- "+langdata.room+": "+langdata.verifchoose+"<br />"; }
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (name.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }

	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_boxs_store.jsp","salle="+selectsalle.value+"&id="+id+"&name="+name);
	}
}
function delSubmit(id) {
	DBAjax("ajax_boxs_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_id").value = tds[3].firstChild.value;
	T$("add_name").value = tds[3].firstChild.nextSibling.nodeValue;
	T$("add_site").value = tds[1].firstChild.value;
	FillSalle(true,tds[2].firstChild.value);
}
