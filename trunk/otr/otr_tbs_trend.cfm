<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
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
<!---
	Long over due Change Log
	2012.05.25	mst	Added some more Tool-Tip's
	2013.04.19	mst	Removed old code about Chart problem on Linux (which was not true)
					This was solved with JAVA_OPTIONS=-Djava.awt.headless=true
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true" />
<cfquery name="qInstance" datasource="#Application.datasource#">
	select db_name 
	from otr_db 
	order by db_name
</cfquery>

<cfquery name="qRepDate" datasource="#Application.datasource#">
	select rep_date 
	from otr_space_rep_timestamps_v 
	order by rep_date
</cfquery>

<cfquery name="qRepYear" datasource="#Application.datasource#">
	select extract(YEAR from rep_date) as rep_year
	from otr_space_rep_timestamps_v 
	group by extract(YEAR from rep_date)
	order by extract(YEAR from rep_date) DESC
</cfquery>
<cfsetting enablecfoutputonly="false" />
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Instance Tablespace Trend</title>
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
function makeDisable(){
    var x=document.getElementById("from_date");
    x.disabled=true;
    var y=document.getElementById("to_date");
    y.disabled=true;
    var z=document.getElementById("year");
    z.disabled=false;
}
function makeEnable(){
    var x=document.getElementById("from_date");
    x.disabled=false;
    var y=document.getElementById("to_date");
    y.disabled=false;
    var z=document.getElementById("year");
    z.disabled=true;
}
function toggle_select(){
	if (document.getElementById("monthly").checked) {
		makeDisable();
	} else {
		makeEnable();
	}
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
			document.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
		else { // IE 4 
			document.all.loaderDiv.style.visibility = 'visible'; 
			document.all.snapshot.location = 'otr_tbs_newsnapshot.cfm';
		} 
	} 
}
// -->
</script>
</head>
<body onload="hideDiv(); makeEnableSubmit();makeEnable();">
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Instance Tablespace Trend</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
<form action="otr_tbs_trend_rep.cfm" "report" method="post">
<table border="0" width="100%" cellpadding="2" cellspacing="2">
<tr>
	<td align="right" width="200">Instance:</td>
	<td width="120">
		<select name="db_name" class="otrtip" title="<div align='center'>Select an Instance for<br />your Trend report.</div>"><cfoutput query="qInstance">
		<option value="#Trim(qInstance.db_name)#">#Trim(qInstance.db_name)#</option>
		</cfoutput></select>
	</td>
	<td align="right" width="150">1 snapshot / Month:</td>
	<td width="50">
		<input type="checkbox" name="monthly" id="monthly" value="1" onclick="toggle_select();" class="otrtip" title="<div align='center'>Select this to just see<br />one snapshot / month for<br />the selected year</div>">
	</td>
	<td align="right" width="20">Year:</td>
	<td width="100">
		<select name="year" id="year" class="otrtip" title="<div align='center'>Select which year this<br />Trend report should contain.</div>"><cfoutput query="qRepYear">
		<option value="#qRepYear.rep_year#">#qRepYear.rep_year#</option>
		</cfoutput></select>
	</td>
	<td align="right" width="50">From:</td>
	<td width="100">
		<select name="from_date" id="from_date" class="otrtip" title="<div align='center'>Select starting snapshot date<br />for your report.</div>"><cfoutput query="qRepDate">
		<option value="#DateFormat(qRepDate.rep_date,"dd-mm-yyyy")#">#DateFormat(qRepDate.rep_date,"dd.mm.yyyy")#</option>
		</cfoutput></select>
	</td>
	<td align="right" width="50">To:</td>
	<td width="100">
		<select name="to_date" id="to_date" class="otrtip" title="<div align='center'>Select ending snapshot date<br />for your report.</div>"><cfoutput query="qRepDate">
		<option value="#DateFormat(qRepDate.rep_date,"dd-mm-yyyy")#"<cfif qRepDate.CurrentRow IS qRepDate.RecordCount> selected</cfif>>#DateFormat(qRepDate.rep_date,"dd.mm.yyyy")#</option>
		</cfoutput></select>
	</td>
	<td>&nbsp;</td>
</tr>
<tr>
	<td colspan="11"><!---<a href="javascript:showDiv();">ShowDiv</a> <a href="javascript:hideDiv();">HideDiv</a>--->&nbsp;</td>
</tr>
<tr>
	<!---<td>&nbsp;</td>--->
	<td colspan="11" align="center"><input type="submit" name="qSubmit" id="qSubmit" value="Show Trend"></td>
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
</div>
<!--- <cfdump var="#CGI#"> --->
</body>
</html></cfprocessingdirective>
