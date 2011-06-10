-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 05/02/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.xlink(
    IN  in_id_user      integer,
    IN  in_id_inode     bigint,
    IN  in_id_xfile     bigint,
    IN  in_ctime        bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.xlink(
    IN  in_id_user      integer,
    IN  in_id_inode     bigint,
    IN  in_id_xfile     bigint,
    IN  in_ctime        timestamptz DEFAULT NULL
) RETURNS void AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_file              mike.file%rowtype;
    v_xfile             mike.xfile%rowtype;
    v_as_file_xfile     mike.as_file_xfile%rowtype;
    v_versioning_size   bigint;
    v_exist             boolean := false;
    v_last              boolean := true;
BEGIN
    -- file
    SELECT * INTO v_file FROM mike.file WHERE id_user = in_id_user AND id_inode = in_id_inode AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'file ''%'' not found', in_id_inode; END IF;

    -- xfile
    SELECT * INTO v_xfile FROM mike.xfile WHERE id_xfile = in_id_xfile;
    IF NOT FOUND THEN RAISE EXCEPTION 'xfile ''%'' not found', in_id_xfile; END IF;

    -- selecting last link of the inode
    SELECT * INTO v_as_file_xfile FROM mike.as_file_xfile WHERE id_user = in_id_user AND id_inode = in_id_inode ORDER BY ctime DESC LIMIT 1;

    IF FOUND THEN
        -- check if last xfile linked is not already the one we are linking
        IF v_as_file_xfile.id_xfile = in_id_xfile THEN
            RAISE WARNING 'xfile ''%'' is already the last linked to ''%'', doing nothing', in_id_xfile, in_id_file;
            RETURN;
        END IF;

        -- checking if given ctime is greater than last one
        IF in_ctime IS NOT NULL AND in_ctime < v_as_file_xfile.ctime THEN
            v_last := false;
        END IF;

        -- checking if id_xfile already part of the inode history
        PERFORM * FROM mike.as_file_xfile WHERE id_xfile = in_id_xfile LIMIT 1;

        IF FOUND THEN
            v_exist := true;
        END IF;

        -- checking that in_ctime is unique
        IF in_ctime IS NOT NULL THEN
            SELECT * INTO v_as_file_xfile FROM mike.as_file_xfile WHERE id_user = in_id_user AND id_inode = in_id_inode AND ctime = in_ctime LIMIT 1;

            IF FOUND AND v_as_file_xfile.id_xfile = in_id_xfile THEN
                RAISE WARNING 'exact same link already exists, doing nothing';
                RETURN;
            ELSEIF FOUND THEN
                RAISE EXCEPTION 'file ''%'' already has a link with given ctime', in_id_inode;
            END IF;
        END IF;
    END IF;

    -- linking
    INSERT INTO mike.as_file_xfile (
        id_user,
        id_inode,
        id_xfile,
        ctime
    )
    VALUES (
        in_id_user,
        in_id_inode,
        in_id_xfile,
        coalesce(in_ctime, now())
    );

    -- don't continue if xfile already part of the history and not last version
    IF v_exist = true AND v_last = false THEN
        RETURN;
    END IF;

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
        mtime           = greatest(mtime, now())
    WHERE
        id_inode    = in_id_inode AND
        state       = 0;

    -- update parent directory
    UPDATE mike.directory SET
        size                    = size - v_file.size + v_xfile.size,
        versioning_size         = versioning_size - v_file.versioning_size + v_versioning_size,
        inner_size              = inner_size - v_file.size + v_xfile.size,
        inner_versioning_size   = inner_versioning_size - v_file.versioning_size + v_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        id_inode    = v_file.id_inode_parent AND
        state       = 0;

    -- update great parents directories
    UPDATE mike.directory SET
        inner_size              = inner_size - v_file.size + v_xfile.size,
        inner_versioning_size   = inner_versioning_size - v_file.versioning_size + v_versioning_size,
        mtime                   = greatest(mtime, now()),
        inner_mtime             = greatest(inner_mtime, now())
    WHERE
        treepath   @> subpath(v_file.treepath, 0, nlevel(v_file.treepath) - 2) AND
        state       = 0;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;
