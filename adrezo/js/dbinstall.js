//@Author: Yann POSTEC
function T$(i){return document.getElementById(i)}
function T$$(e,p){return p.getElementsByTagName(e)}
function cleanXML(d){
	var c=T$$('*',d);
	for(i=0;i<c.length;i++){
		a=c[i].previousSibling;
		if(a && a.nodeType==3 && !a.data.replace(/\s/g,'')) { a.parentNode.removeChild(a); }
		b=c[i].nextSibling;
		if(b && b.nodeType==3 && !b.data.replace(/\s/g,'')) { b.parentNode.removeChild(b); }
	}
	return d;
}
function returnLogin() {
	window.location.replace("../login.jsp");
}
function reloadPage() {
	window.location.reload(true);
}
function installDB() {
	var bNext = true;
	T$("installBtn").style.display="none";
	if (T$("checkTable").checked) { bNext = installSection('table');	}
	if (bNext && T$("checkPrimary").checked) { bNext = installSection('primary');	}
	if (bNext && T$("checkView").checked) { bNext = installSection('view');	}
	if (bNext && T$("checkData").checked) { bNext = installSection('data');	}
	if (bNext && T$("checkForeign").checked) { bNext = installSection('foreign');	}
	if (bNext && T$("checkSequence").checked) { bNext = installSection('sequence');	}
	if (bNext && T$("checkTrigger").checked) { bNext = installSection('trigger');	}
	bNext?T$("returnBtn").style.display="inline":T$("retryBtn").style.display="inline";
}
function createP(s,msg,err) {
	T$("div"+s).removeChild(T$("wait"+s));
	var p=document.createElement("p");
	if (err) { p.className = "err"; } else { p.className = "ok"; }
	p.innerHTML += msg;
	T$("div"+s).appendChild(p);
	return err?false:true;
}
function installSection(s) {
	var bNext = false;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { bNext = createP(s,T$("errorTxt").value+" : "+xhr.status+", "+xhr.statusText,true); }
		if (xhr.readyState==4 && xhr.status==200) {
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
				var msg = T$$("msg",response)[0].firstChild.nodeValue;
				if (erreur == "true") { bNext = createP(s,T$("errorTxt").value+" : "+msg,true);
				} else { bNext = createP(s,msg,false); }
			} else { bNext = createP(s,T$("errorTxt").value+" : "+T$("xmlTxt").value,true); }
		}
	};
	var img=document.createElement("img");
	img.id = "wait"+s;
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	T$("div"+s).style.display="inline";
	T$("div"+s).appendChild(img);
	xhr.open("POST","sqlinstall_"+s+".jsp",false);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send();
	return bNext;
}
