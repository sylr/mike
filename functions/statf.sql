-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.statf_t CASCADE;

CREATE TYPE mike.statf_t AS (
    id_inode                bigint,
    id_inode_parent         bigint,
    id_user                 integer,
    state                   smallint,
    mimetype                text,
    name                    text,
    path                    text,
    treepath                ltree,
#ifndef NO_ATIME
    atime                   timestamp with time zone,
#endif
    ctime                   timestamp with time zone,
    mtime                   timestamp with time zone,
    size                    bigint,
    versioning_size         bigint
);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.statf(
    IN  in_id_inode         bigint
) RETURNS mike.statf_t AS $__$

-- Version: MIKE_VERSION

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(id_mimetype) AS mimetype,
    name,
    path,
    treepath,
#ifndef NO_ATIME
    atime,
#endif
    ctime,
    mtime,
    size,
    versioning_size
FROM mike.file
WHERE
    id_inode = $1;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.statf(
    IN  in_id_inode         bigint
) IS 'stat a file';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.statf(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS mike.statf_t AS $__$

-- Version: MIKE_VERSION

SELECT
    id_inode,
    id_inode_parent,
    id_user,
    state,
    mike.__get_mimetype(id_mimetype) AS mimetype,
    name,
    path,
    treepath,
#ifndef NO_ATIME
    atime,
#endif
    ctime,
    mtime,
    size,
    versioning_size
FROM mike.file
WHERE
    id_inode    = $1 AND
    id_user     = $2;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.statf(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'stat a file';
