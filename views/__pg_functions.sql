-- Mike's View
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP VIEW IF EXISTS mike.__pg_functions CASCADE;

CREATE OR REPLACE VIEW mike.__pg_functions AS
SELECT
    p.oid AS oid,
    p.proname AS "Name",
    pg_catalog.pg_get_function_identity_arguments(p.oid) AS "Arguments"
FROM
    pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE
    n.nspname ~ '^(mike)$'
ORDER BY "Name", "Arguments";
