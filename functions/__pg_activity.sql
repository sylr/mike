-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 24/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.__pg_activity_t CASCADE;

CREATE TYPE mike.__pg_activity_t AS (
    datname         name,
    procpid         integer,
    usename         name,
    duration        interval,
    current_query   text
);

DROP FUNCTION IF EXISTS mike.__pg_activity(
    datname         text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__pg_activity(
    datname         text DEFAULT NULL
) RETURNS SETOF __pg_activity_t AS $__$

SELECT
    datname,
    procpid,
    usename,
    now() - query_start AS duration,
    current_query
FROM 
    pg_stat_activity
WHERE
    $1 IS NULL OR
    datname = $1;

$__$ LANGUAGE sql STABLE;

COMMENT ON FUNCTION mike.__pg_activity(
    datname         text
) IS 'show databases activity';
