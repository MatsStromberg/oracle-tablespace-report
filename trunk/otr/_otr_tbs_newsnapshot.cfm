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
	
	The Oracle Tablespace Report do need an Oracle EM 10g/12cR1 or R2 Repository
	(Copyright Oracle Inc.) since it will get some of it's data from the Grid 
	Repository.
    
    You should have received a copy of the GNU General Public License 
    along with the Oracle Tablespace Report.  If not, see 
    <http://www.gnu.org/licenses/>.
--->
<!--- 
	Long over due Change Log
	2012.05.20	mst	Delete snapshot of Instances not in Blackout.
	2012.05.23	mst	Fixed the delete statement that was messed up!!!
	2012.08.14	mst	Added parameters to the jdbc connect string.
	2013.04.17	mst	Re-written the NFS Lookup.  OTRREP does not have 
					to be in the same Instance as the EM Repositorys!!!
	2013.04.18	mst	Added SYSTEM Username from the Target DB
--->
<!--- Get the HashKey --->
<cfset sHashKey = Trim(Application.pw_hash.lookupKey()) />

<cfset dToday = DateFormat(Now(),'dd-mm-yyyy')>
<!--- <cfoutput>#dToday#<br />#CGI.HTTP_REFERER#</cfoutput> --->
<!--- Delete any snapshot done TODAY except from Instances in Blackout status --->
<cfquery name="qDelete" datasource="#Application.datasource#">
	delete from otr_db_space_rep a
	where trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
	  and UPPER(a.db_name) = (select UPPER(b.db_name) from otr_db b where UPPER(b.db_name) = UPPER(a.db_name) and b.db_blackout = 0)
</cfquery>
<cfquery name="qDelete2" datasource="#Application.datasource#">
	delete from otr_nfs_space_rep a
	where trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
	  and UPPER(a.db_name) = (select UPPER(b.db_name) from otr_db b where UPPER(b.db_name) = UPPER(a.db_name) and b.db_blackout = 0)
</cfquery>
<cfquery name="qDelete3" datasource="#Application.datasource#">
	delete from otr_asm_space_rep a
	where trunc(a.rep_date) = trunc(to_date('#dToday#','DD-MM-YYYY'))
	  and UPPER(a.db_name) = (select UPPER(b.db_name) from otr_db b where UPPER(b.db_name) = UPPER(a.db_name) and b.db_blackout = 0)
</cfquery>

<!--- SnapShot Routine --->
<cfset dRepDate = CreateODBCDateTime(CreateDateTime(Year(Now()),Month(Now()),Day(Now()),Hour(Now()),Minute(Now()),0)) />
<!--- DB Instances with Password --->
<cfquery name="qInstances" datasource="#Application.datasource#">
	select db_name, system_username, system_password, db_host, db_port, db_asm, db_rac, db_servicename, db_blackout
	from otr_db
	order by db_name
</cfquery>
<cfoutput query="qInstances">
	<cfif Trim(qInstances.system_password) IS NOT "" AND qInstances.db_blackout IS 0>
		<cftry>
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
			<cfset sPassword = Application.pw_hash.decryptOraPW(Trim(qInstances.system_password), Trim(sHashKey)) />
			<!--- Create Temporary Data Source --->
			<cfset s = StructNew() />
			<cfif qInstances.db_rac IS 1>
				<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#/#UCase(qInstances.db_servicename)#" />
			<cfelse>
				<cfset s.hoststring   = "jdbc:oracle:thin:@#LCase(sHost)#:#iPort#:#UCase(qInstances.db_name)#" />
			</cfif>
			<cfset s.drivername   = "oracle.jdbc.OracleDriver" />
			<cfset s.databasename = "#UCase(qInstances.db_name)#" />
			<cfset s.username     = "#UCase(qInstances.system_username)#" />
			<cfset s.password     = "#sPassword#" />
			<cfset s.port         = "#iPort#" />
			<cfset s.logintimeout = "5" />
			<cfset s.connectiontimeout = "5" />
			<cfset s.connectionretries = "2" />
			<cfset s.maxconnections	= "20" />

			<!--- If Temporary Datasource exists... Delete it --->
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
			</cfif>
			<!--- Create a Temporary Datasource for the Instance --->
			<cfif NOT DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceCreate( "#UCase(qInstances.db_name)#temp", s ) />
			</cfif>

			<!--- Check if the Instance is using ASM --->
			<cfif qInstances.db_asm IS 1>
				<cfset bASM = 1 />
			<cfelse>
				<cfset bASM = 0 />
			</cfif>

			<!--- Lookup the Tablespaces to be monitored --->
			<cfquery name="qTBS" datasource="#Application.datasource#">
				select a.db_name, a.db_tbs_name
				  from otrrep.otr_cust_appl_tbs a
				 where exists (select 1 from otrrep.otr_cust_appl_tbs b where b.cust_appl_id=a.cust_appl_id)
				   and UPPER(a.db_name) = '#UCase(qInstances.db_name)#'
				 order by cust_appl_id, db_tbs_name;
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
					  AND NVL(ROUND(a.BYTES / 1024 / 1024 , 2),0) > 0

				 ORDER BY ((a.BYTES - NVL (b.BYTES, 0)) / a.BYTES) DESC
				</cfquery>
				<!--- Tablespace Statistics --->
				<cfif qT.RecordCount IS NOT 0>
					<cfquery name="qInsert" datasource="#Application.datasource#">
						insert into OTRREP.OTR_DB_SPACE_REP
							(DB_NAME,REP_DATE,DB_TBS_NAME,DB_TBS_USED_MB,DB_TBS_FREE_MB,DB_TBS_CAN_GROW_MB,DB_TBS_MAX_FREE_MB,DB_TBS_PRC_USED,DB_TBS_REAL_PRC_USED)
						 values
							(<cfoutput>'#UCase(qInstances.db_name)#',#dRepDate#,'#qT.tablespace_name#',#qT.mb_used#,#qT.mb_free#,#qT.can_grow_to#,#qT.max_mb_free#,#qT.prc_used#,#qT.prc#)</cfoutput>
					</cfquery>
				</cfif>
			</cfloop>
			<!--- NFS Statistics --->
			<cfquery name="qN" datasource="OTR_SYSMAN">
				SELECT DISTINCT '#Trim(qInstances.db_name)#' db_name, n.target_name hostname, n.nfs_server,
								n.filesystem, n.mountpoint mountpoint,
								ROUND (n.sizeb / 1024 / 1024, 2) mb_total,
								ROUND (n.usedb / 1024 / 1024, 2) mb_used,
								ROUND (n.freeb / 1024 / 1024, 2) mb_free,
								ROUND ((n.usedb / n.sizeb) * 100) prc_used
						   FROM sysman.mgmt$storage_report_nfs n,
								sysman.mgmt$target t,
								sysman.mgmt$target s
						  WHERE n.target_guid = t.target_guid
							AND n.mountpoint =
								(SELECT DISTINCT ma.os_storage_entity
											FROM sysman.mgmt$db_datafiles_all ma,
												 sysman.mgmt$storage_report_nfs NO
										   WHERE ma.os_storage_entity = NO.mountpoint
											 AND REPLACE(UPPER(ma.target_name),
														'.#UCase(Application.oracle.domain_name)#',
														''
														) = UPPER('#Trim(qInstances.db_name)#')
											 AND NO.mountpoint <> '/')
							AND s.host_name = t.host_name
							AND n.target_name =
								(SELECT DISTINCT mh.host_name
								   FROM sysman.mgmt$db_datafiles_all mh
								  WHERE REPLACE(UPPER(mh.target_name),
													'.#UCase(Application.oracle.domain_name)#',
													''
												) = UPPER('#Trim(qInstances.db_name)#'))
				UNION
				SELECT DISTINCT '#Trim(qInstances.db_name)#' db_name, NO.target_name hostname, NO.nfs_server,
								NO.filesystem, NO.mountpoint mountpoint,
								ROUND (NO.sizeb / 1024 / 1024, 2) mb_total,
								ROUND (NO.usedb / 1024 / 1024, 2) mb_used,
								ROUND (NO.freeb / 1024 / 1024, 2) mb_free,
								ROUND ((NO.usedb / NO.sizeb) * 100) prc_used
						   FROM sysman.mgmt$storage_report_nfs NO,
								sysman.mgmt$target ot,
								sysman.mgmt$target so
						  WHERE ot.target_guid = NO.target_guid
							AND UPPER(so.target_name) LIKE UPPER('#Trim(qInstances.db_name)#') || '%'
							AND NO.mountpoint =
								(SELECT DISTINCT ma.os_storage_entity
								   FROM sysman.mgmt$db_redologs_all ma,
										sysman.mgmt$storage_report_nfs NO
								  WHERE ma.os_storage_entity = NO.mountpoint
									AND REPLACE(UPPER(ma.target_name),
													'.#UCase(Application.oracle.domain_name)#',
													''
												) = UPPER('#Trim(qInstances.db_name)#')
									AND NO.mountpoint <> '/')
							AND so.host_name = ot.host_name
							AND NO.target_name =
								(SELECT DISTINCT mh.host_name
								   FROM sysman.mgmt$db_redologs_all mh
								  WHERE REPLACE(UPPER(mh.target_name),
													'.#UCase(Application.oracle.domain_name)#',
													''
												) = UPPER('#Trim(qInstances.db_name)#'))
			</cfquery>
			<cfloop query="qN">
				<cfif qN.RecordCount IS NOT 0>
					<cfquery name="qInsert2" datasource="#Application.datasource#">
						insert into OTRREP.OTR_NFS_SPACE_REP
							(DB_NAME,REP_DATE,HOSTNAME,NFS_SERVER,FILESYSTEM,MOUNTPOINT,NFS_MB_TOTAL,NFS_MB_USED,NFS_MB_FREE,NFS_PRC_USED)
						 values
							(<cfoutput>'#UCase(qInstances.db_name)#',#dRepDate#,'#qN.hostname#','#qN.nfs_server#','#qN.filesystem#','#qN.mountpoint#',#qN.mb_total#,#qN.mb_used#,#qN.mb_free#,#qN.prc_used#)</cfoutput>
					</cfquery>
				</cfif>
			</cfloop>

			<!--- ASM Statistics --->
			<cfif bASM IS 1>
				<cfquery name="qA" datasource="#UCase(qInstances.db_name)#temp">
					select name, total_mb, free_mb, (total_mb - free_mb) used_mb,
					       voting_files,
					       ROUND (((total_mb - free_mb) / total_mb) * 100, 2) prc_used
					  from v$asm_diskgroup_stat
				</cfquery>
				<cfloop query="qA">
					<cfif qA.RecordCount IS NOT 0>
						<cfquery name="qInsert3" datasource="#Application.datasource#">
						insert into OTRREP.OTR_ASM_SPACE_REP
							(DB_NAME, HOSTNAME, REP_DATE, DG_NAME, ASM_MB_TOTAL, ASM_MB_USED, ASM_MB_FREE, ASM_PRC_USED)
						 values
							(<cfoutput>'#UCase(qInstances.db_name)#','#qInstances.db_host#',#dRepDate#,
							   '#qA.name#', #qA.total_mb#, #qA.used_mb#, #qA.free_mb#, #qA.prc_used#</cfoutput>)
						</cfquery>
					</cfif>
				</cfloop>
			</cfif>

			<!--- If Temporary Datasource exists... Delete it --->
			<cfif DataSourceIsValid("#UCase(qInstances.db_name)#temp")>
				<cfset DataSourceDelete( "#UCase(qInstances.db_name)#temp" ) />
			</cfif>

			<cfcatch type="Database">
				<cfset iDBErr = 1>
				<!--- <cfdump var="#cfcatch#"> --->
			</cfcatch>
		</cftry>

	</cfif><!---<cfoutput>#qInstances.db_name#</cfoutput><br />--->
</cfoutput>
DONE!
