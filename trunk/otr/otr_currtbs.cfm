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
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfquery name="qInstances" datasource="#Application.datasource#">
	select db.db_name, db.system_password 
	  from otr_db db
	 order by db_name
</cfquery>

<cfquery name="qAlarm" datasource="#Application.datasource#">
    select tablespace_name, max_mb_free, prc
      from otr_tbs_space_rep_v
     where prc > #Application.tablespace.prc_used#
       and max_mb_free < #Application.tablespace.mb_left#
     order by prc DESC
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Instances</title>
<cfinclude template="_otr_css.cfm">
<META HTTP-EQUIV="Refresh" CONTENT="300"> 
<cfjavascript minimize="false" munge="false">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  }
}
</cfjavascript>
<!--- else {
    /* window.showHourglasses = false; */
  }
--->
</head>

<body>
<div align="center">
<table border="0" cellpadding="5">
<tr>
	<td class="bodyline">
	<table border="0" cellpadding="0" cellspacing="0">
	<tr>
		<td width="100" style="font-size: 9pt;font-weight: bold;">SID</td>
		<td align="center" width="40" style="font-size: 9pt;font-weight: bold;">Status</td>
	</tr>
	<cfoutput query="qInstances">
	<cfset iDBErr = 0>
	<cftry>
		<!--- Get Listener Port --->
		<cfquery name="qPort" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   a.property_value = '#Trim(qInstances.db_name)#'
			and   b.property_name = 'Port'
		</cfquery>

		<!--- Get Host server --->
		<cfquery name="qHost" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   a.property_value = '#Trim(qInstances.db_name)#'
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
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate( "#UCase(qInstances.db_name)#temp", s ) />
		</cfif>

		<!--- <cfquery name="qAlarm" datasource="#Application.datasource#">
		    select tablespace_name, max_mb_free, prc
		    from otr_tbs_space_rep_v@#qInstances.db_name##Application.oracle.domain_name#
		    where prc > 98
		    and max_mb_free < 1800
		    order by prc DESC
		</cfquery> --->
		<cfquery name="qAlarm" datasource="#UCase(qInstances.db_name)#temp">
			SELECT nvl(b.tablespace_name,nvl(a.tablespace_name,'UNKOWN')) tablespace_name,
			       ROUND(NVL(b.BYTES, 0) / 1024 / 1024, 2) mb_free,
			       ROUND(((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0)) / 1024 / 1024, 2) max_mb_free,
			       ROUND(((a.maxbytes - ((a.maxbytes - a.BYTES) + NVL (b.BYTES, 0))) / a.maxbytes) * 100, 2) prc
			  FROM (SELECT tablespace_name, SUM (BYTES) BYTES,
			                 SUM (CASE
			                         WHEN maxbytes = 0
			                            THEN BYTES
			                         ELSE maxbytes
			                      END) maxbytes
			            FROM dba_data_files
			        GROUP BY tablespace_name) a,
			       (SELECT   tablespace_name, SUM (BYTES) BYTES, MAX (BYTES) largest
			            FROM dba_free_space
			        GROUP BY tablespace_name) b
			 WHERE a.tablespace_name = b.tablespace_name(+)
			   AND ROUND(((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0)) / 1024 / 1024, 2) < #Application.tablespace.mb_left#
			   AND ROUND(((a.maxbytes - ((a.maxbytes - a.BYTES) + NVL (b.BYTES, 0))) / a.maxbytes) * 100, 2) > #Application.tablespace.prc_used#
			ORDER BY ((a.BYTES - NVL (b.BYTES, 0)) / a.BYTES) DESC
		</cfquery>
		<cfcatch type="Database">
			<cfset iDBErr = 1>
		</cfcatch>
	</cftry>
	<cfset iRecordCount = qAlarm.RecordCount><cfif iRecordCount IS NOT 0 OR iDBErr IS 1>
	<tr<cfif qInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td>#qInstances.db_name#</td>
		<td align="center"<cfif iRecordCount IS NOT 0> title="#qAlarm.tablespace_name##chr(13)##qAlarm.max_mb_free# MB Free, #qAlarm.prc# used."<cfelseif iDBErr IS 1> title="Instance is Down or#chr(13)#don't exist anymore"</cfif> style="<cfif iRecordCount IS NOT 0 OR iDBErr IS 1>background-color: red; cursor: help;<cfelse>background-color: green;</cfif>"><cfif iDBErr IS 1>Down<cfelseif iRecordCount GT 0><a href="otr_tbs_fix.cfm?SID=#qInstances.db_name#&TBS=#qAlarm.tablespace_name#" target="_parent" style="color: 000;">TBS<cfelse>&nbsp;</cfif></td>
	</tr></cfif>
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>
	</cfoutput>
	</table>
	</td>
</tr>
</table>
</div>

</body>
</html></cfprocessingdirective>
