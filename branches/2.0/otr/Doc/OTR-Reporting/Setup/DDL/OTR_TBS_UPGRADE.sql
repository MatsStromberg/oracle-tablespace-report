ACCEPT P_OTRDB DEFAULT 'OTR' CHAR Prompt "Enter Database Alias for the OTR Repository [OTR]: "
ACCEPT P_OTRREP_Password CHAR Prompt "Enter Password for user OTRREP: " HIDE

PROMPT Connecting as OTRREP on &P_OTRDB database
connect OTRREP/&P_OTRREP_Password@&P_OTRDB

PROMPT Creating Table 'OTR_CUST_APPL_TBS' - MAINTAINED OVER EXCEL!
create table OTR_CUST_APPL_TBS
 (CUST_ID            VARCHAR(20)   NOT NULL
 ,CUST_APPL_ID       VARCHAR(100)
 ,DB_NAME            VARCHAR(20)   NOT NULL
 ,DB_TBS_NAME        VARCHAR(30)   NOT NULL
 ,THRESHOLD_WARNING  NUMBER(6)     DEFAULT 85
 ,THRESHOLD_CRITICAL NUMBER(6)     DEFAULT 97
 )
 TABLESPACE OTR_REP_DATA
/

COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.CUST_ID IS 'Short ID for custumer, usually a 3 letter code'
/
COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.CUST_APPL_ID IS 'Descriptive name for the Instance'
/
COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.DB_NAME IS 'TNS NAME used for Oracle Net connection'
/
COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.DB_TBS_NAME IS 'Tablespace name to monitor'
/
COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.THRESHOLD_WARNING IS 'Warning threshold value'
/
COMMENT ON COLUMN OTRREP.OTR_CUST_APPL_TBS.THRESHOLD_CRITICAL IS 'Critical threshold value'
/

PROMPT Adding constraint to table 'OTR_CUST_APPL_TBS'
ALTER TABLE OTR_CUST_APPL_TBS
 ADD (CONSTRAINT OTR_CUST_APPL_TBS_PK PRIMARY KEY (DB_NAME, DB_TBS_NAME)
      USING INDEX TABLESPACE OTR_REP_INDX)
/

PROMPT Loading Basic data from old External Table
INSERT INTO OTR_CUST_APPL_TBS
 (CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME)
 (SELECT CUST_ID, CUST_APPL_ID, DB_NAME, DB_TBS_NAME
   FROM OTR_CUST_APPL_TBS_XT)
/

PROMPT Adding new columns to table 'OTR_DB'
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_HOST  VARCHAR2(100 BYTE))
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_PORT  NUMBER(6)  DEFAULT 1521)
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_ASM  NUMBER(3)  DEFAULT 0)
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_RAC  NUMBER(3)  DEFAULT 0)
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_SERVICENAME  VARCHAR2(100 BYTE))
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_BLACKOUT  NUMBER(3)  DEFAULT 0)
/

COMMENT ON COLUMN OTRREP.OTR_DB.DB_HOST IS 'Host server for this Instance'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_PORT IS 'Listener Port for this Instance'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_ASM IS 'Storage using ASM = 1, NO ASM = 0'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_RAC IS 'RAC = 1, NO RAC = 0'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_SERVICENAME IS 'Service Name is required for RAC!'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_BLACKOUT IS 'BLACKOUT = 1, ONLINE = 0'
/

PROMPT Creating Table 'OTR_ASM_SPACE_REP'
CREATE TABLE OTR_ASM_SPACE_REP
 (DB_NAME              VARCHAR2(20)  NOT NULL
 ,HOSTNAME             VARCHAR2(50)  NOT NULL
 ,REP_DATE             DATE          NOT NULL -- SYSDATE without time, TRUNC
 ,DG_NAME              VARCHAR2(30)  NOT NULL -- ASM Disk Group Name
 ,ASM_MB_TOTAL         NUMBER(20,6)  NOT NULL -- ASM Volume Size (in MB)
 ,ASM_MB_USED          NUMBER(20,6)  NOT NULL -- ASM Used Volume Space (in MB)
 ,ASM_MB_FREE          NUMBER(20,6)  NOT NULL -- ASM Avalable Volume Space (in MB)
 ,ASM_PRC_USED         NUMBER(20,6)  NOT NULL -- ASM Available Space  (in Procent) computed
 )
 TABLESPACE OTR_REP_DATA
/

COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.REP_DATE IS 'SYSDATE without time, TRUNC'
/
COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.DG_NAME IS 'ASM Disk Group Name'
/
COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_TOTAL IS 'ASM Volume Size (in MB)'
/
COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_USED IS 'ASM Used Volume Space (in MB)'
/
COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_MB_FREE IS 'ASM Avalable Volume Space (in MB)'
/
COMMENT ON COLUMN OTRREP.OTR_ASM_SPACE_REP.ASM_PRC_USED IS 'ASM Available Space (in Procent) computed'
/

PROMPT Adding constraint to table 'OTR_ASM_SPACE_REP'
ALTER TABLE OTR_ASM_SPACE_REP
 ADD (CONSTRAINT OTR_ASM_SPACE_REP_PK PRIMARY KEY (DB_NAME, DG_NAME, REP_DATE)
      USING INDEX TABLESPACE OTR_REP_INDX)
/