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
<!--- Delete any snapshot done TODAY --->
<cfset dToday = DateFormat(Now(),'dd.mm.yyyy') />
<cfoutput>#dToday#<br />#CGI.HTTP_REFERER#</cfoutput>
<!--- Delete TBS Stats for current Date --->
<cfquery name="qDelete" datasource="#application.datasource#">
	delete from otr_db_space_rep a
	where   trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
</cfquery>

<!--- Delete NFS Stats for current Date --->
<cfquery name="qDelete2" datasource="#application.datasource#">
	delete from otr_nfs_space_rep
	where   trunc(rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
</cfquery>

<!--- Generate a TBS Snapshot using the Stored Procedure OTR_ReportingProc --->
<!--- <CFSTOREDPROC PROCEDURE="OTRREP.OTR_ReportingProc" DATASOURCE="OGC_SYSMAN">
</CFSTOREDPROC> --->
<!--- SnapShot Routine --->
<!--- <cfset dRepDate = DateTimeFormat(Now(), 'dd.MM.yyyy HH:mm:ss') /> --->
<cfset dRepDate = CreateODBCDateTime(CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Hour(Now()),Minute(Now()),0)) />
<!--- DB Instances with Password --->
<cfquery name="qInstances" datasource="#application.datasource#">
	select db_name, system_password 
	from otr_db
	order by db_name
</cfquery>
<cfoutput query="qInstances">
	<cfif Trim(qInstances.system_password) IS NOT "">
	<cftry>
		<!--- Get Listener Port --->
		<cfquery name="qPort" datasource="OTR_SYSMAN">
			select distinct b.property_value
			from mgmt_target_properties a, mgmt_target_properties b
			where a.target_guid = b.target_guid
			and   a.property_value = '#Trim(qInstances.db_name)#'
			and   b.property_name = 'Port'
		</cfquery>

		<!--- Get Listener Port --->
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

		<!--- If Temporary Datasource exists... Delete it --->
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>
		<!--- Create a Temporary Datasource for the Instance --->
		<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceCreate( "#UCase(qInstances.db_name)#temp", s ) />
		</cfif>

		<!--- Lookup the Tablespaces to be monitored --->
		<cfquery name="qTBS" datasource="OTR_OTRREP">
			select a.db_name, a.db_tbs_name
			  from OTRREP.OTR_CUST_APPL_TBS_XT a
    		 where exists (select 1 from OTRREP.OTR_CUST_APPL_TBS_XT b where b.CUST_APPL_ID=a.CUST_APPL_ID)
			   and a.db_name = '#qInstances.db_name#'
	      order by CUST_APPL_ID;
		</cfquery>

		<cfloop query="qTBS">
			<cfquery name="qT" datasource="#UCase(qInstances.db_name)#temp">
				SELECT   nvl(b.tablespace_name,nvl(a.tablespace_name,'UNKOWN')) tablespace_name,
				         ROUND(a.BYTES / 1024 / 1024 , 2) mb_used,
				         ROUND(NVL(b.BYTES, 0) / 1024 / 1024, 2) mb_free,
				         ROUND(a.maxbytes / 1024 / 1024 , 2) can_grow_to,
				         ROUND(((a.maxbytes - a.BYTES) + NVL(b.BYTES, 0)) / 1024 / 1024, 2) max_mb_free,
				         ROUND(((a.BYTES - NVL (b.BYTES, 0)) / a.BYTES) * 100, 2) prc_used,
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
				  AND a.tablespace_name = '#qTBS.db_tbs_name#'
			 ORDER BY ((a.BYTES - NVL (b.BYTES, 0)) / a.BYTES) DESC
			</cfquery>

			<!--- Tablespace Statistics --->
			<cfif qT.RecordCount IS NOT 0>
				<cfquery name="qInsert" datasource="OTR_OTRREP">
					insert into OTRREP.OTR_DB_SPACE_REP
						(DB_NAME,REP_DATE,DB_TBS_NAME,DB_TBS_USED_MB,DB_TBS_FREE_MB,DB_TBS_CAN_GROW_MB,DB_TBS_MAX_FREE_MB,DB_TBS_PRC_USED,DB_TBS_REAL_PRC_USED)
					 values
						(<cfoutput>'#qInstances.db_name#',#dRepDate#,'#qT.tablespace_name#',#qT.mb_used#,#qT.mb_free#,#qT.can_grow_to#,#qT.max_mb_free#,#qT.prc_used#,#qT.prc#)</cfoutput>
				</cfquery>
			</cfif>
		</cfloop>
		<!--- NFS Statistics --->
		<cfquery name="qN" datasource="OTR_SYSMAN">
		   SELECT DISTINCT io.db_name, n.target_name hostname, n.nfs_server,
		                   n.filesystem, n.mountpoint mountpoint,
		                   ROUND (n.sizeb / 1024 / 1024, 2) mb_total,
		                   ROUND (n.usedb / 1024 / 1024, 2) mb_used,
		                   ROUND (n.freeb / 1024 / 1024, 2) mb_free,
		                   ROUND ((n.usedb / n.sizeb) * 100) prc_used
		              FROM otrrep.otr_db io,
		                   sysman.mgmt$storage_report_nfs n,
		                   sysman.mgmt$target t,
		                   sysman.mgmt$target s
		             WHERE n.target_guid = t.target_guid
		               AND io.db_name = '#qInstances.db_name#'
		               AND n.mountpoint =
		                      (SELECT DISTINCT ma.os_storage_entity
		                                  FROM sysman.mgmt$db_datafiles_all ma,
		                                       sysman.mgmt$storage_report_nfs NO
		                                 WHERE ma.os_storage_entity = NO.mountpoint
		                                   AND REPLACE (ma.target_name,
		                                                '.#Application.oracle.domain_name#',
		                                                ''
		                                               ) = io.db_name
		                                   AND NO.mountpoint <> '/')
		               AND s.host_name = t.host_name
		               AND n.target_name =
		                      (SELECT DISTINCT mh.host_name
		                                  FROM sysman.mgmt$db_datafiles_all mh
		                                 WHERE REPLACE (mh.target_name,
		                                                '.#Application.oracle.domain_name#',
		                                                ''
		                                               ) = io.db_name)
		   UNION
		   SELECT DISTINCT io.db_name, NO.target_name hostname, NO.nfs_server,
		                   NO.filesystem, NO.mountpoint mountpoint,
		                   ROUND (NO.sizeb / 1024 / 1024, 2) mb_total,
		                   ROUND (NO.usedb / 1024 / 1024, 2) mb_used,
		                   ROUND (NO.freeb / 1024 / 1024, 2) mb_free,
		                   ROUND ((NO.usedb / NO.sizeb) * 100) prc_used
		              FROM otrrep.otr_db io,
		                   sysman.mgmt$storage_report_nfs NO,
		                   sysman.mgmt$target ot,
		                   sysman.mgmt$target so
		             WHERE ot.target_guid = NO.target_guid
		               AND io.db_name = '#qInstances.db_name#'
		               AND so.target_name LIKE io.db_name || '%'
		               AND NO.mountpoint =
		                      (SELECT DISTINCT ma.os_storage_entity
		                                  FROM sysman.mgmt$db_redologs_all ma,
		                                       sysman.mgmt$storage_report_nfs NO
		                                 WHERE ma.os_storage_entity = NO.mountpoint
		                                   AND REPLACE (ma.target_name,
		                                                '.#Application.oracle.domain_name#',
		                                                ''
		                                               ) = io.db_name
		                                   AND NO.mountpoint <> '/')
		               AND so.host_name = ot.host_name
		               AND NO.target_name =
		                      (SELECT DISTINCT mh.host_name
		                                  FROM sysman.mgmt$db_redologs_all mh
		                                 WHERE REPLACE (mh.target_name,
		                                                '.#Application.oracle.domain_name#',
		                                                ''
		                                               ) = io.db_name);
		</cfquery>

		<cfloop query="qN">
			<cfif qN.RecordCount IS NOT 0>
				<cfquery name="qInsert2" datasource="OTR_OTRREP">
					insert into OTRREP.OTR_NFS_SPACE_REP
						(DB_NAME,REP_DATE,HOSTNAME,NFS_SERVER,FILESYSTEM,MOUNTPOINT,NFS_MB_TOTAL,NFS_MB_USED,NFS_MB_FREE,NFS_PRC_USED)
					 values
						(<cfoutput>'#qInstances.db_name#',#dRepDate#,'#qN.hostname#','#qN.nfs_server#','#qN.filesystem#','#qN.mountpoint#',#qN.mb_total#,#qN.mb_used#,#qN.mb_free#,#qN.prc_used#)</cfoutput>
				</cfquery>
			</cfif>
		</cfloop>

		<!--- If Temporary Datasource exists... Delete it --->
		<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
			<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
		</cfif>

		<cfcatch type="Database">
			<cfset iDBErr = 1>
		</cfcatch>
	</cftry>

	</cfif>
</cfoutput>

<cfsetting enablecfoutputonly="false">
</cfprocessingdirective>
