-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.rmdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.rmdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) RETURNS void AS $__$

DECLARE
    v_directory             mike.directory%rowtype;
    v_directory_parent      mike.directory%rowtype;
BEGIN
    -- select directory
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode AND id_user = in_id_user;
    IF NOT FOUND THEN RAISE EXCEPTION 'directory #% owned by #% not found', in_id_inode, in_id_user; END IF;

    -- directory already removed
    IF v_directory.state >= 2 THEN
        RAISE EXCEPTION 'directory #% already removed', in_id_inode;
    END IF;

    -- select parent directory
    SELECT * INTO v_directory_parent FROM mike.directory WHERE id_inode = v_directory.id_inode_parent AND id_user = in_id_user;

    -- dereferencing directory
    UPDATE mike.directory SET
        id_inode_parent = id_inode,
        state           = 2,
        name            = substring('3487$$' || name, 0, 255),
        path            = '/' || substring('3487$$' || name, 0, 255),
        treepath        = subpath(treepath, nlevel(v_directory.treepath) - 1),
        mtime           = now()
    WHERE id_inode = in_id_inode;

    -- update children state to 'waiting for physical removal'
    UPDATE mike.inode SET
        state       = 2,
        path        = '/' || substring('3487$$' || name, 0, 255) || substring(path, length(v_directory.path) + 1),
        treepath    = subpath(treepath, nlevel(v_directory.treepath) - 1),
        mtime       = now()
    WHERE treepath <@ v_directory.treepath AND id_inode != in_id_inode;

    -- directory removed is a root directory we stop here
    IF v_directory.id_inode_parent = NULL THEN
        RETURN;
    END IF;

    -- update id_inode_parent
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

    -- parent directory removed is a root directory we stop here
    IF v_directory_parent.id_inode_parent = NULL THEN
        RETURN;
    END IF;

    -- update ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count - v_directory.inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        treepath @> subpath(v_directory.treepath, 0, nlevel(v_directory.treepath) - 1);
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.rmdir(
    IN  in_id_user          integer,
    IN  in_id_inode         bigint
) IS 'this function flags a directory and all its children inodes as removed';
