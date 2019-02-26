//@Author: Yann POSTEC
function fillTable(sqlid,limit,offset,search,searchip,order,sqlsort) {
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
					var mytr = T$("tableinfos").tBodies[0].insertRow(-1);
					if (T$$("ctx_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("ctx_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("site_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("site_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("subnet_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("subnet_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("ptype_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("ptype_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("pid",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("pid",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("ip",lines[i])[0].hasChildNodes()&&T$$("mask",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(displayip(T$$("ip",lines[i])[0].firstChild.nodeValue)+"/"+T$$("mask",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("ip_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("ip_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
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
	xhr.send("id="+sqlid+"&limit="+limit+"&offset="+offset+"&search="+search+"&searchip="+searchip+"&order="+order+"&sort="+sqlsort);
}
function SwitchSearch(i) {
		switch(i) {
			case 0: T$("sqs_order").value="ctx_name";break;
			case 1: T$("sqs_order").value="site_name";break;
			case 2: T$("sqs_order").value="subnet_name";break;
			case 3: T$("sqs_order").value="ptype_name";break;
			case 4: T$("sqs_order").value="pid";break;
			case 5: T$("sqs_order").value="ip";break;
			case 6: T$("sqs_order").value="ip_name";break;
		}
}
