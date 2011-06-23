-- Mike's View
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 22/06/2011
-- copyright: All rights reserved

DROP VIEW IF EXISTS mike.__pg_tables CASCADE;

CREATE OR REPLACE VIEW mike.__pg_tables AS
SELECT
    pg_stat_all_tables.relid,
    pg_stat_all_tables.relname,
    pg_class.relpages AS relpages,
    pg_relation_size(pg_stat_all_tables.relname::text) AS relsize,
    pg_stat_all_tables.seq_scan,
    pg_stat_all_tables.seq_tup_read,
    pg_stat_all_tables.idx_scan,
    pg_stat_all_tables.idx_tup_fetch,
    pg_stat_all_tables.n_tup_ins,
    pg_stat_all_tables.n_tup_upd,
    pg_stat_all_tables.n_tup_del,
    pg_stat_all_tables.n_tup_hot_upd,
    pg_stat_all_tables.n_live_tup,
    pg_stat_all_tables.n_dead_tup,
    date_trunc('second', pg_stat_all_tables.last_vacuum) AS last_vacuum,
    date_trunc('second', pg_stat_all_tables.last_autovacuum) AS last_autovacuum,
    date_trunc('second', pg_stat_all_tables.last_analyze) AS last_analyze,
    date_trunc('second', pg_stat_all_tables.last_autoanalyze) AS last_autoanalyze
FROM
    pg_stat_all_tables
JOIN
    pg_class ON (pg_stat_all_tables.relid = pg_class.oid)
WHERE 
    pg_stat_all_tables.schemaname = 'mike'::name AND 
    pg_stat_all_tables.schemaname !~ '^pg_toast'::text;
