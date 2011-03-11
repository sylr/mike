-- Mike's Misc
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 11/03/2011
-- copyright: All rights reserved

SELECT
    n.nspname AS "Schema",
    pg_catalog.format_type(t.oid, NULL) AS "Name"
FROM pg_catalog.pg_type t
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
WHERE
    (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid)) AND
    NOT EXISTS (SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid) AND
    n.nspname = 'mike' AND
    pg_catalog.pg_type_is_visible(t.oid)
ORDER BY 1, 2;
