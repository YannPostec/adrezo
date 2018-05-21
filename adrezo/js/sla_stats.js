//@Author: Yann POSTEC
function dispCompare() {
	var cb = T$("cb_compare");
	var span = T$("span_compare");
	if (cb.checked) { span.style.display=""; }
	else { span.style.display="none"; }
}
function fillCompDate() {
	var m1 = T$("s_m1");
	var y1 = T$("s_y1");
	var m2 = T$("s_m2");
	var y2 = T$("s_y2");

	if (m1.value == 0) {
		m2.value = 0;
		y2.value = y1.selectedIndex>0?y1.value-1:y1.value;
	} else if (m1.value == 1) {
		y2.value = y1.selectedIndex>0?y1.value-1:y1.value;
		m2.value = y1.selectedIndex>0?12:1;
	} else {
		m2.value = m1.value-1;
		y2.value = y1.value;
	}
}
function zeroMonth(nb) {
	return nb.length>1?nb:'0'+nb;
}
function fillClients() {
	var m1 = T$("s_m1").value;
	var y1 = T$("s_y1").value;
	var m2 = T$("s_m2").value;
	var y2 = T$("s_y2").value;
	T$("h_m1").value = m1;
	T$("h_y1").value = y1;
	T$("h_m2").value = m2;
	T$("h_y2").value = y2;
	var comp = T$("cb_compare").checked?1:0;
	var stamp1 = m1==0?y1:y1+zeroMonth(m1);
	var stamp2 = m2==0?y2:y2+zeroMonth(m2);
	var digit = T$("s_digit").value;
	if (digit > 5 || digit < 1) { digit = 3; }
	var div = T$("stats");

	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
		if (xhr.readyState==4 && xhr.status==200) {
			while (div.childNodes.length > 0) { div.removeChild(div.lastChild); }
			var ul = document.createElement("ul");
			ul.className = "acc";
			ul.id = "rootacc";
			ul.innerHTML = xhr.responseText;
			div.appendChild(ul);
			var accname = "rootacc";
			window[accname]=new TINY.accordion.slider(accname);
			window[accname].init(accname,"h3",0,-1);
		}
	};
	xhr.open("POST","ajax_stats_clients.jsp",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send("stamp1="+stamp1+"&stamp2="+stamp2+"&comp="+comp+"&digit="+digit);
}
function fillSites(id) {
	var m1 = T$("h_m1").value;
	var y1 = T$("h_y1").value;
	var m2 = T$("h_m2").value;
	var y2 = T$("h_y2").value;
	var comp = T$("cb_compare").checked?1:0;
	var stamp1 = m1==0?y1:y1+zeroMonth(m1);
	var stamp2 = m2==0?y2:y2+zeroMonth(m2);
	var digit = T$("s_digit").value;
	if (digit > 5 || digit < 1) { digit = 3; }

	var lic = T$("lic"+id);
	if (lic.dataset.filled == false) {
		lic.dataset.filled = true;
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				var cont = T$("cctn"+id);
				var ul = document.createElement("ul");
				ul.className = "acc";
				ul.id = "cacc"+id;
				ul.innerHTML = xhr.responseText;
				cont.appendChild(ul);
				var accname = "cacc"+id;
				window[accname]=new TINY.accordion.slider(accname);
				window[accname].init(accname,"h3",0,-1);
			}
		};
		xhr.open("POST","ajax_stats_sites.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id+"&stamp1="+stamp1+"&stamp2="+stamp2+"&comp="+comp+"&digit="+digit);
	}
}
function fillDevices(id) {
	var m1 = T$("h_m1").value;
	var y1 = T$("h_y1").value;
	var m2 = T$("h_m2").value;
	var y2 = T$("h_y2").value;
	var comp = T$("cb_compare").checked?1:0;
	var stamp1 = m1==0?y1:y1+zeroMonth(m1);
	var stamp2 = m2==0?y2:y2+zeroMonth(m2);
	var digit = T$("s_digit").value;
	if (digit > 5 || digit < 1) { digit = 3; }

	var lis = T$("lis"+id);
	if (lis.dataset.filled == false) {
		lis.dataset.filled = true;
		var xhr=new XMLHttpRequest();
		xhr.onreadystatechange=function(){
			if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
			if (xhr.readyState==4 && xhr.status==200) {
				var cont = T$("sctn"+id);
				var ul = document.createElement("ul");
				ul.innerHTML = xhr.responseText;
				cont.appendChild(ul);
			}
		};
		xhr.open("POST","ajax_stats_devices.jsp",true);
		xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
		xhr.send("id="+id+"&stamp1="+stamp1+"&stamp2="+stamp2+"&comp="+comp+"&digit="+digit);
	}
}
function statsLoad(y,m) {
	T$("s_m1").value=m;
	T$("s_y1").value=y;
	fillCompDate();
	fillClients();
}
