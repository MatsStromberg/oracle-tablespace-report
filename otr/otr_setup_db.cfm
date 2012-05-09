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


<cfquery name="qEM" datasource="OTR_SYSMAN">
	select distinct database_name
	from sysman.mgmt_db_dbninstanceinfo_ecm
	order by database_name
</cfquery>

<cfloop query="qEM">
	<!--- Get Listener Port --->
	<cfquery name="qPort" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '<cfoutput>#Trim(UCase(qEM.database_name))#</cfoutput>'
		   and b.property_name = 'Port'
	</cfquery>

	<!--- Get Host server --->
	<cfquery name="qHost" datasource="OTR_SYSMAN">
		select distinct b.property_value
		  from mgmt_target_properties a, mgmt_target_properties b
		 where a.target_guid = b.target_guid
		   and UPPER(a.property_value) = '<cfoutput>#Trim(UCase(qEM.database_name))#</cfoutput>'
		   and b.property_name = 'MachineName'
	</cfquery>

	<!--- Check if it's a Cluster/RAC --->
	<cfquery name="qRACcheck" datasource="OTR_SYSMAN">
		select database_name, global_name
		  from mgmt$db_dbninstanceinfo
		 where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#'
		   and target_type = 'oracle_database'
	</cfquery>
	<cfif qRACcheck.RecordCount GT 1>
		<cfset bRAC = 1 />
		<cfquery name="qServiceName" datasource="OTR_SYSMAN">
			select distinct global_name
			  from mgmt$db_dbninstanceinfo
			 where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#'
		</cfquery>
		<cfset sServiceName = qServiceName.global_name />
	<cfelse>
		<cfset bRAC = 0 />
		<cfset sServiceName = "" />
	</cfif>
	<cfset sHost = Trim(qHost.property_value) />


	<cfquery name="qCreateDBs" datasource="#Application.datasource#">
		insert into otrrep.otr_db (db_name, db_env, db_desc, system_password, db_host, db_port, db_rac, db_servicename)
		values (<cfoutput>'#qEM.database_name#','SEE', '#qEM.database_name#', '',
			'#qHost.property_value#', #qPort.property_value#, #bRAC#,'#sServiceName#'</cfoutput>)
	</cfquery>
</cfloop>

<cflocation url="/otr/otr_setup_db_edit.cfm" addtoken="No" />
<!--- <cflocation url="/otr/otr_setup.cfm" addtoken="no" /> --->
