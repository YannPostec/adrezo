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
function fillSurnet(id) {
	var rootli = T$("surli"+id);
	var cont = T$("surcontent"+id);
	if (rootli.dataset.filled == false) {
		rootli.dataset.filled = true;
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				var divwait = T$("wait"+id);
				cont.removeChild(divwait);
				var ul = document.createElement("ul");
				ul.className = "acc";
				ul.id = "acc"+id;
				ul.innerHTML = xhr.responseText;
				cont.appendChild(ul);
				var accname = "acc"+id;
				window[accname]=new TINY.accordion.slider(accname);
				window[accname].init(accname,"h3",0,-1);
				showAdmin(false);
			}
		};
		var divwait=document.createElement("div");
		divwait.id="wait"+id;
		var img=document.createElement("img");
		img.src = "../img/wait_bar.gif";
		img.alt = "WaitBar";
		img.width = 345;
		img.heigth = 21;
		divwait.appendChild(img);
		cont.appendChild(divwait);
		xhr.open("POST","ajax_norm_fill.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id);
	}
}
function delConfirm(e,id) {
	e.stopPropagation();
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function delSubmit(id) {
	DBAjax("ajax_surnet_delete.jsp","id="+id,true,function callback(result) {
		if (result) {
			var li = T$("surli"+id);
			while (li.childNodes.length > 0) { li.removeChild(li.lastChild); }
			li.parentNode.removeChild(li);
		}
	});
}
function addSubmit(e,id) {
	e.stopPropagation();
	TINY.box.show({url:'box_surnet_add.jsp',post:'parent='+id,openjs:function(){myedit()}});
}
function addRoot(e) {
	e.stopPropagation();
	TINY.box.show({url:'box_surnet_add.jsp',post:'parent=0',openjs:function(){myedit()}});
}
function lstSubmit(e,id) {
	e.stopPropagation();
	TINY.box.show({url:'box_surnet_lst.jsp',post:'id='+id});
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
function myedit() {
	var editor = new TINY.editor.edit('editor', {
	id: 'tinyeditor',
	width: 584,
	height: 175,
	cssclass: 'tinyeditor',
	controlclass: 'tinyeditor-control',
	rowclass: 'tinyeditor-header',
	dividerclass: 'tinyeditor-divider',
	controls: ['bold', 'italic', 'underline', 'strikethrough', '|', 'subscript', 'superscript', '|',
		'orderedlist', 'unorderedlist', '|', 'outdent', 'indent', '|', 'leftalign',
		'centeralign', 'rightalign', 'blockjustify', '|', 'unformat', '|', 'undo', 'redo', 'n',
		'font', 'size', 'style', '|', 'image', 'hr', 'link', 'unlink', '|'],
	footer: true,
	fonts: ['Verdana','Arial','Georgia','Trebuchet MS'],
	xhtml: true,
	bodyid: 'editor',
	footerclass: 'tinyeditor-footer',
	toggle: {text: 'source', activetext: 'wysiwyg', cssclass: 'toggle'},
	resize: {cssclass: 'resize'}
	});
	TINY.box.dim();
}
function modSubmit(e,id) {
	e.stopPropagation();
	TINY.box.show({url:'box_surnet_modif.jsp',openjs:function(){myedit()},post:'id='+id});
}		
function modValid(e) {
	var strAlert=[];
	var boxerror = T$("boxerror");
	while (boxerror.firstChild) { boxerror.removeChild(boxerror.firstChild); }
	var tds = T$$("td",T$("modRow"));
	var id = tds[0].firstChild.value;
	var ipr = tds[0].firstChild.nextSibling.value;
	var ip = renderip(ipr);
	var mask = tds[1].firstChild.value;
	var def = tds[2].firstChild.value;
	editor.post();
	var infos = T$("tinyeditor").value;
	var calc = tds[4].firstChild.checked?1:0;

	if (ip.length != 12) { strAlert.push("- "+langdata.ip+": "+langdata.verifip); }
	else if (!verifip(ip)) { strAlert.push("- "+langdata.ip+": "+langdata.verifippart); }
	if (mask == "" || isNaN(mask) || mask > 32 || mask < 2) { strAlert.push("- "+langdata.mask+": "+langdata.verifmask); }
	if (!def) { strAlert.push("- "+langdata.name+": "+langdata.verifnotnull); }
	else {
		if (def.indexOf("/") != -1) { strAlert.push("- "+langdata.name+": "+langdata.verifnoslash); }
		if (def.length > 500) { strAlert.push("- "+langdata.name+": "+langdata.verifsize+" : 100"); }
	}
	
	if (strAlert.length > 0) {
		var txt = document.createTextNode(langdata.invalidfield+" :");
		boxerror.appendChild(txt);
		for (var i=0;i<strAlert.length;i++) {
			var txt = document.createTextNode(strAlert[i]);
			var lb = document.createElement("br");
			boxerror.appendChild(lb);
			boxerror.appendChild(txt);
		}
		TINY.box.dim();
	} else {
		TINY.box.hide();
		DBAjax("ajax_surnet_update.jsp","id="+id+"&def="+def+"&infos="+infos+"&mask="+mask+"&ip="+ip+"&calc="+calc,true,function callback(result) {
			if (result) {
				T$("surh"+id).lastChild.data = " "+ipr+"/"+mask+" ("+def+")";
				T$("surinfos"+id).innerHTML = infos;
			}
		});
	}
}
function addValid(e) {
	var strAlert=[];
	var boxerror = T$("boxerror");
	while (boxerror.firstChild) { boxerror.removeChild(boxerror.firstChild); }
	var tds = T$$("td",T$("addRow"));
	var parent = tds[0].firstChild.value;
	var ipr = tds[0].firstChild.nextSibling.value;
	var ip = renderip(ipr);
	var mask = tds[1].firstChild.value;
	var def = tds[2].firstChild.value;
	editor.post();
	var infos = T$("tinyeditor").value;
	var calc = tds[4].firstChild.checked?1:0;

if (ip.length != 12) { strAlert.push("- "+langdata.ip+": "+langdata.verifip); }
	else if (!verifip(ip)) { strAlert.push("- "+langdata.ip+": "+langdata.verifippart); }
	if (mask == "" || isNaN(mask) || mask > 32 || mask < 2) { strAlert.push("- "+langdata.mask+": "+langdata.verifmask); }
	if (!def) { strAlert.push("- "+langdata.name+": "+langdata.verifnotnull); }
	else {
		if (def.indexOf("/") != -1) { strAlert.push("- "+langdata.name+": "+langdata.verifnoslash); }
		if (def.length > 500) { strAlert.push("- "+langdata.name+": "+langdata.verifsize+" : 100"); }
	}
	
	if (strAlert.length > 0) {
		var txt = document.createTextNode(langdata.invalidfield+" :");
		boxerror.appendChild(txt);
		for (var i=0;i<strAlert.length;i++) {
			var txt = document.createTextNode(strAlert[i]);
			var lb = document.createElement("br");
			boxerror.appendChild(lb);
			boxerror.appendChild(txt);
		}
		TINY.box.dim();
	} else {
		TINY.box.hide();
		if (parent==0) {
			DBAjax("ajax_surnet_store.jsp","ip="+ip+"&def="+def+"&infos="+infos+"&mask="+mask+"&parent="+parent+"&calc="+calc,false);
		} else {
			DBAjax("ajax_surnet_store.jsp","ip="+ip+"&def="+def+"&infos="+infos+"&mask="+mask+"&parent="+parent+"&calc="+calc,true,function callback(result) {
				if (result) {
					if (T$("surli"+parent).dataset.filled!=0) {
						T$("surli"+parent).dataset.filled=0;
						T$("surcontent"+parent).removeChild(T$("acc"+parent));
					}
					fillSurnet(parent);
				}
			});
		}
	}
}
function lstValid(e) {
	var id = T$("sel_lst_id").value;
	var sellist = T$("sel_lst_sub_choisi");
	var list="(";
	for (var i=0;i<sellist.options.length;i++) {
		list+=sellist.options[i].value;
		if (i<sellist.options.length-1) { list+=","; }
	}
	list+=")";
	TINY.box.hide();
	DBAjax("ajax_surnet_lst_update.jsp","id="+id+"&list="+list,true,function callback(result) {
		if (result) {
			if (T$("surli"+id).dataset.filled!=0) {
				T$("surli"+id).dataset.filled=0;
				T$("surcontent"+id).removeChild(T$("acc"+id));
			}
			fillSurnet(id);
		}
	});
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
				var divwait=T$("box_surnet_wait");
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
		var divwait=T$("box_surnet_wait");
		while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
		var img=document.createElement("img");
		img.src = "../img/wait_bar.gif";
		img.alt = "WaitBar";
		img.width = 345;
		img.heigth = 21;
		divwait.appendChild(img);
		xhr.open("POST","ajax_surnet_lst_fillsite.jsp",true);
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
			var divwait=T$("box_surnet_wait");
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
	var divwait=T$("box_surnet_wait");
	while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	xhr.open("POST","ajax_surnet_lst_fillsub.jsp",true);
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
function calcSubmit(e,id) {
	e.stopPropagation();
	TINY.box.show({url:'box_surnet_calc.jsp',post:'id='+id});
}
function verifNet() {
	if (T$("box_surnet_ip").value&&T$("box_surnet_mask").value) {
		var myIP = new IPv4_Address(T$("box_surnet_ip").value,T$("box_surnet_mask").value);
		if (T$("box_surnet_ip").value != myIP.netaddressDotQuad) { T$("boxwarn").style.display = "inline"; }
		else { T$("boxwarn").style.display = "none"; }
	}
}
function calcLoad(id) {
	T$("calc_invalid").style.display = "none";
	var t = T$("table").tBodies[0];
	while (t.childNodes.length>0) {t.removeChild(t.firstChild);}
	var divwait = T$("calc_wait");
	var diverr = T$("calc_err");
	var calcmask = parseInt(T$("calc_mask").value);
	var surmask = parseInt(T$("calc_surmask").value);
	if (calcmask == "" || isNaN(calcmask) || calcmask > 32 || calcmask < 2 || calcmask <= surmask) { T$("calc_invalid").style.display = "inline"; }
	else {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1);
			}
			if (xhr.readyState==4 && xhr.status==200) {
				while (divwait.childNodes.length > 0) { divwait.removeChild(divwait.lastChild); }
				while (diverr.childNodes.length > 0) { diverr.removeChild(diverr.lastChild); }
				var response = xhr.responseXML.documentElement;
				if (response) {
					response = cleanXML(response);
					var err = T$$("err",response)[0].firstChild.nodeValue;
					if (err == "false") {
						var m = T$$("sub",response);
						if (m.length) {
							for (var i=0;i<m.length;i++) {
								var sub = m[i].firstChild.nodeValue;
								var mytr = T$("table").tBodies[0].insertRow(-1);
								var mytd = mytr.insertCell(-1);
								mytd.appendChild(document.createTextNode(sub));
							}
							sortiny.init();
						} else {
							diverr.innerHTML = langdata.calcnosub;
						}
					} else {
						var erreur = T$$("msg",response)[0].firstChild.nodeValue;
						diverr.innerHTML = langdata.error+" : "+erreur;
					}
				} else {
					diverr.innerHTML = langdata.xhrerror;
				}
				TINY.box.dim();
			}
		};
		var img=document.createElement("img");
		img.src = "../img/wait_bar.gif";
		img.alt = "WaitBar";
		img.width = 345;
		img.heigth = 21;
		divwait.appendChild(img);
		TINY.box.dim();
		xhr.open("POST","../normcalc",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id+"&mask="+calcmask);
	}
}
