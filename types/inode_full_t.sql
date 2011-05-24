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
    mimetype                text,
    name                    text,
    path                    text,
    treepath                ltree,
    ctime                   timestamp with time zone,
    mtime                   timestamp with time zone,
    inner_mtime             timestamp with time zone,
#ifndef NO_ATIME
    atime                   timestamp with time zone,
#endif /* NO_ATIME */
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
    mike.__get_mimetype(0::smallint) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    inner_mtime,
#ifndef NO_ATIME
    NULL::timestamp AS atime,
#endif
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
    mike.__get_mimetype(id_mimetype) AS mimetype,
    name,
    path,
    treepath,
    ctime,
    mtime,
    NULL::timestamp AS inner_mtime,
#ifndef NO_ATIME
    atime,
#endif
    size,
    NULL::bigint AS inner_size,
    versioning_size,
    NULL::bigint AS inner_versioning_size,
    NULL::integer AS dir_count,
    NULL::bigint AS inner_dir_count,
    NULL::integer AS file_count,
    NULL::bigint AS inner_file_count
*/
