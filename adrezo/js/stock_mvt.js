//@Author: Yann POSTEC
function FillSite(node,origin) {
	var ctx = node.value;
	if (origin == "src" || origin == "dst") {
		if (origin == "src") {
			var site = T$("srcsite");
			var type = T$("srctype");
			var stk = T$("srcstk");
		}
		if (origin == "dst") {
			var site = T$("dstsite");
			var type = T$("dsttype");
			var stk = T$("dststk");
		}
		if (node.selectedIndex > 0) {
			EmptySelect(site);
			EmptySelect(type);
			stk.innerHTML="";

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
							site.add(opt);
						}
					} else {
						showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSite","error",0,1);
					}
				}
			};
			xhr.open("POST","ajax_mvt_fillsite.jsp",true);
			xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhr.send("ctx="+ctx);
		}
	}
}
function FillType(node,origin) {
	var site = node.value;
	if (origin == "src" || origin == "dst") {
		if (origin == "src") {
			var type = T$("srctype");
			var stk = T$("srcstk");
		}
		if (origin == "dst") {
			var type = T$("dsttype");
			var stk = T$("dststk");
		}
		if (node.selectedIndex > 0) {
			EmptySelect(type);
			stk.innerHTML="";

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
							type.add(opt);
						}
					} else {
						showDialog(langdata.xhrapperror,langdata.xhrapptext+" FillSite","error",0,1);
					}
				}
			};
			xhr.open("POST","ajax_mvt_filltype.jsp",true);
			xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhr.send("site="+site);
		}
	}
}
function FillStock(node,origin) {
	var type = node.value;
	if (origin == "src" || origin == "dst") {
		if (origin == "src") { var stk = T$("srcstk"); }
		if (origin == "dst") { var stk = T$("dststk"); }
		if (node.selectedIndex > 0) {
			stk.innerHTML="";

			var xhr=new XMLHttpRequest();
			xhr.onreadystatechange=function(){
				if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
				if (xhr.readyState==4 && xhr.status==200) {
					stk.innerHTML = xhr.responseText;
					if (origin == "src") { T$("srcqty").value = xhr.responseText; }
				}
			};
			xhr.open("POST","ajax_mvt_fillstock.jsp",true);
			xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
			xhr.send("type="+type);
		}
	}
}
function MoveStock() {
	var q = T$("mvtqty").value;
	var sq = T$("srcqty").value;
	var src = T$("srctype");
	var s = src.value;
	var dst = T$("dsttype");
	var d = dst.value;
	var strAlert = "";
	if (q == "" || isNaN(q) || q <= 0) { strAlert += "- "+langdata.stkqty+": "+langdata.verifnumber+"<br />"; }
	if (+q > +sq) { strAlert += "- "+langdata.stkmove+"<br />"; }
	if (src.selectedIndex == 0) { strAlert += "- "+langdata.stksrc+": "+langdata.verifchoose+"<br />"; }
	if (dst.selectedIndex == 0) { strAlert += "- "+langdata.stkdst+": "+langdata.verifchoose+"<br />"; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_mvt_move.jsp","qty="+q+"&src="+s+"&dst="+d);
	}
}
