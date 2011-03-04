-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.stat(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.stat(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) RETURNS SETOF mike.inode AS $__$

SELECT * FROM mike.inode WHERE id_user = $1 AND id_inode = $2;

$__$ LANGUAGE sql STABLE COST 1000;

COMMENT ON FUNCTION mike.stat(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) IS 'stat a inode';
