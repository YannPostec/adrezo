//@Author: Michael Leigeber, www.scriptiny.com
//Modification : Yann POSTEC
function keyPressHandler(e) {
	var kC  = (window.event) ? event.keyCode : e.keyCode;
	var Esc = (window.event) ? 27 : e.DOM_VK_ESCAPE;
	if(kC==Esc) { hideDialog(); }
}
function pageWidth() {
  return window.innerWidth != null ? window.innerWidth : document.documentElement && document.documentElement.clientWidth ? document.documentElement.clientWidth : document.body != null ? document.body.clientWidth : null;
}
function pageHeight() {
  return window.innerHeight != null? window.innerHeight : document.documentElement && document.documentElement.clientHeight ? document.documentElement.clientHeight : document.body != null? document.body.clientHeight : null;
}
function topPosition() {
  return typeof window.pageYOffset != 'undefined' ? window.pageYOffset : document.documentElement && document.documentElement.scrollTop ? document.documentElement.scrollTop : document.body.scrollTop ? document.body.scrollTop : 0;
}
function leftPosition() {
  return typeof window.pageXOffset != 'undefined' ? window.pageXOffset : document.documentElement && document.documentElement.scrollLeft ? document.documentElement.scrollLeft : document.body.scrollLeft ? document.body.scrollLeft : 0;
}
function showDialog(title,message,type,autohide,displayclose) {
  if(!type) {
    type = 'error';
  }
  var dialog;
  var dialogheader;
  var dialogclose;
  var dialogtitle;
  var dialogcontent;
  var dialogmask;
  if(!T$('dialog')) {
    dialog = document.createElement('div');
    dialog.id = 'dialog';
    dialogheader = document.createElement('div');
    dialogheader.id = 'dialog-header';
    dialogtitle = document.createElement('div');
    dialogtitle.id = 'dialog-title';
    dialogclose = document.createElement('div');
    dialogclose.id = 'dialog-close'
    dialogcontent = document.createElement('div');
    dialogcontent.id = 'dialog-content';
    dialogmask = document.createElement('div');
    dialogmask.id = 'dialog-mask';
    document.body.appendChild(dialogmask);
    document.body.appendChild(dialog);
    dialog.appendChild(dialogheader);
    dialogheader.appendChild(dialogtitle);
    dialogheader.appendChild(dialogclose);
    dialog.appendChild(dialogcontent);;
    dialogclose.setAttribute('onclick','hideDialog()');
    dialogclose.onclick = hideDialog;
	if(displayclose) { document.onkeypress = keyPressHandler; }
	else if (document.onkeypress) { document.onkeypress = null; }
  } else {
    dialog = T$('dialog');
    dialogheader = T$('dialog-header');
    dialogtitle = T$('dialog-title');
    dialogclose = T$('dialog-close');
    dialogcontent = T$('dialog-content');
    dialogmask = T$('dialog-mask');
    dialogmask.style.visibility = "visible";
    dialog.style.visibility = "visible";
    if(displayclose) { document.onkeypress = keyPressHandler; }
  }
  dialog.style.opacity = 1.00;
  dialog.style.filter = 'alpha(opacity=100)';
  dialog.alpha = 100;
  var width = pageWidth();
  var height = pageHeight();
  var left = leftPosition();
  var top = topPosition();
  var dialogwidth = dialog.offsetWidth;
  var dialogheight = dialog.offsetHeight;
  var topposition = top + (height / 3) - (dialogheight / 2);
  if (topposition < top) { topposition = top + (height / 3); }
  var leftposition = left + (width / 2) - (dialogwidth / 2);
  dialog.style.top = topposition + "px";
  dialog.style.left = leftposition + "px";
  dialogheader.className = type + "header";
  dialogtitle.innerHTML = title;
  dialogcontent.className = type;
  dialogcontent.innerHTML = message;
  var content = T$('dlgcontent');
  dialogmask.style.height = content.offsetHeight + 'px';
  if(autohide) {
    dialogclose.style.visibility = "hidden";
    window.setTimeout("hideDialog()", (autohide * 1000));
  } else {
    dialogclose.style.visibility = "visible";
  }
  if(displayclose) { dialogclose.style.visibility = "visible"; }
  else { dialogclose.style.visibility = "hidden"; }
}
function hideDialog() {
  var dialog = T$('dialog');
  dialog.style.visibility = "hidden";
  T$('dialog-mask').style.visibility = "hidden";
  if (document.onkeypress) { document.onkeypress = null; }
}
