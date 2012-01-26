DROP VIEW OTRREP.OTR_DB_HOST_REP_V;

CREATE OR REPLACE FORCE VIEW otrrep.otr_db_host_rep_v (instance_name,
                                                         host_name
                                                        )
AS
    select e.instance_name, d.machine   
      from SYS.v_$session d,
           SYS.v_$thread c,
           SYS.v_$instance e
     where  c.thread# = e.thread#
       and (d.program LIKE '%(PMON)' OR d.SID = 1);
