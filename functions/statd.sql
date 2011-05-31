-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.statd_t CASCADE;

CREATE TYPE mike.statd_t AS (
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
    inner_mtime             timestamp with time zone,
    size                    bigint,
    inner_size              bigint,
    versioning_size         bigint,
    inner_versioning_size   bigint,
    dir_count               smallint,
    inner_dir_count         integer,
    file_count              smallint,
    inner_file_count        integer
);

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.statd(
    IN  in_id_inode         bigint
) RETURNS mike.statd_t AS $__$

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
    inner_mtime,
    size,
    inner_size,
    versioning_size,
    inner_versioning_size,
    dir_count,
    inner_dir_count,
    file_count,
    inner_file_count
FROM mike.directory
WHERE id_inode = $1;

$__$ LANGUAGE sql STABLE COST 10;

COMMENT ON FUNCTION mike.statd(
    IN  in_id_inode             bigint
) IS 'stat a directory';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.statd(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS mike.statd_t AS $__$

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
    inner_mtime,
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

COMMENT ON FUNCTION mike.statd(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'stat a directory';
