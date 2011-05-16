-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.mvdir(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint,
    IN  in_name                 text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.mvdir(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint,
    IN  in_name                 text DEFAULT NULL
) RETURNS void AS $__$

DECLARE
    v_int                       integer;
    v_nlevel                    integer;
    v_directory                 mike.directory%rowtype;
    v_old_directory_parent      mike.directory%rowtype;
    v_new_directory_parent      mike.directory%rowtype;
BEGIN
    -- select in_id_inode
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'in_id_inode % not found', in_id_inode; END IF;

    -- select v_old_id_inode_parent
    SELECT * INTO v_old_directory_parent FROM mike.directory WHERE id_inode = v_directory.id_inode_parent AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'v_old_id_inode_parent % not found', v_old_id_inode_parent; END IF;

    -- select in_new_id_inode_parent
    SELECT * INTO v_new_directory_parent FROM mike.directory WHERE id_inode = in_new_id_inode_parent AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'in_new_id_inode_parent % not found', in_new_id_inode_parent; END IF;

    -- check target validity
    IF v_new_directory_parent.treepath <@ v_directory.treepath THEN
        RAISE EXCEPTION 'you can not move a directory to one of its children';
    END IF;

#ifdef TREE_MAX_DEPTH
    -- check treepath max depth in source children
    SELECT max(nlevel(treepath)) INTO v_nlevel FROM mike.directory WHERE v_directory.treepath @> treepath;
    v_int := v_nlevel - nlevel(v_directory.treepath) + nlevel(v_new_directory_parent.treepath);

    IF v_int >= mike.__get_conf_int('tree_max_depth') THEN
        RAISE EXCEPTION 'source tree depth too large for target directory';
    END IF;
#endif /* TREE_MAX_DEPTH */

    -- look if folder name already exists in target
    PERFORM id_inode FROM mike.directory WHERE id_inode = in_new_id_inode_parent AND id_user = in_id_user AND name = coalesce(in_name, v_directory.name);
    IF FOUND THEN RAISE EXCEPTION 'inode name ''%'' already exists in %', v_directory.name, in_new_id_inode_parent; END IF;

    -- update id_inode_parent of in_id_inode
    UPDATE mike.directory SET
       id_inode_parent  = in_new_id_inode_parent,
       name             = coalesce(in_name, v_directory.name)
    WHERE id_inode = in_id_inode;

    -- update path and treepath of in_id_inode children
    UPDATE mike.inode SET
        treepath            = replace(treepath::text, v_old_directory_parent.treepath::text || '.', v_new_directory_parent.treepath::text || '.')::ltree,
        path                = v_new_directory_parent.path || '/' || coalesce(in_name, v_directory.name) || substr(path, length(v_directory.path) + 1)
    WHERE
        id_user = in_id_user
        AND treepath ~ ('*.' || in_id_inode || '.*')::lquery;

    -- update v_directory.id_inode_parent metadata
    UPDATE mike.directory SET
        dir_count               = dir_count - 1,
        inner_dir_count         = inner_dir_count - v_directory.inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        id_inode = v_directory.id_inode_parent;

    -- update v_directory.id_inode_parent ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count - v_directory.inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        nlevel(v_old_directory_parent.treepath) > 1
        AND treepath @> subpath(v_old_directory_parent.treepath, 0, nlevel(v_old_directory_parent.treepath) - 1);

     -- update v_new_directory_parent.id_inode metadata
     UPDATE mike.directory SET
        dir_count               = dir_count + 1,
        inner_dir_count         = inner_dir_count + v_directory.inner_dir_count + 1,
        inner_file_count        = inner_file_count + v_directory.inner_file_count,
        inner_size              = inner_size + v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size + v_directory.inner_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        id_inode = v_new_directory_parent.id_inode;

    -- update v_directory.id_inode_parent ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count + v_directory.inner_dir_count + 1,
        inner_file_count        = inner_file_count + v_directory.inner_file_count,
        inner_size              = inner_size + v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size + v_directory.inner_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        nlevel(v_new_directory_parent.treepath) > 1
        AND treepath @> subpath(v_new_directory_parent.treepath, 0, nlevel(v_new_directory_parent.treepath) - 1);
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.mvdir(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint,
    IN  in_name                 text
) IS 'copy a directory and its content inside another one';
