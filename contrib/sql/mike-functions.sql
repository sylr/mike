-- Mike's Misc
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

SELECT
  p.proname AS "Name",
  pg_catalog.pg_get_function_identity_arguments(p.oid) AS "Argument data types"
FROM pg_catalog.pg_proc p
LEFT JOIN pg_catalog.pg_namespace n ON n.oid = p.pronamespace
WHERE
    n.nspname ~ '^(mike)$'
ORDER BY 1, 2;
