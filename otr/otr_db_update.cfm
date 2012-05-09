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
<cfquery name="qUpdate" datasource="#application.datasource#">
update otr_db
set db_name = <cfqueryparam value="#FORM.db_name#" cfsqltype="cf_sql_varchar" />,
	db_env = <cfqueryparam value="#FORM.db_env#" cfsqltype="cf_sql_varchar" />,
	db_desc = <cfqueryparam value="#FORM.db_desc#" cfsqltype="cf_sql_varchar" />,
	system_password = <cfqueryparam value="#Application.pw_hash.encryptOraPW(Trim(FORM.system_password))#" cfsqltype="cf_sql_varchar" />,
	db_host = <cfqueryparam value="#FORM.db_host#" cfsqltype="cf_sql_varchar" />,
	db_port = <cfqueryparam value="#FORM.db_port#" cfsqltype="cf_sql_integer" />,
	<cfif IsDefined("FORM.db_rac")>
		db_rac = <cfqueryparam value="#FORM.db_rac#" cfsqltype="cf_sql_integer" />,
	<cfelse>
		db_rac = 0,
	</cfif>
	db_servicename = <cfqueryparam value="#FORM.db_servicename#" cfsqltype="cf_sql_varchar" />
where db_name = <cfqueryparam value="#FORM.old_db_name#" cfsqltype="cf_sql_varchar" />
</cfquery>

<cflocation url="otr_db.cfm" addtoken="No">
