-- Mike's View
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 08/06/2011
-- copyright: All rights reserved

DROP VIEW IF EXISTS mike.__pg_activity CASCADE;

#ifdef PG_VERSION_GE_9_2
CREATE OR REPLACE VIEW mike.__pg_activity AS
SELECT
    datname,
    pid,
    usename,
    waiting AS wait,
    now() - query_start AS duration,
    query
FROM
    pg_stat_activity
WHERE
    datname = current_database()
ORDER BY
    duration DESC;
#else
CREATE OR REPLACE VIEW mike.__pg_activity AS
SELECT
    datname,
    procpid,
    usename,
    waiting AS wait,
    now() - query_start AS duration,
    current_query
FROM
    pg_stat_activity
WHERE
    datname = current_database()
ORDER BY
    duration DESC;
#endif
