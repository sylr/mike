-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.xstatf(
    IN  in_id_inode         bigint
) RETURNS mike.inode_full_t AS $__$

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(id_mimetype) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    NULL::timestamptz AS inner_mtime,
#ifndef NO_ATIME
    atime,
#endif
    size,
    NULL::bigint AS inner_size,
    versioning_size,
    NULL::bigint AS inner_versioning_size,
    NULL::smallint AS dir_count,
    NULL::integer AS inner_dir_count,
    NULL::smallint AS file_count,
    NULL::integer AS inner_file_count
FROM mike.file
WHERE
    id_inode = $1;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.xstatf(
    IN  in_id_inode         bigint
) IS 'stat a file with extended return type';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.xstatf(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS mike.inode_full_t AS $__$

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(id_mimetype) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    NULL::timestamptz AS inner_mtime,
#ifndef NO_ATIME
    atime,
#endif
    size,
    NULL::bigint AS inner_size,
    versioning_size,
    NULL::bigint AS inner_versioning_size,
    NULL::smallint AS dir_count,
    NULL::integer AS inner_dir_count,
    NULL::smallint AS file_count,
    NULL::integer AS inner_file_count
FROM mike.file
WHERE
    id_inode    = $1 AND
    id_user     = $2;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.xstatf(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'stat a file with extended return type';
