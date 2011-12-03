ACCEPT P_OTRDB DEFAULT 'OTR' CHAR Prompt "Enter Database Alias for the OTR Repository [OTR]: "
ACCEPT P_SYS_Password CHAR Prompt "Enter Password for user SYS: " HIDE
ACCEPT P_OTRREP_Password CHAR Prompt "Enter Password for user OTRREP: " HIDE
Prompt "Path for the External table must be LOCALLY on the OTR DB Server (no UNC path allowed!)"
ACCEPT P_XTFILE DEFAULT '/orascripts/scripts/monitoring/xt/OTR' CHAR Prompt "Enter path for the External Table [/orascripts/scripts/monitoring/xt/OTR]: "
ACCEPT P_SQLNET_DOMAIN DEFAULT 'MBCZH.CH' CHAR Prompt "Enter SQLNET.DEFAULT_DOMAIN [MBCZH.CH]: "

-- PROMPT Connecting as SYS AS SYSDBA on OGC2ICB database, please enter SYS password and press ENTER
connect SYS/&P_SYS_Password@&P_OTRDB AS SYSDBA

PROMPT Creating DIRECTORY 'OTR_REP_DATA_DIR'
REM NOTICE: Must be LOCALLY on the OTR Repository DB Server (no UNC path allowed)!
REM         Can ofcourse be an NFS mountpoint!
create directory OTR_REP_DATA_DIR as '&P_XTFILE'
/

GRANT ALL ON DIRECTORY OTR_REP_DATA_DIR TO OTRREP
/

PROMPT Connecting as OTRREP on &P_OTRDB database
connect OTRREP/&P_OTRREP_Password@&P_OTRDB


PROMPT Creating Table 'OTR_DB'
CREATE TABLE OTR_DB
 (DB_NAME VARCHAR2(20)  NOT NULL
 ,DB_ENV  CHAR(3)       NOT NULL
 ,DB_DESC VARCHAR2(100) NOT NULL 
 ,SYSTEM_PASSWORD VARCHAR2(200)
 )
 TABLESPACE OTR_REP_DATA
/

COMMENT ON COLUMN OTRREP.OTR_DB.DB_NAME IS 'TNS NAME used for Oracle Net connection'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_ENV IS 'Environment (DEE=Dedicated Enterprise Edition, DSE=Dedicated Standard Edition, SEE=Shared EE, SSE=Shared SE, INT=Internal Infrastructure, DEV=Development Instances)'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_DESC IS 'Descriptive name for the Instance'
/
COMMENT ON COLUMN OTRREP.OTR_DB.SYSTEM_PASSWORD IS 'Password for user SYSTEM'
/


PROMPT Creating Table 'OTR_CUST'
CREATE TABLE OTR_CUST
 (CUST_ID   VARCHAR2(20)  NOT NULL
 ,CUST_NAME VARCHAR2(100) NOT NULL
 )
 TABLESPACE OTR_REP_DATA
/

COMMENT ON COLUMN OTRREP.OTR_CUST.CUST_ID IS 'Short ID for custumer, usually a 3 letter code'
/
COMMENT ON COLUMN OTRREP.OTR_CUST.CUST_NAME IS 'Company name of the customer'
/


PROMPT Creating Table 'OTR_CUST_APPL_TBS_XT' - EXTERNALLY IDENTIFIED (MAINTAINED BY XLS)!
create table OTR_CUST_APPL_TBS_XT
 (CUST_ID           VARCHAR2(20)
 ,CUST_APPL_ID      VARCHAR2(30)
 ,DB_NAME           VARCHAR2(20)
 ,DB_TBS_NAME       VARCHAR2(30)
 )
 organization external  
 (type oracle_loader  
  default directory OTR_REP_DATA_DIR
  access parameters (records delimited by newline 
                     fields terminated by ';') 
  location ('OTR_CUST_APPL_TBS_XT.DAT'))
/

PROMPT Creating Table 'OTR_DB_SPACE_REP'
CREATE TABLE OTR_DB_SPACE_REP
 (DB_NAME              VARCHAR2(20)  NOT NULL
 ,DB_TBS_NAME          VARCHAR2(30)  NOT NULL
 ,REP_DATE             DATE          NOT NULL -- SYSDATE without time, TRUNC
 ,DB_TBS_USED_MB       NUMBER(20,6)  NOT NULL -- Tablespace USED bytes (in MB)
 ,DB_TBS_FREE_MB       NUMBER(20,6)  NOT NULL -- Tablespace FREE bytes (in MB) computed
 ,DB_TBS_CAN_GROW_MB   NUMBER(20,6)  NOT NULL -- Tablespace Can Grow to bytes (in MB) computed
 ,DB_TBS_MAX_FREE_MB   NUMBER(20,6)  NOT NULL -- Tablespace MAX FREE bytes (in MB) computed
 ,DB_TBS_PRC_USED      NUMBER(20,6)  NOT NULL -- Tablespace Used (in Procent) computed
 ,DB_TBS_REAL_PRC_USED NUMBER(20,6)  NOT NULL -- Tablespace with autoextent Used (in Procent) computed
 )
 TABLESPACE OTR_REP_DATA
/

PROMPT Creating Table 'OTR_NFS_SPACE_REP'
CREATE TABLE OTR_NFS_SPACE_REP
 (DB_NAME              VARCHAR2(20)  NOT NULL
 ,HOSTNAME             VARCHAR2(50)  NOT NULL
 ,NFS_SERVER           VARCHAR2(20)  NOT NULL
 ,FILESYSTEM           VARCHAR2(150) NOT NULL
 ,MOUNTPOINT           VARCHAR2(100) NOT NULL
 ,REP_DATE             DATE          NOT NULL -- SYSDATE without time, TRUNC
 ,NFS_MB_TOTAL         NUMBER(20,6)  NOT NULL -- NFS Volume Size (in MB)
 ,NFS_MB_USED          NUMBER(20,6)  NOT NULL -- NFS Used Volume Space (in MB)
 ,NFS_MB_FREE          NUMBER(20,6)  NOT NULL -- NFS Avalable Volume Space (in MB)
 ,NFS_PRC_USED         NUMBER(20,6)  NOT NULL -- NFS Available Space  (in Procent) computed
 )
 TABLESPACE OTR_REP_DATA
/


PROMPT Creating constraints
PROMPT Creating PK constraints
PROMPT Adding constraint to table 'OTR_DB'
ALTER TABLE OTR_DB
 ADD (CONSTRAINT OTR_DB_PK PRIMARY KEY (DB_NAME)
      USING INDEX TABLESPACE OTR_REP_INDX)
/

PROMPT Adding constraint to table 'OTR_CUST'
ALTER TABLE OTR_CUST
 ADD (CONSTRAINT OTR_CUST_PK PRIMARY KEY (CUST_ID)
      USING INDEX TABLESPACE OTR_REP_INDX)
/


PROMPT Adding constraint to table 'OTR_DB_SPACE_REP'
ALTER TABLE OTR_DB_SPACE_REP
 ADD (CONSTRAINT OTR_DB_SPACE_REP_PK PRIMARY KEY (DB_NAME, DB_TBS_NAME, REP_DATE)
      USING INDEX TABLESPACE OTR_REP_INDX)
/

PROMPT Adding constraint to table 'OTR_NFS_SPACE_REP'
ALTER TABLE OTR_NFS_SPACE_REP
 ADD (CONSTRAINT OTR_NFS_SPACE_REP_PK PRIMARY KEY (DB_NAME, MOUNTPOINT, REP_DATE)
      USING INDEX TABLESPACE OTR_REP_INDX)
/


PROMPT Creating CHECK constraints
PROMPT Creating Check Constraint on 'OTR_DB'
ALTER TABLE OTR_DB
 ADD (CONSTRAINT OTR_DB_DB_ENV_CHK CHECK (DB_ENV IN ('DEE','DSE','INT','SEE','SSE','DEV')))
/

PROMPT CREATING VIEWS
REM View definition for constructing the relation CUSTOMER, DB and APPLICATION
create or replace view OTRREP.OTR_CUST_APPL_DB_V as 
select distinct a.CUST_ID,a.CUST_APPL_ID,a.DB_NAME,b.DB_ENV
 from OTRREP.OTR_CUST_APPL_TBS_XT a
     ,OTR_DB b
     ,OTR_CUST c
where b.db_name = a.db_name
  and c.cust_id = a.cust_id
order by a.CUST_ID,a.CUST_APPL_ID,a.DB_NAME
/

REM View definition for constructing the relation CUSTOMER, DB, APPLICATION and TBS
create or replace view OTRREP.OTR_CUST_APPL_DB_TBS_V as 
select a.CUST_ID,a.CUST_APPL_ID,a.DB_NAME,a.DB_TBS_NAME,b.DB_ENV
 from OTRREP.OTR_CUST_APPL_TBS_XT a
     ,OTR_DB b
     ,OTR_CUST c
where b.db_name = a.db_name
  and c.cust_id = a.cust_id
order by a.CUST_ID,a.CUST_APPL_ID,a.DB_NAME,a.DB_TBS_NAME
/

REM View definition for accessing gathered Oracle Tablespace Reporting data
create or replace force view otrrep.otr_space_rep_v (cust_id,
                                                     cust_appl_id,
                                                     rep_date,
                                                     db_name,
                                                     db_env,
                                                     db_tbs_name,
                                                     db_tbs_used_mb,
                                                     db_tbs_free_mb,
                                                     db_tbs_real_used_mb,
                                                     db_tbs_can_grow_mb,
                                                     db_tbs_max_free_mb,
                                                     db_tbs_prc_used,
                                                     db_tbs_real_prc_used
                                                    )
AS
   SELECT   a.cust_id, a.cust_appl_id, b.rep_date, a.db_name, a.db_env,
            b.db_tbs_name, b.db_tbs_used_mb, b.db_tbs_free_mb,
            (b.db_tbs_used_mb - b.db_tbs_free_mb) AS db_tbs_real_used_mb,
            b.db_tbs_can_grow_mb, b.db_tbs_max_free_mb, b.db_tbs_prc_used,
            b.db_tbs_real_prc_used
       FROM otr_cust_appl_db_tbs_v a, otr_db_space_rep b
      WHERE b.db_name = a.db_name AND b.db_tbs_name = a.db_tbs_name
   ORDER BY a.cust_appl_id, a.db_env, a.db_name, a.db_tbs_name
/


REM View definition for showing distinct timestamps for gathered Oracle Tablespace Reporting data
CREATE OR REPLACE FORCE VIEW otrrep.otr_space_rep_timestamps_v (rep_date)
AS
   SELECT DISTINCT TRUNC (rep_date) rep_date
              FROM otr_db_space_rep
          ORDER BY rep_date
/

REM View definition for showing the LATEST timestamp for gathered Oracle Tablespace Reporting data
CREATE OR REPLACE FORCE VIEW otrrep.otr_space_rep_max_timestamp_v (rep_date)
AS
   SELECT   MAX (TRUNC (rep_date)) rep_date
       FROM otr_db_space_rep
   ORDER BY rep_date
/

REM View definition for showing the EARLIEST timestamp for gathered Oracle Tablespace Reporting data
CREATE OR REPLACE FORCE VIEW otrrep.otr_space_rep_min_timestamp_v (rep_date)
AS
   SELECT   MIN (TRUNC (rep_date)) rep_date
       FROM otr_db_space_rep
   ORDER BY rep_date
/

REM View definition for showing the first and the last timestamp for gathered Oracle Tablespace Reporting data
CREATE OR REPLACE FORCE VIEW otrrep.otr_space_rep_min_max_v (first_date,
                                                             last_date
                                                            )
AS
   SELECT f.rep_date AS first_date, l.rep_date AS last_date
     FROM otr_space_rep_min_timestamp_v f, otr_space_rep_max_timestamp_v l
/

REM Create VIEW using "OTR_CR_VIEW_TBS_FREE.sql"
-- @@ is used for nested scripts
@@OTR_CR_VIEW_TBS_FREE.sql
REM Create VIEW using "OTR_CR_VIEW_DB_HOST.sql"
@@OTR_CR_VIEW_DB_HOST.sql
