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

PROMPT Adding new columns to table 'OTR_DB'
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_HOST  VARCHAR2(100 BYTE))
/
ALTER TABLE OTRREP.OTR_DB
 ADD (DB_PORT  NUMBER(6)  DEFAULT 1521)
/

COMMENT ON COLUMN OTRREP.OTR_DB.DB_HOST IS 'Host server for this Instance'
/
COMMENT ON COLUMN OTRREP.OTR_DB.DB_PORT IS 'Listener Port for this Instance'
/