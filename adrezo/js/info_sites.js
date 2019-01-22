//@Author: Yann POSTEC
function fillTable(sqlid,limit,offset,search,order,sqlsort) {
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
					if (T$$("id",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("id",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("ctx_name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("ctx_name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("cod_site",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("cod_site",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
					if (T$$("name",lines[i])[0].hasChildNodes()) { mytr.insertCell(-1).appendChild(document.createTextNode(T$$("name",lines[i])[0].firstChild.nodeValue)); } else { mytr.insertCell(-1); }
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
	xhr.send("id="+sqlid+"&limit="+limit+"&offset="+offset+"&search="+search+"&order="+order+"&sort="+sqlsort);
}
function SwitchSearch(i) {
		switch(i) {
			case 0: T$("sqs_order").value="id";break;
			case 1: T$("sqs_order").value="ctx_name";break;
			case 2: T$("sqs_order").value="cod_site";break;
			case 3: T$("sqs_order").value="name";break;
		}
}
