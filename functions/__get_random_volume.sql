-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 05/02/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.__get_random_volume(
    OUT out_id_volume       smallint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_random_volume(
    OUT out_id_volume       smallint
) AS $__$

-- select random volume with an active state and which
-- max size has not been reached with a security window.

-- the randomness instead of selecting the least used volume allows
-- to spread to io load due to uploads and asynchronous treatements

DECLARE
    v_percentage    bigint;
BEGIN
    v_percentage := __get_conf_bigint('volume_security_window', false, 10);

    SELECT
        id_volume INTO out_id_volume
    FROM mike.volume
    WHERE
        state = 0 AND
        greatest(virtual_used_size, real_used_size) < max_size - (max_size * v_percentage / 100)
    ORDER BY
        random()
    LIMIT 1;

    IF NOT FOUND THEN RAISE EXCEPTION 'no active and not full volume found'; END IF;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;
