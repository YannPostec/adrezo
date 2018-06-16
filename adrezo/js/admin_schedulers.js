//@Author : Yann POSTEC
function modSubmit() {
	var strAlert="";
	var seljob1 = T$("sel1").value;
	var seljob2 = T$("sel2").value;
	var seljob3 = T$("sel3").value;
	var seljob4 = T$("sel4").value;
	var seljob5 = T$("sel5").value;
	var seljob6 = T$("sel6").value;
	var seljob7 = T$("sel7").value;
	var seljob8 = T$("sel8").value;
	var seljob9 = T$("sel9").value;
	var seljob10 = T$("sel10").value;
	var seljob11 = T$("sel11").value;
	var djob1 = T$("day1").value;
	var djob2 = T$("day2").value;
	if (!djob1 || isNaN(djob1) || djob1 < 1) { strAlert += "- Job 1: "+langdata.verifnumber+"<br />"; }
	if (!djob2 || isNaN(djob2) || djob2 < 1) { strAlert += "- Job 2: "+langdata.verifnumber+"<br />"; }
	var param8 = 1;
	if (T$("job8_param_hour").checked) { param8 = T$("job8_param_hour").value; }
	if (T$("job8_param_day").checked) { param8 = T$("job8_param_day").value; }
	if (T$("job8_param_month").checked) { param8 = T$("job8_param_month").value; }
	if (strAlert != "") {
		showDialog(langdata.invalidfield+" :",strAlert,"warning",0,1);
	} else {
		DBAjax("ajax_schedulers_store.jsp","s1="+seljob1+"&s2="+seljob2+"&s3="+seljob3+"&s4="+seljob4+"&s5="+seljob5+"&d1="+djob1+"&d2="+djob2+"&s6="+seljob6+"&s7="+seljob7+"&s8="+seljob8+"&s9="+seljob9+"&s10="+seljob10+"&p8="+param8+"&s11="+seljob11);
	}
}
function displayJobs() {
	var b = T$("tJobList").tBodies[0];
	while (b.childNodes.length>0) {b.removeChild(b.firstChild);}
	var xhr=new XMLHttpRequest();
	xhr.onreadystatechange=function(){
		if (xhr.readyState==4 && xhr.status!=200) { showDialog(langdata.xhrapperror,langdata.xhrapptext+"!<br/>"+langdata.error+" "+xhr.status+"<br/>"+xhr.statusText,"error",0,1); }
		if (xhr.readyState==4 && xhr.status==200) {
			var divwait=T$("jobwait");
			while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
			response = xhr.responseXML.documentElement;
			if (response) { response = cleanXML(response); }
			var valid = T$$("valid",response)[0].firstChild.nodeValue;
			if (valid == "true") {
					var erreur = T$$("erreur",response)[0].firstChild.nodeValue;
					if (erreur == "true") {
						txtdlg = T$$("msg",response)[0].firstChild.nodeValue + "<br/><br/><input type='button' value='"+langdata.closedlg+"' onclick='javascript:hideDialog()'/>";
						showDialog(langdata.xhrapperror,txtdlg,"error",0,1);
					} else {
						var jobs = T$$("job",response);
						for (var i=0;i<jobs.length;i++) {
							var tr = b.insertRow(-1);
							var jobname = T$$("name",jobs[i])[0].firstChild.nodeValue;
							var td = tr.insertCell(-1);
							var txt = document.createTextNode(jobname);
							td.align = "center";
							td.appendChild(txt);
							var jobgroup = T$$("group",jobs[i])[0].firstChild.nodeValue;
							var td = tr.insertCell(-1);
							var txt = document.createTextNode(jobgroup);
							td.align = "center";
							td.appendChild(txt);
							var jobprev = T$$("prev",jobs[i])[0].firstChild.nodeValue;
							var td = tr.insertCell(-1);
							var txt = document.createTextNode(jobprev);
							td.align = "center";
							td.appendChild(txt);
							var jobnext = T$$("next",jobs[i])[0].firstChild.nodeValue;
							var td = tr.insertCell(-1);
							var txt = document.createTextNode(jobnext);
							td.align = "center";
							td.appendChild(txt);
						}
					}
			} else {
				showDialog(langdata.xhrapperror,langdata.xhrapptext+" displayJobs","error",0,1);
			}
		}
	};
	var divwait=T$("jobwait");
	while (divwait.childNodes.length>0) {divwait.removeChild(divwait.firstChild);}
	var img=document.createElement("img");
	img.src = "../img/wait_bar.gif";
	img.alt = "WaitBar";
	img.width = 345;
	img.heigth = 21;
	divwait.appendChild(img);
	xhr.open("POST","../jobs",true);
	xhr.setRequestHeader('Content-type','application/x-www-form-urlencoded');
	xhr.send();
}
function getPurgePhoto() {
	DBAjax("../purge","",true);
}

