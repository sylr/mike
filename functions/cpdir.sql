-- # Mike's Function
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 12/05/2011
-- # copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.cpdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint,
    IN  in_id_inode_target  bigint,
    IN  in_name             text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.cpdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint,
    IN  in_id_inode_target  bigint,
    IN  in_name             text DEFAULT NULL
) RETURNS bigint AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_file                              mike.file%rowtype;
    v_directory                         mike.directory%rowtype;
    v_directory_src                     mike.directory%rowtype;
    v_directory_target                  mike.directory%rowtype;
    v_nextval                           bigint;
    v_nextval_file                      bigint;
    v_id_inode_parent                   bigint;
    v_id_inode_parent_target_hstore     hstore;
    v_path_target_hstore                hstore;
    v_treepath_target_hstore            hstore;
    v_path                              text;
    v_treepath                          ltree;
    v_return                            bigint;
BEGIN
    -- select in_id_inode
    SELECT * INTO v_directory_src FROM mike.directory WHERE id_inode = in_id_inode AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'directory ''%'' not found', in_id_inode; END IF;

    -- select in_id_inode_target
    SELECT * INTO v_directory_target FROM mike.directory WHERE id_inode = in_id_inode_target AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'target directory ''%'' not found', in_id_inode; END IF;

    -- check that source directory does not already exists in target
    PERFORM * FROM mike.directory WHERE id_inode_parent = in_id_inode_target AND id_user = in_id_user AND state = 0 AND name = coalesce(in_name, v_directory_src.name);
    IF FOUND THEN RAISE EXCEPTION 'there already is a directory named ''%'' in ''%''', coalesce(in_name, v_directory_src.name), in_id_inode_target; END IF;

    -- select in_id_inode children directory
    FOR v_directory IN
        SELECT
            *
        FROM mike.directory
        WHERE
            id_user     = in_id_user    AND
            state       = 0             AND
            treepath    ~ ('*.' || in_id_inode || '.*')::lquery
        ORDER BY treepath ASC
    LOOP
        -- sequence
        SELECT nextval('inode_id_inode_seq'::regclass) INTO v_nextval;

        -- paths
        IF v_id_inode_parent_target_hstore IS NULL THEN
            v_path              := v_directory_target.path || '/' || coalesce(in_name, v_directory_src.name);
            v_directory.name    := coalesce(in_name, v_directory_src.name);

            v_treepath          := v_directory_target.treepath || v_nextval::text::ltree;
            v_id_inode_parent   := v_directory_target.id_inode;

            v_path_target_hstore            := (v_nextval::text             => v_path::text)::hstore;
            v_treepath_target_hstore        := (v_nextval::text             => v_treepath::text)::hstore;
            v_id_inode_parent_target_hstore := (v_directory.id_inode::text  => v_nextval::text)::hstore;

            v_return    := v_nextval;
        ELSE
            v_path              := (v_path_target_hstore       -> (v_id_inode_parent_target_hstore -> v_directory.id_inode_parent::text)) || '/' || v_directory.name;
            v_treepath          := (v_treepath_target_hstore   -> (v_id_inode_parent_target_hstore -> v_directory.id_inode_parent::text)) || v_nextval::text::ltree;
            v_id_inode_parent   := (v_id_inode_parent_target_hstore -> v_directory.id_inode_parent::text)::bigint;

            v_path_target_hstore            := v_path_target_hstore             || (v_nextval::text             => v_path::text)::hstore;
            v_treepath_target_hstore        := v_treepath_target_hstore         || (v_nextval::text             => v_treepath::text)::hstore;
            v_id_inode_parent_target_hstore := v_id_inode_parent_target_hstore  || (v_directory.id_inode::text  => v_nextval::text)::hstore;
        END IF;

        -- insert in_id_inode children directory
        INSERT INTO mike.directory (
            id_inode, id_inode_parent, id_user,
            name, path, treepath,
            ctime, mtime, inner_mtime,
            size, inner_size,
            versioning_size, inner_versioning_size,
            dir_count, inner_dir_count,
            file_count, inner_file_count
        )
        VALUES (
            v_nextval, v_id_inode_parent, in_id_user,
            v_directory.name, v_path, v_treepath,
            v_directory.ctime, v_directory.mtime, v_directory.inner_mtime,
            v_directory.size, v_directory.inner_size,
            v_directory.versioning_size, v_directory.inner_versioning_size,
            v_directory.dir_count, v_directory.inner_dir_count,
            v_directory.file_count, v_directory.inner_file_count
        );

        -- insert directory's files
        FOR v_file IN
            SELECT
                id_inode, id_inode_parent, in_id_user,
                state, id_mimetype, name,
                v_path || '/' || name, v_treepath,
                ctime, mtime,
#ifdef INODE_RAND_COLUMN
                rand,
#endif /* INODE_RAND_COLUMN */
                size, versioning_size
#ifndef NO_ATIME
                , atime
#endif /* NO_ATIME */
            FROM mike.file
            WHERE
                id_user         = in_id_user    AND
                state           = 0             AND
                id_inode_parent = v_directory.id_inode
        LOOP
            -- sequence
            SELECT nextval('inode_id_inode_seq'::regclass) INTO v_nextval_file;

            -- file insert
            INSERT INTO mike.file (
                id_inode, id_inode_parent, id_user,
                state, id_mimetype, name,
                path, treepath,
                ctime, mtime,
#ifdef INODE_RAND_COLUMN
                rand,
#endif /* INODE_RAND_COLUMN */
                size, versioning_size
#ifndef NO_ATIME
                , atime
#endif /* NO_ATIME */
            )
            VALUES (
                v_nextval_file, v_nextval, v_file.id_user,
                v_file.state, v_file.id_mimetype, v_file.name,
                v_path || '/' || v_file.name, v_treepath || v_nextval_file::text::ltree,
                v_file.ctime, v_file.mtime,
#ifdef INODE_RAND_COLUMN
                v_file.rand,
#endif /* INODE_RAND_COLUMN */
                v_file.size, v_file.versioning_size
#ifndef NO_ATIME
                , v_file.atime
#endif /* NO_ATIME */
            );

            -- file's links
            INSERT INTO mike.as_file_xfile
            SELECT
                id_user,
                v_nextval_file,
                id_xfile,
                ctime
            FROM mike.as_file_xfile
            WHERE
                id_inode = v_file.id_inode;
        END LOOP;
    END LOOP;

     -- update v_directory_target.id_inode metadata
     UPDATE mike.directory SET
        dir_count               = dir_count + 1,
        inner_dir_count         = inner_dir_count + v_directory_src.inner_dir_count + 1,
        inner_file_count        = inner_file_count + v_directory_src.inner_file_count,
        inner_size              = inner_size + v_directory_src.inner_size,
        inner_versioning_size   = inner_versioning_size + v_directory_src.inner_versioning_size,
        mtime                   = greatest(mtime, v_directory_src.mtime),
        inner_mtime             = greatest(inner_mtime, v_directory_src.inner_mtime)
    WHERE
        id_inode = v_directory_target.id_inode;

    IF v_directory_target.id_inode_parent IS NOT NULL THEN
        -- update v_directory.id_inode_parent ancestors metadata
        UPDATE mike.directory SET
            inner_dir_count         = inner_dir_count + v_directory_src.inner_dir_count + 1,
            inner_file_count        = inner_file_count + v_directory_src.inner_file_count,
            inner_size              = inner_size + v_directory_src.inner_size,
            inner_versioning_size   = inner_versioning_size + v_directory_src.inner_versioning_size,
            mtime                   = greatest(mtime, now()),
            inner_mtime             = greatest(inner_mtime, now())
        WHERE
            treepath @> subpath(v_directory_target.treepath, 0, nlevel(v_directory_target.treepath) - 1);
    END IF;

    RETURN v_return;
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.cpdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint,
    IN  in_id_inode_target  bigint,
    IN  in_name             text
) IS 'copy a directory and its content inside another one';
