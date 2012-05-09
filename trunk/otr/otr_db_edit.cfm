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

<cfquery name="qEdit" datasource="#application.datasource#">
	select db_name, db_env, db_desc, system_password, db_host, db_port, db_rac, db_servicename
	from otr_db 
	where db_name = '#URL.db_name#'
	order by db_name
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Edit Oracle Instance</title>
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
		document.getElementById("snapshot").src = 'otr_tbs_newsnapshot.cfm';
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
<h2><cfoutput>#application.company#</cfoutput> - Edit Oracle Instance</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<cfoutput query="qEdit">
	<form action="otr_db_update.cfm" method="post">
	<input type="Hidden" name="old_db_name" value="#Trim(qEdit.db_name)#">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">Oracle SID:&nbsp;</td>
		<td width="150"><input type="text" name="db_name" id="db_name" value="#Trim(qEdit.db_name)#" size="10"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold; text-align: right">Environment:&nbsp;</td>
		<td width="150">
			<select name="db_env">
				<option value="DEE"<cfif Trim(qEdit.db_env) IS "DEE"> selected</cfif>>(DEE) Dedicated Enterprise Edition</option>
				<option value="DSE"<cfif Trim(qEdit.db_env) IS "DSE"> selected</cfif>>(DSE) Dedicated Standard Edition</option>
				<option value="SEE"<cfif Trim(qEdit.db_env) IS "SEE"> selected</cfif>>(SEE) Shared Enterprise Edition</option>
				<option value="SSE"<cfif Trim(qEdit.db_env) IS "SSE"> selected</cfif>>(SSE) Shared Standard Edition</option>
				<option value="DEV"<cfif Trim(qEdit.db_env) IS "DEV"> selected</cfif>>(DEV) Deevelopment Enterprise Edition</option>
				<option value="INT"<cfif Trim(qEdit.db_env) IS "INT"> selected</cfif>>(INT) Internal Enterprise Edition</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Description:&nbsp;</td>
		<td width="300"><input type="text" name="db_desc" id="db_desc" value="#Trim(qEdit.db_desc)#" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">SYSTEM Password:&nbsp;</td>
		<td width="300"><input type="password" name="system_password" id="system_password" value="<cfif Trim(qEdit.system_password) GT "">#Application.pw_hash.decryptOraPW(Trim(qEdit.system_password))#</cfif>" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Hostname:&nbsp;</td>
		<td width="300"><input type="text" name="db_host" id="db_host" value="#Trim(qEdit.db_host)#" size="33"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Listener Port:&nbsp;</td>
		<td width="300"><input type="text" name="db_port" id="db_port" value="#Trim(qEdit.db_port)#" size="6"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">RAC Instance:&nbsp;</td>
		<td width="300"><input type="checkbox" name="db_rac" id="db_rac" value="1"<cfif qEdit.db_rac IS 1> checked</cfif>></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Service Name:&nbsp;</td>
		<td width="300"><input type="text" name="db_servicename" id="db_servicename" value="#Trim(qEdit.db_servicename)#" size="33"></td>
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
