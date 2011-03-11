-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/12/2010
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__get_mimetype(
    IN  in_id_mimetype      smallint
) RETURNS text AS $__$

SELECT mimetype FROM mike.mimetype WHERE id_mimetype = $1;

$__$ LANGUAGE sql STABLE COST 10;
