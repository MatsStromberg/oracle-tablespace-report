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
<cfquery name="qInsert" datasource="#application.datasource#">
<cfif IsDefined("FORM.system_password") AND Trim(FORM.system_password GT "")>
	insert into otr_db
			(db_name, db_env, db_desc, system_password) 
	 VALUES (<cfqueryparam value="#FORM.db_name#" cfsqltype="cf_sql_varchar" />,
			 <cfqueryparam value="#FORM.db_env#"  cfsqltype="cf_sql_varchar" />,
	 		 <cfqueryparam value="#FORM.db_desc#" cfsqltype="cf_sql_varchar" />,
	 		 <cfqueryparam value="#Application.pw_hash.encryptOraPW(Trim(FORM.system_password))#" cfsqltype="cf_sql_varchar" />)
<cfelse>
	insert into otr_db
			(db_name, db_env, db_desc) 
	 VALUES (<cfqueryparam value="#FORM.db_name#" cfsqltype="cf_sql_varchar" />,
			 <cfqueryparam value="#FORM.db_env#"  cfsqltype="cf_sql_varchar" />,
	 		 <cfqueryparam value="#FORM.db_desc#" cfsqltype="cf_sql_varchar" />)
</cfif>
</cfquery>

<cfquery name="qDBLinkCheck" datasource="#application.datasource#">
	select * from user_db_links
	where db_link = <cfqueryparam value="#FORM.db_name#.#application.oracle.domain_name#" cfsqltype="cf_sql_varchar">
</cfquery>

<cfset link_name = #Trim(FORM.db_name)# & ".#Trim(application.oracle.domain_name)#" />
<cfif qDBLinkCheck.RecordCount IS 0>
	<cfquery name="qCreateDBLink" datasource="#application.datasource#">
		create database link "#link_name#" connect to "#Application.dbusername#" identified by "#application.dbpassword#" using '#link_name#'
	</cfquery>
</cfif>

<cflocation url="otr_db.cfm" addtoken="No">
