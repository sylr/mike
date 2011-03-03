-- Mike's type
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 03/03/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.inode_full_t CASCADE;

CREATE TYPE mike.inode_full_t AS (
-- inode base struct
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
    atime                   timestamp with time zone,
    size                    bigint,
    versioning_size         bigint,
-- directory struct
    inner_mtime             timestamp with time zone,
    inner_size              bigint,
    inner_versioning_size   bigint,
    dir_count               smallint,
    inner_dir_count         integer,
    file_count              smallint,
    inner_file_count        integer
);
