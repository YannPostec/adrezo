//@Author: Yann POSTEC
var addsortiny = new TINY.table.sorter('addsortiny','addtable',{
		headclass:'head',
		ascclass:'asc',
		descclass:'desc',
		evenclass:'evenrow',
		oddclass:'oddrow',
		evenselclass:'evenselected',
		oddselclass:'oddselected',
		paginate:true,
		size:10,
		currentid:'addcurrentpage',
		totalid:'addtotalpages',
		startingrecid:'addstartrecord',
		endingrecid:'addendrecord',
		totalrecid:'addtotalrecords',
		hoverid:'selectedrow',
		navid:'addtablenav',
		init:false
	});
function ResetAdd() {
	T$("add_id").value = "";
	T$("add_hostname").value = "";
	T$("add_port").value = "";
	T$("add_login").value = "";
	T$("add_pwd").value = "";
	T$("add_type").selectedIndex = 0;
	T$("add_ssl").selectedIndex = 0;
	T$("add_auth").selectedIndex = 0;
	T$("add_enable").selectedIndex = 0;
}
function ConfirmDlg(id) {
	showDialog(langdata.confirm,langdata.objdel+"<br/><br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+id+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function addSubmit() {
	var strAlert="";
	var selecttype = T$("add_type");
	var selectssl = T$("add_ssl");
	var selectauth = T$("add_auth");
	var selectenable = T$("add_enable");
	var type = selecttype.value;
	var ssl = selectssl.value;
	var auth = selectauth.value;
	var id = T$("add_id").value;
	var hostname = T$("add_hostname").value;
	var port = T$("add_port").value;
	var login = T$("add_login").value;
	var pwd = T$("add_pwd").value;
	var enable = selectenable.value;

	if (selecttype.selectedIndex == 0) { strAlert += "- "+langdata.type+": "+langdata.verifchoose+"<br />"; }	
	if (!port || isNaN(port) || port < 0) { strAlert += "- "+langdata.port+": "+langdata.verifnumber+"<br />"; }
	if (!hostname) { strAlert += "- "+langdata.name+": "+langdata.verifnotnull+"<br />"; }
	else if (hostname.length > 50) { strAlert += "- "+langdata.name+": "+langdata.verifsize+" : 50<br />"; }
	if (selectauth.selectedIndex == 1) {
		if (!login) { strAlert += "- "+langdata.login+": "+langdata.verifnotnull+"<br />"; }
		else if (login.length > 64) { strAlert += "- "+langdata.login+": "+langdata.verifsize+" : 64<br />"; }
		if (pwd && pwd.length > 64) { strAlert += "- "+langdata.pwd+": "+langdata.verifsize+" : 64<br />"; }
	}
	
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_dhcp_store.jsp","id="+id+"&hostname="+hostname+"&port="+port+"&login="+login+"&pwd="+pwd+"&type="+type+"&ssl="+ssl+"&auth="+auth+"&enable="+enable);
	}
}
function delSubmit(id) {
	DBAjax("ajax_dhcp_delete.jsp","id="+id);
}
function sendModif(e) {
	var node = e.target;
	var tds = T$$("td",node.parentNode.parentNode.parentNode);
	T$("add_type").value = tds[1].firstChild.value;
	T$("add_id").value = tds[2].firstChild.value;
	T$("add_hostname").value = tds[2].firstChild.nextSibling.nodeValue;
	T$("add_port").value = tds[3].firstChild.nodeValue;
	T$("add_ssl").value = tds[4].firstChild.value;
	T$("add_auth").value = tds[5].firstChild.value;
	T$("add_login").value = tds[6].firstChild?tds[6].firstChild.nodeValue:"";
	T$("add_pwd").value = "";
	T$("add_enable").value = tds[8].firstChild.value;
}
function defaultTypePort() {
	if (T$("add_type").selectedIndex > 0) {
		T$("add_port").value = typedefaultport[T$("add_type").value];
	}
}
function addExclu(id,name) {
	TINY.box.show({url:'box_dhcp_addexclu.jsp',openjs:function(){ExcluLoad(id)},post:'id='+id+'&name='+name});
}
function listExclu(id,name) {
	TINY.box.show({url:'box_dhcp_listexclu.jsp',openjs:function(){TINY.box.dim()},post:'id='+id+'&name='+name});
}
function listValid(id) {
	TINY.box.hide();
	DBAjax("ajax_dhcp_listexclu.jsp","id="+id);
}
function addValid(e) {
	var node=e.target;
	var srv=node.parentNode.firstChild.value;
	var scope=node.parentNode.firstChild.nextSibling.value;
	TINY.box.hide();
	DBAjax("ajax_dhcp_addexclu.jsp","srv="+srv+"&scope="+scope);
}
function ExcluLoad(id) {
	var divwait = T$("addexclu_wait");
	var diverr = T$("addexclu_err");
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
					var m = T$$("scope",response);
					if (m.length) {
						for (var i=0;i<m.length;i++) {
							var scope = m[i].firstChild.nodeValue;
							var mytr = T$("addtable").tBodies[0].insertRow(-1);
							var mytd = mytr.insertCell(-1);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = id;
							mytd.appendChild(ipt);
							var ipt = document.createElement("input");
							ipt.type = "hidden";
							ipt.value = scope;
							mytd.appendChild(ipt);
							var img = document.createElement("img");
							img.src = "../img/icon_valid.png";
							img.alt = "Select Scope";
							img.addEventListener("click",addValid,false);
							mytd.appendChild(img);
							var mytd = mytr.insertCell(-1);
							mytd.appendChild(document.createTextNode(scope));
						}
						addsortiny.init();
					} else {
						diverr.innerHTML = langdata.dhcpscopeno;
					}
				} else {
					var erreur = T$$("msg",response)[0].firstChild.nodeValue;
					diverr.innerHTML = langdata.dhcpscopeerror+" : "+erreur;
				}
			} else {
				diverr.innerHTML = langdata.dhcpscopeerror;
			}
			TINY.box.dim();
		}
	};
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	var txt = document.createTextNode(langdata.dhcpscopewait);
	divwait.appendChild(txt);
	divwait.appendChild(document.createElement("br"));
	divwait.appendChild(img);
	TINY.box.dim();
	xhr.open("POST","../dhcpscope",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("id="+id);
}
