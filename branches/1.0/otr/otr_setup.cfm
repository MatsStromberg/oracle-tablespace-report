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
<!--- Customers available? --->
<cfquery name="qRepClient" datasource="#Application.datasource#">
	select cust_id, cust_name 
	  from otr_cust 
	 order by cust_name
</cfquery>
<!--- Instances available ? --->
<cfquery name="qDBInstances" datasource="#Application.datasource#">
	select db_name
	  from otr_db
</cfquery>

<cfset cDirSep = FileSeparator() />
<cfset sPath = ExpandPath('/') />
<cfset sTemplatePath = GetDirectoryfrompath(GetBasetemplatePath()) />
<cfset bNoTablespace = 0 />
<!--- Does the file exist ? If not it's a new Setup --->
<cfif cDirSep IS "/">
	<cfset sFileCheck = #Application.ogc_external_table# & #cDirSep# & "OTR_CUST_APPL_TBS_XT.DAT" />
<cfelse>
	<cfset sFileCheck = #sTemplatePath# & #cDirSep# & "OTR_CUST_APPL_TBS_XT.DAT" />
</cfif>
<!--- Create a new OTR_CUST_APPL_TBS_XT.DAT if it doesn't exists --->
<cfif NOT FileExists(sFileCheck)>
	<cfset bNoTablespace = 1 />
</cfif>
<!--- atleast one DB-Instance and one Customer exists --->
<cfif qRepClient.RecordCount IS NOT 0 AND qDBInstances.RecordCount IS NOT 0 AND bNoTablespace IS 0>
	<cflocation url="/otr/index.cfm" addtoken="no" />
</cfif>
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">

</head>

<body>
<cfinclude template="_otr_menu_setup.cfm">
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report - Setup</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
		<strong>OTR Setup Menu</strong>
		<table border="0" width="400">
			<tr>
				<td>
		<ul>
		<cfif qDBInstances.RecordCount IS 0>
			<li>1. <a href="otr_setup_db.cfm" onfocus="this.blur();">Get Instances from your EM Repository</a></li>
		<cfelse>
			<li>1. Get Instances from your EM Repository</li>
		</cfif>
		<cfif qRepClient.RecordCount IS 0>
			<li>2. <a href="otr_setup_cust.cfm" onfocus="this.blur();">Create atleast 1 customer (Your self)</a></li>
		<cfelse>
			<li>2. Create atleast 1 customer (Your self)</li>
		</cfif>
		<cfif bNoTablespace IS 1>
			<li>3. <a href="otr_setup_ext.cfm" onfocus="this.blur();">Create the external table source</a></li>
		<cfelse>
			<li>3. Create the external table source</li>
		</cfif>
		</ul>
				</td>
			</tr>
		</table>
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
