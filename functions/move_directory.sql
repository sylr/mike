-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.move_directory(
    IN  in_id_user              bigint,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.move_directory(
    IN  in_id_user              bigint,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint
) RETURNS void AS $__$

DECLARE
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

    -- look if folder name already exists in target
    SELECT id_inode FROM mike.directory WHERE id_inode = in_new_id_inode_parent AND id_user = in_id_user AND name = v_directory.name;
    IF FOUND THEN RAISE EXCEPTION 'directory name ''%''  already exists in %', v_directory.name, in_new_id_inode_parent; END IF;

    -- update id_inode_parent of in_id_inode
    UPDATE mike.directory SET id_inode_parent = in_new_id_inode_parent WHERE id_inode = in_id_inode;

    -- update path and treepath of in_id_inode children
    UPDATE mike.inode SET
        treepath            = replace(treepath::text, v_old_directory_parent.treepath::text, v_new_directory_parent.treepath::text)::ltree,
        path                = v_new_directory_parent.path || substr(path, length(v_old_directory_parent.path) + 1)
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
        datem                   = greatest(datem, now()),
        inner_datem             = greatest(inner_datem, now())
    WHERE
        id_inode = v_directory.id_inode_parent;

    -- update v_directory.id_inode_parent ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count - v_directory.inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        datem                   = greatest(datem, now()),
        inner_datem             = greatest(inner_datem, now())
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
        datem                   = greatest(datem, now()),
        inner_datem             = greatest(inner_datem, now())
    WHERE
        id_inode = v_new_directory_parent.id_inode;

    -- update v_directory.id_inode_parent ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count + v_directory.inner_dir_count + 1,
        inner_file_count        = inner_file_count + v_directory.inner_file_count,
        inner_size              = inner_size + v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size + v_directory.inner_versioning_size,
        datem                   = greatest(datem, now()),
        inner_datem             = greatest(inner_datem, now())
    WHERE
        nlevel(v_new_directory_parent.treepath) > 1
        AND treepath @> subpath(v_new_directory_parent.treepath, 0, nlevel(v_new_directory_parent.treepath) - 1);
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.move_directory(
    IN  in_id_user              bigint,
    IN  in_id_inode             bigint,
    IN  in_new_id_inode_parent  bigint
) IS 'copy a directory and its content inside another one';

