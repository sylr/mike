-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.xstatd(
    IN  in_id_inode         bigint
) RETURNS mike.inode_full_t AS $__$

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(0::smallint) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    inner_mtime,
#ifndef NO_ATIME
    NULL::timestamptz AS atime,
#endif
    size,
    inner_size,
    versioning_size,
    inner_versioning_size,
    dir_count,
    inner_dir_count,
    file_count,
    inner_file_count
FROM mike.directory
WHERE
    id_inode = $1;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.xstatd(
    IN  in_id_inode             bigint
) IS 'stat a directory with extended return type';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.xstatd(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS mike.inode_full_t AS $__$

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(0::smallint) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    inner_mtime,
#ifndef NO_ATIME
    NULL::timestamptz AS atime,
#endif
    size,
    inner_size,
    versioning_size,
    inner_versioning_size,
    dir_count,
    inner_dir_count,
    file_count,
    inner_file_count
FROM mike.directory
WHERE
    id_inode    = $1 AND
    id_user     = $2;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.xstatd(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'stat a directory with extended return type';
