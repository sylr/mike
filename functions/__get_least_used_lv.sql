-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__get_least_used_lv(
) RETURNS text AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_user_count    integer;
    v_return        text;
BEGIN
    IF 'user_count' = mike.__get_conf('lv_repartition_mode', false) THEN
        SELECT
            lv.name INTO v_return
        FROM
            mike.lv
        ORDER BY
            coalesce(array_length(users, 1), 0) ASC,
            random()
        LIMIT 1;

        RETURN v_return;
    ELSIF 'liv_tup' = mike.__get_conf('lv_repartition_mode', false) THEN
       SELECT
            lv.name INTO v_return
        FROM
            mike.lv
        JOIN pg_stat_user_tables ON (relname = 'file_' || lv.name OR relname = 'directory_' || lv.name)
        GROUP BY
            lv.name
        ORDER BY
            sum(n_live_tup),
            random()
        ASC LIMIT 1;

        RETURN v_return;
    END IF;

    -- user count
    SELECT count(id_user) INTO v_user_count FROM mike.user;

    -- default methods if no configuration set
    -- if we have less than an hundred users we user user count by lv to return least
    -- used lv, otherwise we used the sum of tuples of file_<lv> and directory_<lv>
    IF v_user_count < 100 THEN
        SELECT
            lv.name INTO v_return
        FROM
            mike.lv
        ORDER BY
            coalesce(array_length(users, 1), 0) ASC,
            random()
        LIMIT 1;
    ELSE
       SELECT
            lv.name INTO v_return
        FROM
            mike.lv
        JOIN pg_stat_user_tables ON (relname = 'file_' || lv.name OR relname = 'directory_' || lv.name)
        GROUP BY
            lv.name
        ORDER BY
            sum(n_live_tup),
            random()
        ASC LIMIT 1;
    END IF;

    RETURN v_return;
END;

$__$ LANGUAGE plpgsql STABLE;
