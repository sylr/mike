-- # Mike's Function
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 26/07/2010
-- # copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.remove_directory(
    IN  in_id_user          bigint,
    IN  in_id_inode         bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.remove_directory(
    IN  in_id_user          bigint,
    IN  in_id_inode         bigint
) RETURNS void AS $__$

DECLARE
    v_directory         mike.directory%rowtype;
BEGIN
    -- select id_inode
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode AND id_user = in_id_user;

    -- update id_inode
    UPDATE mike.directory SET id_inode_parent = id_inode WHERE id_inode = in_id_inode;

    -- update children status
    UPDATE mike.inode SET state = 2 WHERE treepath <@ v_directory.treepath;

    -- update id_inode_parent
    UPDATE mike.directory SET 
        dir_count               = dir_count - 1,
        inner_dir_count         = inner_dir_count - v_directory.inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        datem                   = greatest(datem, NOW()),
        inner_datem             = greatest(inner_datem, NOW())
    WHERE
        id_inode_parent = v_directory.id_inode_parent;

    -- update ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count         = inner_dir_count - 1,
        inner_file_count        = inner_file_count - v_directory.inner_file_count,
        inner_size              = inner_size - v_directory.inner_size,
        inner_versioning_size   = inner_versioning_size - v_directory.inner_versioning_size,
        inner_datem             = greatest(inner_datem, NOW())
    WHERE
        treepath @> subpath(v_directory.treepath, 0, nlevel(v_directory.treepath) - 1);
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.remove_directory(
    IN  in_id_user          bigint,
    IN  in_id_inode         bigint
) IS 'this function flags a directory and all its children as removed';

