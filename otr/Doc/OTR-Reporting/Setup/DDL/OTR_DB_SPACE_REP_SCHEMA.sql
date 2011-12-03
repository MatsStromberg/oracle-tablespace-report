whenever sqlerror exit rollback
ACCEPT P_OTRDB DEFAULT 'OTR' CHAR Prompt "Enter Database Alias for the OTR Repository [OTR]: "
ACCEPT P_SYS_Password CHAR Prompt "Enter Password for user SYS: " HIDE
ACCEPT P_DATFILE DEFAULT '/u01/oradata/otr_db/OTR' CHAR Prompt "Enter path for the otr_rep_data01.dbf [/u01/oradata/otr_db/OTR]: "
ACCEPT P_IDXFILE DEFAULT '/u01/oradata/otr_db/OTR' CHAR Prompt "Enter path for the otr_rep_indx01.dbf [/u01/oradata/otr_db/OTR]: "

prompt Password for SYS
conn sys/&P_SYS_Password@&P_OTRDB as sysdba

CREATE TABLESPACE "OTR_REP_DATA" 
    LOGGING 
    DATAFILE '&P_DATFILE/otr_rep_data01.dbf' SIZE 10M REUSE 
    AUTOEXTEND 
    ON NEXT  10240K MAXSIZE 2048M EXTENT MANAGEMENT LOCAL SEGMENT
    SPACE MANAGEMENT  AUTO 
/

CREATE TABLESPACE "OTR_REP_INDX" 
    LOGGING 
    DATAFILE '&P_IDXFILE/otr_rep_indx01.dbf' SIZE 10M REUSE 
    AUTOEXTEND 
    ON NEXT  10240K MAXSIZE 2048M EXTENT MANAGEMENT LOCAL SEGMENT
    SPACE MANAGEMENT  AUTO 
/

REM Oracle Tablespace Reporting repository owner on central db (OTR) 
CREATE USER OTRREP IDENTIFIED BY otrrep4otr
  TEMPORARY TABLESPACE temp 
  DEFAULT TABLESPACE OTR_REP_DATA 
  QUOTA UNLIMITED ON OTR_REP_DATA;

ALTER USER OTRREP QUOTA UNLIMITED ON OTR_REP_INDX;

grant create database link to otrrep;
grant create session to otrrep;
grant create view to otrrep;
grant create table to otrrep;
grant create procedure to otrrep;
grant alter session to otrrep;

grant select on sys.dba_data_files to otrrep;
grant select on sys.dba_free_space to otrrep;
grant select on sys.dba_tablespaces to otrrep;
grant select on sys.dba_temp_files to otrrep;
grant select on sys.dba_undo_extents to otrrep;
grant select on sys.gv_$sort_segment to otrrep;
grant select on sys.ts$ to otrrep;
grant select on sys.v_$instance to otrrep; 
grant select on sys.v_$session to otrrep;
grant select on sys.v_$thread to otrrep;

alter user otrrep identified by otrrep4otr;

