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

<!--- Pickup Thresholds from Target DB's --->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select distinct db_name, db_host, db_port, system_password, db_rac, db_servicename
	  from otr_db
	order by db_name
</cfquery>

<cfloop query="qInstances">
	<cftry>
		<cfoutput>#qInstances.db_name#</cfoutput><br />

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfif qInstances.db_rac IS 1>
                        <cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qInstances.db_host)#:#qInstances.db_port#/#UCase(qInstances.db_servicename)#" />
		<cfelse>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(qInstances.db_host)#:#qInstances.db_port#:#UCase(qInstances.db_name)#" />
		</cfif>
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#qInstances.db_port#" />

		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate("#UCase(qInstances.db_name)#temp", s) />
		</cfif>

		<!--- Get all tablespaces except SYSTEM, SYSAUX, TEMP% and UNDO% --->
		<cfquery name="qAllTBS" datasource="#UCase(qInstances.db_name)#temp">
			select tablespace_name 
			  from dba_tablespaces
			 where tablespace_name NOT IN ('SYSTEM','SYSAUX')
			   and tablespace_name NOT LIKE 'TEMP%'
			   and tablespace_name NOT LIKE 'UNDO%'
		</cfquery>
		<!--- Lookup the first created customer --->
		<cfquery name="qCust" datasource="#Application.datasource#">
			select cust_id
			  from otr_cust
		</cfquery>
		<!--- Lookup Application Info --->
		<cfquery name="qApplID" datasource="#Application.datasource#">
			select db_desc
			  from otr_db
			 where UPPER(db_name) = '#UCase(qInstances.db_name)#'
		</cfquery>
		<!--- Create Basis Tablespace Info for the Instance --->
		<cfloop query="qAllTBS">
			<cfquery name="qCreateTBS" datasource="#Application.datasource#">
				insert into otr_cust_appl_tbs
				       (cust_id, cust_appl_id, db_name, db_tbs_name)
				       VALUES ('#qCust.cust_id#', '#qApplID.db_desc#', 
				               '#UCase(qInstances.db_name)#', '#qAllTBS.tablespace_name#')
			</cfquery>
		</cfloop>
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
