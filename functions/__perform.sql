-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 27/11/2010
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__perform(
    IN  in_sql          text
) RETURNS void AS $__$

-- Version: MIKE_VERSION

BEGIN
    PERFORM in_sql;
END;

$__$ LANGUAGE plpgsql;
