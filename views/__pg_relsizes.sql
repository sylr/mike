-- Mike's View
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 08/06/2011
-- copyright: All rights reserved

DROP VIEW IF EXISTS mike.__pg_relsizes CASCADE;

CREATE OR REPLACE VIEW mike.__pg_relsizes AS
SELECT
    relname,
    relpages,
    pg_size_pretty(relpages::bigint * 8 * 1024) AS size,
    pg_size_pretty(pg_relation_size(relname::text)) AS pg_size
FROM
    pg_class
JOIN
    pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE
    nspname = 'mike'
ORDER BY
    relpages DESC;
