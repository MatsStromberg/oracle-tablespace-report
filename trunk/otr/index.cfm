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
<!---
	Long over due Change Log
	2012.05.25	mst	Added some more Tool-Tip's
	2012.05.26	mst	Getting setting for the refresh time from Application.cfc
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cftry>
<cfquery name="qRepDate" datasource="#Application.datasource#">
	select rep_date 
	  from otr_space_rep_timestamps_v 
	order by rep_date desc
</cfquery>
	<cfcatch type="Database">
		<!--- Either the datasource is missing or we have not configured
		      any OTR Repository yet. --->
		<cflocation url="/bluedragon/administrator/index.cfm" addtoken="No" />
	</cfcatch>
</cftry>

<cfquery name="qRepClient" datasource="#Application.datasource#">
	select cust_id, cust_name 
	  from otr_cust 
	order by cust_name
</cfquery>

<cfquery name="qDBInstances" datasource="#Application.datasource#">
	select db_name
	from otr_db
</cfquery>
<!--- New Setup? If so, we'll do some basic Database updates. --->
<cfif qDBInstances.RecordCount IS 0>
	<cflocation url="/otr/otr_setup.cfm" addtoken="no" />
</cfif>
<cfset dummy = SetLocale("#Application.locale_string#") />
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">
<script type="text/javascript">
<!--
function makeDisableSubmit(){
    var x=document.getElementById("qSubmit")
    x.disabled=true
}
function makeEnableSubmit(){
    var x=document.getElementById("qSubmit")
    x.disabled=false
}
/* function toggle_select(){
	if (document.getElementById("monthly").checked) {
		makeDisable();
	} else {
		makeEnable();
	}
} */
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
		document.getElementById("snapshot").src = 'otr_tbs_newsnapshot.cfm?MENU=Yes';
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
function setCurrTBS() {
	$("#tbsstatus").attr('src', 'otr_currtbs.cfm');
	return false;
	/*$("#tbsstatus").load(); */
}
function setAllTBS() {
	$("#tbsstatus").attr('src', 'otr_alltbs.cfm');
	$("#tbsstatus").load();
	return false;
}
$(document).ready(function() {
	// Change iFrame on a Button Click Event
	$("#bAll").click(function(event){
		document.getElementById("tbsstatus").attr('src', 'otr_alltbs.cfm');
		document.getElementById("tbsstatus").load();
		/*$("#tbsstatus").attr('src', 'otr_alltbs.cfm');
		$("#tbsstatus").load();*/
	});
}); 
// -->
</script>
</head>

<body onload="makeEnableSubmit();">
<cfinclude template="_top_menu.cfm">
<br />
<div align="center">
<h2><cfoutput>#Application.company#</cfoutput> - Oracle Tablespace Report</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
		<cfif qRepDate.RecordCount IS NOT 0>
		<form action="otr_tbs_report.cfm" name="report" method="post">
		<table border="0" width="100%" cellpadding="2" cellspacing="2">
		<tr>
			<td align="right" width="200">Report Date:</td>
			<td>
				<select name="rep_date" class="otrtip" title="<div align='center'>Select a snapshot date<br />for your report.</div>"><cfoutput query="qRepDate">
				<option value="#DateFormat(qRepDate.rep_date,"dd-mm-yyyy")#">#LSDateFormat(qRepDate.rep_date,'medium')#</option>
				</cfoutput></select>
			</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td align="right">Customer:</td>
			<td>
				<select name="rep_cust" class="otrtip" title="<div align='center'>Select a specific customer<br />or ALL to list the usage for<br />all your customers.</div>">
				<option value="">ALL
				<cfoutput query="qRepClient">
				<option value="#qRepClient.cust_id#">#qRepClient.cust_name#</option>
				</cfoutput></select>
			</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td align="right">Include:</td>
			<td>
				<input type="checkbox" name="development" value="1" checked class="otrtip" title="<div align='center'>De-select this to explude<br />Development Databases.<br />Environment set to DEV</div>"> Development DB's&nbsp;&nbsp;
				<input type="checkbox" name="internal" value="1" checked class="otrtip" title="<div align='center'>De-select this to explude<br />Internal Databases.<br />Environment set to INT</div>"> Internal DB's (<span class="otrtip" title="Grid Control 10g/Cloud Control 12c" style="cursor: help; border-bottom: 1px dotted;">Enterprise Manager</span>, <span class="otrtip" title="Oracle Recovery Manager" style="cursor: help; border-bottom: 1px dotted;">RMAN</span> & <span class="otrtip" title="NetApp's SnapManager for Oracle" style="cursor: help; border-bottom: 1px dotted;">SMO</span> etc.)
			</td>
		</tr>
		<tr>
			<td colspan="2">&nbsp;</td>
		</tr>
		<tr>
			<td>&nbsp;</td>
			<td><input type="submit" name="qSubmit" id="qSubmit" value="Run Report"></td>
		</tr>
		</table>
		</form>
		<cfelse>
		<table border="0" width="100%" cellpadding="2" cellspacing="2">
		<tr>
			<td align="center">
				<p>
				There are no Snapshots available so we can't generate any usage reports yet.<br />
				If your Setup and Configuration is completed you can now generate a manual Snapshot
				from the menu above <em>New Snapshot</em>.<br />
				When this is done the reporting menu will be displayed.
				</p>
				<!--- Dummy used to fake the Submit Button if No snapshots is created. 
					  This is a quick & dirty fix to avoid a JavaAcript error only --->
				<div name="qSubmit" id="qSubmit"></div>
			</td>
		</tr>
		</table>
		</cfif>
	</td>
	<td align="center" width="160" valign="top">
	<b>Current Status</b><br />
	<div align="center"><iframe src="otr_currtbs.cfm" name="tbsstatus" id="tbsstatus" width="150" marginwidth="0" marginheight="0" frameborder="0"></iframe></div>
	Updated every <cfoutput>#Int(Application.monitoring_cycle * 60)#</cfoutput> Minutes<br />
	For more Info... MouseOver<br />
	the Status column.<br />
	<br />
	<!--- <input type="button" name="bAll" value="ALL">--->
	<a href="javascript:void(0);" class="otrtip" title="<div align='center'>Display Status of all<br />Oracle Instances</div>" onclick="setAllTBS();">All</a> | <a href="javascript:void(0);" class="otrtip" title="<div align='center'>Display Status of<br />Oracle Instances<br />with a problem</div>" onclick="setCurrTBS();">Trouble</a>
	</td>
</tr>
<tr>
	<td align="center" colspan="2" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
