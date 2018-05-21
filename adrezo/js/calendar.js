//@Author: Yann POSTEC
function calZero(myi) {
	var mys = String(myi);
	if (mys.length == 1) { return "0" + mys; }
	else { return mys; }
}
function calDestroy(div) {
	while (div.childNodes.length>0) { div.removeChild(div.firstChild); }
	div.className = "";
}
function calCreate(e) {
	var node = e.target;
	var div = node.nextSibling;
	var ipt = node.parentNode.firstChild;
	var mydate = ipt.value;
	
	if (mydate.length == 0 || (mydate.length == 10 && new RegExp("\\d{2}/\\d{2}/\\d{4}").test(mydate))) {
		calDestroy(div);
		calRender(div,ipt,mydate);
	}
}
function calPrevMonth(div,ipt,mydate) {
	var prevMonth = "01/" + calZero(mydate.getMonth()) + "/" + mydate.getFullYear();
	calDestroy(div);
	calRender(div,ipt,prevMonth);
}
function calNextMonth(div,ipt,mydate) {
	var nextMonth = "01/" + calZero(mydate.getMonth()+2) + "/" + mydate.getFullYear();
	calDestroy(div);
	calRender(div,ipt,nextMonth);
}
function calPick(div,ipt,mydate,day) {
	var pickdate = calZero(day) + "/" + calZero(mydate.getMonth()+1) + "/" + mydate.getFullYear();
	ipt.value = pickdate;
	calDestroy(div);
}
function calRender(div,ipt,mydate) {
	div.className = "caldiv";
	var monthsName = [langdata.caljan,langdata.calfeb,langdata.calmar,langdata.calapr,langdata.calmay,langdata.caljun,langdata.caljul,langdata.calaug,langdata.calsep,langdata.caloct,langdata.calnov,langdata.caldec];
	var today = new Date();
	var viewDate;
	var selDate;
	if (mydate != "") {
		selDate = new Date(mydate.substring(6,10),mydate.substring(3,5)-1,mydate.substring(0,2));
		if (selDate<today) { viewDate = new Date(); } else { viewDate = selDate; }
	} else { viewDate = new Date(); }
	var dayEnd = new Date(viewDate.getFullYear(),viewDate.getMonth()+1,0).getDate();
	var dayFirst = new Date(viewDate.getFullYear(),viewDate.getMonth(),1).getDay();
	var ArrayDays = new Array();
	ArrayDays[0] = new Array();
	if (dayFirst == 0) {
		ArrayDays[0] = [0,0,0,0,0,0];
	} else if (dayFirst > 1) {
		for (var i=0;i<dayFirst-1;i++) {
			ArrayDays[0][i] = 0;
		}
	}
	var i = 0;
	var j = ArrayDays[0].length;
	for (var d=1;d<=dayEnd;d++) {
		if ((mydate == "" || selDate<today || mydate.substring(3,5)-1 == today.getMonth()) && d<today.getDate()) {
			ArrayDays[i][j] = 0;
		} else {
			ArrayDays[i][j] = d;
		}
		if (j == 6) {
			j=0;
			i++;
			if (d != dayEnd) { ArrayDays[i] = new Array(); }
		} else { j++; }
	}
	var lastRow = ArrayDays.length-1;
	for (var k=ArrayDays[lastRow].length;k<7;k++) {
		ArrayDays[lastRow][k] = 0;
	}
	var ul = document.createElement("ul");ul.className = "caltr";
	var li = document.createElement("li");li.className = "calprev";
	li.onclick = function() { calPrevMonth(div,ipt,viewDate); }
	ul.appendChild(li);
	var li = document.createElement("li");li.className = "calmonth";
	var txt = document.createTextNode(monthsName[viewDate.getMonth()] + " " + viewDate.getFullYear());
	li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");li.className = "calnext";
	li.onclick = function() { calNextMonth(div,ipt,viewDate); }
	ul.appendChild(li);
	div.appendChild(ul);
	var ul = document.createElement("ul");ul.className = "caltr";
	var li = document.createElement("li");li.className = "calendtd";var txt = document.createTextNode("L");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("M");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("M");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("J");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("V");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("S");li.appendChild(txt);ul.appendChild(li);
	var li = document.createElement("li");var txt = document.createTextNode("D");li.appendChild(txt);ul.appendChild(li);
	div.appendChild(ul);
	for (var i=0;i<ArrayDays.length;i++) {
		var ul = document.createElement("ul");
		ul.className = "caltr";
		for (var j=0;j<7;j++) {
			var li = document.createElement("li");
			if (j == 0) { li.className = "calendtd"; }
			var day = ArrayDays[i][j];
			if (day == 0) {
				var txt = document.createTextNode("");
				li.className += " calempty";
				li.appendChild(txt);
			} else {
				var txt = document.createTextNode(day);
				var lk = document.createElement("a");
				lk.onclick = function() { calPick(div,ipt,viewDate,this.firstChild.nodeValue); }
				if (day == today.getDate() && viewDate.getMonth() == today.getMonth() && viewDate.getFullYear() == today.getFullYear()) { lk.className = "calcurrent"; }
				lk.appendChild(txt);		
				li.appendChild(lk);
			}
			ul.appendChild(li);
		}
		div.appendChild(ul);
	}
}
