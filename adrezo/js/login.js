//@Author: Yann POSTEC
function handleEnter(field,event,errver) {
	var keyCode = event.keyCode ? event.keyCode : event.which ? event.which : event.charCode;
	if (keyCode == 13) { cnxSubmit(errver); return false; }
	else { return true; }
}
function cnxSubmit(errver) {
	var bOK = true;
	if (document.all && !window.atob) { document.getElementById("browserTest").style.display = "inline"; bOK=false; }
	if (errver) { document.getElementById("versionTest").style.display = "inline"; bOK=false; }
	if (bOK) { document.getElementById("fCnx").submit(); }
}
