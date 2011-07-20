-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

-- Version: MIKE_VERSION

CREATE OR REPLACE FUNCTION mike.__lvusers(
    in_lv_name      text
) RETURNS integer[] AS $__$

DECLARE
    v_return    integer[];
BEGIN
    SELECT users INTO v_return FROM mike.lv WHERE name = in_lv_name;

    RETURN v_return;
END;

$__$ LANGUAGE plpgsql IMMUTABLE;
