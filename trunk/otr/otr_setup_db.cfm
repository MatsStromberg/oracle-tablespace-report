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
<!--- 
	Long over due Change Log
	2012.05.20	mst	Adding comments and picking up Info about ASM Storage.
--->

<!--- Get Instances from Enterprise Manager Repository --->
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

<cfquery name="qInstances" datasource="#Application.datasource#">
	select db_name, system_password, db_host, db_port, db_asm, db_rac, db_servicename
	  from otr_db
  order by db_name
</cfquery>

<cfoutput query="qInstances">
	<cfif Trim(qInstances.system_password) IS NOT "" AND qInstances.db_blackout IS 0>
	<cftry>
		<cfif Trim(qInstances.db_port) IS "">
			<!--- Get Listener Port from EM --->
			<cfquery name="qPort" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'Port'
			</cfquery>
			<cfset iPort = qPort.property_value />
		<cfelse>
			<cfset iPort = qInstances.db_port />
		</cfif>

		<cfif Trim(qInstances.db_host) IS "" >
			<!--- Get Host server from EM --->
			<cfquery name="qHost" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'MachineName'
			</cfquery>
			<cfset sHost = Trim(qHost.property_value) />
		<cfelse>
			<cfset sHost = Trim(qInstances.db_host) />
		</cfif>

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfif qInstances.db_rac IS 1>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
		<cfelse>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
		</cfif>
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#iPort#" />

		<!--- If Temporary Datasource exists... Delete it --->
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>
		<!--- Create a Temporary Datasource for the Instance --->
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate( "#UCase(qInstances.db_name)#temp", s ) />
		</cfif>

		<!--- Check if the Instance is using ASM --->
		<cfquery name="qASM" datasource="#UCase(qInstances.db_name)#temp">
			select distinct SUBSTR(file_name,1,1) asm
			  from dba_data_files
			 where SUBSTR(file_name,1,1) = '+'
		</cfquery>
		<cfif qASM.RecordCount IS 1>
			<cfset bASM = 1 />
		<cfelse>
			<cfset bASM = 0 />
		</cfif>
		<!--- Update OTR Repository --->
		<cfquery name="qUpdateASM" datasource="#Application.datasource#">
		   update otr_db
		   set db_asm = #bASM#
		  where UPPER(db_name) = '#Trim(UCase(qInstances.db_name))#'
		</cfquery>

		<!--- If Temporary Datasource exists... Delete it --->
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>

		<cfcatch type="Database">
			<!--- If Temporary Datasource exists... Delete it --->
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
			</cfif>
			<!--- <cfdump var="#cfcatch#"> --->
		</cfcatch>
	</cftry>

</cfquery>

<cflocation url="/otr/otr_setup_db_edit.cfm" addtoken="No" />
<!--- <cflocation url="/otr/otr_setup.cfm" addtoken="no" /> --->
