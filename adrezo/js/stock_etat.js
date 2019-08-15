//@Author: Yann POSTEC
function ConfirmDlg(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	var id = tds[1].firstChild.value;
	var ec = T$("user_stock").value=="true"?tds[7].firstChild.value:tds[6].firstChild.value;
	showDialog(langdata.confirm,langdata.stkrecep+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:ReceptionCommande("+id+","+ec+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function ChangeEtat() {
	var t = T$$("tr",T$("mytbody"));
	var invent = T$("chkInventaire")?T$("chkInventaire").checked:false;
	var variations = "";
	var strAlert = "";
	
	for (var i=0;i<t.length;i++) {
		var variation = t[i].cells[5].firstChild.value;
		if (variation != "" && (isNaN(variation) || variation == 0)) { strAlert += variation+": "+langdata.verifvariation+"<br />"; }
	}
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		for (var i=0;i<t.length;i++) {
			var id = t[i].cells[1].firstChild.value;
			var variation = t[i].cells[5].firstChild.value;
			if (variation != "" && !isNaN(variation) && variation != 0) {
				if (variations != "") { variations += "&"; }
				variations += "var" + id + "=" + variation;
			}
		}
		var myelt = "inv=" + invent;
		if (variations != "") { myelt += "&" + variations; }
		DBAjax("ajax_stock_change.jsp",myelt,true,function callback(result) {
			if (result) {
				window.location.search = '?site='+T$("selSite").value;
			}
		});
	}
}
function ReceptionCommande(id,ec) {
	if (id) {
		DBAjax("ajax_stock_reception.jsp","id="+id+"&ec="+ec,true,function callback(result) {
			if (result) {
				window.location.search = '?site='+T$("selSite").value;
			}
		});
	}	
}
function ShowBox(e) {
	var node = e.target;
	var id = node.parentNode.parentNode.nextSibling.firstChild.value;
	var limit = T$("limit").value;
	if (isNaN(limit)) { showDialog(langdata.processerr+": ",langdata.stklimit,"error",0,1); }
	else {
		TINY.box.show({url:'stock_mvt.jsp',post:'type='+id+'&limit='+limit});
	}
}
function goMainSite(site) {
	T$("selSite").value=site;
	changeStock();
}
function changeStock() {
	T$("sqs_special").value=T$("selSite").value;
	T$("sqs_search").value="";
	sortTable();
}
function fillTable(sqlid,limit,offset,search,searchip,order,sqlsort,special) {
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
					var encours=0;
					var seuil=0;
					var stock=0;
					if (T$$("encours",lines[i])[0].hasChildNodes()) { encours=Number(T$$("encours",lines[i])[0].firstChild.nodeValue); }
					if (T$$("seuil",lines[i])[0].hasChildNodes()) { seuil=Number(T$$("seuil",lines[i])[0].firstChild.nodeValue); }
					if (T$$("stock",lines[i])[0].hasChildNodes()) { stock=Number(T$$("stock",lines[i])[0].firstChild.nodeValue); }
					if (T$$("cat",lines[i])[0].hasChildNodes() && T$$("id",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("id",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						mytd.appendChild(document.createTextNode(T$$("cat",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("idx",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("idx",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }					
					if (T$$("def",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.appendChild(document.createTextNode(T$$("def",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("stock",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						if (stock+encours < seuil) {
							mytd.style.color = "#ff0000";
							mytd.style.fontWeight = "bold";
						}
						mytd.appendChild(document.createTextNode(T$$("stock",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$("user_stock").value=="true") {
						var mytd = mytr.insertCell(-1);
						var ipt = document.createElement("input");
						ipt.type="text";
						ipt.size=5;
						ipt.value="";
						mytd.appendChild(ipt);
					}
					if (T$$("seuil",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						mytd.appendChild(document.createTextNode(T$$("seuil",lines[i])[0].firstChild.nodeValue));
					} else { mytr.insertCell(-1); }
					if (T$$("encours",lines[i])[0].hasChildNodes()) {
						var mytd = mytr.insertCell(-1);
						mytd.style.textAlign = "center";
						var hid = document.createElement("input");
						hid.type = "hidden";
						hid.value = T$$("encours",lines[i])[0].firstChild.nodeValue;
						mytd.appendChild(hid);
						if (encours!=0) {
							mytd.appendChild(document.createTextNode(T$$("encours",lines[i])[0].firstChild.nodeValue+" "));
							if (T$("user_stockad").value=="true") {
								var shadowspan = T$("spanshadow").firstChild.cloneNode(true);
								mytd.appendChild(shadowspan);
							}
						}
					} else { mytr.insertCell(-1); }
					if (T$("user_stock").value=="true") {
						var shadowtd = T$("tdshadow").cloneNode(true);
						shadowtd.removeAttribute("id");
						mytr.appendChild(shadowtd);
					}
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
	xhr.send("id="+sqlid+"&limit="+limit+"&offset="+offset+"&search="+search+"&searchip="+searchip+"&order="+order+"&sort="+sqlsort+"&special="+special);
}
function SwitchSearch(i) {
		switch(i) {
			case 1: T$("sqs_order").value="cat";break;
			case 2: T$("sqs_order").value="idx";break;
			case 3: T$("sqs_order").value="def";break;
			case 4: T$("sqs_order").value="stock";break;
			case 6: T$("sqs_order").value="seuil";break;
			case 7: T$("sqs_order").value="encours";break;
		}
}
