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

-- mike ------------------------------------------------------------------------

COMMENT ON SCHEMA mike IS 'mike, a lightweight, robust, efficient vitual file system';

-- mike.info -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.info CASCADE;

CREATE TABLE mike.info (
    key                     varchar(64)     NOT NULL CHECK (key != '') UNIQUE,
    value                   text
);

COMMENT ON TABLE mike.info IS 'informations about database deployement';
COMMENT ON COLUMN mike.info.key IS 'information identifier';
COMMENT ON COLUMN mike.info.value IS 'information value';

-- mike.user -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.user CASCADE;

CREATE TABLE mike.user (
    id_user                 bigserial       NOT NULL PRIMARY KEY,
    id_user_sso             varchar(512)    DEFAULT NULL,
    nickname                varchar(64)     DEFAULT NULL,
    state                   integer         NOT NULL DEFAULT 1,
    datec                   timestamptz     NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE mike.user IS 'user informations';
COMMENT ON COLUMN mike.user.id_user IS 'user unique identifier';
COMMENT ON COLUMN mike.user.id_user_sso IS 'user unique external identifier';
COMMENT ON COLUMN mike.user.nickname IS 'user nickname';
COMMENT ON COLUMN mike.user.state IS 'user state';
COMMENT ON COLUMN mike.user.datec IS 'user creation date';

-- mike.group ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.group CASCADE;

CREATE TABLE mike.group (
    id_group                bigserial       NOT NULL PRIMARY KEY,
    id_user                 bigint          NOT NULL REFERENCES mike.user(id_user),
    name                    varchar(64)     NOT NULL CHECK(name != ''),
    description             varchar(512)    DEFAULT NULL
);

COMMENT ON TABLE mike.group IS 'group informations';
COMMENT ON COLUMN mike.group.id_group IS 'group unique identifier';
COMMENT ON COLUMN mike.group.id_user IS 'group owner';
COMMENT ON COLUMN mike.group.name IS 'group name';
COMMENT ON COLUMN mike.group.description IS 'group description';

-- mike.as_user_group ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_user_group CASCADE;

CREATE TABLE mike.as_user_group (
    id_user                 bigint  NOT NULL REFERENCES mike.user(id_user),
    id_group                bigint  NOT NULL REFERENCES mike.group(id_group)
);

COMMENT ON TABLE mike.as_user_group IS 'associative table between mike.user and mike.group';
COMMENT ON COLUMN mike.as_user_group.id_user IS 'user identifier';
COMMENT ON COLUMN mike.as_user_group.id_group IS 'group identifier';

CREATE INDEX as_user_group_id_user_btree_idx    ON mike.as_user_group   USING btree (id_user);
CREATE INDEX as_user_group_id_group_btree_idx   ON mike.as_user_group   USING btree (id_group);

-- mike.inode_state ------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode_state CASCADE;

CREATE TABLE mike.inode_state (
    state                   integer         NOT NULL PRIMARY KEY,
    description             varchar(160)    NOT NULL CHECK(description != '')
);

COMMENT ON TABLE mike.inode_state IS 'list of inode states';
COMMENT ON COLUMN mike.inode_state.state IS 'state identifier';
COMMENT ON COLUMN mike.inode_state.description IS 'state description';

INSERT INTO mike.inode_state (state, description) VALUES (0, 'alive');
INSERT INTO mike.inode_state (state, description) VALUES (1, 'waiting for physical removal');
INSERT INTO mike.inode_state (state, description) VALUES (2, 'waiting for logical removal');

-- mike.inode ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode CASCADE;

CREATE TABLE mike.inode (
    id_inode                bigserial       NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.inode(id_inode) ON DELETE CASCADE,
    id_user                 bigint          NOT NULL REFERENCES mike.user(id_user),
    state                   integer         NOT NULL DEFAULT 0 REFERENCES mike.inode_state(state),
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

COMMENT ON TABLE mike.inode IS 'inodes are entities extended by all vfs items';
COMMENT ON COLUMN mike.inode.id_inode IS 'inode unique identifier';
COMMENT ON COLUMN mike.inode.id_inode_parent IS 'identifier of parent inode';
COMMENT ON COLUMN mike.inode.id_user IS 'owner of the inode';
COMMENT ON COLUMN mike.inode.state IS 'state of the inode, references mike.inode_state';
COMMENT ON COLUMN mike.inode.name IS 'name of the inode, limited to 256 characters';
COMMENT ON COLUMN mike.inode.path IS 'path of the inode';
COMMENT ON COLUMN mike.inode.treepath IS 'treepath of the inode';
COMMENT ON COLUMN mike.inode.datec IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.datem IS 'last modification timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.datea IS 'last access timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.mimetype IS 'mimetype of the inode';
COMMENT ON COLUMN mike.inode.size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.inode.versioning_size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.inode.group_readable IS 'list of group having readable rights on the inode';
COMMENT ON COLUMN mike.inode.group_writable IS 'list of group having writable rights on the inode';

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

COMMENT ON TABLE mike.directory IS 'table containing all the directory inodes';

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
    id_inode_parent         bigint  REFERENCES mike.directory(id_inode) ON DELETE RESTRICT,
    UNIQUE(id_inode_parent, name)
) INHERITS (mike.inode);

COMMENT ON TABLE mike.file IS 'table containing all the file inodes';

CREATE INDEX file_id_inode_btree_idx            ON mike.file    USING btree (id_inode);
CREATE INDEX file_id_inode_parent_btree_idx     ON mike.file    USING btree (id_inode_parent);
CREATE INDEX file_name_btree_idx                ON mike.file    USING btree (name);
CREATE INDEX file_mimetype_btree_idx            ON mike.file    USING btree (mimetype);
CREATE INDEX file_datec_btree_idx               ON mike.file    USING btree (datec);
CREATE INDEX file_datem_btree_idx               ON mike.file    USING btree (datem);
CREATE INDEX file_path_btree_idx                ON mike.file    USING btree (path);
CREATE INDEX file_treepath_gist_idx             ON mike.file    USING gist (treepath);

-- mike.volume_state -----------------------------------------------------------

DROP TABLE IF EXISTS mike.volume_state CASCADE;

CREATE TABLE mike.volume_state (
    state                   integer         NOT NULL PRIMARY KEY,
    description             varchar(160)    NOT NULL CHECK(description != '')
);

COMMENT ON TABLE mike.volume_state IS 'list of volume states';
COMMENT ON COLUMN mike.volume_state.state IS 'state identifier';
COMMENT ON COLUMN mike.volume_state.description IS 'state description';

INSERT INTO mike.volume_state (state, description) VALUES (0, 'up');
INSERT INTO mike.volume_state (state, description) VALUES (1, 'down');

-- mike.volume -----------------------------------------------------------------

DROP TABLE IF EXISTS mike.volume CASCADE;

CREATE TABLE mike.volume (
    id_volume               serial          NOT NULL PRIMARY KEY,
    state                   integer         NOT NULL REFERENCES mike.volume_state(state) DEFAULT 1,
    path                    varchar(255)    NOT NULL CHECK(substr(path, 1, 1) = '/' AND substring(path, '.$') = '/'),
    used_size               bigint          NOT NULL DEFAULT 0,
    max_size                bigint          NOT NULL DEFAULT 0,
    datec                   timestamptz     NOT NULL DEFAULT NOW(),
    datem                   timestamptz,
    token                   char(40)
);

COMMENT ON TABLE mike.volume IS 'volumes informations';

-- mike.xfile ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.xfile CASCADE;

CREATE TABLE mike.xfile (
    id_xfile                bigserial       NOT NULL PRIMARY KEY,
    id_volume               bigint          NOT NULL REFERENCES mike.volume (id_volume) ON DELETE CASCADE,
    size                    bigint,
    sha1                    character(40),
    md5                     character(32)
);

COMMENT ON TABLE mike.xfile IS 'xfile represents files on the file system';

CREATE INDEX xfile_sha1_btree_idx   ON mike.xfile   USING btree (sha1);
CREATE INDEX xfile_md5_btree_idx    ON mike.xfile   USING btree (md5);

-- mike.as_file_xfile ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_file_xfile CASCADE;

CREATE TABLE mike.as_file_xfile (
    id_inode                bigint  NOT NULL REFERENCES mike.file(id_inode) ON DELETE RESTRICT,
    id_xfile                bigint  NOT NULL REFERENCES mike.xfile(id_xfile) ON DELETE CASCADE
);

COMMENT ON TABLE mike.as_file_xfile IS 'associative table between mike.file and mike.xfile';

CREATE INDEX as_file_xfile_id_inode_btree_idx   ON mike.as_file_xfile   USING btree (id_inode);

