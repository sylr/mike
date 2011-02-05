-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 05/02/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.xlink(
    IN  in_id_inode     bigint,
    IN  id_id_xfile     bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.xlink(
    IN  in_id_inode     bigint,
    IN  id_id_xfile     bigint
) RETURNS void AS $__$

DECLARE
    v_file              mike.file%rowtype;
    v_xfile             mike.xfile%rowtype;
    v_versioning_size   bigint;
BEGIN
    -- file
    SELECT * INTO v_file FROM mike.file WHERE id_inode = in_id_inode AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'file ''%'' not found', in_id_inode; END IF;

    -- xfile
    SELECT * INTO v_xfile FROM mike.xfile WHERE id_xfile = in_id_xfile;
    IF NOT FOUND THEN RAISE EXCEPTION 'xfile ''%'' not found', in_id_file; END IF;

    -- linking
    INSERT INTO mike.as_file_xfile (
        id_inode,
        id_xfile
    )
    VALUES (
        in_id_inode,
        in_id_xfile
    );

    -- calculating versioning size
    SELECT
        sum(size) INTO v_versioning_size
    FROM xfile
    WHERE id_xfile IN (
        SELECT DISTINCT
            id_xfile
        FROM as_file_xfile
        WHERE as_file_xfile.id_inode = in_id_inode
    );

    -- updating file record
    UPDATE mike.file SET
        id_mimetype     = v_xfile.id_mimetype,
        size            = v_xfile.size,
        versioning_size = v_versioning_size,
        datem           = greatest(datem, now())
    WHERE
        id_inode = in_id_inode;

    -- update parent directory
    UPDATE mike.directory SET
        size                    = size - v_file.size + v_xfile.size,
        versioning_size         = versioning_size - v_file.versioning_size + v_versioning_size,
        inner_size              = inner_size - v_file.size + v_xfile.size,
        inner_versioning_size   = inner_versioning_size - v_file.versioning_size + v_versioning_size,
        datem                   = greatest(datem, in_datec),
        inner_datem             = greatest(inner_datem, in_datec)
    WHERE
        id_inode = v_file.id_inode_parent;

    -- update great parents directories
    UPDATE mike.directory SET
        inner_size              = inner_size - v_file.size + v_xfile.size,
        inner_versioning_size   = inner_versioning_size - v_file.versioning_size + v_versioning_size,
        datem                   = greatest(datem, in_datec),
        inner_datem             = greatest(inner_datem, in_datec)
    WHERE
        treepath @> subpath(v_file.treepath, 0, nlevel(v_file.treepath) - 2);
END;

$__$ LANGUAGE plpgsql VOLATILE;
