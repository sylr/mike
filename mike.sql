-- Mike's Schema
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 03/07/2010
-- copyright: All rights reserved

--         __  _________ ______
--        /  |/  /  _/ //_/ __/
--       / /|_/ // // ,< / _/  
--      /_/  /_/___/_/|_/___/  
--


SET search_path TO mike,public;

-- mike.info -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.info CASCADE;

CREATE TABLE mike.info (
    key                     varchar(64)     NOT NULL CHECK (key != '') UNIQUE,
    value                   text
);

-- mike.user -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.user CASCADE;

CREATE TABLE mike.user (
    id_user                 bigserial       NOT NULL PRIMARY KEY,
    id_user_sso             varchar(512)    DEFAULT NULL,
    nickname                varchar(64)     DEFAULT NULL,
    state                   integer         NOT NULL DEFAULT 1,
    datec                   timestamptz     NOT NULL DEFAULT NOW()
);

-- mike.group ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.group CASCADE;

CREATE TABLE mike.group (
    id_group                bigserial       NOT NULL PRIMARY KEY,
    id_user                 bigint          NOT NULL REFERENCES mike.user(id_user),
    name                    varchar(64)     NOT NULL CHECK(name != ''),
    descrition              varchar(512)    DEFAULT NULL
);

-- mike.as_user_group ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_user_group CASCADE;

CREATE TABLE mike.as_user_group (
    id_group                bigint  NOT NULL REFERENCES mike.group(id_group),
    id_user                 bigint  NOT NULL REFERENCES mike.user(id_user)
);

-- mike.inode ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode CASCADE;

CREATE TABLE mike.inode (
    id_inode                bigserial       NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.inode(id_inode) ON DELETE CASCADE,
    id_user                 bigint          NOT NULL REFERENCES mike.user(id_user),
    state                   integer         NOT NULL DEFAULT 0,
    name                    varchar(256)    NOT NULL CHECK(name != ''),
    path                    varchar(5140)   NOT NULL,
    treepath                ltree           NOT NULL,
    datec                   timestamptz     NOT NULL DEFAULT NOW(),
    datem                   timestamptz,
    datea                   timestamptz,
    mimetype                varchar(64),
    size                    bigint          NOT NULL DEFAULT 0,
    versioning_size         bigint          NOT NULL DEFAULT 0,
    group_readable          bigint[],
    group_writable          bigint[]
);

CREATE INDEX inode_id_inode_btree_idx           ON mike.inode   USING btree (id_inode);
CREATE INDEX inode_id_inode_parent_btree_idx    ON mike.inode   USING btree (id_inode_parent);
CREATE INDEX inode_name_btree_idx               ON mike.inode   USING btree (name);
CREATE INDEX inode_mimetype_btree_idx           ON mike.inode   USING btree (mimetype);
CREATE INDEX inode_datec_btree_idx              ON mike.inode   USING btree (datec);
CREATE INDEX inode_datem_btree_idx              ON mike.inode   USING btree (datem);
CREATE INDEX inode_path_btree_idx               ON mike.inode   USING btree (path);
CREATE INDEX inode_treepath_gist_idx            ON mike.inode   USING gist (treepath);

-- mike.directory --------------------------------------------------------------

DROP TABLE IF EXISTS mike.directory CASCADE;

CREATE TABLE mike.directory (
    id_inode                bigint      NOT NULL PRIMARY KEY,
    id_inode_parent         bigint      REFERENCES mike.directory(id_inode) ON DELETE CASCADE,
    inner_size              bigint      NOT NULL DEFAULT 0,
    versioning_inner_size   bigint      NOT NULL DEFAULT 0,
    dir_count               integer     NOT NULL DEFAULT 0,
    dir_inner_count         bigint      NOT NULL DEFAULT 0,
    file_count              integer     NOT NULL DEFAULT 0,
    file_inner_count        bigint      NOT NULL DEFAULT 0,
    UNIQUE (id_inode_parent, name)
) INHERITS (mike.inode);

CREATE INDEX directory_id_inode_btree_idx           ON mike.directory   USING btree (id_inode);
CREATE INDEX directory_id_inode_parent_btree_idx    ON mike.directory   USING btree (id_inode_parent);
CREATE INDEX directory_name_btree_idx               ON mike.directory   USING btree (name);
CREATE INDEX directory_mimetype_btree_idx           ON mike.directory   USING btree (mimetype);
CREATE INDEX directory_datec_btree_idx              ON mike.directory   USING btree (datec);
CREATE INDEX directory_datem_btree_idx              ON mike.directory   USING btree (datem);
CREATE INDEX directory_path_btree_idx               ON mike.directory   USING btree (path);
CREATE INDEX directory_treepath_gist_idx            ON mike.directory   USING gist (treepath);

-- mike.file -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.file CASCADE;

CREATE TABLE mike.file (
    id_inode                bigint  NOT NULL PRIMARY KEY,
    id_inode_parent         bigint  REFERENCES mike.directory(id_inode) ON DELETE CASCADE,
    UNIQUE(id_inode_parent, name)
) INHERITS (mike.inode);

CREATE INDEX file_id_inode_btree_idx            ON mike.file    USING btree (id_inode);
CREATE INDEX file_id_inode_parent_btree_idx     ON mike.file    USING btree (id_inode_parent);
CREATE INDEX file_name_btree_idx                ON mike.file    USING btree (name);
CREATE INDEX file_mimetype_btree_idx            ON mike.file    USING btree (mimetype);
CREATE INDEX file_datec_btree_idx               ON mike.file    USING btree (datec);
CREATE INDEX file_datem_btree_idx               ON mike.file    USING btree (datem);
CREATE INDEX file_path_btree_idx                ON mike.file    USING btree (path);
CREATE INDEX file_treepath_gist_idx             ON mike.file    USING gist (treepath);

-- mike.volume -----------------------------------------------------------------

DROP TABLE IF EXISTS mike.volume CASCADE;

CREATE TABLE mike.volume (
    id_volume               serial          NOT NULL PRIMARY KEY,
    status                  integer         NOT NULL DEFAULT 1,
    path                    varchar(255)    NOT NULL,
    max_size                bigint          NOT NULL
);

-- mike.xfile ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.xfile CASCADE;

CREATE TABLE mike.xfile (
    id_xfile                bigserial       NOT NULL PRIMARY KEY,
    id_volume               bigint          NOT NULL REFERENCES mike.volume (id_volume) ON DELETE CASCADE,
    size                    bigint,
    sha1                    varchar(40),
    md5                     varchar(32)
);

CREATE INDEX xfile_sha1_btree_idx   ON mike.xfile   USING btree (sha1);
CREATE INDEX xfile_md5_btree_idx    ON mike.xfile   USING btree (md5);

-- mike.as_file_xfile ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_file_xfile CASCADE;

CREATE TABLE mike.as_file_xfile (
    id_inode                bigint  NOT NULL REFERENCES mike.file(id_inode) ON DELETE CASCADE,
    id_xfile                bigint  NOT NULL REFERENCES mike.xfile(id_xfile) ON DELETE CASCADE
);

CREATE INDEX as_file_xfile_id_inode_btree_idx   ON mike.as_file_xfile   USING btree (id_inode);

