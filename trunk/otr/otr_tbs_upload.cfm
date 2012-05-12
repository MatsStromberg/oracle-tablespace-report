<!---
    Copyright (C) 2010-2012 - Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Mats Strömberg - ms@network23.net

    This file is part of the Oracle Tablespace Report.

    The Oracle Tablespace Report is free software: you can redistribute 
    it and/or modify it under the terms of the GNU General Public License 
    as published by the Free Software Foundation, either version 3 of the 
    License, or (at your option) any later version.

    The Oracle Tablespace Report is distributed in the hope that it will 
    be useful, but WITHOUT ANY WARRANTY; without even the implied warranty 
    of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU 
    General Public License for more details.
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">


<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Usage CSV or XLS Upload</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
function makeDisableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=true;
    var y=document.getElementById("qReset");
    y.disabled=true;
}
function makeEnableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=false;
}
function hideDiv() { 
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("loaderDiv").style.visibility = 'hidden'; 
		document.getElementById("loaderDiv").style.display = 'none'; 
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.loaderDiv.visibility = 'hidden'; 
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'hidden'; 
		} 
	} 
} 

function showDiv() { 
	if (document.getElementById) { // DOM3 = IE5, NS6 
		document.getElementById("loaderDiv").style.visibility = 'visible'; 
		document.getElementById("loaderDiv").style.display = 'block'; 
		document.getElementById("snapshot").src = 'otr_tbs_newsnapshot.cfm?MENU=YES';
	} 
	else { 
		if (document.layers) { // Netscape 4 
			document.loaderDiv.visibility = 'visible'; 
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'visible'; 
		} 
	} 
} 

function submit_check() {
	if (document.getElementById) { // DOM3 = IE5, NS6 
		if (document.getElementById("file_name").value.length == 0) {
			document.getElementById("errormsg").innerHTML = "Only files with extention .xls or .csv allowed!!";
			return false;
		}
		else if (document.getElementById("file_name").value.length > 0) {
			if (document.getElementById("file_name").value.substring(document.getElementById("file_name").value.length-3) == 'xls') {
				document.getElementById("file_type").value = 'xls';
				return true;
			}
			else if (document.getElementById("file_name").value.substring(document.getElementById("file_name").value.length-4) == 'xlsx') {
				document.getElementById("file_type").value = 'xlsx';
				return true;
			}

			else if (document.getElementById("file_name").value.substring(document.getElementById("file_name").value.length-3) == 'csv') {
					 document.getElementById("file_type").value = 'csv';
					return true;
			}
			else {
				document.getElementById("errormsg").innerHTML = "Only files with extention .xls or .csv allowed!!";
				document.getElementById("file_name").value = '';
				return false;
			}
		}
	}
}
// -->
</script>
<!---				document.getElementById("errormsg").innerHTML = 'Only files with extention .xls or .csv allowed!!'; --->
</head>
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Usage CSV or XLS Upload</h2>
<!--- <h4>NOTE: CSV File must be in UNIX Format!!!</h4> --->
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<form action="otr_tbs_doupload.cfm" id="fileupload" method="post" enctype="multipart/form-data" onsubmit="return submit_check();">
	<input type="Hidden" name="file_type" id="file_type" value="csv">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">CSV/XLS File:&nbsp;</td>
		<td width="150"><input type="file" name="file_name" id="file_name" value="" size="40"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td align="center" colspan="2"><input value="Upload" id="qSubmit" type="submit">&nbsp;&nbsp;&nbsp;<input type="reset" id="qReset"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td colspan="2" align="center"><div id="errormsg" style="color: red; font-weight: bold;">&nbsp;</div></td>
	</tr>
	</table>
	</form>
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
