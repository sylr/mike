-- Mike's Schema
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 03/07/2010
-- copyright: All rights reserved

--         __  _________ ______
--        /  |/  /  _/ //_/ __/
--       / /|_/ // // ,< / _/  
--      /_/  /_/___/_/|_/___/  
--

-- mike ------------------------------------------------------------------------

COMMENT ON SCHEMA mike IS 'mike, a lightweight, robust, efficient vitual file system';

-- mike.info -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.info CASCADE;

CREATE TABLE mike.info (
    key                     text        NOT NULL CHECK (key ~ '^[A-Z0-9_]{2,}$'),
    ctime                   timestamptz NOT NULL DEFAULT now(),
    value                   text,
    PRIMARY KEY (key, ctime)
);

COMMENT ON TABLE mike.info IS 'informations about database deployement';
COMMENT ON COLUMN mike.info.key IS 'information identifier';
COMMENT ON COLUMN mike.info.value IS 'information value';

-- mike.info -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.conf CASCADE;

CREATE TABLE mike.conf (
    key                     text            NOT NULL PRIMARY KEY CHECK (key ~ '^[a-z0-9_]{2,}$') UNIQUE,
    value                   text,
    ctime                   timestamptz     NOT NULL DEFAULT now(),
    mtime                   timestamptz
);

COMMENT ON TABLE mike.conf IS 'configurations table';
COMMENT ON COLUMN mike.conf.key IS 'configuration identifier';
COMMENT ON COLUMN mike.conf.value IS 'configuration value';

-- mike.user_state -------------------------------------------------------------

DROP TABLE IF EXISTS mike.user_state CASCADE;

CREATE TABLE mike.user_state (
    state                   smallint        NOT NULL PRIMARY KEY,
    label                   text            NOT NULL CHECK (label ~ '^[A-Z0-9_]{2,}$'),
    description             text            NOT NULL CHECK (description != '')
);

COMMENT ON TABLE mike.user_state IS 'list of user states';
COMMENT ON COLUMN mike.user_state.state IS 'state identifier';
COMMENT ON COLUMN mike.user_state.label IS 'state label';
COMMENT ON COLUMN mike.user_state.description IS 'state description';

INSERT INTO mike.user_state (state, label, description) VALUES (0, 'ALIVE', 'user alive');
INSERT INTO mike.user_state (state, label, description) VALUES (1, 'LOCKED', 'user locked');

-- mike.user -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.user CASCADE;

CREATE TABLE mike.user (
    id_user                 serial          NOT NULL PRIMARY KEY,
    id_sso                  text            DEFAULT NULL,
    nickname                text            DEFAULT NULL,
    state                   smallint        NOT NULL DEFAULT 1 REFERENCES mike.user_state (state),
    ctime                   timestamptz     NOT NULL DEFAULT now(),
    mtime                   timestamptz,
    UNIQUE (id_sso)
);

COMMENT ON TABLE mike.user IS 'user informations';
COMMENT ON COLUMN mike.user.id_user IS 'user unique identifier';
COMMENT ON COLUMN mike.user.id_sso IS 'user unique external identifier';
COMMENT ON COLUMN mike.user.nickname IS 'user nickname';
COMMENT ON COLUMN mike.user.state IS 'user state';
COMMENT ON COLUMN mike.user.ctime IS 'user creation date';
COMMENT ON COLUMN mike.user.ctime IS 'user modification date';

-- mike.group ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.group CASCADE;

CREATE TABLE mike.group (
    id_group                serial      NOT NULL PRIMARY KEY,
    id_user                 integer     NOT NULL REFERENCES mike.user (id_user),
    name                    text        NOT NULL CHECK (name != ''),
    description             text        DEFAULT NULL
);

COMMENT ON TABLE mike.group IS 'group informations';
COMMENT ON COLUMN mike.group.id_group IS 'group unique identifier';
COMMENT ON COLUMN mike.group.id_user IS 'group owner';
COMMENT ON COLUMN mike.group.name IS 'group name';
COMMENT ON COLUMN mike.group.description IS 'group description';

-- mike.as_user_group ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_user_group CASCADE;

CREATE TABLE mike.as_user_group (
    id_user                 integer NOT NULL REFERENCES mike.user (id_user),
    id_group                integer NOT NULL REFERENCES mike.group (id_group)
);

COMMENT ON TABLE mike.as_user_group IS 'associative table between mike.user and mike.group';
COMMENT ON COLUMN mike.as_user_group.id_user IS 'user identifier';
COMMENT ON COLUMN mike.as_user_group.id_group IS 'group identifier';

-- mike.inode_state ------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode_state CASCADE;

CREATE TABLE mike.inode_state (
    state                   smallint    NOT NULL PRIMARY KEY,
    label                   text        NOT NULL CHECK (label ~ '^[A-Z0-9_]{2,}$'),
    description             text        NOT NULL CHECK (description != '')
);

COMMENT ON TABLE mike.inode_state IS 'list of inode states';
COMMENT ON COLUMN mike.inode_state.state IS 'state identifier';
COMMENT ON COLUMN mike.inode_state.label IS 'state label';
COMMENT ON COLUMN mike.inode_state.description IS 'state description';

INSERT INTO mike.inode_state (state, label, description) VALUES (0, 'ALIVE', 'alive');
INSERT INTO mike.inode_state (state, label, description) VALUES (1, 'TRASHED', 'trashed');
INSERT INTO mike.inode_state (state, label, description) VALUES (2, 'WAITING_FOR_PHYSICAL_REMOVAL', 'waiting for physical removal');
INSERT INTO mike.inode_state (state, label, description) VALUES (3, 'WAITING_FOR_LOGICAL_REMOVAL', 'waiting for data removal');

-- mike.mimetype ---------------------------------------------------------------

DROP TABLE IF EXISTS mike.mimetype CASCADE;

CREATE TABLE mike.mimetype (
    id_mimetype             smallint        NOT NULL PRIMARY KEY,
    mimetype                text            NOT NULL CHECK (mimetype ~ E'^[a-zA-Z0-9_/ .+-]+$'),
    UNIQUE (mimetype)
) WITH (fillfactor = 98);

CREATE SEQUENCE mimetype_id_mimetype_seq START 1 OWNED BY mike.mimetype.id_mimetype;
ALTER TABLE mike.mimetype ALTER COLUMN id_mimetype SET DEFAULT nextval('mimetype_id_mimetype_seq'::regclass)::smallint;

COMMENT ON TABLE mike.mimetype IS 'list of mimetypes';
COMMENT ON COLUMN mike.mimetype.id_mimetype IS 'mimetype identifier';
COMMENT ON COLUMN mike.mimetype.mimetype IS 'mimetype';

INSERT INTO mike.mimetype (id_mimetype, mimetype) VALUES (0::smallint, 'application/x-directory');

-- mike.inode ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode CASCADE;

CREATE TABLE mike.inode (
    id_inode                bigserial       NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.inode (id_inode) ON DELETE CASCADE,
    id_user                 integer         NOT NULL REFERENCES mike.user (id_user),
    state                   smallint        NOT NULL DEFAULT 0::smallint REFERENCES mike.inode_state (state),
    id_mimetype             smallint        REFERENCES mike.mimetype (id_mimetype),
    name                    text            NOT NULL CHECK (
                                                name                       != ''    AND
                                                length(name)               <= 255   AND
                                                strpos(name, '/')           = 0     AND
                                                strpos(name, E'\u000d')     = 0     AND -- no CR
                                                strpos(name, E'\u000a')     = 0         -- no LF
                                            ),
    path                    text            NOT NULL CHECK (substr(path, 1, 1) = '/'),
#ifdef TREE_MAX_DEPTH
    treepath                ltree           NOT NULL CHECK (nlevel(treepath) <= TREE_MAX_DEPTH),
#else
    treepath                ltree           NOT NULL,
#endif /* TREE_MAX_DEPTH */
    ctime                   timestamptz     NOT NULL DEFAULT now(),
    mtime                   timestamptz,
#ifdef INODE_RAND_COLUMN
    rand                    float           NOT NULL DEFAULT random(),
#endif /* INODE_RAND_COLUMN */
    size                    bigint          NOT NULL DEFAULT 0,
    versioning_size         bigint          NOT NULL DEFAULT 0
) WITH (fillfactor = 90);

COMMENT ON TABLE mike.inode IS 'inodes are entities extended by all vfs items';
COMMENT ON COLUMN mike.inode.id_inode IS 'inode unique identifier';
COMMENT ON COLUMN mike.inode.id_inode_parent IS 'identifier of parent inode';
COMMENT ON COLUMN mike.inode.id_user IS 'owner of the inode';
COMMENT ON COLUMN mike.inode.state IS 'state of the inode, references mike.inode_state';
COMMENT ON COLUMN mike.inode.name IS 'name of the inode, limited to 255 characters';
COMMENT ON COLUMN mike.inode.path IS 'path of the inode';
COMMENT ON COLUMN mike.inode.treepath IS 'treepath of the inode';
COMMENT ON COLUMN mike.inode.ctime IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.mtime IS 'last modification timestamp with timezone of the inode';
#ifdef INODE_RAND_COLUMN
COMMENT ON COLUMN mike.inode.rand IS 'random value used for random clustering';
#endif /* INODE_RAND_COLUMN */
COMMENT ON COLUMN mike.inode.id_mimetype IS 'mimetype of the inode';
COMMENT ON COLUMN mike.inode.size IS 'size of the inode';
COMMENT ON COLUMN mike.inode.versioning_size IS 'versioning size of the inode';

-- mike.directory --------------------------------------------------------------

DROP TABLE IF EXISTS mike.directory CASCADE;

CREATE TABLE mike.directory (
    id_inode                bigint          NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.directory (id_inode) ON DELETE CASCADE,
    id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype) DEFAULT 0::smallint,
    inner_mtime             timestamptz,
    inner_size              bigint          NOT NULL DEFAULT 0,
    inner_versioning_size   bigint          NOT NULL DEFAULT 0,
    dir_count               smallint        NOT NULL DEFAULT 0::smallint,
    inner_dir_count         integer         NOT NULL DEFAULT 0,
    file_count              smallint        NOT NULL DEFAULT 0::smallint,
    inner_file_count        integer         NOT NULL DEFAULT 0,
    UNIQUE (id_inode_parent, state, name)
) INHERITS (mike.inode) WITH (fillfactor = 90);

COMMENT ON TABLE mike.directory IS 'table containing all the directory inodes';
COMMENT ON COLUMN mike.directory.id_inode IS 'inode unique identifier';
COMMENT ON COLUMN mike.directory.id_inode_parent IS 'identifier of parent inode';
COMMENT ON COLUMN mike.directory.id_user IS 'owner of the inode';
COMMENT ON COLUMN mike.directory.id_mimetype IS 'mimetype of the inode';
COMMENT ON COLUMN mike.directory.state IS 'state of the inode, references mike.inode_state';
COMMENT ON COLUMN mike.directory.name IS 'name of the inode, limited to 255 characters';
COMMENT ON COLUMN mike.directory.path IS 'path of the inode';
COMMENT ON COLUMN mike.directory.treepath IS 'treepath of the inode';
COMMENT ON COLUMN mike.directory.ctime IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.directory.mtime IS 'last modification timestamp with timezone of the inode';
COMMENT ON COLUMN mike.directory.inner_mtime IS 'modification date of last updated child directory';
COMMENT ON COLUMN mike.directory.size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.directory.inner_size IS 'size sum of child directories';
COMMENT ON COLUMN mike.directory.versioning_size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.directory.inner_versioning_size IS 'versioning size sum of child directories';
COMMENT ON COLUMN mike.directory.dir_count IS 'number of direct child directories';
COMMENT ON COLUMN mike.directory.inner_dir_count IS 'number of child directories';
COMMENT ON COLUMN mike.directory.file_count IS 'number of direct child files';
COMMENT ON COLUMN mike.directory.inner_file_count IS 'number of child files';

-- mike.file -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.file CASCADE;

CREATE TABLE mike.file (
    id_inode                bigint  NOT NULL PRIMARY KEY,
    id_inode_parent         bigint  NOT NULL REFERENCES mike.directory (id_inode) ON DELETE RESTRICT,
#ifndef NO_ATIME
    atime                   timestamptz,
#endif /* NO_ATIME */
    UNIQUE(id_inode_parent, state, name)
) INHERITS (mike.inode) WITH (fillfactor = 90);

COMMENT ON TABLE mike.file IS 'table containing all the file inodes';
COMMENT ON COLUMN mike.file.id_inode IS 'inode unique identifier';
COMMENT ON COLUMN mike.file.id_inode_parent IS 'identifier of parent inode';
COMMENT ON COLUMN mike.file.id_user IS 'owner of the inode';
COMMENT ON COLUMN mike.file.id_mimetype IS 'mimetype of the inode';
COMMENT ON COLUMN mike.file.state IS 'state of the inode, references mike.inode_state';
COMMENT ON COLUMN mike.file.name IS 'name of the inode, limited to 255 characters';
COMMENT ON COLUMN mike.file.path IS 'path of the inode';
COMMENT ON COLUMN mike.file.treepath IS 'treepath of the inode';
COMMENT ON COLUMN mike.file.ctime IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.file.mtime IS 'last modification timestamp with timezone of the inode';
#ifndef NO_ATIME
COMMENT ON COLUMN mike.file.atime IS 'last access timestamp with timezone of the inode';
#endif /* NO_ATIME */
COMMENT ON COLUMN mike.file.size IS 'size of the inode';
COMMENT ON COLUMN mike.file.versioning_size IS 'versioning size of the inode';

-- mike.volume_state -----------------------------------------------------------

DROP TABLE IF EXISTS mike.volume_state CASCADE;

CREATE TABLE mike.volume_state (
    state                   integer         NOT NULL PRIMARY KEY,
    label                   text            NOT NULL CHECK (label ~ '^[A-Z0-9_]{2,}$'),
    description             text            NOT NULL CHECK (description != '')
);

COMMENT ON TABLE mike.volume_state IS 'list of volume states';
COMMENT ON COLUMN mike.volume_state.state IS 'state identifier';
COMMENT ON COLUMN mike.volume_state.label IS 'state label';
COMMENT ON COLUMN mike.volume_state.description IS 'state description';

INSERT INTO mike.volume_state (state, label, description) VALUES (0, 'UP', 'volume up');
INSERT INTO mike.volume_state (state, label, description) VALUES (1, 'DOWN', 'volume down');

-- mike.volume -----------------------------------------------------------------

DROP TABLE IF EXISTS mike.volume CASCADE;

CREATE TABLE mike.volume (
    id_volume               smallint        NOT NULL PRIMARY KEY,
    state                   integer         NOT NULL REFERENCES mike.volume_state (state) DEFAULT 1,
    path                    text            NOT NULL CHECK (substr(path, 1, 1) = '/' AND substring(path, '.$') = '/'),
    virtual_used_size       bigint          NOT NULL DEFAULT 0,
    real_used_size          bigint          NOT NULL DEFAULT 0,
    max_size                bigint          NOT NULL DEFAULT 0,
    ctime                   timestamptz     NOT NULL DEFAULT now(),
    mtime                   timestamptz,
    token                   text
) WITH (fillfactor = 95);

CREATE SEQUENCE volume_id_volume_seq START 1 OWNED BY mike.volume.id_volume;
ALTER TABLE mike.volume ALTER COLUMN id_volume SET DEFAULT nextval('volume_id_volume_seq'::regclass)::smallint;

COMMENT ON TABLE mike.volume IS 'volumes informations';
COMMENT ON COLUMN mike.volume.id_volume IS 'volume unique identifier';
COMMENT ON COLUMN mike.volume.state IS 'state of the volumes, references mike.volume_state';
COMMENT ON COLUMN mike.volume.path IS 'path of the volumes';
COMMENT ON COLUMN mike.volume.virtual_used_size IS 'virtual used size used on the volumes';
COMMENT ON COLUMN mike.volume.real_used_size IS 'real used size used on the volumes';
COMMENT ON COLUMN mike.volume.max_size IS 'max size available on the volumes';
COMMENT ON COLUMN mike.volume.ctime IS 'creation date off the volumes';
COMMENT ON COLUMN mike.volume.mtime IS 'last modification date of the volumes';
COMMENT ON COLUMN mike.volume.token IS 'security token for volume removal';

-- mike.xfile ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.xfile CASCADE;

CREATE TABLE mike.xfile (
    id_xfile                bigserial       NOT NULL PRIMARY KEY,
    id_volume               smallint        NOT NULL REFERENCES mike.volume (id_volume) ON DELETE CASCADE,
    id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype) ON DELETE RESTRICT,
    size                    bigint          NOT NULL,
    sha1                    text            CHECK (length(sha1) = 40),
    md5                     text            CHECK (length(md5) = 32)
) WITH (fillfactor = 95);

COMMENT ON TABLE mike.xfile IS 'xfile represents files on the file system';

-- mike.as_file_xfile ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_file_xfile CASCADE;

CREATE TABLE mike.as_file_xfile (
    id_inode                bigint          NOT NULL REFERENCES mike.file (id_inode) ON DELETE RESTRICT,
    id_xfile                bigint          NOT NULL REFERENCES mike.xfile (id_xfile) ON DELETE CASCADE,
    ctime                   timestamptz     NOT NULL DEFAULT now()
);

COMMENT ON TABLE mike.as_file_xfile IS 'associative table between mike.file and mike.xfile';

