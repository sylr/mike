-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

-- Version: MIKE_VERSION

CREATE OR REPLACE FUNCTION mike.__lvcreate(
    in_lv_name      text
) RETURNS void AS $__$

BEGIN
    -- check lv name
    IF in_lv_name !~ '^lv_.*' THEN
        RAISE EXCEPTION 'lv name must start with ''lv_''';
    END IF;

    -- unicity check
    PERFORM * FROM pg_catalog.pg_class
    LEFT JOIN pg_catalog.pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    WHERE
        pg_class.relkind = 'r' AND
        pg_namespace.nspname !~ '^pg_toast'  AND
        pg_namespace.nspname ~ '^(mike)$' AND
        pg_class.relname = 'directory_' || in_lv_name;

    IF FOUND THEN RAISE EXCEPTION 'lv ''%'' already exists', in_lv_name; END IF;

    -- directory ---------------------------------------------------------------

    EXECUTE $$
        CREATE TABLE $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$ (
            id_inode                bigint          NOT NULL PRIMARY KEY,
            id_inode_parent         bigint          REFERENCES $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$ (id_inode) ON DELETE CASCADE,
            id_mimetype             smallint        NOT NULL REFERENCES mike.mimetype (id_mimetype) DEFAULT 0::smallint,
            inner_mtime             timestamptz,
            inner_size              bigint          NOT NULL DEFAULT 0,
            inner_versioning_size   bigint          NOT NULL DEFAULT 0,
            dir_count               smallint        NOT NULL DEFAULT 0::smallint,
            inner_dir_count         integer         NOT NULL DEFAULT 0,
            file_count              smallint        NOT NULL DEFAULT 0::smallint,
            inner_file_count        integer         NOT NULL DEFAULT 0,
            UNIQUE (id_inode_parent, state, name),
            CHECK (id_user = ANY (mike.__lvusers('$$ || in_lv_name || $$')))
        ) INHERITS (mike.directory) WITH (fillfactor = 90);
    $$;

    EXECUTE $$
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_id_inode_parent_alive_btree_idx') || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING btree (id_inode_parent)   WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_id_inode_parent_dead_btree_idx')  || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING btree (id_inode_parent)   WITH (fillfactor = 99)  WHERE state > 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_id_user_alive_btree_idx')         || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING btree (id_user)           WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_id_user_dead_btree_idx')          || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING btree (id_user)           WITH (fillfactor = 95)  WHERE state > 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_ctime_btree_idx')                 || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING btree (ctime)             WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_treepath_alive_gist_idx')         || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING gist  (treepath)          WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('directory_' || in_lv_name || '_treepath_dead_gist_idx')          || $$ ON $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$   USING gist  (treepath)          WITH (fillfactor = 95)  WHERE state > 0;
    $$;

    -- file --------------------------------------------------------------------

    EXECUTE $$
        CREATE TABLE $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$ (
            id_inode                bigint  NOT NULL PRIMARY KEY,
            id_inode_parent         bigint  NOT NULL REFERENCES $$ || 'mike.' || quote_ident('directory_' || in_lv_name) || $$ (id_inode) ON DELETE RESTRICT,
#ifndef NO_ATIME
            atime                   timestamptz,
#endif /* NO_ATIME */
            UNIQUE(id_inode_parent, state, name),
            CHECK (id_user = ANY (mike.__lvusers('$$ || in_lv_name || $$')))
        ) INHERITS (mike.file) WITH (fillfactor = 90);
    $$;

    EXECUTE $$
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_id_inode_parent_alive_btree_idx')  || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (id_inode_parent)       WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_id_inode_parent_dead_btree_idx')   || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (id_inode_parent)       WITH (fillfactor = 99)  WHERE state > 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_id_user_alive_btree_idx')          || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (id_user)               WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_id_user_dead_btree_idx')           || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (id_user)               WITH (fillfactor = 95)  WHERE state > 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_id_mimetype_btree_idx')            || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (id_mimetype)           WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_ctime_btree_idx')                  || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING btree (ctime)                 WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_treepath_alive_gist_idx')          || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING gist  (treepath)              WITH (fillfactor = 95)  WHERE state = 0;
        CREATE INDEX $$ || quote_ident('file_' || in_lv_name || '_treepath_dead_gist_idx')           || $$ ON $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$    USING gist  (treepath)              WITH (fillfactor = 99)  WHERE state > 0;
    $$;

    -- as_file_xfile -----------------------------------------------------------

    EXECUTE $$
        CREATE TABLE $$ || 'mike.' || quote_ident('as_file_xfile_' || in_lv_name) || $$ (
            id_user                 integer         NOT NULL REFERENCES mike.user (id_user) ON DELETE CASCADE,
            id_inode                bigint          NOT NULL REFERENCES $$ || 'mike.' || quote_ident('file_' || in_lv_name) || $$ (id_inode) ON DELETE CASCADE,
            id_xfile                bigint          NOT NULL REFERENCES mike.xfile (id_xfile) ON DELETE CASCADE,
            ctime                   timestamptz     NOT NULL DEFAULT now(),
            CHECK (id_user = ANY (mike.__lvusers('$$ || in_lv_name || $$')))
        ) INHERITS (mike.as_file_xfile) WITH (fillfactor = 90);
    $$;

    EXECUTE $$
        CREATE INDEX $$ || quote_ident('as_file_xfile_' || in_lv_name || '_id_user_id_inode_btree_idx') || $$ ON $$ || 'mike.' || quote_ident('as_file_xfile_' || in_lv_name) || $$ USING btree (id_user, id_inode) WITH (fillfactor = 95);
    $$;

    -- lv
    INSERT INTO mike.lv (name) VALUES (in_lv_name);
END;

$__$ LANGUAGE plpgsql;
