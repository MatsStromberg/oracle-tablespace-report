whenever sqlerror exit rollback
set vwrify off
ACCEPT P_OTR_TARGET_DB CHAR Prompt "Enter Database Alias for the Target DB: "
ACCEPT P_OTRREP_USER DEFAULT 'OTRREP_SYSTEM' CHAR Prompt "Enter the Username for your OTRREP User [OTRREP_SYSTEM]: "
ACCEPT P_OTRREP_USER_PW CHAR Prompt "Enter password for your &&P_OTRREP_USER User: " HIDE
ACCEPT P_SYS_Password CHAR Prompt "Enter Password for user SYS: " HIDE

conn sys/&P_SYS_Password@&P_OTR_TARGET_DB as sysdba

prompt
prompt Choose the &P_OTRREP_USER user's User tablespace.

column dbu_default format a28 heading 'DEFAULT PERMANENT TABLESPACE'
select t.tablespace_name, t.contents
     , decode(dp.property_name,'DEFAULT_PERMANENT_TABLESPACE','*') dbu_default
  from sys.dba_tablespaces t
     , sys.database_properties dp
 where t.contents           = 'PERMANENT'
   and t.status             = 'ONLINE'
   and dp.property_name(+)  = 'DEFAULT_PERMANENT_TABLESPACE'
   and dp.property_value(+) = t.tablespace_name
   and t.tablespace_name NOT IN ('SYSTEM', 'SYSAUX')
 order by tablespace_name;

prompt
prompt Pressing <return> will result in the database's default User 
prompt tablespace (identified by *) being used.
prompt

ACCEPT user_tablespace CHAR Prompt "Enter Temporary TABLESPACE Name: "
set heading off
col user_tablespace new_value user_tablespace noprint
select 'Using tablespace '||
       nvl('&&user_tablespace',property_value)||
       ' as &&P_OTRREP_USER user tablespace.'
     , nvl('&&user_tablespace',property_value) user_tablespace
  from database_properties
 where property_name='DEFAULT_PERMANENT_TABLESPACE';
set heading on

begin
  if upper('&&user_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
begin
  if upper('&&user_tablespace') = 'SYSAUX' then
    raise_application_error(-20101, 'Install failed - SYSAUX tablespace specified for TEMPORARY tablespace');
  end if;
end;
/

prompt
prompt Choose the &&P_OTRREP_USER user's Temporary tablespace.

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
       ' as &&P_OTRREP_USER temporary tablespace.'
     , nvl('&&temporary_tablespace',property_value) temporary_tablespace
  from database_properties
 where property_name='DEFAULT_TEMP_TABLESPACE';
set heading on

begin
  if upper('&&temporary_tablespace') = 'SYSTEM' then
    raise_application_error(-20101, 'Install failed - SYSTEM tablespace specified for TEMPORARY tablespace');
  end if;
end;
begin
  if upper('&&user_tablespace') = 'SYSAUX' then
    raise_application_error(-20101, 'Install failed - SYSAUX tablespace specified for TEMPORARY tablespace');
  end if;
end;
/


CREATE USER "&&P_OTRREP_USER" PROFILE "APPLICATION_PROFILE" IDENTIFIED BY "&&P_OTRREP_USER_PW" 
	DEFAULT TABLESPACE "&&user_tablespace" 
	TEMPORARY TABLESPACE "&&temporary_tablespace" ACCOUNT UNLOCK;
GRANT "CONNECT" TO "&&P_OTRREP_USER";
GRANT ALTER DATABASE TO "&&P_OTRREP_USER" WITH ADMIN OPTION;
GRANT ALTER TABLESPACE TO "&&P_OTRREP_USER" WITH ADMIN OPTION;
GRANT SELECT ON "PUBLIC"."V$ASM_DISKGROUP_STAT" TO "&&P_OTRREP_USER";
GRANT SELECT ON "SYS"."DBA_DATA_FILES" TO "&&P_OTRREP_USER";
GRANT SELECT ON "SYS"."DBA_FREE_SPACE" TO "&&P_OTRREP_USER;
GRANT SELECT ON "SYS"."DBA_THRESHOLDSgrant select " TO "&&P_OTRREP_USER";
GRANT EXECUTE ON "SYS"."DBMS_SERVER_ALERT" TO "&&P_OTRREP_USER";
