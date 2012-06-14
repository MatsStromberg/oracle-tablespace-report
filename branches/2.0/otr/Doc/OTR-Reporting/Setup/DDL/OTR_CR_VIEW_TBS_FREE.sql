CREATE OR REPLACE FORCE VIEW OTRREP.OTR_TBS_SPACE_REP_V as
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
ORDER BY ((a.BYTES - NVL (b.BYTES, 0)) / a.BYTES) DESC
/

CREATE OR REPLACE FORCE VIEW OTRREP.OTR_TBS_SPACE_REP2_V (tablespace_name,
                                                          allocated_size_mb,
                                                          space_used_mb,
                                                          allocated_space_used_prc,
                                                          allocated_free_space_mb,
                                                          status,
                                                          DATAFILES,
                                                          TYPE,
                                                          extent_management,
                                                          segment_management
                                                         )
AS
   SELECT   /*+  FIRST_ROWS */
            d.tablespace_name, NVL ((a.BYTES / 1024) / 1024, 0),
            ROUND ((NVL (a.BYTES - NVL (f.BYTES, 0), 0) / 1024) / 1024, 1),
            ROUND (NVL (((a.BYTES - NVL (f.BYTES, 0)) / a.BYTES) * 100, 0), 1),
            ROUND ((NVL (f.BYTES, 0) / 1024) / 1024, 1), d.status, a.COUNT,
            d.CONTENTS, d.extent_management, d.segment_space_management
       FROM SYS.dba_tablespaces d,
            (SELECT   tablespace_name, SUM (BYTES) BYTES,
                      COUNT (file_id) COUNT
                 FROM dba_data_files
             GROUP BY tablespace_name) a,
            (SELECT   tablespace_name, SUM (BYTES) BYTES
                 FROM dba_free_space
             GROUP BY tablespace_name) f
      WHERE d.tablespace_name = a.tablespace_name(+)
        AND d.tablespace_name = f.tablespace_name(+)
        AND NOT d.CONTENTS = 'UNDO'
        AND NOT (d.extent_management = 'LOCAL' AND d.CONTENTS = 'TEMPORARY')
        AND d.tablespace_name LIKE '%'
   UNION ALL
   SELECT   d.tablespace_name, NVL ((a.BYTES / 1024) / 1024, 0),
            ROUND ((NVL (t.BYTES, 0) / 1024) / 1024, 1),
            ROUND (NVL ((t.BYTES / a.BYTES) * 100, 0), 1),
            ROUND (  (NVL (a.BYTES, 0) / 1024) / 1024
                   - (NVL (t.BYTES, 0) / 1024) / 1024, 1),
            d.status, a.COUNT, d.CONTENTS, d.extent_management,
            d.segment_space_management
       FROM SYS.dba_tablespaces d,
            (SELECT   tablespace_name, SUM (BYTES) BYTES,
                      COUNT (file_id) COUNT
                 FROM dba_temp_files
             GROUP BY tablespace_name) a,
            (SELECT   ss.tablespace_name,
                      SUM (ss.used_blocks * ts.BLOCKSIZE) BYTES
                 FROM gv$sort_segment ss, SYS.ts$ ts
                WHERE ss.tablespace_name = ts.NAME
             GROUP BY ss.tablespace_name) t
      WHERE d.tablespace_name = a.tablespace_name(+)
        AND d.tablespace_name = t.tablespace_name(+)
        AND d.extent_management = 'LOCAL'
        AND d.CONTENTS = 'TEMPORARY'
        AND d.tablespace_name LIKE '%'
   UNION ALL
   SELECT   d.tablespace_name, ROUND (NVL ((a.BYTES / 1024) / 1024, 0), 1),
            ROUND ((NVL (u.BYTES, 0) / 1024) / 1024, 1),
            ROUND (NVL ((u.BYTES / a.BYTES) * 100, 0), 1),
            ROUND ((NVL (a.BYTES - NVL (u.BYTES, 0), 0) / 1024) / 1024, 1),
            d.status, a.COUNT, d.CONTENTS, d.extent_management,
            d.segment_space_management
       FROM SYS.dba_tablespaces d,
            (SELECT   tablespace_name, SUM (BYTES) BYTES,
                      COUNT (file_id) COUNT
                 FROM dba_data_files
             GROUP BY tablespace_name) a,
            (SELECT   tablespace_name, SUM (BYTES) BYTES
                 FROM (SELECT   tablespace_name, SUM (BYTES) BYTES, status
                           FROM dba_undo_extents
                          WHERE status = 'ACTIVE'
                       GROUP BY tablespace_name, status
                       UNION ALL
                       SELECT   tablespace_name, SUM (BYTES) BYTES, status
                           FROM dba_undo_extents
                          WHERE status = 'UNEXPIRED'
                       GROUP BY tablespace_name, status)
             GROUP BY tablespace_name) u
      WHERE d.tablespace_name = a.tablespace_name(+)
        AND d.tablespace_name = u.tablespace_name(+)
        AND d.CONTENTS = 'UNDO'
        AND d.tablespace_name LIKE '%'
   ORDER BY 1
/
