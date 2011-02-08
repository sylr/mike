-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/02/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__mod_cons_hash(
    IN  in_dividend     bigint,
    IN  in_divisor      integer,
    OUT remainder       integer
) AS $__$

BEGIN
    SELECT in_dividend % in_divisor INTO remainder;
END;

$__$ LANGUAGE plpgsql IMMUTABLE COST 10;
