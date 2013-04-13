whenever sqlerror exit rollback
ACCEPT P_OTRDB DEFAULT 'OTR' CHAR Prompt "Enter Database Alias for the OTR Repository [OTR]: "
ACCEPT P_SYS_Password CHAR Prompt "Enter Password for user SYS: " HIDE
ACCEPT P_DATFILE DEFAULT '/u01/oradata/otr_db/OTR' CHAR Prompt "Enter path for the otr_rep_data01.dbf [/u01/oradata/otr_db/OTR]: "
ACCEPT P_IDXFILE DEFAULT '/u01/oradata/otr_db/OTR' CHAR Prompt "Enter path for the otr_rep_indx01.dbf [/u01/oradata/otr_db/OTR]: "

prompt Password for SYS
conn sys/&P_SYS_Password@&P_OTRDB as sysdba

prompt
prompt Choose the OTRREP user's Temporary tablespace.

column db_default format a26 heading 'DB DEFAULT TEMP TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_TEMP_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'TEMPORARY'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_TEMP_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default Temporary 
prompt tablespace (identified by *) being used.
prompt

ACCEPT temporary_tablespace CHAR Prompt "Enter Temporary TABLESPACE Name: "
set heading off
col temporary_tablespace new_value temporary_tablespace noprint
select 'Using tablespace '||
       nvl('&&temporary_tablespace',property_value)||
       ' as OTRREP temporary tablespace.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';
set heading on

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
/

prompt
prompt
prompt ... Creating OTRREP user

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
  TEMPORARY TABLESPACE &&temporary_tablespace 
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

-- alter user otrrep identified by otrrep4otr;

