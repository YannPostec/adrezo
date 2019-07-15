//@Author: Michael Leigeber, www.scriptiny.com
//Modification : Yann POSTEC
TINY.table=function(){
	function sorter(n,t,p){this.n=n; this.id=t; this.p=p;}
	sorter.prototype.init=function(){
		this.set(); var t=this.t, i=d=0; t.h=T$$('tr',t)[0];
		t.l=t.r.length;
		if (typeof t.r[0] === 'undefined') { t.w=0; }
		else { t.w=t.r[0].cells.length; }
		t.a=[]; t.c=[];
		this.cl = T$$("tr",T$("tableheaders"))[0];
		for(i;i<t.w;i++){
			var c=t.h.cells[i]; t.c[i]={};
			var tdcl=this.cl.cells[i];
			if(c.className!='nosort'){
				c.className=this.p.headclass; c.onclick=new Function(this.n+'.search('+i+')');
				c.onmousedown=function(){return false};
				tdcl.className=this.p.headclass;tdcl.onclick=new Function(this.n+'.search('+i+')');
				tdcl.onmousedown=function(){return false};
			}
		}
		this.sort(T$("sortiny_column").value,T$("sortiny_dir").value)
	};
	sorter.prototype.search=function(i){
		var t=this.t;
		T$("sqs_sort").value=t.h.cells[i].className==this.p.ascclass?"desc":"asc";
		T$("sortiny_dir").value=t.h.cells[i].className==this.p.ascclass?0:1;
		SwitchSearch(i);
		T$("sortiny_column").value=i;
		sortTable();
	};
	sorter.prototype.sort=function(x,f){
		T$("sortiny_column").value = x;
		T$("sortiny_dir").value = f;
		var t=this.t; t.y=x; var x=t.h.cells[t.y], i=0, n=document.createElement('tbody');
		var tdcl = this.cl.cells[t.y];
		for(i=0;i<t.w;i++){var c=t.h.cells[i];var ctdcl=this.cl.cells[i]; if(c.className!='nosort'){c.className=this.p.headclass;ctdcl.className=this.p.headclass;}}
		if(f==0){x.className=this.p.descclass; tdcl.className=x.className;}
		else{x.className=this.p.ascclass; tdcl.className=this.p.ascclass}
		this.set(); this.alt(); this.sethover()
	};
	sorter.prototype.sethover=function(){
		if(this.p.hoverid){
			for(var i=0;i<this.t.l;i++){
				var r=this.t.r[i];
				r.setAttribute('onmouseover',this.n+'.hover('+i+',1)');
				r.setAttribute('onmouseout',this.n+'.hover('+i+',0)')
			}
		}
	};
	sorter.prototype.alt=function(){
		var t=this.t, i=x=0;
		for(i;i<t.l;i++){
			var r=t.r[i];
			r.className=x%2==0?this.p.evenclass:this.p.oddclass; var cells=T$$('td',r);
			for(var z=0;z<t.w;z++){cells[z].className=t.y==z?x%2==0?this.p.evenselclass:this.p.oddselclass:''}
			x++
		}
	};
	sorter.prototype.hover=function(i,d){
		this.t.r[i].id=d?this.p.hoverid:''
	};
	sorter.prototype.set=function(){
		var t=T$(this.id); t.b=T$$('tbody',t)[0]; t.r=t.b.rows; this.t=t
	};
	return{sorter:sorter}
}();
