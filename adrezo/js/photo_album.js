//@Author: Yann POSTEC
function DisplayPhoto(id) {
	var d = T$(id);
	d.style.display == "none" ? d.style.display = "block" : d.style.display = "none"
}
function SwitchView(e,id) {
	var node = e.target;
	var p = T$("sens_"+id);
	var txt = p.firstChild ? p.firstChild.nodeValue : "";
	if (txt.indexOf(langdata.recto) != -1) {
		txt = txt.replace(langdata.recto,langdata.verso);
	} else {
		txt = txt.replace(langdata.verso,langdata.recto);
	}
	if (p.firstChild) {
		p.firstChild.nodeValue = txt;
		DisplayPhoto(id+"_RH");
		DisplayPhoto(id+"_RB");
		DisplayPhoto(id+"_VH");
		DisplayPhoto(id+"_VB");
	}
}
function EmptySelect(mysel) {
	mysel.selectedIndex = 0;
	var options = T$$("option",mysel);
	while (mysel.options.length > 1) {
		mysel.removeChild(mysel.lastChild);
	}
}
function FillSalle(node,selsalle) {
	var site = node.value;
	var selectsalle = T$(selsalle);
	EmptySelect(selectsalle);
	
	if (node.selectedIndex > 0) {
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
						selectsalle.add(opt);
					}
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSalle","error",0,1);
				}
			}
		};
		xhr.open("POST","ajax_photo_fillsalle.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("site="+site);
	}
}
function showAdmin(invert) {
	var node = T$("adminchoice");
	var choice = node.dataset.choice;
	var n=TC$("admin");
	if (choice == "no") {
		if (invert) {
			node.src = "../img/button_admin_green.png";
			node.dataset.choice = "yes";
			for (i=0;i<n.length;i++) { n[i].style.display = "inline"; }
		} else {
			for (i=0;i<n.length;i++) { n[i].style.display = ""; }
		}
	} else if (choice == "yes") {
		if (invert) {
			node.src = "../img/button_admin_red.png";
			node.dataset.choice = "no";
			for (i=0;i<n.length;i++) { n[i].style.display = ""; }
		} else {
			for (i=0;i<n.length;i++) { n[i].style.display = "inline"; }
		}
	}
}
function FillBody(node) {
	var salle = node.value;
	var mydiv = T$("album");
	
	if (node.selectedIndex > 0) {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				mydiv.innerHTML = xhr.responseText;
				window.accordion=new TINY.accordion.slider("accordion");
				accordion.init("acc","h3",0);
				accordion.pr(1);
				showAdmin(false);
				T$("OldestPic").innerHTML=T$("OldestPicture").value;
				T$("NewestPic").innerHTML=T$("NewestPicture").value;
				T$("InfosDatesPhotos").style.display = "inline";
			}
		};
		xhr.open("POST","ajax_album_fill.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("salle="+salle);
	}
}
function ModifyPhotoNameConfirm(id) {
	var p = T$("photoname_"+id);
	var txt = p.firstChild ? p.firstChild.nodeValue:"";
	showDialog(langdata.photoname,langdata.name+" : <input type='text' maxlength='50' value='"+txt+"' /><input type='button' value='"+langdata.mod+"' onclick='javascript:ModifyPhotoName(event,"+id+");'/>  <input type='button' value='"+langdata.edundo+"' onclick='hideDialog();'/>","prompt",0,1);
}
function ModifyPhotoName(e,id) {
	var node = e.target;
	var txt = node.previousSibling.value;
	if (txt.indexOf("'")>0) {
		T$("dialog-content").innerHTML+="<p>"+langdata.noquote+"</p>";
	} else {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
			}
			if (xhr.readyState==4 && xhr.status==200) {
				response = xhr.responseXML.documentElement;
				if (response) { response = cleanXML(response);}
				var valid = T$$("valid",response)[0].firstChild.nodeValue;
				if (valid == "true") {
					var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
					var typedlg = "success";
					var headdlg = langdata.xhrvalid;
					var txtdlg = T$$("msg",response)[0].firstChild.nodeValue + "<br/><br/>";
					txtdlg += "<input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog();' />";
					if (erreur == "true") {
						typedlg = "error";
						headdlg = langdata.xhrerror;
					} else {
						var p = T$("photoname_"+id);
						if (p.firstChild) {	p.firstChild.nodeValue = txt; }
						else { p.appendChild(document.createTextNode(txt)); }
					}
					showDialog(headdlg,txtdlg,typedlg,0,0);
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" ModifyPhotoName","error",0,1);
				}
			}
		};
		showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
		xhr.open("POST","ajax_photo_modifyname.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id+"&txt="+txt);
	}
}
function ModifyBaieNameConfirm(id) {
	var p = T$("baiename_"+id);
	var txt = p.firstChild ? p.firstChild.nodeValue : "";
	showDialog(langdata.rackname,langdata.name+" : <input type='text' maxlength='15' value='"+txt+"' /><input type='button' value='"+langdata.mod+"' onclick='javascript:ModifyBaieName(event,"+id+");'/>  <input type='button' value='"+langdata.edundo+"' onclick='hideDialog();'/>","prompt",0,1);
}
function ModifyBaieName(e,id) {
	var node = e.target;
	var txt = node.previousSibling.value;
	if (txt.indexOf("'")>0) {
		T$("dialog-content").innerHTML+="<p>"+langdata.noquote+"</p>";
	} else {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
			}
			if (xhr.readyState==4 && xhr.status==200) {
				response = xhr.responseXML.documentElement;
				if (response) { response = cleanXML(response); }
				var valid = T$$("valid",response)[0].firstChild.nodeValue;
				if (valid == "true") {
					var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
					var typedlg = "success";
					var headdlg = langdata.xhrvalid;
					var txtdlg = T$$("msg",response)[0].firstChild.nodeValue + "<br/><br/>";
					txtdlg += "<input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog();' />";
					if (erreur == "true") {
						typedlg = "error";
						headdlg = langdata.xhrerror;
					} else {
						var p = T$("baiename_"+id);
						if (p.firstChild) {	p.firstChild.nodeValue = txt; }
						else { p.appendChild(document.createTextNode(txt)); }
					}
					showDialog(headdlg,txtdlg,typedlg,0,0);
				} else {
					showDialog(langdata.xhrapperror,langdata.xhrapptext+" ModifyBaieName","error",0,1);
				}
			}
		};
		showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
		xhr.open("POST","ajax_baie_modifyname.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id+"&txt="+txt);
	}
}
function DeletePhotoConfirm(id,div,photo) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:DeletePhoto(\""+id+'","'+div+'",'+photo+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function DeletePhoto(id,div,photo) {
	DBAjax("ajax_photo_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var pic = T$(div);
			if (photo) { pic.parentNode.removeChild(pic); }
			else { while (pic.childNodes.length > 0) { pic.removeChild(pic.lastChild); } }
		}		
	});
}
function OpenReplace(e,id,dir,suf,name) {
	TINY.box.show({url:'photo_replace.jsp',post:'id='+id+'&dir='+dir+'&suf='+suf+'&name='+name,openjs:function(){TINY.box.dim()}});
}
function OpenUpload(e,type,idparent,name) {
	TINY.box.show({url:'photo_upload.jsp',post:'type='+type+'&idparent='+idparent+'&name='+name,openjs:function(){TINY.box.dim()}});
}
function progressHandler(event){
	var percent = (event.loaded / event.total) * 100;
	T$("upProgress").value = Math.round(percent);
	T$("upStatus").innerHTML = langdata.upload+" : "+Math.round(percent)+"%";
	if (percent==100) { T$("upStatus").innerHTML = langdata.photoupend; }
}
function errorHandler(event){
	T$("upStatus").innerHTML = langdata.uperr;
	T$("upResult").innerHTML = event.target.status+" : "+event.target.statusText;
	TINY.box.dim();
}
function abortHandler(event){
	T$("upStatus").innerHTML = langdata.upcancel;
}
function completeReplaceUploadHandler(event) {
	var response = event.target.responseXML.documentElement;
	if (response) { response = cleanXML(response); }
	var erreur = T$$("err",response)[0].firstChild.nodeValue;
	var msg = T$$("msg",response)[0].firstChild.nodeValue;
	if (erreur == "true") {
		T$("upStatus").innerHTML = langdata.processerr;
		T$("upResult").innerHTML = msg;
	} else {
		T$("upStatus").innerHTML = langdata.processend;
		var myimg = T$("pic_"+T$("upId").value);
		myimg.src=myimg.src+'?'+Math.random();
		T$("upBtnClose").style.display = "inline";
	}
	TINY.box.dim();
}
function completeUploadHandler(event) {
	var response = event.target.responseXML.documentElement;
	if (response) { response = cleanXML(response); }
	var erreur = T$$("err",response)[0].firstChild.nodeValue;
	var msg = T$$("msg",response)[0].firstChild.nodeValue;
	if (erreur == "true") {
		T$("upStatus").innerHTML = langdata.processerr;
		T$("upResult").innerHTML = msg;
	} else {
		T$("upStatus").innerHTML = langdata.processend;
		var type=T$("upType").value;
		if (type==0) {
			var salle = T$("upIdParent").value;
			var div = T$("containPhotos");
			while (div.childNodes.length>0) { div.removeChild(div.lastChild); }
			var xhr=new XMLHttpRequest();
			xhr.onreadystatechange=function(){
				if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
				if (xhr.readyState==4 && xhr.status==200) {
					div.innerHTML = xhr.responseText;
					showAdmin(false);
				}
			};
			xhr.open("POST","ajax_album_photo.jsp",true);
			xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhr.send("salle="+salle);
		} else if (type==1) {
			var baietype = T$("upName").value;
			var baiename = T$("upBaieName").value;
			var baieid = T$("upIdParent").value;
			var div = T$(baieid+"_"+baietype);
			while (div.childNodes.length>0) { div.removeChild(div.lastChild); }
			var xhr=new XMLHttpRequest();
			xhr.onreadystatechange=function(){
				if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
				if (xhr.readyState==4 && xhr.status==200) {
					div.innerHTML = xhr.responseText;
					if ((baietype=="VH"||baietype=="VB") && !T$("sens_"+baieid)) {
						div = T$("caption_"+baieid);
						var p = document.createElement("p");
						p.className = "text";
						p.id = "sens_"+baieid;
						p.addEventListener("click",function(){SwitchView(event,baieid);},false);
						p.appendChild(document.createTextNode(" ("+langdata.recto+")"));
						div.appendChild(p);
					}
					showAdmin(false);
				}
			};
			xhr.open("POST","ajax_album_baie.jsp",true);
			xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhr.send("baieid="+baieid+"&baiename="+baiename+"&baietype="+baietype);
		}
	}
	T$("upBtnClose").style.display = "inline";
	TINY.box.dim();
}
function submitReplaceUpload() {
	var f = T$("fReplaceUpload");
	if (f.file.value != "") {
		T$("upBtnUpload").style.display = "none";
		T$("upFile").style.display = "none";
		T$("upProgress").style.display = "inline";
		T$("upStatus").innerHTML = langdata.upbegin;
		TINY.box.dim();
		var file = T$("upFile").files[0];
		var dir = T$("upDir").value;
		var suf = T$("upSuf").value;
		var id = T$("upId").value;
		var formdata = new FormData();
		formdata.append("dir",dir);
		formdata.append("suf",suf);
		formdata.append("id",id);
		formdata.append("file", file);
		var ajax = new XMLHttpRequest();
		ajax.upload.addEventListener("progress", progressHandler, false);
		ajax.addEventListener("load", completeReplaceUploadHandler, false);
		ajax.addEventListener("error", errorHandler, false);
		ajax.addEventListener("abort", abortHandler, false);
		ajax.open("POST", "../replaceupload");
		ajax.send(formdata);
	}
}
function submitUpload() {
	var f = T$("fUpload");
	if (f.file.value != "") {
		T$("upBtnUpload").style.display = "none";
		T$("upFile").style.display = "none";
		T$("upProgress").style.display = "inline";
		T$("upStatus").innerHTML = langdata.upbegin;
		TINY.box.dim();
		var file = T$("upFile").files[0];
		var type = T$("upType").value;
		var idparent = T$("upIdParent").value;
		var name = T$("upName").value;
		var formdata = new FormData();
		formdata.append("type",type);
		formdata.append("idparent",idparent);
		formdata.append("name",name);
		formdata.append("file", file);
		var ajax = new XMLHttpRequest();
		ajax.upload.addEventListener("progress", progressHandler, false);
		ajax.addEventListener("load", completeUploadHandler, false);
		ajax.addEventListener("error", errorHandler, false);
		ajax.addEventListener("abort", abortHandler, false);
		ajax.open("POST", "../upload");
		ajax.send(formdata);
	}
}
function slideShowSalle(e,s) {
	e.stopPropagation();
	window.open("slideshow_room.jsp?salle="+s);
}
function slideShowBox(e,b,n) {
	e.stopPropagation();
	window.open("slideshow_box.jsp?box="+b+"&name="+n);
}
