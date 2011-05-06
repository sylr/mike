-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.__pg_functions_t CASCADE;

CREATE TYPE mike.__pg_functions_t AS (
    "oid"           oid,
    "name"          name,
    arguments       text
);

CREATE OR REPLACE FUNCTION mike.__pg_functions(
) RETURNS SETOF __pg_functions_t AS $__$

SELECT
    p.oid AS oid,
    p.proname AS name,
    pg_catalog.pg_get_function_identity_arguments(p.oid) AS arguments
FROM
    pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE
    n.nspname ~ '^(mike)$'
ORDER BY 1, 2;

$__$ LANGUAGE sql;
