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
	2012.05.16	mst	Now using Active Critical Threshold stored on the Target DB
	2012.05.18	mst	Changed the check on used % to use GE rather than GT which is
					what EM is using.
	2012.05.25	mst	Fixed listing correct error message if the SYSTEM accout
					is Locked or Expired
	2012.05.25	mst	Added Can-Grow-To value to the Alarm ToolTip message to give
					relevance to the Used %
	2012.05.26	mst	Getting setting for the refresh time from Application.cfc
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">

<cfquery name="qInstances" datasource="#Application.datasource#">
	select db_name, system_password, db_host, db_port, db_rac, db_servicename, db_blackout
	  from otr_db
	 order by db_name
</cfquery>
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#Application.company#</cfoutput> - Oracle Instances</title>
<cfinclude template="_otr_css.cfm">
<META HTTP-EQUIV="Refresh" CONTENT="<cfoutput>#Int(Application.monitoring_cycle * 60)#</cfoutput>">
<cfjavascript minimize="false" munge="false">
function confirmation(txt, url) {
  if (confirm(txt)) {
    document.location.href = url;
  }
}
</cfjavascript>
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
	<cfset iDBErr = 0 />
	<cftry>
		<cfif qInstances.db_blackout IS 1>
			<cfset iDBErr = 4 />
		<cfelse>
		<cfif Trim(qInstances.db_port) IS "">
			<!--- Get Listener Port from EM --->
			<cfquery name="qPort" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'Port'
			</cfquery>
			<cfset iPort = qPort.property_value />
		<cfelse>
			<cfset iPort = qInstances.db_port />
		</cfif>

		<cfif Trim(qInstances.db_host) IS "" >
			<!--- Get Host server from EM --->
			<cfquery name="qHost" datasource="OTR_SYSMAN">
				select distinct b.property_value
				from mgmt_target_properties a, mgmt_target_properties b
				where a.target_guid = b.target_guid
				and   UPPER(a.property_value) = '#Trim(UCase(qInstances.db_name))#'
				and   b.property_name = 'MachineName'
			</cfquery>
			<cfset sHost = Trim(qHost.property_value) />
		<cfelse>
			<cfset sHost = Trim(qInstances.db_host) />
		</cfif>

		<!--- Decrypt the SYSTEM Password --->
		<cfset sPassword = Trim(Application.pw_hash.decryptOraPW(qInstances.system_password)) />
		<!--- Create Temporary Data Source --->
		<cfset s = StructNew() />
		<cfif qInstances.db_rac IS 1>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
		<cfelse>
			<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
		</cfif>
		<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
		<cfset s.databasename = "#UCase(qInstances.db_name)#" />
		<cfset s.username     = "system" />
		<cfset s.password     = "#sPassword#" />
		<cfset s.port         = "#iPort#" />

		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate("#UCase(qInstances.db_name)#temp", s) />
		</cfif>

		<cfquery name="qAlarm" datasource="#UCase(qInstances.db_name)#temp">
			SELECT NVL(b.tablespace_name, NVL(a.tablespace_name, 'UNKOWN')) tablespace_name,
		            ROUND(a.BYTES / 1024 / 1024, 2) mb_used,
		            ROUND(NVL(b.BYTES, 0) / 1024 / 1024, 2) mb_free,
		            ROUND(a.maxbytes / 1024 / 1024, 2) can_grow_to,
		            ROUND(((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0)) / 1024 / 1024, 2) max_mb_free,
		            ROUND(((a.BYTES - NVL(b.BYTES, 0)) / a.BYTES) * 100, 2) prc_used,
		            ROUND(((a.maxbytes - ((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0))) / a.maxbytes) * 100, 2) prc
		       FROM SYS.dba_tablespaces d,
		            (SELECT   tablespace_name, SUM(BYTES) BYTES,
		                      SUM(CASE
		                             WHEN maxbytes = 0
		                                THEN BYTES
		                             ELSE maxbytes
		                          END
		                         ) maxbytes
		                 FROM dba_data_files
		             GROUP BY tablespace_name) a,
		            (SELECT   tablespace_name, SUM(BYTES) BYTES, MAX(BYTES) largest
		                 FROM dba_free_space
		             GROUP BY tablespace_name) b
		      WHERE a.tablespace_name = b.tablespace_name(+)
		        AND d.tablespace_name = a.tablespace_name(+)
		        AND NOT d.CONTENTS = 'UNDO'
		        AND NOT (d.extent_management = 'LOCAL' AND d.CONTENTS = 'TEMPORARY')
		        AND d.tablespace_name LIKE '%'
				AND ROUND(((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0)) / 1024 / 1024, 2) < #Application.tablespace.mb_left#
				AND ROUND(((a.maxbytes - ((a.maxbytes - a.BYTES) + NVL (b.BYTES, 0))) / a.maxbytes) * 100, 2) >= (select NVL((select critical_value from sys.dba_thresholds 
									 where metrics_name like '%Tablespace Space Usage' 
									   and object_name = b.tablespace_name),(select critical_value from sys.dba_thresholds
									 where metrics_name = 'Tablespace Space Usage'
									   and nvl(object_name,'-OTR-TBS-') = '-OTR-TBS-')) critical from dual)
		   UNION ALL
		   SELECT   NVL(d.tablespace_name, NVL (a.tablespace_name, 'UNKOWN')) tablespace_name,
		            ROUND(a.BYTES / 1024 / 1024, 0) mb_used,
		            ROUND(NVL(a.BYTES - t.BYTES, 0) / 1024 / 1024, 2) mb_free,
		            ROUND(a.maxbytes / 1024 / 1024, 2) can_grow_to,
		            ROUND((a.maxbytes - t.BYTES) / 1024 / 1024, 2) max_mb_free,
		            ROUND(((a.BYTES - NVL(a.BYTES - t.BYTES, 0)) / a.BYTES) * 100, 2) prc_used,
		            ROUND(((a.maxbytes - NVL(a.maxbytes - t.BYTES, 0)) / a.maxbytes) * 100, 2) prc
		       FROM SYS.dba_tablespaces d,
		            (SELECT   tablespace_name, SUM(BYTES) BYTES,
		                      SUM(CASE
		                             WHEN maxbytes = 0
		                                THEN BYTES
		                             ELSE maxbytes
		                          END
		                         ) maxbytes
		                 FROM dba_temp_files
		             GROUP BY tablespace_name) a,
		            (SELECT   ss.tablespace_name,
		                      SUM (ss.used_blocks * ts.BLOCKSIZE) BYTES
		                 FROM gv$sort_segment ss, SYS.ts$ ts
		                WHERE ss.tablespace_name = ts.NAME
		             GROUP BY ss.tablespace_name) t
		      WHERE a.tablespace_name = t.tablespace_name(+)
		        AND d.tablespace_name = a.tablespace_name(+)
		        AND d.extent_management = 'LOCAL'
		        AND d.CONTENTS = 'TEMPORARY'
		        AND d.tablespace_name LIKE '%'
				AND ROUND((a.maxbytes - t.BYTES) / 1024 / 1024, 2) < #Application.tablespace.mb_left#
				AND ROUND(((a.maxbytes - NVL(a.maxbytes - t.BYTES, 0)) / a.maxbytes) * 100, 2) >= (select NVL((select critical_value from sys.dba_thresholds 
									 where metrics_name like '%Tablespace Space Usage' 
									   and object_name = d.tablespace_name),(select critical_value from sys.dba_thresholds
									 where metrics_name = 'Tablespace Space Usage'
									   and nvl(object_name,'-OTR-TBS-') = '-OTR-TBS-')) critical from dual)
		   UNION ALL
		   SELECT   NVL(d.tablespace_name,
		                 NVL(a.tablespace_name, 'UNKOWN')
		               ) tablespace_name,
		            ROUND(a.BYTES / 1024 / 1024, 0) mb_used,
		            ROUND(NVL(a.BYTES - u.BYTES, a.BYTES) / 1024 / 1024, 2) mb_free,
		            ROUND(a.maxbytes / 1024 / 1024, 2) can_grow_to,
		            ROUND(NVL(a.maxbytes - u.BYTES, a.maxbytes) / 1024 / 1024, 2) max_mb_free,
		            ROUND(((a.BYTES - NVL(a.BYTES - u.BYTES, a.BYTES)) / a.BYTES) * 100, 2) prc_used,
		            ROUND(((a.maxbytes - NVL (a.maxbytes - u.BYTES, a.maxbytes)) / a.maxbytes) * 100, 2) prc
		       FROM SYS.dba_tablespaces d,
		            (SELECT   tablespace_name,SUM (BYTES) BYTES,
		                      SUM(CASE
		                             WHEN maxbytes = 0
		                                THEN BYTES
		                             ELSE maxbytes
		                          END
		                         ) maxbytes
		                 FROM dba_data_files
		             GROUP BY tablespace_name) a,
		            (SELECT   tablespace_name, SUM (BYTES) BYTES
		                 FROM (SELECT   tablespace_name, SUM(BYTES) BYTES, status
		                           FROM dba_undo_extents
		                          WHERE status = 'ACTIVE'
		                       GROUP BY tablespace_name, status
		                       UNION ALL
		                       SELECT   tablespace_name, SUM(BYTES) BYTES, status
		                           FROM dba_undo_extents
		                          WHERE status = 'UNEXPIRED'
		                       GROUP BY tablespace_name, status)
		             GROUP BY tablespace_name) u
		      WHERE a.tablespace_name = u.tablespace_name(+)
		        AND d.tablespace_name = a.tablespace_name(+)
		        AND d.CONTENTS = 'UNDO'
		        AND d.tablespace_name LIKE '%'
				AND ROUND(NVL(a.maxbytes - u.BYTES, a.maxbytes) / 1024 / 1024, 2) < #Application.tablespace.mb_left#
				AND ROUND(((a.maxbytes - NVL (a.maxbytes - u.BYTES, a.maxbytes)) / a.maxbytes) * 100, 2) >= (select NVL((select critical_value from sys.dba_thresholds 
									 where metrics_name like '%Tablespace Space Usage' 
									   and object_name = d.tablespace_name),(select critical_value from sys.dba_thresholds
									 where metrics_name = 'Tablespace Space Usage'
									   and nvl(object_name,'-OTR-TBS-') = '-OTR-TBS-')) critical from dual)
		   ORDER BY 7 DESC
		</cfquery>
		</cfif>
		<cfcatch type="Database">
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
			</cfif>
			<cfset iDBErr = 1>
			<cfset errTT = "Instance is Down or #chr(10)#don't exist anymore" />
			<cfif #cfcatch.nativeerrorcode# GTE 28000>
				<cfset iDBErr = cfcatch.nativeerrorcode />
				<cfset errTT = cfcatch.queryError />
			</cfif>
		</cfcatch>
	</cftry>
	<cftry>
		<cfset iRecordCount = qAlarm.RecordCount>
		<cfcatch type="Any">
			<cfset iRecordCount = 0 />
			<cfset iDBErr IS 1 />
		</cfcatch>
	</cftry>
	<tr<cfif qInstances.CurrentRow mod 2> class="alternate"</cfif>>
		<td>#qInstances.db_name#</td>
		<!--- <td align="center"<cfif iRecordCount IS NOT 0> title="#qAlarm.tablespace_name##chr(13)##qAlarm.max_mb_free# MB Free, #qAlarm.prc# % used."<cfelseif iDBErr IS 1> title="Instance is Down or#chr(13)#don't exist anymore"<cfelseif iDBErr IS 4> title="Instance is in#chr(13)#Blackout status"</cfif> style="<cfif iRecordCount IS NOT 0 OR iDBErr IS 1 OR iDBErr IS 4>background-color: red; cursor: help;<cfelse>background-color: green;</cfif>"><cfif iDBErr IS 1>Down<cfelseif iDBErr IS 4>Blackout<cfelseif iRecordCount GT 0><a href="otr_tbs_fix.cfm?SID=#qInstances.db_name#&TBS=#qAlarm.tablespace_name#" target="_parent" style="color: 000;">TBS</a><cfelse>&nbsp;</cfif></td> --->
		<td align="center"<cfif iRecordCount IS NOT 0 AND iDBErr IS 1> title="#qAlarm.tablespace_name##chr(13)#Can Grow To:#qAlarm.can_grow_to# MB#chr(13)##qAlarm.max_mb_free# MB Free, #qAlarm.prc#% used."<cfelseif iDBErr IS 1> title="Instance is Down or #chr(13)#don't exist anymore"<cfelseif iDBErr IS 4> title="Instance is in#chr(13)#Blackout status"<cfelseif iDBErr GTE 28000> title="#errTT#"</cfif> style="<cfif iRecordCount IS NOT 0 OR iDBErr IS NOT 0>background-color: red; cursor: help;<cfelse>background-color: green;</cfif>"><cfif iDBErr IS 1>Down<cfelseif iDBErr IS 4>Blackout<cfelseif iDBErr GTE 28000>#iDBErr#<cfelseif iRecordCount GT 0><a href="otr_tbs_fix.cfm?SID=#qInstances.db_name#&TBS=#qAlarm.tablespace_name#" target="_parent" style="color: 000;">TBS</a><cfelse>&nbsp;</cfif></td>
	</tr>
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete("#UCase(qInstances.db_name)#temp") />
		</cfif>
	</cfoutput>
	</table>
	</td>
</tr>
</table>
</div>

</body>
</html></cfprocessingdirective>
