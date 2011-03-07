-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/04/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.rename(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_name             text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.rename(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_name             text
) RETURNS void AS $__$

DECLARE
    v_inode                     mike.inode%rowtype;
BEGIN
    -- select in_id_inode
    SELECT * INTO v_inode FROM mike.inode WHERE id_inode = in_id_inode AND id_user = in_id_user AND state = 0;
    IF NOT FOUND THEN RAISE EXCEPTION 'in_id_inode #% not found', in_id_inode; END IF;

    -- checking is name already exists
    PERFORM
        *
    FROM mike.inode
    WHERE
        id_inode_parent = v_inode.id_inode_parent AND
        id_user         = in_id_user AND
        state           = 0 AND
        name            = in_new_name AND
        id_mimetype     = v_inode.id_mimetype;

    IF FOUND THEN RAISE EXCEPTION 'an inode of same type already exists in the same directory'; END IF;

    -- updating path of inode and children if any
    UPDATE mike.inode SET
        path = substring(v_inode.path, 0, length(v_inode.path) - length(v_inode.name) + 1) || in_new_name || substring(path, length(v_inode.path) + 1)
    WHERE
        id_user      = in_id_user AND
        treepath    <@ v_inode.treepath;

    -- updating mtime of inode
    UPDATE mike.inode SET
        name    = in_new_name,
        mtime   = greatest(mtime, now())
    WHERE
        id_user     = in_id_user AND
        id_inode    = v_inode.id_inode;

    -- updating ancestors inner mtime
    IF v_inode.id_inode_parent IS NOT NULL THEN
        UPDATE mike.directory SET
            inner_mtime = greatest(inner_mtime, now())
        WHERE
            id_user      = in_id_user AND
            treepath    @> v_inode.treepath AND
            id_inode    != v_inode.id_inode;
     END IF;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.rename(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_new_name             text
) IS 'rename an inode';
