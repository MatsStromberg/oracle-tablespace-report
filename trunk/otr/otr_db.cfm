<!---
    Copyright (C) 2011 - Oracle Tablespace Report Project - http://www.network23.net
    
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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfquery name="qInstances" datasource="#application.datasource#">
	select db_name, db_env, db_desc, system_password 
	from otr_db 
	order by db_name
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Instances</title>
<link rel="stylesheet" href="JScripts/jQuery/jquery.tablesorter/themes/blue/style.css" type="text/css" id="" media="print, projection, screen" />
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
$(document).ready(function(){
	$("table").tablesorter({debug: false, widgets: ['zebra'],sortList: [[0,0]]});
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
</script>
<cfjavascript minimize="false" munge="true">
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
<h2><cfoutput>#application.company#</cfoutput> - Oracle Instances</h2>
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<table border="0" cellpadding="0" cellspacing="0" class="tablesorter">
	<thead>
	<tr>
		<th width="100" style="font-size: 9pt;font-weight: bold;">SID</th>
		<th width="300" style="font-size: 9pt;font-weight: bold;">Description</th>
		<th width="100" style="font-size: 9pt;font-weight: bold;">Environment</th>
		<td width="150" style="font-size: 9pt;font-weight: bold;">SYSTEM Password</td>
		<td width="30" style="font-size: 9pt; font-weight: bold;">&nbsp;</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Edit</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">Delete</td>
		<td align="center" width="50" style="font-size: 9pt;font-weight: bold;">New</td>
	</tr>
	</thead>
	<tbody>
	<cfif qInstances.RecordCount IS 0><tr>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td>&nbsp;</td>
		<td align="center"><a href="otr_db_new.cfm"><img src="images/btn_new.gif" alt="New" title="New" width="18" height="18" border="0"></a></td>
	</tr></cfif>
	<cfoutput query="qInstances"><tr<cfif qInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td>#qInstances.db_name#</td>
		<td>#qInstances.db_desc#</td>
		<td class="ogctip" title="<cfif qInstances.db_env IS "SEE">Shared Enterprise Edition<cfelseif qInstances.db_env IS "DEE">Dedicated Enterprise Edition<cfelseif qInstances.db_env IS "DEV">Development Enterprise Edition<cfelseif qInstances.db_env IS "INT">Internal Enterprise Edition<cfelse>Shared Enterprise Edition</cfif>" style="cursor: help; text-align: center;">#qInstances.db_env#</td>
		<td><cfif Trim(qInstances.system_password) NEQ "">**********</cfif></td>
		<td><cfif Trim(qInstances.system_password) NEQ ""><iframe src="otr_system_test.cfm?SID=#qInstances.db_name#" name="pwtest" id="pwtest" width="30" height="20" marginwidth="0" marginheight="0" scrolling="no" frameborder="0"></iframe><cfelse>&nbsp;</cfif></td>
		<td align="center"><a href="otr_db_edit.cfm?db_name=#qInstances.db_name#"><img src="images/btn_edit.gif" alt="Edit" title="Edit" width="24" height="20" border="0"></a></td>
		<td align="center"><a onClick="confirmation('Do you really want to delete #qInstances.db_name#?\nAll Statistics will also be deleted!!!','otr_db_delete.cfm?db_name=#qInstances.db_name#');"><img src="images/btn_delete.gif" alt="Delete" title="Delete" width="24" height="20" border="0" style="cursor: hand;"></a></td>
		<td align="center"><a href="otr_db_new.cfm"><img src="images/btn_new.gif" alt="New" title="New" width="18" height="18" border="0"></a></td>
	</tr></cfoutput>
	</tbody>
	<tfoot>
	<tr>
		<td colspan="6" style="font-size: 8pt;font-weight: normal;font-style: oblique">Number of Instances: <cfoutput>#qInstances.RecordCount#</cfoutput></td>
	</tr>
	</tfoot>
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
