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


<cfquery name="qEM" datasource="OTR_SYSMAN">
	select distinct DATABASE_NAME
	from SYSMAN.MGMT_DB_DBNINSTANCEINFO_ECM
	ORDER BY DATABASE_NAME
</cfquery>

<cfloop query="qEM">
	<!--- Get Listener Port --->
	<cfquery name="qPort" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '<cfoutput>#Trim(qEM.DATABASE_NAME)#</cfoutput>'
		and   b.property_name = 'Port'
	</cfquery>

	<!--- Get Host server --->
	<cfquery name="qHost" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '<cfoutput>#Trim(qEM.DATABASE_NAME)#</cfoutput>'
		and   b.property_name = 'MachineName'
	</cfquery>

	<cfquery name="qCreateDBs" datasource="#Application.datasource#">
		insert into OTRREP.OTR_DB (DB_NAME, DB_ENV, DB_DESC, SYSTEM_PASSWORD, DB_HOST, DB_PORT)
		VALUES ('<cfoutput>#qEM.DATABASE_NAME#</cfoutput>','SEE', '<cfoutput>#qEM.DATABASE_NAME#</cfoutput>', '',
				'<cfoutput>#qHost.property_value#</cfoutput>', <cfoutput>#qPort.property_value#</cfoutput>)
	</cfquery>
</cfloop>

<cflocation url="/otr/otr_setup_db_edit.cfm" addtoken="No" />
<!--- <cflocation url="/otr/otr_setup.cfm" addtoken="no" /> --->
