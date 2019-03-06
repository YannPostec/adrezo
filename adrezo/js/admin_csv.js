//@Author: Yann POSTEC
function progressHandler(event){
	var percent = (event.loaded / event.total) * 25;
	T$("upProgress").value = Math.round(percent);
	T$("upStatus").innerHTML = langdata.upload+" : "+Math.round(percent)+"%";
	if (percent==25) { T$("upStatus").innerHTML = langdata.upend; }
}
function errorHandler(event){
	T$("upStatus").innerHTML = langdata.uperr;
	T$("upError").innerHTML = event.target.status+" : "+event.target.statusText;
	T$("upBtnReset").style.display = "inline";
}
function abortHandler(event){
	T$("upStatus").innerHTML = langdata.upcancel;
	T$("upBtnReset").style.display = "inline";
}
function completeUploadHandler(event) {
	var response = event.target.responseXML.documentElement;
	if (response) { response = cleanXML(response); }
	var erreur = T$$("err",response)[0].firstChild.nodeValue;
	var msg = T$$("msg",response)[0].firstChild.nodeValue;
	if (erreur == "true") {
		T$("upStatus").innerHTML = langdata.analyserr;
		T$("upError").innerHTML = msg;
		T$("upBtnReset").style.display = "inline";
	} else {
		T$("upStatus").innerHTML = langdata.analysend;
		T$("upResult").innerHTML = msg+"<br />";
		var contextes = T$$("ctx",response);
		var sites = T$$("site",response);
		var subnets = T$$("subnet",response);
		var vlans = T$$("vlan",response);
		var ips = T$$("ip",response);
		T$("upStatus").innerHTML = langdata.process+" "+langdata.ctx;
		if (contextes.length) {
			var mycpt = new Array();
			var aelt = new Array();
			for (i=0;i<contextes.length;i++) {
				var id="id"+i+"="+T$$("ctxid",contextes[i])[0].firstChild.nodeValue;
				var name="&name"+i+"="+T$$("ctxname",contextes[i])[0].firstChild.nodeValue;
				mycpt[i]=i;
				aelt[i]=id+name;
			}
			var myelt = "listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhrctx=new XMLHttpRequest();
			xhrctx.onreadystatechange=function(){
				if (xhrctx.readyState==4 && xhrctx.status!=200) {
					T$("upError").innerHTML = langdata.error+": "+xhrctx.status+". "+xhrctx.statusText;
					T$("upBtnReset").style.display = "inline";
				}
				if (xhrctx.readyState==4 && xhrctx.status==200) {
					T$("upResult").innerHTML += xhrctx.responseText;
					T$("upProgress").value += 15;
				}
			};
			xhrctx.open("POST","ajax_csv_ctx.jsp",false);
			xhrctx.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhrctx.send(myelt);
		} else { T$("upProgress").value += 15; }
		T$("upStatus").innerHTML = langdata.process+" "+langdata.site;
		if (sites.length) {
			var mycpt = new Array();
			var aelt = new Array();
			for (i=0;i<sites.length;i++) {
				var id="id"+i+"="+T$$("siteid",sites[i])[0].firstChild.nodeValue;
				var ctx="&ctx"+i+"="+T$$("sitectx",sites[i])[0].firstChild.nodeValue;
				var cod="&cod"+i+"="+T$$("sitecod",sites[i])[0].firstChild.nodeValue;
				var name="&name"+i+"="+T$$("sitename",sites[i])[0].firstChild.nodeValue;
				mycpt[i]=i;
				aelt[i]=id+ctx+cod+name;
			}
			var myelt = "listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhrsite=new XMLHttpRequest();
			xhrsite.onreadystatechange=function(){
				if (xhrsite.readyState==4 && xhrsite.status!=200) {
					T$("upError").innerHTML = langdata.error+": "+xhrsite.status+". "+xhrsite.statusText;
					T$("upBtnReset").style.display = "inline";
				}
				if (xhrsite.readyState==4 && xhrsite.status==200) {
					T$("upResult").innerHTML += xhrsite.responseText;
					T$("upProgress").value += 15;
				}
			};
			xhrsite.open("POST","ajax_csv_site.jsp",false);
			xhrsite.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhrsite.send(myelt);
		} else { T$("upProgress").value += 15; }
		T$("upStatus").innerHTML = langdata.process+" "+langdata.vlan;
		if (vlans.length) {
			var mycpt = new Array();
			var aelt = new Array();
			for (i=0;i<vlans.length;i++) {
				var id="id"+i+"="+T$$("vlanid",vlans[i])[0].firstChild.nodeValue;
				var site="&site"+i+"="+T$$("vlansite",vlans[i])[0].firstChild.nodeValue;
				var vid="&vid"+i+"="+T$$("vlanvid",vlans[i])[0].firstChild.nodeValue;
				var def="&def"+i+"="+T$$("vlanname",vlans[i])[0].firstChild.nodeValue;
				mycpt[i]=i;
				aelt[i]=id+site+vid+def;
			}
			var myelt = "listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhrvlan=new XMLHttpRequest();
			xhrvlan.onreadystatechange=function(){
				if (xhrvlan.readyState==4 && xhrvlan.status!=200) {
					T$("upError").innerHTML = langdata.error+": "+xhrvlan.status+". "+xhrvlan.statusText;
					T$("upBtnReset").style.display = "inline";
				}
				if (xhrvlan.readyState==4 && xhrvlan.status==200) {
					T$("upResult").innerHTML += xhrvlan.responseText;
					T$("upProgress").value += 15;
				}
			};
			xhrvlan.open("POST","ajax_csv_vlan.jsp",false);
			xhrvlan.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhrvlan.send(myelt);
		} else { T$("upProgress").value += 15; }		
		T$("upStatus").innerHTML = langdata.process+" "+langdata.subnet;
		if (subnets.length) {
			var mycpt = new Array();
			var aelt = new Array();
			for (i=0;i<subnets.length;i++) {
				var id="id"+i+"="+T$$("subnetid",subnets[i])[0].firstChild.nodeValue;
				var ctx="&ctx"+i+"="+T$$("subnetctx",subnets[i])[0].firstChild.nodeValue;
				var site="&site"+i+"="+T$$("subnetsite",subnets[i])[0].firstChild.nodeValue;
				var vlan="&vlan"+i+"="+T$$("subnetvlan",subnets[i])[0].firstChild.nodeValue;
				var ip="&ip"+i+"="+T$$("subnetip",subnets[i])[0].firstChild.nodeValue;
				var mask="&mask"+i+"="+T$$("subnetmask",subnets[i])[0].firstChild.nodeValue;
				var def="&def"+i+"="+T$$("subnetname",subnets[i])[0].firstChild.nodeValue;
				var gw=(T$$("subnetgw",subnets[i])[0].childNodes.length>0)?"&gw"+i+"="+T$$("subnetgw",subnets[i])[0].firstChild.nodeValue:"&gw"+i+"=";
				var bc="&bc"+i+"="+T$$("subnetbc",subnets[i])[0].firstChild.nodeValue;
				mycpt[i]=i;
				aelt[i]=id+ctx+site+vlan+ip+mask+def+gw+bc;
			}
			var myelt = "listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhrsubnet=new XMLHttpRequest();
			xhrsubnet.onreadystatechange=function(){
				if (xhrsubnet.readyState==4 && xhrsubnet.status!=200) {
					T$("upError").innerHTML = langdata.error+": "+xhrsubnet.status+". "+xhrsubnet.statusText;
					T$("upBtnReset").style.display = "inline";
				}
				if (xhrsubnet.readyState==4 && xhrsubnet.status==200) {
					T$("upResult").innerHTML += xhrsubnet.responseText;
					T$("upProgress").value += 15;
				}
			};
			xhrsubnet.open("POST","ajax_csv_subnet.jsp",false);
			xhrsubnet.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhrsubnet.send(myelt);
		} else { T$("upProgress").value += 15; }				
		T$("upStatus").innerHTML = langdata.process+" "+langdata.ip;
		if (ips.length) {
			var mycpt = new Array();
			var aelt = new Array();
			for (i=0;i<ips.length;i++) {
				var id="id"+i+"="+T$$("ipid",ips[i])[0].firstChild.nodeValue;
				var ctx="&ctx"+i+"="+T$$("ipctx",ips[i])[0].firstChild.nodeValue;
				var site="&site"+i+"="+T$$("ipsite",ips[i])[0].firstChild.nodeValue;
				var subnet="&subnet"+i+"="+T$$("ipsubnet",ips[i])[0].firstChild.nodeValue;
				var ip="&ip"+i+"="+T$$("ipip",ips[i])[0].firstChild.nodeValue;
				var mask="&mask"+i+"="+T$$("ipmask",ips[i])[0].firstChild.nodeValue;
				var name="&name"+i+"="+T$$("ipname",ips[i])[0].firstChild.nodeValue;
				var def=(T$$("ipdef",ips[i])[0].childNodes.length>0)?"&def"+i+"="+T$$("ipdef",ips[i])[0].firstChild.nodeValue:"&def"+i+"=";
				var mac=(T$$("ipmac",ips[i])[0].childNodes.length>0)?"&mac"+i+"="+T$$("ipmac",ips[i])[0].firstChild.nodeValue:"&mac"+i+"=";
				mycpt[i]=i;
				aelt[i]=id+ctx+site+subnet+ip+mask+name+def+mac;
			}
			var myelt = "listCpt=" + mycpt.join(",") + "&" + aelt.join("&");
			var xhrip=new XMLHttpRequest();
			xhrip.onreadystatechange=function(){
				if (xhrip.readyState==4 && xhrip.status!=200) {
					T$("upError").innerHTML = langdata.error+": "+xhrip.status+". "+xhrip.statusText;
					T$("upBtnReset").style.display = "inline";
				}
				if (xhrip.readyState==4 && xhrip.status==200) {
					T$("upResult").innerHTML += xhrip.responseText;
					T$("upProgress").value += 15;
				}
			};
			xhrip.open("POST","ajax_csv_ip.jsp",false);
			xhrip.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhrip.send(myelt);
		} else { T$("upProgress").value += 15; }				
		T$("upStatus").innerHTML = langdata.processend;
		T$("upBtnReset").style.display = "inline";
	}
}
function submitUpload() {
	var f = T$("fUpload");
	if (f.file.value != "") {
		if (T$("upFile").files[0].size < 5242880) {
			T$("upBtnUpload").style.display = "none";
			T$("upFile").style.display = "none";
			T$("upProgress").style.display = "inline";
			T$("upStatus").innerHTML = langdata.upbegin;
			var formdata = new FormData();
			formdata.append("file", T$("upFile").files[0]);
			var ajax = new XMLHttpRequest();
			ajax.upload.addEventListener("progress", progressHandler, false);
			ajax.addEventListener("load", completeUploadHandler, false);
			ajax.addEventListener("error", errorHandler, false);
			ajax.addEventListener("abort", abortHandler, false);
			ajax.open("POST", "../importcsv");
			ajax.send(formdata);
		} else {
			T$("upStatus").innerHTML = langdata.filesize;
		}
	}
}
function resetUpload() {
	T$("upBtnUpload").style.display = "inline";
	T$("upFile").style.display = "inline";
	T$("upProgress").style.display = "none";
	T$("upProgress").value = 0;
	T$("upStatus").innerHTML = "";
	T$("upResult").innerHTML = "";
	T$("upError").innerHTML = "";
	T$("upBtnReset").style.display = "none";
}
