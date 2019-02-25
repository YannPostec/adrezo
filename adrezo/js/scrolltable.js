//@Author: Yann POSTEC
var timer;
window.onscroll=function(){
	document.documentElement.scrollTop > 100 || document.body.scrollTop > 100 ? T$("upscroll").style.display="block" : T$("upscroll").style.display="none"
	if (T$("btnFillNext") && ( (document.documentElement.clientHeight+document.documentElement.scrollTop>=T$("tablefooter").offsetTop) || (document.body.clientHeight+document.body.scrollTop>=T$("tablefooter").offsetTop) )) { loadTable(); }
	document.documentElement.scrollTop>T$("tableinfos").offsetTop || document.body.scrollTop>T$("tableinfos").offsetTop ? T$("tableheaders").style.display="block" : T$("tableheaders").style.display="none"
}
function ScrollUp() {
	window.scroll(0,0);
}
function resizeHeaders() {
	var ti=T$("tableinfos");
	var th=T$("tableheaders");
	ti.h=T$$('tr',ti)[0];
	th.h=T$$('tr',th)[0];
	for (i=0;i<ti.h.cells.length;i++) {
		var myw = window.getComputedStyle(ti.h.cells[i], null).getPropertyValue("width");
		th.h.cells[i].style.width=myw;
	}
}
function loadTable() {
	var s=T$("sqs_search").value;
	// Render IP for database search
	if (/^[0-9.]+$/.test(s)) { s = renderip(s); }
	// Escaping Single Quote
	s = s.replace(/'/g,"''");
	// Escaping Backslash
	s = s.replace(/\\/g,"\\\\\\");
	// URI Compliance
	s=encodeURIComponent(s);
	fillTable(T$("sqs_id").value,T$("sqs_limit").value,T$("sqs_offset").value,s,T$("sqs_order").value,T$("sqs_sort").value);
	resizeHeaders();
	sortiny.init();
}
function refreshTable(init) {
	resizeHeaders();
	if (init) { sortiny.init(); }
}
function searchTable() {
	clearTimeout(timer);
	
	timer=setTimeout(function() {
		clearTable();
		T$("sqs_offset").value = 0;
		loadTable();
	},300);
}
function sortTable() {
	clearTable();
	T$("sqs_offset").value=0;
	loadTable();
}
function clearTable() {
	var t = T$("tableinfos").tBodies[0];
	while (t.hasChildNodes()) {
		t.removeChild(t.firstChild);
	}
}
function cleanFoot() {
	var foot = T$("tablefooter");
	while (foot.hasChildNodes()) {
		foot.removeChild(foot.lastChild);
	}
}
function createP(msg) {
	cleanFoot();
	var p=document.createElement("p");
	p.innerHTML += msg;
	p.className = "err";
	T$("tablefooter").appendChild(p);
}
function createNext(limit) {
	cleanFoot();
	T$("sqs_offset").value = eval(T$("sqs_offset").value) + eval(T$("sqs_limit").value);
	if (T$("tablefooter").offsetTop<document.documentElement.clientHeight || T$("tablefooter").offsetTop<document.body.clientHeight) { loadTable(); }
	else {
		var btn = document.createElement("input");
		btn.type = "button";
		btn.id = "btnFillNext";
		btn.value = "Load "+limit+" next lines";
		btn.addEventListener("click",loadTable,false);
		T$("tablefooter").appendChild(btn);
	}
}
