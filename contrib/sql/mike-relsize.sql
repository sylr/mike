-- Mike's Misc
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

SELECT
    relname,
    relpages,
    pg_size_pretty(relpages * 8 * 1024) AS size
FROM pg_class
JOIN pg_catalog.pg_namespace ON pg_class.relnamespace = pg_namespace.oid
WHERE nspname = 'mike'
ORDER BY relpages DESC;
