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
	2013.04.18	mst	Created DB upgrade template for Release 2.1
--->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN"><cfprocessingdirective suppresswhitespace="Yes"><cfsetting enablecfoutputonly="true">
<cfset bDropDirectory = 0 />
<!--- OTR_DB --->
<cftry>
	<!--- SYSTEM_USERNAME --->
	<cfquery name="qCheckOTR_DB01" datasource="#Application.datasource#">
		select system_username from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL01" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (SYSTEM_USERNAME VARCHAR2(20) DEFAULT <cfoutput>'#Application.default_system_username#'</cfoutput> NOT NULL)
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL01" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.SYSTEM_USERNAME IS 'Username for user SYSTEM'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_HOST --->
	<cfquery name="qCheckOTR_DB02" datasource="#Application.datasource#">
		select db_host from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL02" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_HOST VARCHAR2(100 BYTE))
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL02" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_HOST IS 'Host server for this Instance'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_PORT --->
	<cfquery name="qCheckOTR_DB03" datasource="#Application.datasource#">
		select db_port from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL03" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_PORT  NUMBER(6)  DEFAULT 1521)
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL03" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_PORT IS 'Listener Port for this Instance'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_ASM --->
	<cfquery name="qCheckOTR_DB04" datasource="#Application.datasource#">
		select db_asm from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL04" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_ASM  NUMBER(3)  DEFAULT 0)
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL04" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_ASM IS 'Storage using ASM = 1, NO ASM = 0'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_RAC --->
	<cfquery name="qCheckOTR_DB05" datasource="#Application.datasource#">
		select db_rac from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL05" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_RAC  NUMBER(3)  DEFAULT 0)
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL05" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_RAC IS 'RAC = 1, NO RAC = 0'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_SERVICENAME --->
	<cfquery name="qCheckOTR_DB06" datasource="#Application.datasource#">
		select db_servicename from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL06" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_SERVICENAME  VARCHAR2(100))
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL06" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_SERVICENAME IS 'Service Name is required for RAC!'
		</cfquery>
	</cfcatch>
</cftry>
<cftry>
	<!--- DB_BLACKOUT --->
	<cfquery name="qCheckOTR_DB07" datasource="#Application.datasource#">
		select db_blackout from otr_db
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_DB_COL07" datasource="#Application.datasource#">
			ALTER TABLE OTRREP.OTR_DB
				ADD (DB_BLACKOUT  NUMBER(3) DEFAULT 0)
		</cfquery>
		<cfquery name="qCommentOTR_DB_COL07" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_DB.DB_BLACKOUT IS 'BLACKOUT = 1, ONLINE = 0'
		</cfquery>
	</cfcatch>
</cftry>
<!--- Update SYSTEM_USERNAME --->
<cfquery name="qUpdateOTR_DB" datasource="#Application.datasource#">
	update otr_db
	   set system_username = '<cfoutput>#Application.default_system_username#</cfoutput>'
	 where system_username = ''
</cfquery>

<!--- OTR_CUST_APPL_TBS --->
<cftry>
	<!--- CUST_ID --->
	<cfquery name="qCheckOTR_CUST_APPL_TBS01" datasource="#Application.datasource#">
		select cust_id from otr_cust_appl_tbs
	</cfquery>
	<cfcatch type="Database">
		<cfquery name="qCreateOTR_CUST_APPL_TBS" datasource="#Application.datasource#">
			create table OTR_CUST_APPL_TBS
			 (CUST_ID            VARCHAR(20)   NOT NULL
			 ,CUST_APPL_ID       VARCHAR(100)
			 ,DB_NAME            VARCHAR(20)   NOT NULL
			 ,DB_TBS_NAME        VARCHAR(30)   NOT NULL
			 ,THRESHOLD_WARNING  NUMBER(6)     DEFAULT 85
			 ,THRESHOLD_CRITICAL NUMBER(6)     DEFAULT 97
			 )
			 TABLESPACE OTR_REP_DATA
		</cfquery>

		<!--- Add comments to Columns --->
		<cfquery name="qCommentOTR_CUST_APPL_TBS01" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.CUST_ID IS 'Short ID for custumer, usually a 3 letter code'
		</cfquery>
		<cfquery name="qCommentOTR_CUST_APPL_TBS02" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.CUST_APPL_ID IS 'Descriptive name for the Instance'
		</cfquery>
		<cfquery name="qCommentOTR_CUST_APPL_TBS03" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.DB_NAME IS 'TNS NAME used for Oracle Net connection'
		</cfquery>
		<cfquery name="qCommentOTR_CUST_APPL_TBS04" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.DB_TBS_NAME IS 'Tablespace name to monitor'
		</cfquery>
		<cfquery name="qCommentOTR_CUST_APPL_TBS05" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.THRESHOLD_WARNING IS 'Warning threshold value'
		</cfquery>
		<cfquery name="qCommentOTR_CUST_APPL_TBS06" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.THRESHOLD_CRITICAL IS 'Critical threshold value'
		</cfquery>

		<!--- Create Contraint OTR_CUST_APPL_TBS --->
		<cfquery name="qCreateConstraintOTR_CUST_APPL_TBS" datasource="#Application.datasource#">
			ALTER TABLE OTR_CUST_APPL_TBS
			 ADD (CONSTRAINT OTR_CUST_APPL_TBS_PK PRIMARY KEY (DB_NAME, DB_TBS_NAME)
			      USING INDEX TABLESPACE OTR_REP_INDX)
		</cfquery>
	</cfcatch>
</cftry>

<!--- OTR_CUST_APPL_TBS_XT --->
<cftry>
	<!--- CUST_ID --->
	<cfquery name="qCheckOTR_CUST_APPL_TBS_XT01" datasource="#Application.datasource#">
		select cust_id from otr_cust_appl_tbs_xt
	</cfquery>
	<cfquery name="qCountOTR_CUST_APPL_TBS" datasource="#Application.datasource#">
		select cust_id from OTR_CUST_APPL_TBS
	</cfquery>
	<cfif qCountOTR_CUST_APPL_TBS.RecordCount IS 0 AND qCheckOTR_CUST_APPL_TBS_XT01 GT 0>
		<cfquery name="qGetOTR_CUST_APPL_TBS_XT" datasource="#Application.datasource#">
			INSERT INTO OTR_CUST_APPL_TBS
			 (CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME)
			 (SELECT CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME
			   FROM OTR_CUST_APPL_TBS_XT)
		</cfquery>
	</cfif>
	<cfquery name="qCountOTR_CUST_APPL_TBS2" datasource="#Application.datasource#">
		select cust_id from OTR_CUST_APPL_TBS
	</cfquery>
	<cfif qCheckOTR_CUST_APPL_TBS_XT01.RecordCount IS qCountOTR_CUST_APPL_TBS2.RecordCount>
		<!--- If All records got properly copied we'll drop the old EXTERNAL TABLE --->
		<cfquery name="qDropOTR_CUST_APPL_TBS_XT" datasource="#Application.datasource#">
			drop table "OTRREP"."OTR_CUST_APPL_TBS_XT" cascade constraints PURGE;
		</cfquery>
		<cfset bDropDirectory = 1 />
	</cfif>
	<cfcatch type="Database">
	</cfcatch>
</cftry>

<!--- OTR_TBS_SETTINGS --->
<cftry>
	<cfquery name="qCheckOTR_TBS_SETTINGS" datasource="#Application.datasource#">
		select db_name from OTR_TBS_SETTINGS
	</cfquery>
	<cfcatch>
		<!--- Create OTR_TBS_SETTINGS --->
		<cfquery name="qCreateOTR_TBS_SETTINGS" datasource="#Application.datasource#">
			CREATE TABLE OTR_TBS_SETTINGS
			 (DB_NAME VARCHAR2(20)		NOT NULL
			 ,DB_TBS_NAME				VARCHAR2(30)  NOT NULL
			 ,DB_TBS_INIT_SIZE_MB		NUMBER(20,6)  DEFAULT 128	NOT NULL
			 ,DB_TBS_FILE_MAX_MB		NUMBER(20,6)  DEFAULT 4096	NOT NULL
			 ,DB_TBS_FILE_INC_MB		NUMBER(20,6)  DEFAULT 8		NOT NULL
			 ,DB_TBS_CAN_GROW_INC1_MB	NUMBER(20,6)  DEFAULT 1024	NOT NULL
			 ,DB_TBS_CAN_GROW_INC2_MB	NUMBER(20,6)  DEFAULT 2048	NOT NULL
			 )
			 TABLESPACE OTR_REP_DATA
		</cfquery>

		<!--- Add comments to Columns --->
		<cfquery name="qCommentOTR_TBS_SETTINGS01" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_NAME IS 'TNS NAME used for Oracle Net connection'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS02" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_NAME IS 'Tablespace Name'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS03" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_INIT_SIZE_MB IS 'Initial Size of a Datafile (MB)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS04" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_FILE_MAX_MB IS 'Maximum Size of a Datafile (MB)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS05" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_FILE_INC_MB IS 'Increment by-Size of a new Datafile (MB)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS06" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_CAN_GROW_INC1_MB IS 'Can Grow To Increment (1) for a Datafile (MB)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_SETTINGS07" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_SETTINGS.DB_TBS_CAN_GROW_INC2_MB IS 'Can Grow To Increment (2) for a Datafile (MB)'
		</cfquery>

		<!--- Create Contraint OTR_TBS_SETTINGS --->
		<cfquery name="qCreateConstraintOTR_TBS_SETTINGS" datasource="#Application.datasource#">
			ALTER TABLE OTR_TBS_SETTINGS
			 ADD (CONSTRAINT OTR_TBS_SETTINGS_PK PRIMARY KEY (DB_NAME, DB_TBS_NAME)
				  USING INDEX TABLESPACE OTR_REP_INDX)
		</cfquery>
	</cfcatch>
</cftry>

<!--- OTR_DB_SPACE_REP - Add Index --->
<cfquery name="qCreateIndexOTR_DB_SPACE_REP" datasource="#Application.datasource#">
	CREATE INDEX "OTRREP"."OTR_DB_SPACE_REP_IX" 
		ON "OTRREP"."OTR_DB_SPACE_REP" 
		("REP_DATE" DESC , "DB_NAME", "DB_TBS_NAME") 
		TABLESPACE "OTR_REP_INDX" LOGGING
</cfquery>
<!--- OTR_NFS_SPACE_REP - Add Index --->
<cfquery name="qCreateIndexOTR_NFS_SPACE_REP" datasource="#Application.datasource#">
	CREATE INDEX "OTRREP"."OTR_NFS_SPACE_REP_IX" 
		ON "OTRREP"."OTR_NFS_SPACE_REP" 
		("REP_DATE" DESC , "DB_NAME", "MOUNTPOINT") 
		TABLESPACE "OTR_REP_INDX" LOGGING
</cfquery>
<!--- OTR_ASM_SPACE_REP --->
<cftry>
	<cfquery name="qCheckOTR_ASM_SPACE_REP" datasource="#Application.datasource#">
		select db_name from OTR_ASM_SPACE_REP
	</cfquery>
	<cfcatch>
		<!--- Create OTR_TBS_SETTINGS --->
		<cfquery name="qCreateOTR_ASM_SPACE_REP" datasource="#Application.datasource#">
			CREATE TABLE OTR_ASM_SPACE_REP
			 (DB_NAME              VARCHAR2(20)  NOT NULL
			 ,HOSTNAME             VARCHAR2(50)  NOT NULL
			 ,REP_DATE             DATE          NOT NULL
			 ,DG_NAME              VARCHAR2(30)  NOT NULL
			 ,ASM_MB_TOTAL         NUMBER(20,6)  NOT NULL
			 ,ASM_MB_USED          NUMBER(20,6)  NOT NULL
			 ,ASM_MB_FREE          NUMBER(20,6)  NOT NULL
			 ,ASM_PRC_USED         NUMBER(20,6)  NOT NULL
			 )
			 TABLESPACE OTR_REP_DATA
		</cfquery>

		<!--- Add comments to Columns --->
		<cfquery name="qCommentOTR_ASM_SPACE_REP01" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.HOSTNAME IS 'Hostname'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP02" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.REP_DATE IS 'SYSDATE'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP03" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.DG_NAME IS 'ASM Disk Group Name'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP04" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_TOTAL IS 'ASM Volume Size (in MB)'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP05" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_USED IS 'ASM Used Volume Space (in MB)'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP06" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_FREE IS 'ASM Avalable Volume Space (in MB)'
		</cfquery>
		<cfquery name="qCommentOTR_ASM_SPACE_REP07" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_PRC_USED IS 'ASM Available Space (in Procent) computed'
		</cfquery>

		<!--- Create Contraint OTR_ASM_SPACE_REP --->
		<cfquery name="qCreateConstraintOTR_ASM_SPACE_REP" datasource="#Application.datasource#">
			ALTER TABLE OTR_ASM_SPACE_REP
			 ADD (CONSTRAINT OTR_ASM_SPACE_REP_PK PRIMARY KEY (DB_NAME, DG_NAME, REP_DATE)
				  USING INDEX TABLESPACE OTR_REP_INDX)
		</cfquery>
		<!--- Create Index OTR_ASM_SPACE_REP --->
		<cfquery name="qCreateIndexOTR_ASM_SPACE_REP" datasource="#Application.datasource#">
			CREATE INDEX "OTRREP"."OTR_ASM_SPACE_REP_IX" 
				ON "OTRREP"."OTR_ASM_SPACE_REP" 
				("REP_DATE" DESC , "DB_NAME", "DG_NAME") 
				TABLESPACE "OTR_REP_INDX" LOGGING
		</cfquery>
	</cfcatch>
</cftry>

<!--- OTR_ASM_SPACE_REP --->
<cftry>
	<cfquery name="qCheckOTR_TBS_ALERTS" datasource="#Application.datasource#">
		select db_name from OTR_TBS_ALERTS
	</cfquery>
	<cfcatch>
		<!--- Create OTR_TBS_ALERTS --->
		<cfquery name="qCreateOTR_TBS_ALERTS" datasource="#Application.datasource#">
			CREATE TABLE OTR_TBS_ALERTS
			 (REP_DATE             DATE          NOT NULL
			 ,MSG_TYPE             NUMBER(6)     DEFAULT 0
			 ,DB_NAME              VARCHAR2(20)  NOT NULL
			 ,DB_TBS_NAME          VARCHAR2(30)
			 ,DB_ERR               NUMBER(6)     DEFAULT 0
			 ,MB_USED              NUMBER(20,6)
			 ,MB_FREE              NUMBER(20,6)
			 ,CAN_GROW_TO          NUMBER(20,6)
			 ,MAX_MB_FREE          NUMBER(20,6)
			 ,PRC_USED             NUMBER(6,2)
			 ,PRC                  NUMBER(6,2)
			  )
			 TABLESPACE OTR_REP_DATA
		</cfquery>

		<!--- Add comments to Columns --->
		<cfquery name="qCommentOTR_TBS_ALERTS01" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.REP_DATE IS 'SYSDATE'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS02" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.MSG_TYPE IS 'Error Type 0 = OK, 1 = TBS, 2 = DOWN, 3 = LOCKED'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS03" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.DB_NAME IS 'Database Name (SID)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS04" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.DB_TBS_NAME IS 'Tablespace Name'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS05" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.DB_ERR IS 'Error Code'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS06" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.MB_USED IS 'Tablespace USED bytes (in MB)'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS07" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.MB_FREE IS 'Tablespace FREE bytes (in MB) computed'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS08" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.CAN_GROW_TO IS 'Tablespace Can Grow to bytes (in MB) computed'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS09" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.MAX_MB_FREE IS 'Tablespace MAX FREE bytes (in MB) computed'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS10" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.PRC_USED IS 'Tablespace Used (in Procent) computed'
		</cfquery>
		<cfquery name="qCommentOTR_TBS_ALERTS11" datasource="#Application.datasource#">
			COMMENT ON COLUMN OTRREP.OTR_TBS_ALERTS.PRC IS 'Tablespace with autoextent Used (in Procent) computed'
		</cfquery>

		<!--- Create Contraint OTR_TBS_ALERTS --->
		<cfquery name="qCreateConstraintOTR_TBS_ALERTS" datasource="#Application.datasource#">
			ALTER TABLE OTR_TBS_ALERTS
			 ADD (CONSTRAINT OTR_TBS_ALERTS_PK PRIMARY KEY (REP_DATE, MSG_TYPE, DB_NAME, DB_TBS_NAME)
				  USING INDEX TABLESPACE OTR_REP_INDX)
		</cfquery>
	</cfcatch>
</cftry>

<!--- Create View Contraint OTR_TBS_SPACE_REP_V --->
<cfquery name="qCreateViewOTR_TBS_SPACE_REP_V" datasource="#Application.datasource#">
CREATE OR REPLACE FORCE VIEW OTRREP.OTR_TBS_SPACE_REP_V as
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
		   ORDER BY 7 DESC
</cfquery>

<!--- Create View Contraint OTR_DB_HOST_REP_V --->
<cfquery name="qCreateViewOTR_DB_HOST_REP_V" datasource="#Application.datasource#">
	CREATE OR REPLACE FORCE VIEW otrrep.otr_db_host_rep_v (instance_name,
                                                         host_name
                                                        )
	AS
	select distinct e.instance_name, d.machine   
	  from SYS.v_$session d,
	       SYS.v_$thread c,
	       SYS.v_$instance e
	 where c.thread#chr(35)# = e.thread#chr(35)#
	   and (d.program LIKE '%(PMON)' OR d.SID = 1)
</cfquery>

<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">

</head>

<body>
<cfinclude template="_otr_menu_setup.cfm">
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report - Repository Setup</h2>
<cfsetting enablecfoutputonly="false">
<html>
<head>
	<title><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report</title>
<cfinclude template="_otr_css.cfm">

</head>

<body>
<cfinclude template="_otr_menu_setup.cfm">
<br />
<div align="center">
<h2><cfoutput>#application.company#</cfoutput> - Oracle Tablespace Report - Setup</h2>
<table border="0" width="980" cellpadding="10">
<tr>
	<td class="bodyline" align="center" valign="top">
		<strong>OTR Setup Repository</strong>
		<table border="0" width="400">
		<tr><td>&nbsp;</td></tr>
		<tr><td align="center">OTR Repository Upgraded!</td></tr>
		<tr><td>&nbsp;</td></tr>
		<cfif bDropDirectory IS 1><tr><td style="color: green; font-weight: bold; text-align: center;">Please manually drop the Directory Object OTR_REP_DATA_DIR in Schema OTRREP!</td></tr>
		<tr><td>&nbsp;</td></tr></cfif>
		<tr><td style="color: red; font-weight: bold; text-align: center;">The system will return to the main screen within 5 seconds!</td></tr>
		<tr><td>&nbsp;</td></tr>
		</table>
	</td>
<tr>
	<td align="center" colspan="2" style="font-size: 8pt; text-align: center;">
<cfinclude template="_footer.cfm" />
	</td>
</tr>
</table>
</div>
<cfpause interval="5">
<cflocation url="/otr/index.cfm" addtoken="no" />
</body>
</html></cfprocessingdirective>

