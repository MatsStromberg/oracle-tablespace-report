<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
    Contributing Developers:
    Mats Str�mberg - ms@network23.net

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
	2012.05.20	mst	Delete of commented out code.
	2013.04.17	mst	Added SYSTEM Username
--->
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<!--- Pickup Thresholds from Target DB's --->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select distinct a.db_name, b.system_username, b.system_password, b.db_host, b.db_port, b.db_rac, b.db_servicename
	  from otr_cust_appl_tbs a, otr_db b
	 where UPPER(a.db_name) = UPPER(b.db_name)
	order by a.db_name
</cfquery>

<cfloop query="qInstances">
	<cftry>
		<cfoutput>#qInstances.db_name#</cfoutput><br />
		
		<cfif Trim(qInstances.db_port) IS "">
			<!--- Get Listener Port --->
			<cfquery name="qPort" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '<cfoutput>#Trim(UCase(qInstances.db_name))#</cfoutput>'
				and   b.property_name = 'Port'
			</cfquery>
			<cfset iPort = #qPort.property_value# />
		<cfelse>
			<cfset iPort = #qInstances.db_port# />
		</cfif>

		<cfif Trim(qInstances.db_host) IS "">
			<!--- Get Host server --->
			<cfquery name="qHost" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '<cfoutput>#Trim(UCase(qInstances.db_name))#</cfoutput>'
				and   b.property_name = 'MachineName'
			</cfquery>
			<cfset sHost = #Trim(qHost.property_value)# />
		<cfelse>
			<cfset sHost = Trim(qInstances.db_host) />
		</cfif>

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Application.pw_hash.decryptOraPW(Trim(qInstances.system_password), Trim(sHashKey)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfif qInstances.db_rac IS 1>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
		<cfelse>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
		</cfif>
		<!--- <cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qHost.property_value)#:#qPort.property_value#:#UCase(qInstances.db_name)#" /> --->
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "#UCase(qInstances.system_username)#" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#iPort#" />

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
