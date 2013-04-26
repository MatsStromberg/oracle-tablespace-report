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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!---
	Long over due Change Log
	2013.04.17	mst	Added SYSTEM Username
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<cfquery name="qEdit" datasource="#Application.datasource#" maxrows="1">
	select db_name, db_env, db_desc, system_username, system_password, db_host, db_port, db_asm, db_rac, db_servicename
	from otr_db 
	where NVL(system_password,'$NONE$') = '$NONE$'
	order by db_name
</cfquery>

<cfif qEdit.RecordCount IS 0>
	<!--- All System Passwords are set --->
	<cflocation url="/otr/otr_setup.cfm" addtoken="no" />
</cfif>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Edit Oracle Instance</title>
<cfinclude template="_otr_css.cfm">
</head>
<body>
<cfinclude template="_otr_menu_setup.cfm">
<div align="center">
<h2><cfoutput>#Application.company#</cfoutput> - Edit Oracle Instance</h2>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<cfoutput query="qEdit">
	<form action="otr_setup_db_update.cfm" method="post">
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
				<option value="DEV"<cfif Trim(qEdit.db_env) IS "DEV"> selected</cfif>>(DEV) Development Enterprise Edition</option>
				<option value="INT"<cfif Trim(qEdit.db_env) IS "INT"> selected</cfif>>(INT) Internal Enterprise Edition</option>
			</select>
		</td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">Description:&nbsp;</td>
		<td width="300"><input type="text" name="db_desc" id="db_desc" value="#Trim(qEdit.db_desc)#" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">SYSTEM Username:&nbsp;</td>
		<td width="300"><input type="text" name="system_username" id="system_username" value="#Trim(qEdit.system_username)#" size="35"></td>
	</tr>
	<tr>
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">SYSTEM Password:&nbsp;</td>
		<td width="300"><input type="password" name="system_password" id="system_password" value="<cfif Trim(qEdit.system_password) GT "" AND Trim(qEdit.system_password) IS NOT "$NONE$">#Application.pw_hash.decryptOraPW(Trim(qEdit.system_password), Trim(sHashKey))#</cfif>" size="35"><cfif URL.Error = "Yes">&nbsp;<img src="images/check_error.png" alt="Wrong Password" width="30" height="20" border="0"></cfif></td>
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
		<td width="300" align="right" style="font-size: 9pt;font-weight: bold;">ASM Storage:&nbsp;</td>
		<td width="300"><input type="checkbox" name="db_asm" id="db_asm" value="1"<cfif qEdit.db_asm IS 1> checked</cfif>></td>
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
