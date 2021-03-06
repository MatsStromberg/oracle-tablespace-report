<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Mats Str�mberg - ms@network23.net

    This file is part of the Oracle Tablespace Report.

    The Oracle Tablespace Report is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Oracle Tablespace Report is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
	
	The Oracle Tablespace Report do need an Oracle Enterprise
	Manager 10g or later Repository (Copyright Oracle Inc.)
	since it will get some of it's data from the EM Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!---
	Long over due Change Log
	2013.04.21	mst	Added initi of otrtip_u
	2013.04.24	mst	changed from tablesoter.js to dataTables.js
--->
<link rel="shortcut icon" href="images/favicon.ico" />
<link rel="apple-touch-icon" href="images/apple-touch-icon.png">
<link rel="apple-touch-icon" sizes="72x72" href="images/apple-touch-icon-72x72.png">
<link rel="apple-touch-icon" sizes="114x114" href="images/apple-touch-icon-114x114.png">
<link rel="stylesheet" href="otr.css" type="text/css" />
<link href="JScripts/jQuery/tipTip.css" rel="stylesheet" type="text/css">
<!--[if lt IE 9]>
<link href="JScripts/jQuery/tipTip_ie8.css" rel="stylesheet" type="text/css">
<![endif]-->
<style type="text/css">
<!--
/* Import the fancy styles for IE only (NS4.x doesn't use the @import function) */
@import url("formIE.css");
-->
</style>
<script src="JScripts/jQuery/jquery-1.8.2.min.js" type="text/javascript"></script>
<script src="JScripts/jQuery/jquery.tipTip.minified.js" type="text/javascript"></script>
<script src="JScripts/jQuery/jquery.dataTables/jquery.dataTables.min.js" type="text/javascript"></script>
<link href="JScripts/jQuery/jquery.dataTables/jquery.dataTables.css" rel="stylesheet" type="text/css" />

<script type="text/javascript">
<!--
$(document).ready(function(){
	$(".otrtip").tipTip({
		maxWidth: "auto",
		edgeOffset: 10,
		delay: 100
	});
	$(".otrtip_u").tipTip({
		defaultPosition: "top",
		maxWidth: "auto",
		edgeOffset: 10,
		delay: 100
	});
	// $("table").tablesorter({debug: false, widgets: ['zebra'],sortList: [[0,0]]});
});
function hideHalgeDiv() { 
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("halgeDiv").style.visibility = 'hidden'; 
		document.getElementById("halgeDiv").style.display = 'none'; 
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.halgeDiv.visibility = 'hidden'; 
		} 
		else { // IE 4 
			document.all.halgeDiv.style.visibility = 'hidden'; 
		} 
	} 
} 

function showHalgeDiv() { 
	var w = 0;
	var h = 0;
	//IE
	if(!window.innerWidth) {
		//strict mode
		if(!(document.documentElement.clientWidth == 0)) {
			w = document.documentElement.clientWidth;
			h = document.documentElement.clientHeight;
		}
		//quirks mode
		else {
			w = document.body.clientWidth;
			h = document.body.clientHeight;
		}
	}
	//w3c
	else {
		w = window.innerWidth;
		h = window.innerHeight;
	}
	w = (w/2) - 225;
	h = (h/2) - 130;
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("halgeDiv").style.left = w; 
		document.getElementById("halgeDiv").style.top = h; 
		document.getElementById("halgeDiv").style.visibility = 'visible'; 
		document.getElementById("halgeDiv").style.display = 'block'; 
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.halgeDiv.visibility = 'visible'; 
		} 
		else { // IE 4 
			document.all.halgeDiv.style.visibility = 'visible'; 
		} 
	}
	halgeDelay();
}
function halgeDelay() {
	startCountDown(5, 1000);
	setTimeout("hideHalgeDiv()", 5000);
}
function startCountDown(i, p) {
// store parameters
var pause = p;
// make reference to div
var countDownObj = document.getElementById("countDown");
if (countDownObj == null) {
// error
	alert("div not found, check your id");
// bail
return;
}
countDownObj.count = function(i) {
// write out count
countDownObj.innerHTML = i + " Sec";
if (i == 0) {
// execute function
//fn();
// stop
return;
}
setTimeout(function() {
// repeat
countDownObj.count(i - 1);
},
pause
);
}
// set it going
countDownObj.count(i);
}

// -->
</script>
<cfset cDirSep = FileSeparator()>
<cfif cDirSep IS "/">
	<cfset sHost = "#Application.obd_host#" />
<cfelse>
	<cfset sHost = "#Application.obd_desktop_host#" />
</cfif>
