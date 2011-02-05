-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 05/02/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.__get_least_used_active_volume(
    OUT out_id_volume       smallint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_least_used_active_volume(
    OUT out_id_volume       smallint
) AS $__$

-- select least used volume with an active state
-- look that max_size volume have not been reached
-- with a 5% security window

BEGIN
    SELECT id_volume INTO out_id_volume
    FROM mike.volume
    WHERE
        state = 0
        AND used_size < max_size - (max_size * 5 / 100)
    ORDER BY used_size ASC
    LIMIT 1;

    IF NOT FOUND THEN RAISE EXCEPTION 'no volume found'; END IF;
END;

$__$ LANGUAGE plpgsql STABLE;
