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

BEGIN
    RETURN QUERY
        (
            -- directories
            SELECT *
            FROM mike.directory
            WHERE
                id_user = in_id_user
                AND id_inode_parent = in_id_inode
            ORDER BY name
        )
        UNION ALL
        (
            -- files
            SELECT *,
                NULL AS inner_mtime,
                NULL AS inner_size,
                NULL AS inner_versioning_size,
                NULL AS dir_count,
                NULL AS inner_dir_count,
                NULL AS file_count,
                NULL AS inner_file_count
            FROM mike.file
            WHERE
                id_user = in_id_user
                AND id_inode_parent = in_id_inode
            ORDER BY name
        );
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint
) IS 'list all inodes inside a directory';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_limit                integer,
    IN  in_offser               integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_limit                integer DEFAULT NULL,
    IN  in_offset               integer DEFAULT NULL
) RETURNS SETOF mike.inode_full_t AS $__$

BEGIN
    RETURN QUERY
        SELECT * FROM (
            (
                -- directories
                SELECT *
                FROM mike.directory
                WHERE
                    id_user         = in_id_user AND
                    id_inode_parent = in_id_inode
                ORDER BY name
            )
            UNION ALL
            (
                -- files
                SELECT *,
                    NULL AS inner_mtime,
                    NULL AS inner_size,
                    NULL AS inner_versioning_size,
                    NULL AS dir_count,
                    NULL AS inner_dir_count,
                    NULL AS file_count,
                    NULL AS inner_file_count
                FROM mike.file
                WHERE
                    id_user         = in_id_user AND
                    id_inode_parent = in_id_inode
                ORDER BY name
            )
        ) AS aggregate
        LIMIT in_limit
        OFFSET in_offset;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

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
    RETURN QUERY EXECUTE $$
        SELECT * FROM (
            (
                -- directories
                SELECT *
                FROM mike.directory
                WHERE
                    id_user         = $$ || in_id_user    || $$ AND
                    id_inode_parent = $$ || in_id_inode   || $$
            )
            UNION ALL
            (
                -- files
                SELECT *,
                    NULL AS inner_mtime,
                    NULL AS inner_size,
                    NULL AS inner_versioning_size,
                    NULL AS dir_count,
                    NULL AS inner_dir_count,
                    NULL AS file_count,
                    NULL AS inner_file_count
                FROM mike.file
                WHERE
                    id_user         = $$ || in_id_user    || $$ AND
                    id_inode_parent = $$ || in_id_inode   || $$
            )
        )  AS aggregate
        ORDER BY $$ || in_order_by;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

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
    IN  in_limit                integer DEFAULT NULL,
    IN  in_offset               integer DEFAULT NULL
) RETURNS SETOF mike.inode_full_t AS $__$

BEGIN
    RETURN QUERY EXECUTE $$
        SELECT * FROM (
            (
                -- directories
                SELECT *
                FROM mike.directory
                WHERE
                    id_user         = $$ || in_id_user    || $$ AND
                    id_inode_parent = $$ || in_id_inode   || $$
            )
            UNION ALL
            (
                -- files
                SELECT *,
                    NULL AS inner_mtime,
                    NULL AS inner_size,
                    NULL AS inner_versioning_size,
                    NULL AS dir_count,
                    NULL AS inner_dir_count,
                    NULL AS file_count,
                    NULL AS inner_file_count
                FROM mike.file
                WHERE
                    id_user         = $$ || in_id_user    || $$ AND
                    id_inode_parent = $$ || in_id_inode   || $$
            )
        )  AS aggregate
        ORDER BY    $$ || in_order_by   || $$
        LIMIT       $$ || in_limit      || $$
        OFFSET      $$ || in_offset;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.ls(
    IN  in_id_user              integer,
    IN  in_id_inode             bigint,
    IN  in_order_by             text,
    IN  in_limit                integer,
    IN  in_offset               integer
) IS 'list all inodes inside a directory with sorting and paging';
