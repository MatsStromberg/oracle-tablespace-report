set echo off verify off showmode off feedback off;
whenever sqlerror exit sql.sqlcode

REM NOTICE! ON MANY DBs THE "USERS" AND "TEMP" TABLESPACES HAVE NON-STANDARD NAMES (TEMPTBS, TEMP01, USERS01, USERS1 etc.)!
ACCEPT P_OTRDB CHAR Prompt "Enter Database Alias for the Target DB (TNSNAMES): "
ACCEPT P_SYS_Password CHAR Prompt "Enter Password for user SYS: " HIDE

-- PROMPT Connecting as SYS AS SYSDBA on the Target database
connect SYS/&P_SYS_Password@&P_OTRDB AS SYSDBA

prompt
prompt
prompt Choose the Permanent (USER) tablespace for the OTRREP user
prompt ----------------------------------------------------------

prompt Below is the list of online tablespaces in this database which can
prompt can be used for storing data and objects.  
prompt Tablespace marked with a * is the default permanent tablespace. 
prompt selecting the SYSTEM tablespace as tablespace for OTRREP when
prompt there is an USERS tablespace available don't make sence!!!

prompt Select the OTRREP user's Standard tablespace.

column db_default format a26 heading 'DB DEFAULT PERMANENT TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_PERMANENT_TABLESPACE','*') db_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'PERMANENT'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_PERMANENT_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default Permanent 
prompt tablespace (identified by *) being used.
prompt

ACCEPT permanent_tablespace CHAR Prompt "Enter Permanent TABLESPACE Name: "
set heading off
col permanent_tablespace new_value permanent_tablespace noprint
select 'Using tablespace '||
       nvl('&&permanent_tablespace',property_value)||
       ' as OTRREP permanent tablespace.'
     , nvl('&&permanent_tablespace',property_value) permanent_tablespace
  from database_properties
 where property_name='DEFAULT_PERMANENT_TABLESPACE';
set heading on

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

CREATE USER OTRREP IDENTIFIED BY otrrep4otr
  DEFAULT TABLESPACE &&permanenet_tablespace 
  TEMPORARY TABLESPACE &&temporary_tablespace 
  QUOTA UNLIMITED ON &&permanant_tablespace;

grant connect to otrrep;
grant select_catalog_role to otrrep;
alter user otrrep default role all;
grant create database link to otrrep;
grant create session to otrrep;
grant create table to otrrep;
grant create view to otrrep;
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


REM Create VIEW using "OTR_CR_VIEW_TBS_FREE.sql"
-- @@ is used for nested scripts
@@OTR_CR_VIEW_TBS_FREE.sql
REM Create VIEW using "OTR_CR_VIEW_DB_HOST.sql"
@@OTR_CR_VIEW_DB_HOST.sql
