<!---
    Copyright (C) 2011 - Oracle Tablespace Report Project - http://www.network23.net
    
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
	
	The Oracle Tablespace Report do need an Oracle Grid Control 10g Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<cfquery name="qHostInstances" datasource="#application.datasource#">
	select distinct a.hostname db_host, a.db_name, a.rep_date
	from otrrep.otr_nfs_space_rep a, otrrep.otr_space_rep_max_timestamp_v b
	where TRUNC(a.rep_date) = b.rep_date 
	order by rep_date desc, hostname, db_name
</cfquery>

<cfquery name="getDate" datasource="#application.datasource#">
	select rep_date from otrrep.otr_space_rep_max_timestamp_v
</cfquery>

<cfset pdf_date = DateFormat(getDate.rep_date, 'dd-mm-yyyy') />
<cfscript>
	logger(msg="Start PDF #pdf_date#", level="info");
</cfscript>
<!--- Define Date Format --->
<cfset dummy = SetLocale("#application.locale_string#") />
<cfdocument format="pdf" filename="#application.host_instance_pdf_dir#dbhosts_instances_#pdf_date#.pdf" overwrite="yes" pagetype="A4">
<style>
  table {
    -fs-table-paginate: paginate;
  }
</style>
<cfdocumentitem type="header">
	<table width="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td align="left">DB-HOSTS - ORACLE INSTANCES - <cfoutput>#LSDateFormat(getDate.rep_date, 'medium')#</cfoutput></td>
	</tr>
	</table>
</cfdocumentitem>
<cfdocumentitem type="footer">
	<table width="100%" border="1" cellpadding="0" cellspacing="0">
	<tr>
		<td align="right"><cfoutput>#application.company# - Page #cfdocument.currentsectionpagenumber# of
            #cfdocument.totalsectionpagecount#</cfoutput></td>
	</tr>
	</table>
</cfdocumentitem>
<cfdocumentsection>
	<table border="0" cellpadding="0" cellspacing="0">
	<thead>
	<tr>
		<th width="200" style="font-size: 9pt;font-weight: bold;">Host</th>
		<th width="200" style="font-size: 9pt;font-weight: bold;">SID</th>
	</tr>
	</thead>
	<tbody>
	<cfoutput query="qHostInstances"><tr<cfif qHostInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td>#qHostInstances.db_host#</td>
		<td>#qHostInstances.db_name#</td>
	</tr><cfset dRepDate = LSDateFormat(qHostInstances.rep_date, 'medium') /></cfoutput>
	</tbody>
	<tr>
		<td colspan="2" style="font-size: 8pt;font-weight: normal;font-style: oblique">Number of Instances: <cfoutput>#qHostInstances.RecordCount#, Stand: #dRepDate#</cfoutput></td>
	</tr>
	</table>
</cfdocumentsection>
</cfdocument>
<cfexecute name="/bin/chown" arguments="pccr:dba /opt/pro/dir/ccr/oracle/dbhosts_instances_#pdf_date#.pdf" />
<cfscript>
	logger(msg="End PDF #pdf_date#", level="info");
</cfscript>

