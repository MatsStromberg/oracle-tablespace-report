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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfif IsDefined("URL.SID")>
	<cfset sOraSID = URL.SID />
<cfelse>
	<cfabort>
</cfif>
<cfquery name="qInstance" datasource="#application.datasource#">
	select db_name, system_password, db_host, db_port, db_rac, db_servicename 
	from otr_db 
	where UPPER(db_name) = '#UCase(Trim(sOraSID))#'
	order by db_name
</cfquery>

<cfset iDBErr = 0 />

<cfif IsDefined("URL.check")>
	<cfif Trim(qInstance.db_port) IS "">
		<!--- Get Listener Port --->
		<cfquery name="qPort" datasource="OTR_SYSMAN">
			select distinct b.property_value
			  from mgmt_target_properties a, mgmt_target_properties b
			 where a.target_guid = b.target_guid
			   and UPPER(a.property_value) = '#Trim(UCase(qInstance.db_name))#'
			   and b.property_name = 'Port'
		</cfquery>
		<cfset iPort = qPort.property_value />
	<cfelse>
		<cfset iPort = qInstance.db_port />
	</cfif>
	<cfif Trim(qInstance.db_host) IS "">
		<!--- Get Host --->
		<cfquery name="qHost" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   UPPER(a.property_value) = '#Trim(UCase(qInstance.db_name))#'
			and   b.property_name = 'MachineName'
		</cfquery>
		<!--- Check if it's a Cluster/RAC --->
		<cfquery name="qRACcheck" datasource="OTR_SYSMAN">
			select database_name, global_name
			  from MGMT$DB_DBNINSTANCEINFO 
			 where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#' 
			   and target_type = 'oracle_database'
		</cfquery>
		<cfif qRACcheck.RecordCount GT 1>
			<cfset bRAC = 1 />
	                <cfquery name="qServiceName" datasource="OTR_SYSMAN">
        	                select distinct global_name
	                          from MGMT$DB_DBNINSTANCEINFO
	                         where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#'
	                </cfquery>
			<cfset sServiceName = qServiceName.global_name />
		<cfelse>
			<cfset bRAC = 0 />
		</cfif>
		<cfset sHost = Trim(qHost.property_value) />
	<cfelse>
                <!--- Check if it's a Cluster/RAC --->
                <cfquery name="qRACcheck" datasource="OTR_SYSMAN">
                        select database_name, global_name
                          from MGMT$DB_DBNINSTANCEINFO
                         where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#'
                           and target_type = 'oracle_database'
                </cfquery>
                <cfif qRACcheck.RecordCount GT 1>
                        <cfset bRAC = 1 />
                        <cfquery name="qServiceName" datasource="OTR_SYSMAN">
                                select distinct global_name
                                  from MGMT$DB_DBNINSTANCEINFO
                                 where UPPER(database_name) = '#Trim(UCase(qInstance.db_name))#'
                        </cfquery>
                        <cfset sHost = Trim(qInstance.db_host) />
			<cfif Trim(qInstance.db_servicename) IS "">
	                        <cfset sServiceName = qServiceName.global_name />
			<cfelse>
				<cfset sServiceName = Trim(qInstance.db_servicename) />
			</cfif>
                <cfelse>
                        <cfset bRAC = 0 />
			<cfset sHost = Trim(qInstance.db_host) />
			<cfset bRAC = 0 />
		</cfif>
	</cfif>

	<!--- Decrypt the SYSTEM Password --->
	<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstance.system_password)) />
	<!--- Create Temporary Data Source --->
	<cfset s = StructNew() />
	<cfif bRAC IS 1>
		<!--- RAC uses hostname:port/service_name --->
		<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(sServiceName)#" />
	<cfelse>
		<!--- Single Instance uses hostname:port:SID --->
		<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstance.db_name)#" />
	</cfif>
	<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
	<cfset s.databasename = "#UCase(qInstance.db_name)#" />
	<cfset s.username     = "system" />
	<cfset s.password     = "#sPassword#" />
	<cfset s.port         = "#iPort#" />

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
	<cfif DataSourceIsValid("#UCase(Trim(qInstance.db_name))#temp")>
		<cfset DataSourceDelete( "#UCase(Trim(qInstance.db_name))#temp" ) />
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
