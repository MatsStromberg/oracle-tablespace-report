<!---
    Copyright (C) 2011 - Oracle Tablespace Report Project - http://www.network23.net
    
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
<cfquery name="qRepDate" datasource="#application.datasource#">
	select rep_date 
	from otr_space_rep_timestamps_v 
	order by rep_date desc
</cfquery>
<cfset iRecordCount = 0>
<cfoutput query="qRepDate"><cfif DayOfWeek(qRepDate.rep_date) IS NOT Application.snapshot_day><cfset iRecordCount = 1></cfif></cfoutput>
<!--- Set Local Date Format --->
<cfset dummy = SetLocale("#Application.locale_string#") />
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Delete Tablespace Snapshot</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
function makeDisableSubmit(){
    var x=document.getElementById("qSubmit");
    x.disabled=true;
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
</head>
<body<cfif iRecordCount IS 0> onLoad="makeDisableSubmit();"</cfif>>
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Delete Tablespace Snapshot</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
<form action="otr_tbs_dodeletesnapshot.cfm" method="post">
<table border="0" width="100%" cellpadding="2" cellspacing="2">
<tr>
	<td align="right" width="200">Report Date:</td>
	<td>
		<cfif iRecordCount IS NOT 0><select name="rep_date"><cfoutput query="qRepDate"><cfif DayOfWeek(qRepDate.rep_date) IS NOT Application.snapshot_day>
		<option value="#DateFormat(qRepDate.rep_date,"dd-mm-yyyy")#">#LSDateFormat(qRepDate.rep_date,'medium')#</option></cfif>
		</cfoutput></select> <span style="font-style: oblique;">Friday Snapshots are not listed</span><cfelse><span style="font-style: oblique;">No Snapshots to delete.... only Friday Snapshots left.</span></cfif>
	</td>
</tr>
<tr>
	<td colspan="2">&nbsp;</td>
</tr>
<tr>
	<td>&nbsp;</td>
	<td><input type="submit" name="qSubmit" id="qSubmit" value="Delete Snapshot"></td>
</tr>
</table>
</form>
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
