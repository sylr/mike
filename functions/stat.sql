-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.stat_t CASCADE;

CREATE TYPE mike.stat_t AS (
    id_inode                bigint,
    id_inode_parent         bigint,
    id_user                 integer,
    state                   smallint,
    mimetype                text,
    name                    text,
    path                    text,
    treepath                ltree,
    ctime                   timestamp with time zone,
    mtime                   timestamp with time zone,
    size                    bigint,
    versioning_size         bigint
);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.stat(
    IN  in_id_inode         bigint
) RETURNS mike.stat_t AS $__$

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
    ctime,
    mtime,
    size,
    versioning_size
FROM mike.inode
WHERE
    id_inode = $1;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.stat(
    IN  in_id_inode         bigint
) IS 'stat an inode';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.stat(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS mike.stat_t AS $__$

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
    ctime,
    mtime,
    size,
    versioning_size
FROM mike.inode
WHERE
    id_inode    = $1 AND
    id_user     = $2;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.stat(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'stat an inode';
