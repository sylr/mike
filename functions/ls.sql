-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 03/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) RETURNS SETOF mike.inode_full_t AS $__$

(
    -- directories
    SELECT
        id_inode,
        id_inode_parent,
        id_user,
        state,
        id_mimetype,
        name,
        path,
        treepath,
        ctime,
        mtime,
        inner_mtime,
        NULL AS atime,
        size,
        inner_size,
        versioning_size,
        inner_versioning_size,
        dir_count,
        inner_dir_count,
        file_count,
        inner_file_count
    FROM mike.directory
    WHERE
        id_user         = $1 AND
        id_inode_parent = $2
    ORDER BY mike.__natsort(name)
)
UNION ALL
(
    -- files
    SELECT
        id_inode,
        id_inode_parent,
        id_user,
        state,
        id_mimetype,
        name,
        path,
        treepath,
        ctime,
        mtime,
        NULL AS inner_mtime,
        atime,
        size,
        NULL AS inner_size,
        versioning_size,
        NULL AS inner_versioning_size,
        NULL AS dir_count,
        NULL AS inner_dir_count,
        NULL AS file_count,
        NULL AS inner_file_count
    FROM mike.file
    WHERE
        id_user         = $1 AND
        id_inode_parent = $2
    ORDER BY mike.__natsort(name)
);

$__$ LANGUAGE sql STABLE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) IS 'list all inodes inside a directory';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_limit                integer,
    IN  in_offset               integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_limit                integer,
    IN  in_offset               integer DEFAULT 0
) RETURNS SETOF mike.inode_full_t AS $__$

SELECT * FROM (
    (
        -- directories
        SELECT
            id_inode,
            id_inode_parent,
            id_user,
            state,
            id_mimetype,
            name,
            path,
            treepath,
            ctime,
            mtime,
            inner_mtime,
            NULL AS atime,
            size,
            inner_size,
            versioning_size,
            inner_versioning_size,
            dir_count,
            inner_dir_count,
            file_count,
            inner_file_count
        FROM mike.directory
        WHERE
            id_user         = $1 AND
            id_inode_parent = $2
        ORDER BY mike.__natsort(name)
    )
    UNION ALL
    (
        -- files
        SELECT
            id_inode,
            id_inode_parent,
            id_user,
            state,
            id_mimetype,
            name,
            path,
            treepath,
            ctime,
            mtime,
            NULL AS inner_mtime,
            atime,
            size,
            NULL AS inner_size,
            versioning_size,
            NULL AS inner_versioning_size,
            NULL AS dir_count,
            NULL AS inner_dir_count,
            NULL AS file_count,
            NULL AS inner_file_count
        FROM mike.file
        WHERE
            id_user         = $1 AND
            id_inode_parent = $2
        ORDER BY mike.__natsort(name)
    )
) AS aggregate
LIMIT $3
OFFSET $4;

$__$ LANGUAGE sql STABLE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_limit                integer,
    IN  in_offset               integer
) IS 'list all inodes inside a directory with paging';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text
) RETURNS SETOF mike.inode_full_t AS $__$

BEGIN
    -- sanity check
    PERFORM mike.__check_order_by_cond(in_order_by, 'inode_full_t');

    RETURN QUERY EXECUTE $$
        SELECT * FROM (
            (
                -- directories
                SELECT
                    id_inode,
                    id_inode_parent,
                    id_user,
                    state,
                    id_mimetype,
                    name,
                    path,
                    treepath,
                    ctime,
                    mtime,
                    inner_mtime,
                    NULL AS atime,
                    size,
                    inner_size,
                    versioning_size,
                    inner_versioning_size,
                    dir_count,
                    inner_dir_count,
                    file_count,
                    inner_file_count
                FROM mike.directory
                WHERE
                    id_user         = $1 AND
                    id_inode_parent = $2
            )
            UNION ALL
            (
                -- files
                SELECT
                    id_inode,
                    id_inode_parent,
                    id_user,
                    state,
                    id_mimetype,
                    name,
                    path,
                    treepath,
                    ctime,
                    mtime,
                    NULL AS inner_mtime,
                    atime,
                    size,
                    NULL AS inner_size,
                    versioning_size,
                    NULL AS inner_versioning_size,
                    NULL AS dir_count,
                    NULL AS inner_dir_count,
                    NULL AS file_count,
                    NULL AS inner_file_count
                FROM mike.file
                WHERE
                    id_user         = $1 AND
                    id_inode_parent = $2
            )
        )  AS aggregate
        ORDER BY $$ || in_order_by || $$;$$
        USING
            in_id_user,
            in_id_inode;
END;

$__$ LANGUAGE plpgsql STABLE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text
) IS 'list all inodes inside a directory with sorting';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text,
    IN  in_limit                integer,
    IN  in_offset               integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text,
    IN  in_limit                integer,
    IN  in_offset               integer DEFAULT 0
) RETURNS SETOF mike.inode_full_t AS $__$

BEGIN
    -- sanity check
    PERFORM mike.__check_order_by_cond(in_order_by, 'inode_full_t');

    RETURN QUERY EXECUTE $$
        SELECT * FROM (
            (
                -- directories
                SELECT
                    id_inode,
                    id_inode_parent,
                    id_user,
                    state,
                    id_mimetype,
                    name,
                    path,
                    treepath,
                    ctime,
                    mtime,
                    inner_mtime,
                    NULL AS atime,
                    size,
                    inner_size,
                    versioning_size,
                    inner_versioning_size,
                    dir_count,
                    inner_dir_count,
                    file_count,
                    inner_file_count
                FROM mike.directory
                WHERE
                    id_user         = $1 AND
                    id_inode_parent = $2
            )
            UNION ALL
            (
                -- files
                SELECT
                    id_inode,
                    id_inode_parent,
                    id_user,
                    state,
                    id_mimetype,
                    name,
                    path,
                    treepath,
                    ctime,
                    mtime,
                    NULL AS inner_mtime,
                    atime,
                    size,
                    NULL AS inner_size,
                    versioning_size,
                    NULL AS inner_versioning_size,
                    NULL AS dir_count,
                    NULL AS inner_dir_count,
                    NULL AS file_count,
                    NULL AS inner_file_count
                FROM mike.file
                WHERE
                    id_user         = $1 AND
                    id_inode_parent = $2
            )
        )  AS aggregate
        ORDER BY    $$ || in_order_by || $$
        LIMIT       $3
        OFFSET      $4;$$
        USING
            in_id_user,
            in_id_inode,
            in_limit,
            in_offset;
END;

$__$ LANGUAGE plpgsql STABLE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text,
    IN  in_limit                integer,
    IN  in_offset               integer
) IS 'list all inodes inside a directory with sorting and paging';
