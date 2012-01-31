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
<cfif IsDefined("URL.SID")>
	<cfset sOraSID = URL.SID />
<cfelse>
	<cfabort>
</cfif>
<cfquery name="qInstance" datasource="#application.datasource#">
	select db_name, system_password 
	from otr_db 
	where db_name = '#UCase(Trim(sOraSID))#'
	order by db_name
</cfquery>

<cfset iDBErr = 0 />

<cfif IsDefined("URL.check")>
	<!--- Get Listener Port --->
	<cfquery name="qPort" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '#Trim(qInstance.db_name)#'
		and   b.property_name = 'Port'
	</cfquery>
	<!--- Get Listener Port --->
	<cfquery name="qHost" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '#Trim(qInstance.db_name)#'
		and   b.property_name = 'MachineName'
	</cfquery>

	<!--- Decrypt the SYSTEM Password --->
	<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstance.system_password)) />
	<!--- Create Temporary Data Source --->
	<cfset s = StructNew() />
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qHost.property_value)#:#qPort.property_value#:#UCase(qInstance.db_name)#" />
	<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
	<cfset s.databasename = "#UCase(qInstance.db_name)#" />
	<cfset s.username     = "system" />
	<cfset s.password     = "#sPassword#" />
	<cfset s.port         = "#qPort.property_value#" />

	<cfif DataSourceIsValid("#UCase(qInstance.db_name)#temp")>
		<cfset DataSourceDelete( "#UCase(qInstance.db_name)#temp" ) />
	</cfif>
	<cfif NOT DataSourceIsValid("#UCase(qInstance.db_name)#temp")>
		<cfset DataSourceCreate( "#UCase(qInstance.db_name)#temp", s ) />
	</cfif>
	<cftry>
		<cfquery name="qCheck" datasource="#UCase(qInstance.db_name)#temp">
			select * from v$instance
		</cfquery>
		<cfif qCheck.RecordCount IS NOT 0><cfset iDBErr = 2></cfif>
		<cfcatch type="Database">
			<cfset iDBErr = 1>
		</cfcatch>
	</cftry>
	<cfif DataSourceIsValid("#UCase(Trim(FORM.db_name))#temp")>
		<cfset DataSourceDelete( "#UCase(Trim(FORM.db_name))#temp" ) />
	</cfif>
</cfif>
<cfsetting enablecfoutputonly="false">
<html>
	<head>
		<title></title>
	</head>
	<body margin=0>
		<cfif IsDefined("URL.check")>
			<a href="<cfoutput>otr_system_test.cfm?SID=#sOraSID#&check=yes</cfoutput>" onfocus="this.blur();"><cfif iDBErr IS 1><img src="images/check_error.png" alt="Wrong Password" width="30" height="20" border="0"></cfif><cfif iDBErr IS 2><img src="images/check_ok.png" alt="Password Correct" width="30" height="20" border="0"></cfif></a>
		<cfelse>
			<a href="<cfoutput>otr_system_test.cfm?SID=#sOraSID#&check=yes</cfoutput>" onfocus="this.blur();"><img src="images/check.png" alt="Not Checked" width="30" height="20" border="0"></a>
		</cfif>
		<cfif DataSourceIsValid("#UCase(qInstance.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstance.db_name)#temp" ) />
		</cfif>
	</body>
</html></cfprocessingdirective>