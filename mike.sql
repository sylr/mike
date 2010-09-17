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

SET search_path TO mike,public;

-- mike ------------------------------------------------------------------------

COMMENT ON SCHEMA mike IS 'mike, a lightweight, robust, efficient vitual file system';

-- mike.info -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.info CASCADE;

CREATE TABLE mike.info (
    key                     text    NOT NULL CHECK (key != '') UNIQUE,
    value                   text
);

COMMENT ON TABLE mike.info IS 'informations about database deployement';
COMMENT ON COLUMN mike.info.key IS 'information identifier';
COMMENT ON COLUMN mike.info.value IS 'information value';

-- mike.user -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.user CASCADE;

CREATE TABLE mike.user (
    id_user                 serial          NOT NULL PRIMARY KEY,
    id_user_sso             text            DEFAULT NULL,
    nickname                text            DEFAULT NULL,
    state                   integer         NOT NULL DEFAULT 1,
    datec                   timestamptz     NOT NULL DEFAULT now()
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

CREATE INDEX group_id_user_btree_idx    ON mike.group   USING btree (id_user)   WITH (fillfactor = 95);

-- mike.as_user_group ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_user_group CASCADE;

CREATE TABLE mike.as_user_group (
    id_user                 integer NOT NULL REFERENCES mike.user (id_user),
    id_group                integer NOT NULL REFERENCES mike.group (id_group)
);

COMMENT ON TABLE mike.as_user_group IS 'associative table between mike.user and mike.group';
COMMENT ON COLUMN mike.as_user_group.id_user IS 'user identifier';
COMMENT ON COLUMN mike.as_user_group.id_group IS 'group identifier';

CREATE INDEX as_user_group_id_user_btree_idx    ON mike.as_user_group   USING btree (id_user);
CREATE INDEX as_user_group_id_group_btree_idx   ON mike.as_user_group   USING btree (id_group);

-- mike.inode_state ------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode_state CASCADE;

CREATE TABLE mike.inode_state (
    state                   smallint    NOT NULL PRIMARY KEY,
    description             text        NOT NULL CHECK (description != '')
);

COMMENT ON TABLE mike.inode_state IS 'list of inode states';
COMMENT ON COLUMN mike.inode_state.state IS 'state identifier';
COMMENT ON COLUMN mike.inode_state.description IS 'state description';

INSERT INTO mike.inode_state (state, description) VALUES (0, 'alive');
INSERT INTO mike.inode_state (state, description) VALUES (1, 'trashed');
INSERT INTO mike.inode_state (state, description) VALUES (2, 'waiting for physical removal');
INSERT INTO mike.inode_state (state, description) VALUES (3, 'waiting for logical removal');

-- mike.mimetype ---------------------------------------------------------------

DROP TABLE IF EXISTS mike.mimetype CASCADE;

CREATE TABLE mike.mimetype (
    id_mimetype             smallint        NOT NULL PRIMARY KEY,
    mimetype                text            NOT NULL CHECK (mimetype != ''),
    UNIQUE (mimetype)
) WITH (fillfactor = 98);

CREATE SEQUENCE mimetype_id_mimetype_seq START 1 OWNED BY mike.mimetype.id_mimetype;
ALTER TABLE mike.mimetype ALTER COLUMN id_mimetype SET DEFAULT nextval('mimetype_id_mimetype_seq'::regclass)::smallint;

COMMENT ON TABLE mike.mimetype IS 'list of mimetypes';
COMMENT ON COLUMN mike.mimetype.id_mimetype IS 'mimetype identifier';
COMMENT ON COLUMN mike.mimetype.mimetype IS 'mimetype';

CREATE INDEX mimetype_mimetype_btree_idx   ON mike.mimetype     USING btree (mimetype);

INSERT INTO mike.mimetype (id_mimetype, mimetype) VALUES (0::smallint, 'application/x-directory');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/msword');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/octet-stream');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/ogg');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/pdf');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/pgp-signature');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/postscript');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/vnd.ms-cab-compressed');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/vnd.ms-office');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/vnd.oasis.opendocument.text');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-arc');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-archive');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-bzip2');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-coredump');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-empty');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-executable');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-freemind');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-gdbm');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-gnupg-keyring');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-gzip');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-iso9660-image');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-java-keystore');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-kdelnk');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/xml');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-object');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-pgp-keyring');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-rar');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-ruby');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-sharedlib');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-shockwave-flash');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/x-tar');
INSERT INTO mike.mimetype (mimetype) VALUES ('application/zip');
INSERT INTO mike.mimetype (mimetype) VALUES ('audio/mpeg');
INSERT INTO mike.mimetype (mimetype) VALUES ('audio/x-hx-aac-adts');
INSERT INTO mike.mimetype (mimetype) VALUES ('audio/x-wav');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/gif');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/jpeg');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/png');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/svg+xml');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/tiff');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-ico');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-ms-bmp');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-portable-bitmap');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-portable-greymap');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-portable-pixmap');
INSERT INTO mike.mimetype (mimetype) VALUES ('image/x-xcf');
INSERT INTO mike.mimetype (mimetype) VALUES ('message/rfc822');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/html');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/PGP');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/plain');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/rtf');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/troff');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-asm');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-awk');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-c');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-c++');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-diff');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-fortran');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-gawk');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-java');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-lisp');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-m4');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-mail');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-makefile');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-msdos-batch');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-news');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-pascal');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-perl');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-php');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-pl1');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-po');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-shellscript');
INSERT INTO mike.mimetype (mimetype) VALUES ('text/x-tex');
INSERT INTO mike.mimetype (mimetype) VALUES ('video/quicktime');
INSERT INTO mike.mimetype (mimetype) VALUES ('video/x-flv');

-- mike.inode ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.inode CASCADE;

CREATE TABLE mike.inode (
    id_inode                bigserial       NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.inode (id_inode) ON DELETE CASCADE,
    id_user                 integer         NOT NULL REFERENCES mike.user (id_user),
    state                   smallint        NOT NULL DEFAULT 0::smallint REFERENCES mike.inode_state (state),
    id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype),
    name                    text            NOT NULL CHECK (name != '' AND length(name) <= 255),
    path                    text            NOT NULL CHECK (substr(path, 1, 1) = '/'),
    treepath                ltree           NOT NULL CHECK (nlevel(treepath) <= 24),
    datec                   timestamptz     NOT NULL DEFAULT now(),
    datem                   timestamptz,
    datea                   timestamptz,
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
COMMENT ON COLUMN mike.inode.datec IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.datem IS 'last modification timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.datea IS 'last access timestamp with timezone of the inode';
COMMENT ON COLUMN mike.inode.id_mimetype IS 'mimetype of the inode';
COMMENT ON COLUMN mike.inode.size IS 'size of the inode';
COMMENT ON COLUMN mike.inode.versioning_size IS 'versioning size of the inode';

CREATE INDEX inode_id_inode_btree_idx           ON mike.inode   USING btree (id_inode)          WITH (fillfactor = 95);
CREATE INDEX inode_id_inode_parent_btree_idx    ON mike.inode   USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX inode_id_user_btree_idx            ON mike.inode   USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX inode_id_mimetype_btree_idx        ON mike.inode   USING btree (id_mimetype)       WITH (fillfactor = 95);
CREATE INDEX inode_name_btree_idx               ON mike.inode   USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX inode_datec_btree_idx              ON mike.inode   USING btree (datec)             WITH (fillfactor = 95);
CREATE INDEX inode_datem_btree_idx              ON mike.inode   USING btree (datem)             WITH (fillfactor = 95);
CREATE INDEX inode_path_btree_idx               ON mike.inode   USING btree (path)              WITH (fillfactor = 95);
CREATE INDEX inode_treepath_gist_idx            ON mike.inode   USING gist (treepath)           WITH (fillfactor = 95);

-- mike.directory --------------------------------------------------------------

DROP TABLE IF EXISTS mike.directory CASCADE;

CREATE TABLE mike.directory (
    id_inode                bigint          NOT NULL PRIMARY KEY,
    id_inode_parent         bigint          REFERENCES mike.directory (id_inode) ON DELETE CASCADE,
    id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype) DEFAULT 0::smallint,
    inner_datem             timestamptz,
    inner_size              bigint          NOT NULL DEFAULT 0,
    inner_versioning_size   bigint          NOT NULL DEFAULT 0,
    dir_count               integer         NOT NULL DEFAULT 0,
    inner_dir_count         integer         NOT NULL DEFAULT 0,
    file_count              integer         NOT NULL DEFAULT 0,
    inner_file_count        integer         NOT NULL DEFAULT 0,
    UNIQUE (id_inode_parent, name)
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
COMMENT ON COLUMN mike.directory.datec IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.directory.datem IS 'last modification timestamp with timezone of the inode';
COMMENT ON COLUMN mike.directory.inner_datem IS 'modification date of last updated child directory';
COMMENT ON COLUMN mike.directory.datea IS 'last access timestamp with timezone of the inode';
COMMENT ON COLUMN mike.directory.size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.directory.inner_size IS 'size sum of child directories';
COMMENT ON COLUMN mike.directory.versioning_size IS 'size in bytes of the inode';
COMMENT ON COLUMN mike.directory.inner_versioning_size IS 'versioning size sum of child directories';
COMMENT ON COLUMN mike.directory.dir_count IS 'number of direct child directories';
COMMENT ON COLUMN mike.directory.inner_dir_count IS 'number of child directories';
COMMENT ON COLUMN mike.directory.file_count IS 'number of direct child files';
COMMENT ON COLUMN mike.directory.inner_file_count IS 'number of child files';

CREATE INDEX directory_id_inode_btree_idx           ON mike.directory   USING btree (id_inode)          WITH (fillfactor = 95);
CREATE INDEX directory_id_inode_parent_btree_idx    ON mike.directory   USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX directory_id_user_btree_idx            ON mike.directory   USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX directory_name_btree_idx               ON mike.directory   USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX directory_datec_btree_idx              ON mike.directory   USING btree (datec)             WITH (fillfactor = 95);
CREATE INDEX directory_datem_btree_idx              ON mike.directory   USING btree (datem)             WITH (fillfactor = 95);
CREATE INDEX directory_path_btree_idx               ON mike.directory   USING btree (path)              WITH (fillfactor = 95);
CREATE INDEX directory_treepath_gist_idx            ON mike.directory   USING gist (treepath)           WITH (fillfactor = 95);

-- mike.file -------------------------------------------------------------------

DROP TABLE IF EXISTS mike.file CASCADE;

CREATE TABLE mike.file (
    id_inode                bigint  NOT NULL PRIMARY KEY,
    id_inode_parent         bigint  NOT NULL REFERENCES mike.directory (id_inode) ON DELETE RESTRICT,
    UNIQUE(id_inode_parent, name)
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
COMMENT ON COLUMN mike.file.datec IS 'creation timestamp with timezone of the inode';
COMMENT ON COLUMN mike.file.datem IS 'last modification timestamp with timezone of the inode';
COMMENT ON COLUMN mike.file.datea IS 'last access timestamp with timezone of the inode';
COMMENT ON COLUMN mike.file.size IS 'size of the inode';
COMMENT ON COLUMN mike.file.versioning_size IS 'versioning size of the inode';

CREATE INDEX file_id_inode_btree_idx            ON mike.file    USING btree (id_inode)          WITH (fillfactor = 95);
CREATE INDEX file_id_inode_parent_btree_idx     ON mike.file    USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX file_id_user_btree_idx             ON mike.file    USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX file_id_mimetype_btree_idx         ON mike.file    USING btree (id_mimetype)       WITH (fillfactor = 95);
CREATE INDEX file_name_btree_idx                ON mike.file    USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX file_datec_btree_idx               ON mike.file    USING btree (datec)             WITH (fillfactor = 95);
CREATE INDEX file_datem_btree_idx               ON mike.file    USING btree (datem)             WITH (fillfactor = 95);
CREATE INDEX file_path_btree_idx                ON mike.file    USING btree (path)              WITH (fillfactor = 95);
CREATE INDEX file_treepath_gist_idx             ON mike.file    USING gist (treepath)           WITH (fillfactor = 95);

-- mike.volume_state -----------------------------------------------------------

DROP TABLE IF EXISTS mike.volume_state CASCADE;

CREATE TABLE mike.volume_state (
    state                   integer         NOT NULL PRIMARY KEY,
    description             text            NOT NULL CHECK (description != '')
);

COMMENT ON TABLE mike.volume_state IS 'list of volume states';
COMMENT ON COLUMN mike.volume_state.state IS 'state identifier';
COMMENT ON COLUMN mike.volume_state.description IS 'state description';

INSERT INTO mike.volume_state (state, description) VALUES (0, 'up');
INSERT INTO mike.volume_state (state, description) VALUES (1, 'down');

-- mike.volume -----------------------------------------------------------------

DROP TABLE IF EXISTS mike.volume CASCADE;

CREATE TABLE mike.volume (
    id_volume               smallint        NOT NULL PRIMARY KEY,
    state                   integer         NOT NULL REFERENCES mike.volume_state (state) DEFAULT 1,
    path                    text            NOT NULL CHECK (substr(path, 1, 1) = '/' AND substring(path, '.$') = '/'),
    used_size               bigint          NOT NULL DEFAULT 0,
    max_size                bigint          NOT NULL DEFAULT 0,
    datec                   timestamptz     NOT NULL DEFAULT now(),
    datem                   timestamptz,
    token                   text
) WITH (fillfactor = 95);

CREATE SEQUENCE volume_id_volume_seq START 1 OWNED BY mike.volume.id_volume;
ALTER TABLE mike.volume ALTER COLUMN id_volume SET DEFAULT nextval('volume_id_volume_seq'::regclass)::smallint;

COMMENT ON TABLE mike.volume IS 'volumes informations';
COMMENT ON COLUMN mike.volume.id_volume IS 'volume unique identifier';
COMMENT ON COLUMN mike.volume.state IS 'state of the volumes, references mike.volume_state';
COMMENT ON COLUMN mike.volume.path IS 'path of the volumes';
COMMENT ON COLUMN mike.volume.used_size IS 'used size used on the volumes';
COMMENT ON COLUMN mike.volume.max_size IS 'max size available on the volumes';
COMMENT ON COLUMN mike.volume.datec IS 'creation date off the volumes';
COMMENT ON COLUMN mike.volume.datem IS 'last modification date of the volumes';
COMMENT ON COLUMN mike.volume.token IS 'security token for volume removal';

-- mike.xfile ------------------------------------------------------------------

DROP TABLE IF EXISTS mike.xfile CASCADE;

CREATE TABLE mike.xfile (
    id_xfile                bigserial       NOT NULL PRIMARY KEY,
    id_volume               smallint        NOT NULL REFERENCES mike.volume (id_volume) ON DELETE CASCADE,
    id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype) ON DELETE RESTRICT,
    size                    bigint          NOT NULL,
    sha1                    text            CHECK (length(sha1) = 40),
    md5                     text            CHECK (length(md5) = 40)
) WITH (fillfactor = 95);

COMMENT ON TABLE mike.xfile IS 'xfile represents files on the file system';

CREATE INDEX xfile_sha1_btree_idx   ON mike.xfile   USING btree (sha1)  WITH (fillfactor = 95);
CREATE INDEX xfile_md5_btree_idx    ON mike.xfile   USING btree (md5)   WITH (fillfactor = 95);

-- mike.as_file_xfile ----------------------------------------------------------

DROP TABLE IF EXISTS mike.as_file_xfile CASCADE;

CREATE TABLE mike.as_file_xfile (
    id_inode                bigint  NOT NULL REFERENCES mike.file (id_inode) ON DELETE RESTRICT,
    id_xfile                bigint  NOT NULL REFERENCES mike.xfile (id_xfile) ON DELETE CASCADE
);

COMMENT ON TABLE mike.as_file_xfile IS 'associative table between mike.file and mike.xfile';

CREATE INDEX as_file_xfile_id_inode_btree_idx   ON mike.as_file_xfile   USING btree (id_inode)  WITH (fillfactor = 95);

