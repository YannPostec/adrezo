//@Author: Yann POSTEC
var langdata;
var xhrlang=new XMLHttpRequest();
xhrlang.onreadystatechange=function(){ if (xhrlang.readyState==4 && xhrlang.status==200) { langdata = JSON.parse(xhrlang.responseText); } };
xhrlang.open("POST","../ajax_js_lang.jsp",false);
xhrlang.setRequestHeader('Content-type','application/x-www-form-urlencoded');
xhrlang.send();
var TINY={};
function T$(i){return document.getElementById(i)}
function T$$(e,p){return p.getElementsByTagName(e)}
function T$$$(){return document.all?1 : 0}
function TC$(c){return document.getElementsByClassName(c);}
function TrimLZero(mys){return (mys.length>1&&mys.substring(0,1)=="0")?TrimLZero(mys.substring(1,mys.length)):mys}
function partIPValid(mypart){return (!isNaN(mypart)&&mypart>=0&&mypart<256)}
function AddLZero(mys){return (mys.length==1)?"00"+mys:(mys.length==2)?"0"+mys:mys;}
function AddNbZero(mynb){return (mynb<10)?"00"+mynb:(mynb>=10&&mynb<100)?"0"+mynb:mynb;}
function mask_bits(mask){var res;switch (mask) {case 2:res="192000000000";break;case 3:res="224000000000";break;case 4:res="240000000000";break;case 5:res="248000000000";break;case 6:res="252000000000";break;case 7:res="254000000000";break;case 8:res="255000000000";break;case 9:res="255128000000";break;case 10:res="255192000000";break;case 11:res="255224000000";break;case 12:res="255240000000";break;case 13:res="255248000000";break;case 14:res="255252000000";break;case 15:res="255254000000";break;case 16:res="255255000000";break;case 17:res="255255128000";break;case 18:res="255255192000";break;case 19:res="255255224000";break;case 20:res="255255240000";break;case 21:res="255255248000";break;case 22:res="255255252000";break;case 23:res="255255254000";break;case 24:res="255255255000";break;case 25:res="255255255128";break;case 26:res="255255255192";break;case 27:res="255255255224";break;case 28:res="255255255240";break;case 29:res="255255255248";break;case 30:res="255255255252";break;case 31:res="255255255254";break;case 32:res="255255255255";break;default:res="undef";}return res;}
function replaceAll(str,thisval,bythat) {var idx=str.indexOf(thisval);return (idx != -1)?str.substring(0,idx)+bythat+replaceAll(str.substring(idx+1,str.length),thisval,bythat):str}
function displayip(myip){return (myip!=null&&myip.length==12)?TrimLZero(myip.substring(0,3))+"."+TrimLZero(myip.substring(3,6))+"."+TrimLZero(myip.substring(6,9))+"."+TrimLZero(myip.substring(9,12)):myip}
function verifip(myip){return (partIPValid(TrimLZero(myip.substring(0,3)))&&partIPValid(TrimLZero(myip.substring(3,6)))&&partIPValid(TrimLZero(myip.substring(6,9)))&&partIPValid(TrimLZero(myip.substring(9,12))))}
function renderip(myip){return (myip!=null)?(myip.lastIndexOf(".")!=-1)?renderip(myip.substring(0,myip.lastIndexOf(".")))+AddLZero(myip.substring(myip.lastIndexOf(".")+1,myip.length)):AddLZero(myip):myip}
function in_subnet(ip,ipsub,masksub){var mask=mask_bits(masksub);return (ip.length == 12 && mask != "undef")?(AddNbZero(ip.substring(0,3)&mask.substring(0,3)).toString()+AddNbZero(ip.substring(3,6)&mask.substring(3,6)).toString()+AddNbZero(ip.substring(6,9)&mask.substring(6,9)).toString()+AddNbZero(ip.substring(9,ip.length)&mask.substring(9,mask.length)).toString()==ipsub)?true:false:false}
function cleanXML(d){
	var bal=d.getElementsByTagName('*');
	for(i=0;i<bal.length;i++){
		a=bal[i].previousSibling;
		if(a && a.nodeType==3 && !a.data.replace(/\s/g,'')) { a.parentNode.removeChild(a); }
		b=bal[i].nextSibling;
		if(b && b.nodeType==3 && !b.data.replace(/\s/g,'')) { b.parentNode.removeChild(b); }
	}
	return d;
}
function DBAjax(url,param,noreload,callback) {
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
				if (erreur == "true") {
					typedlg = "error";
					headdlg = langdata.xhrerror;
					txtdlg += "<input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog();'/>";
					if (callback) { callback(false); }
				} else {
					txtdlg += "<input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog();";
					if (!noreload) { txtdlg += "window.location.reload(true);"; }
					txtdlg += "'/>";
					if (callback) {callback(true);}
				}
				showDialog(headdlg,txtdlg,typedlg,0,0);
			} else {
				hideDialog();
				if (!noreload) { window.location.reload(true); }
				if (callback) {callback(false);}
			}
		}
	};
	showDialog(langdata.xhrpreload,'<img src="../img/preloader.gif" alt="loading" />',"prompt",0,0);
	xhr.open("POST",url,true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send(param);
}
function chgLang(l) {
	T$("txtMenuMain").value=l;
	T$("frmMenuMain").submit();
}
function EmptySelect(sel) {
	sel.selectedIndex = 0;
	var options = T$$("option",sel);
	while (sel.options.length > 1) {
		sel.removeChild(sel.lastChild);
	}
}
