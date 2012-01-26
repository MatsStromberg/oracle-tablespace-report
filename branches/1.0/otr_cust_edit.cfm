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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfquery name="qRepClient" datasource="#application.datasource#">
	select cust_id, cust_name 
	  from otr_cust 
	 where cust_id = '#URL.cust_id#'
	 order by cust_name
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Edit Oracle Customers</title>
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
// -->
</script>
</head>
<body>
<cfinclude template="_top_menu.cfm">
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Edit Oracle Customers</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<cfoutput query="qRepClient">
	<form action="otr_cust_update.cfm" method="post">
	<input type="Hidden" name="old_cust_id" value="#Trim(qRepClient.cust_id)#">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">Company ID:&nbsp;</td>
		<td width="150"><input type="text" name="cust_id" id="cust_id" value="#Trim(qRepClient.cust_id)#" size="3" onChange="javascript:this.value=this.value.toUpperCase();"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Name of Company:&nbsp;</td>
		<td width="300"><input type="text" name="cust_name" id="cust_name" value="#Trim(qRepClient.cust_name)#" size="30"></td>
	</tr>
	<tr>
		<td colspan="2">&nbsp;</td>
	</tr>
	<tr>
		<td align="center" colspan="2"><input value="Update" id="qSubmit" type="submit">&nbsp;&nbsp;&nbsp;<input type="reset" id="qReset"></td>
	</tr>
	</table>
	</form>
	</cfoutput>
	</td>
</tr>
</table>
</div>
</body>
</html></cfprocessingdirective>
