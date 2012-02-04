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

<!--- Update OTR_DB with Host name and Listener Port --->
<cfquery name="qDB" datasource="#Application.datasource#">
	select DB_NAME
	from OTR_DB
	ORDER BY DB_NAME
</cfquery>
<!---
<cfoutput query="qDB">
	<!--- Get Listener Port --->
	<cfquery name="qP" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '#Trim(qDB.DB_NAME)#'
		and   b.property_name = 'Port'
	</cfquery>

	<!--- Get Listener Port --->
	<cfquery name="qH" datasource="OTR_SYSMAN">
		select distinct b.property_value
		from mgmt_target_properties a, mgmt_target_properties b
		where a.target_guid = b.target_guid
		and   a.property_value = '#Trim(qDB.DB_NAME)#'
		and   b.property_name = 'MachineName'
	</cfquery>

	<cfquery name="qUpdateDBs" datasource="#Application.datasource#">
		update OTRREP.OTR_DB 
		   set DB_HOST = '#qH.property_value#', 
		       DB_PORT = #qP.property_value#
		 where DB_NAME = '#Trim(qDB.DB_NAME)#'
	</cfquery>
</cfoutput>

<!--- Update OTR_CUST_APPL_TBS from OTR_CUST_APPL_TBS_XT --->
<cfquery name="qOldTBS" datasource="#Application.datasource#">
	select CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME
	  from OTR_CUST_APPL_TBS_XT
	order by DB_NAME, DB_TBS_NAME
</cfquery>

<cfoutput query="qOldTBS">
	<cfquery name="qNewTBS" datasource="#Application.datasource#">
		insert into OTR_CUST_APPL_TBS
		 (CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME)
		values ('#qOldTBS.CUST_ID#','#qOldTBS.CUST_APPL_ID#','#qOldTBS.DB_NAME#','#qOldTBS.DB_TBS_NAME#')
	</cfquery>
</cfoutput>
--->
<!--- Pickup Thresholds from Target DB's --->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select distinct a.db_name, b.system_password
	  from otr_cust_appl_tbs a, otr_db b
	 where a.db_name = b.db_name
	order by a.db_name
</cfquery>

<cfloop query="qInstances">
	<cftry>
		<cfoutput>#qInstances.db_name#</cfoutput><br />
		<!--- Get Listener Port --->
		<cfquery name="qPort" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   a.property_value = '<cfoutput>#Trim(qInstances.db_name)#</cfoutput>'
			and   b.property_name = 'Port'
		</cfquery>

		<!--- Get Host server --->
		<cfquery name="qHost" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   a.property_value = '<cfoutput>#Trim(qInstances.db_name)#</cfoutput>'
			and   b.property_name = 'MachineName'
		</cfquery>

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qHost.property_value)#:#qPort.property_value#:#UCase(qInstances.db_name)#" />
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#qPort.property_value#" />

		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate("#UCase(qInstances.db_name)#temp", s) />
		</cfif>
		<!--- Lookup Default Threshold --->
		<cfquery name="qTHdefault" datasource="#UCase(qInstances.db_name)#temp">
			select warning_value, critical_value
			 from sys.dba_thresholds
			where metrics_name = 'Tablespace Space Usage'
			  and nvl(object_name,'-OTR-TBS-') = '-OTR-TBS-'
		</cfquery>
		<!--- Update all thresholds to Default values --->
		<cfoutput query="qTHdefault">
			<cfquery name="qUpdateDefault" datasource="#Application.datasource#">
				update otr_cust_appl_tbs
					set threshold_warning = #Int(qTHdefault.warning_value)#,
					    threshold_critical = #Int(qTHdefault.critical_value)#
				 where db_name = '#UCase(qInstances.db_name)#'
			</cfquery>
		</cfoutput>
		<!--- Lookup all none-default Thresholds --->	
		<cfquery name="qTH" datasource="#UCase(qInstances.db_name)#temp">
			select warning_value, critical_value, object_name
			 from sys.dba_thresholds
			where metrics_name like '%Tablespace Space Usage'
			  and nvl(object_name,'-OTR-TBS-') <> '-OTR-TBS-'
		</cfquery>
		<!--- Update all none-defaull values --->
		<cfoutput query="qTH">
			<cfquery name="qUpdateNoneDefault" datasource="#Application.datasource#">
				update otr_cust_appl_tbs
					set threshold_warning = #Int(qTH.warning_value)#,
					    threshold_critical = #Int(qTH.critical_value)#
				 where db_name = '#UCase(qInstances.db_name)#'
				   and db_tbs_name = '#qTH.object_name#'
			</cfquery>
		</cfoutput>
		<cfcatch type="Database">
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
			</cfif>
			<cfset iDBErr = 1>
		</cfcatch>
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
	</cftry>
</cfloop>

<cflocation url="/otr/otr_setup.cfm" addtoken="no" />
