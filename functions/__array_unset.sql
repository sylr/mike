-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 11/06/2011
-- copyright: All rights reserved

-- Version: MIKE_VERSION

CREATE OR REPLACE FUNCTION mike.__array_unset(
    in_array        integer[],
    in_elements     integer
) RETURNS integer[] AS $__$

SELECT array_agg(unnest) FROM unnest($1) WHERE unnest != $2;

$__$ LANGUAGE sql IMMUTABLE;

CREATE OR REPLACE FUNCTION mike.__array_unset(
    in_array        integer[],
    in_elements     integer[]
) RETURNS integer[] AS $__$

SELECT array_agg(unnest) FROM unnest($1) WHERE unnest != ANY ($2);

$__$ LANGUAGE sql IMMUTABLE;
