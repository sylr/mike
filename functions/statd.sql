-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.statd(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.statd(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) RETURNS SETOF mike.directory AS $__$

SELECT * FROM mike.directory WHERE id_user = $1 AND id_inode = $2;

$__$ LANGUAGE sql STABLE COST 1000;

COMMENT ON FUNCTION mike.statd(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) IS 'stat a directory';
