//@Author: Yann POSTEC
function ConfirmDlg(stamp) {
	showDialog(langdata.confirm,langdata.sladel+"<br/><input type='button' value='"+langdata.dlgyes+"' onclick='javascript:delSubmit("+stamp+");'/>  <input type='button' value='"+langdata.dlgno+"' onclick='hideDialog();'/>","prompt",0,1);
}
function delSubmit(stamp) {
	DBAjax("ajax_stats_delete.jsp","stamp="+stamp);
}
