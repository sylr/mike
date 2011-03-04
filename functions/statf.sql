-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.statf(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.statf(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) RETURNS SETOF mike.file AS $__$

SELECT * FROM mike.file WHERE id_user = $1 AND id_inode = $2;

$__$ LANGUAGE sql STABLE COST 1000;

COMMENT ON FUNCTION mike.statf(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) IS 'stat a file';
