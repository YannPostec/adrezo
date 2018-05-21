//@Author: Yann POSTEC
function addSubmit(ctx) {
	var strAlert="";
	var site;
	var inputs = document.getElementsByName("radio"+ctx);
	for (i=0;i<inputs.length;i++) {
		if (inputs[i].checked) { site=inputs[i].value; }
	}
	if (site) {
			DBAjax("ajax_stock_main.jsp","ctx="+ctx+"&site="+site);
	}
}
