<!---
    Copyright (C) 2010-2013 - Oracle Tablespace Report Project - http://www.network23.net
    
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
	2013.04.25	mst	Updated Copyright note
--->
<cfquery name="qDelete" datasource="#application.datasource#">
	delete from otr_db
	where db_name = <cfqueryparam value="#URL.db_name#" cfsqltype="cf_sql_varchar" />
</cfquery>
<cfquery name="qDelete" datasource="#application.datasource#">
	delete from otr_db_space_rep
	where db_name = <cfqueryparam value="#URL.db_name#" cfsqltype="cf_sql_varchar" />
</cfquery>
<cfquery name="qDBLinkCheck" datasource="#application.datasource#">
	select * from user_db_links
	where db_link = <cfqueryparam value="#URL.db_name#.#application.oracle.domain_name#" cfsqltype="cf_sql_varchar">
</cfquery>
<cfset link_name = #Trim(URL.db_name)# & ".#Trim(application.oracle.domain_name)#" />
<cfif qDBLinkCheck.RecordCount GTE 1>
	<cfquery name="qDropDBLink" datasource="#application.datasource#">
		drop database link "#link_name#"
	</cfquery>
</cfif>

<cflocation url="otr_db.cfm" addtoken="No">
