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
	
	The Oracle Tablespace Report do need an Oracle Enterprise
	Manager 10g or later Repository (Copyright Oracle Inc.)
	since it will get some of it's data from the EM Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfquery name="qRepClient" datasource="#application.datasource#">
	select cust_id, cust_name 
	from otr_cust 
	order by cust_name
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Customers</title>
<link rel="stylesheet" href="JScripts/jQuery/jquery.tablesorter/themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
$(document).ready(function(){
	$("table").tablesorter({debug: false, widgets: ['zebra'],sortList: [[1,0]]});
	$("table").bind("sortStart",function() {  
		$("#sort_overlay").show();  
 	}).bind("sortEnd",function() {  
		$("#sort_overlay").hide();  
	});  
});
function makeDisableSubmit(){
    /*var x=document.getElementById("qSubmit");
    x.disabled=true;*/
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
// -->
</script><!---
<cfjavascript minimize="true" munge="true">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  } else {
    /* window.showHourglasses = false; */
  }
}
</cfjavascript> --->
<!--- <cfjavascript minimize="true" munge="true"> --->
<cfjavascript minimize="true" munge="true">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  } else {
    /* window.showHourglasses = false; */
  }
}
</cfjavascript>
</head>
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
	<div id="sort_overlay">
		Please wait...
	</div>
<h2><cfoutput>#application.company#</cfoutput> - Oracle Customers</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<table border="0" cellpadding="0" cellspacing="0" class="tablesorter">
	<thead>
	<tr>
		<th width="150" style="font-size: 11pt;font-weight: bold;">Company ID</th>
		<th width="300" style="font-size: 11pt;font-weight: bold;">Company name</th>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Edit</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Delete</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">New</td>
	</tr>
	</thead>
	<tfoot>
	<tr>
		<th width="150" style="font-size: 11pt;font-weight: bold;">Company ID</th>
		<th width="300" style="font-size: 11pt;font-weight: bold;">Company name</th>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Edit</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Delete</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">New</td>
	</tr>
	</tfoot>
	<tbody>
	<cfif qRepClient.RecordCount IS 0><tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="center"><a href="otr_cust_new.cfm"><img src="images/btn_new.gif" alt="New" width="18" height="18" border="0" title="New"></a></td>
	</tr></cfif>
	<cfoutput query="qRepClient"><tr<cfif qRepClient.CurrentRow mod 2> class="alternate"</cfif>>
		<td>#qRepClient.cust_id#</td>
		<td>#qRepClient.cust_name#</td>
		<td align="center"><a href="otr_cust_edit.cfm?cust_id=#qRepClient.cust_id#"><img src="images/btn_edit.gif" alt="Edit" title="Edit" width="24" height="20" border="0"></a></td>
		<td align="center"><a onClick="confirmation('Do you really want to delete this record?','otr_cust_delete.cfm?cust_id=#qRepClient.cust_id#');"><img src="images/btn_delete.gif" alt="Delete" title="Delete" width="24" height="20" border="0" style="cursor: hand;"></a></td>
		<td align="center"><a href="otr_cust_new.cfm"><img src="images/btn_new.gif" alt="New" width="18" height="18" border="0" title="New"></a></td>
	</tr></cfoutput>
	</tbody>
	</table>
	</td>
</tr>
<tr>
	<td align="center" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
