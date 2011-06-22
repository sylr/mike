-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 22/06/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION __pg_relkind_pretty(
    in_char     "char"
) RETURNS text AS $__$

BEGIN
    IF in_char = 'r' THEN
        RETURN 'table';
    ELSIF in_char = 'i' THEN
        RETURN 'index';
    ELSIF in_char = 'S' THEN
        RETURN 'sequence';
    ELSIF in_char = 'v' THEN
        RETURN 'view';
    ELSIF in_char = 'c' THEN
        RETURN 'type';
    END IF;
END

$__$ LANGUAGE plpgsql IMMUTABLE;
