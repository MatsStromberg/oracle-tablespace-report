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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!--- 
	Long over due Change Log
	2012.05.20	mst	Fixed the qUpdate Query.
--->
<cfquery name="qUpdate" datasource="#Application.datasource#">
   update otr_db
   set db_name = <cfqueryparam value="#FORM.db_name#" cfsqltype="cf_sql_varchar" />,
	db_env = <cfqueryparam value="#FORM.db_env#" cfsqltype="cf_sql_varchar" />,
	db_desc = <cfqueryparam value="#FORM.db_desc#" cfsqltype="cf_sql_varchar" />,
	system_password = <cfqueryparam value="#Application.pw_hash.encryptOraPW(Trim(FORM.system_password))#" cfsqltype="cf_sql_varchar" />,
	db_host = <cfqueryparam value="#FORM.db_host#" cfsqltype="cf_sql_varchar" />,
	db_port = <cfqueryparam value="#FORM.db_port#" cfsqltype="cf_sql_integer" />,
	<cfif IsDefined("FORM.db_asm")>
		db_asm = 1,
	<cfelse>
		db_asm = 0,
	</cfif>
	<cfif IsDefined("FORM.db_rac")>
		db_rac = 1,
	<cfelse>
		db_rac = 0,
	</cfif>
	db_servicename = <cfqueryparam value="#FORM.db_servicename#" cfsqltype="cf_sql_varchar" />
  where UPPER(db_name) = <cfqueryparam value="#UCase(FORM.old_db_name)#" cfsqltype="cf_sql_varchar" />
</cfquery>

<!--- Decrypt the SYSTEM Password --->
<cfset sPassword = Trim(FORM.system_password) />
<!--- Create Temporary Data Source --->
<cfset s = StructNew() />
<cfif IsDefined("FORM.db_rac")>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(Trim(FORM.db_host))#:#Trim(FORM.db_port)#/#UCase(Trim(FORM.db_servicename))#" />
<cfelse>
	<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(Trim(FORM.db_host))#:#Trim(FORM.db_port)#:#UCase(Trim(FORM.db_name))#" />
</cfif>
<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
<cfset s.databasename = "#UCase(Trim(FORM.db_name))#" />
<cfset s.username     = "system" />
<cfset s.password     = "#sPassword#" />
<cfset s.port         = "#Trim(FORM.db_port)#" />

<cfif DataSourceIsValid("#UCase(Trim(FORM.db_name))#temp")>
	<cfset DataSourceDelete( "#UCase(Trim(FORM.db_name))#temp" ) />
</cfif>
<cfif NOT DataSourceIsValid("#UCase(Trim(FORM.db_name))#temp")>
	<cfset DataSourceCreate( "#UCase(Trim(FORM.db_name))#temp", s ) />
</cfif>
<cftry>
	<cfquery name="qCheck" datasource="#UCase(Trim(FORM.db_name))#temp">
		select * from v$instance
	</cfquery>
	<cfif qCheck.RecordCount IS NOT 0><cfset iDBErr = 0></cfif>
	<cfif iDBErr IS 0>
		<cfquery name="qASM" datasource="#UCase(Trim(FORM.db_name))#temp">
			select distinct SUBSTR(file_name,1,1) asm
			  from dba_data_files
			 where SUBSTR(file_name,1,1) = '+'
		</cfquery>
		<cfif qASM.RecordCount IS 1>
			<cfset bASM = 1 />
		<cfelse>
			<cfset bASM = 0 />
		</cfif>
		<cfquery name="qUpdate" datasource="#Application.datasource#">
		   update otr_db
		   set db_asm = #bASM#
		  where UPPER(db_name) = <cfqueryparam value="#UCase(FORM.db_name)#" cfsqltype="cf_sql_varchar" />
		</cfquery>

	</cfif>
	<cfcatch type="Database">
		<cfset iDBErr = 1>
	</cfcatch>
</cftry>
<cfif DataSourceIsValid("#UCase(Trim(FORM.db_name))#temp")>
	<cfset DataSourceDelete( "#UCase(Trim(FORM.db_name))#temp" ) />
</cfif>

<cfif iDBErr IS 1>
	<cfquery name="qReset" datasource="#Application.datasource#">
		update otr_db
		set system_password = '$NONE$'
		where db_name = <cfqueryparam value="#FORM.db_name#" cfsqltype="cf_sql_varchar" />
	</cfquery>
	<cflocation url="otr_setup_db_edit.cfm?ERROR=Yes" addtoken="No">
<cfelse>
	<cflocation url="otr_setup_db_edit.cfm" addtoken="No">
</cfif>
