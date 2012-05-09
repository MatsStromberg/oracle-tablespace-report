<cfsetting enablecfoutputonly="true" />
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
<cfset cDirSep = FileSeparator()>
<cfquery name="qParFile" datasource="#application.datasource#">
	select * from otr_cust_appl_tbs
</cfquery>

<CFHEADER NAME="Content-Disposition" VALUE="inline; filename=OTR_CUST_APPL_TBS.csv">
<cfcontent type="application/vnd.ms-excel; name='excel'">
<cfoutput query="qParFile">#Trim(qParFile.cust_id)#;#Trim(qParFile.cust_appl_id)#;#Trim(qParFile.db_name)#;#Trim(qParFile.db_tbs_name)#;#Trim(qParFile.threshold_warning)#;#Trim(qParFile.threshold_critical)#
</cfoutput><cfsetting enablecfoutputonly="false" />