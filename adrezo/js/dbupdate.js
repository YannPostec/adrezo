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
function handleEnter(field,event,list) {
	var keyCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	if (keyCode == 13) { updateDB(list); return false; }
	else { return true; }
}
function updateDB(l) {
	T$("errorP").innerHTML = "";
	if (T$("upPwd").value != "") {
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { T$("errorP").innerHTML = T$("errorTxt").value+" : "+xhr.status+", "+xhr.statusText; }
			if (xhr.readyState==4 && xhr.status==200) {
				response = xhr.responseText;
				if (response == "password_ok") {
					var bNext = true;
					T$("upBtn").style.display="none";
					var arrl = l.split(",");
					for (var i=0;i<arrl.length && bNext;i++) {
						bNext = upVersion(arrl[i]);
					}
					T$("returnBtn").style.display="inline";
				}	else {
					T$("errorP").innerHTML = T$("errorTxt").value + " : " + T$("pwdTxt").value;
				}
			}
		};
		xhr.open("POST","updatepwd.jsp",false);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("pwd="+T$("upPwd").value);
	}
}
function createP(v,msg,err) {
	T$("ver"+v).removeChild(T$("wait"+v));
	var p=document.createElement("p");
	if (err) { p.className = "err"; } else { p.className = "ok"; }
	p.innerHTML += msg;
	T$("ver"+v).appendChild(p);
	return err?false:true;
}
function upVersion(v) {
	var bNext = false;
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { bNext = createP(v,T$("errorTxt").value+" : "+xhr.status+", "+xhr.statusText,true); }
		if (xhr.readyState==4 && xhr.status==200) {
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
				var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
				var msg = T$$("msg",response)[0].firstChild.nodeValue;
				if (erreur == "true") { bNext = createP(v,T$("errorTxt").value+" : "+msg,true);
				} else { bNext = createP(v,msg,false); }
			} else { bNext = createP(v,T$("errorTxt").value+" : "+T$("xmlTxt").value,true); }
		}
	};
	var img=document.createElement("img");
	img.id = "wait"+v;
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	var diver=document.createElement("div");
	diver.id="ver"+v;
	var pver=document.createElement("p");
	pver.className = "ver";
	pver.innerHTML = T$("processTxt").value+" "+v;
	diver.appendChild(pver);
	diver.appendChild(img);
	T$("upResult").appendChild(diver);
	xhr.open("POST","sqlupdate_"+v+".jsp",false);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send();
	return bNext;
}
