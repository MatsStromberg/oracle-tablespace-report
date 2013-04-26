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
	2013.04.25	mst	Updated Copyright note
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
<!---
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
<!--- If External Table .DAT Exists --->
<cfif bNoTablespace IS 0>
	<cftry>
		<cfquery name="qTBSxtTest" datasource="#Application.datasource#">
			select db_name
			  from otr_cust_appl_tbs_xt
		</cfquery>
		<cfcatch type="Database">
		</cfcatch>
	</cftry>
</cfif>
--->
<!--- Does the External Table still Exist? --->
<cfset bExtTable = 1 />
<cftry>
	<cfquery name="qTBSextTest" datasource="#Application.datasource#">
		select db_name
		  from otr_cust_appl_tbs_xt
	</cfquery>
	<cfcatch type="Database">
		<cfset bExtTable = 0 />
	</cfcatch>
</cftry>
<!--- Check if the new table exist and if not flag for upgrade.
	  If exist but empty set menu 3 to load data. --->
<cfset bUpgrade = 0 />
<cftry>
	<cfquery name="qTBStest" datasource="#Application.datasource#">
		select db_name
		  from otr_cust_appl_tbs
	</cfquery>
	<cfcatch type="Database">
		<cfset bUpgrade = 1 />
	</cfcatch>
</cftry>
<cfif bUpgrade IS 0>
	<cftry>
		<cfquery name="qASMtableTest" datasource="#Application.datasource#">
			select db_name
			  from otr_asm_space_rep
		</cfquery>
		<cfcatch type="Database">
			<cfset bUpgrade = 1 />
		</cfcatch>
	</cftry>
</cfif>
<cfif bUpgrade IS 0>
	<cfif qTBStest.RecordCount IS 0>
		<cfset bNoTablespace = 1 />
	</cfif>
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
		<cfif bExtTable IS 1>
			<cfif bUpgrade IS 1>
				<li>3. You must run the OTR_TBS_UPGRADE.sql Script and then re-load this page.</li>
			<cfelse>
				<li>3. <a href="otr_setup_copy_tbs.cfm" onfocus="this.blur();">Upgrade the OTR_CUST_APPL_TBS Table.</a></li>
			</cfif>
		<cfelse>
			<cfif bUpgrade IS 1>
				<li>3. You must run the OTR_TBS_UPGRADE.sql Script and then re-load this page.</li>
			<cfelse>
				<cfif bNoTablespace IS 1>
					<li>3. <a href="otr_setup_load_tbs.cfm" onfocus="this.blur();">Load the OTR_CUST_APPL_TBS Table.</a></li>
				</cfif>
			</cfif>
		</cfif>
		<!---
		<cfif bNoTablespace IS 1>
			<li>3. <a href="otr_setup_ext.cfm" onfocus="this.blur();">Create the external table source</a></li>
		<cfelse>
			<li>3. Create the external table source</li>
		</cfif>
		--->
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
