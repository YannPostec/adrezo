//@Author: Yann POSTEC
function EmptySelect(mysel) {
	mysel.selectedIndex = 0;
	var options = T$$("option",mysel);
	while (mysel.options.length > 1) {
		mysel.removeChild(mysel.lastChild);
	}
}
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_name").value = "";
	T$("add_site").selectedIndex = 0;
	EmptySelect(T$("add_salle"));
	EmptySelect(T$("add_box"));
	EmptySelect(T$("add_numero"));
}
function ConfirmDlg(id,box,num) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+","+box+","+num+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function FillSalle(bModify,salle,box,num) {
	EmptySelect(T$("add_salle"));
	EmptySelect(T$("add_box"));
	EmptySelect(T$("add_numero"));	
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
					if (bModify) { FillBox(true,box,num); }
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
function FillBox(bModify,box,num) {
	EmptySelect(T$("add_box"));

	if (T$("add_salle").selectedIndex > 0) {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>Erreur "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
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
							if (opt.value == box) { opt.selected = true; }
						}
						T$("add_box").add(opt);
					}
					if (bModify) { FillNumero(true,num); }
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillBox","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_photo_fillbox.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("salle="+T$("add_salle").value);
	}
}
function FillNumero(bModify,num) {
	EmptySelect(T$("add_numero"));
	if (T$("add_box").selectedIndex > 0) {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>Erreur "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
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
							if (opt.value == num) { opt.selected = true; }
						}
						T$("add_numero").add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillNumero","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_photo_fillnumero.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("box="+T$("add_box").value);
	}
}
function addSubmit() {
	var strAlert="";
	var selectsite = T$("add_site");
	var selectsalle = T$("add_salle");
	var selectbox = T$("add_box");
	var selectnum = T$("add_numero");
	var box = selectbox.value;
	var num = selectnum.value;
	var id = T$("add_id").value;
	var name = T$("add_name").value;

	if (selectsite.selectedIndex == 0) { strAlert += "- "+langdata.site+": "+langdata.verifchoose+"<br />"; }
	else {
		if (selectsalle.selectedIndex == 0) { strAlert += "- "+langdata.room+": "+langdata.verifchoose+"<br />"; }
		else {
			if (selectbox.selectedIndex == 0) { strAlert += "- "+langdata.set+": "+langdata.verifchoose+"<br />"; }
			else {
				if (selectnum.selectedIndex == 0) { strAlert += "- "+langdata.pos+": "+langdata.verifchoose+"<br />"; }
			}
		}
	}
	if (!name) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	if (name.length > 15) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 15<br />"; }
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_baies_store.jsp","box="+box+"&id="+id+"&name="+name+"&num="+num);
	}
}
function delSubmit(id,box,num) {
	DBAjax("ajax_baies_delete.jsp","id="+id+"&box="+box+"&num="+num);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_id").value = tds[4].firstChild.value;
	T$("add_name").value = tds[4].firstChild.nextSibling.nodeValue;
	T$("add_site").value = tds[1].firstChild.value;
	FillSalle(true,tds[2].firstChild.value,tds[3].firstChild.value,tds[5].firstChild.nodeValue);
}
