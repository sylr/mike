-- Mike's type
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 03/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.inode_full_t CASCADE;

CREATE TYPE mike.inode_full_t AS (
    id_inode                bigint,
    id_inode_parent         bigint,
    id_user                 integer,
    state                   smallint,
    id_mimetype             smallint,
    name                    text,
    path                    text,
    treepath                ltree,
    ctime                   timestamp with time zone,
    mtime                   timestamp with time zone,
    inner_mtime             timestamp with time zone,
    atime                   timestamp with time zone,
    size                    bigint,
    inner_size              bigint,
    versioning_size         bigint,
    inner_versioning_size   bigint,
    dir_count               smallint,
    inner_dir_count         integer,
    file_count              smallint,
    inner_file_count        integer
);

-- directory -------------------------------------------------------------------

/*
    id_inode,
    id_inode_parent,
    id_user,
    state,
    id_mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    inner_mtime,
    NULL AS atime,
    size,
    inner_size,
    versioning_size,
    inner_versioning_size,
    dir_count,
    inner_dir_count,
    file_count,
    inner_file_count
*/

-- file ------------------------------------------------------------------------

/*
    id_inode,
    id_inode_parent,
    id_user,
    state,
    id_mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    NULL AS inner_mtime,
    atime,
    size,
    NULL AS inner_size,
    versioning_size,
    NULL AS inner_versioning_size,
    NULL AS dir_count,
    NULL AS inner_dir_count,
    NULL AS file_count,
    NULL AS inner_file_count
*/
