-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__fsck(
    in_id_user      integer,
    in_dry_run      boolean DEFAULT false
) RETURNS void AS $__$

DECLARE
    v_inode             record;
    v_inode2            record;
    a_id_inode_parent   bigint[];
    a_id_inode_parent2  bigint[];
    v_file              record;
    v_directory         record;
    v_record            record;
    v_record2           record;
    v_doomed            boolean;
    v_done              boolean;
BEGIN
    RAISE NOTICE 'fscking tree of user %', in_id_user;
    RAISE NOTICE 'Be patient, this can take a while';

    -- locks --------------------------------------------------------------------

    PERFORM id_inode FROM mike.as_file_xfile WHERE id_inode IN (SELECT id_inode FROM mike.file WHERE id_user = in_id_user) FOR UPDATE;
    PERFORM id_inode FROM mike.inode WHERE id_user = in_id_user FOR UPDATE;

    -- [tree]paths -------------------------------------------------------------

    v_done              := false;
    a_id_inode_parent   := NULL;
    a_id_inode_parent2  := NULL;

    WHILE true LOOP
        FOR v_inode IN SELECT *
            FROM mike.inode
            WHERE
                id_user = in_id_user AND
                state = 0 AND
                (
                    (v_done = true  AND id_inode_parent = ANY (a_id_inode_parent)) OR
                    (v_done = false AND id_inode_parent IS NULL)
                )
        LOOP
            v_doomed := false;

            -- root
            IF v_inode.id_inode_parent IS NULL THEN
                -- path
                IF v_inode.path != ('/' || v_inode.name) THEN
                    RAISE WARNING 'inode % path is doomed (''%'' instead of ''%'')',
                        v_inode.id_inode,
                        v_inode.path,
                        '/' || v_inode.name;

                    v_doomed        := true;
                    v_inode.path    := '/' || v_inode.name;
                END IF;

                -- treepath
                IF v_inode.treepath != v_inode.id_inode::text::ltree THEN
                    RAISE WARNING 'inode % treepath is doomed (''%'' instead of ''%'')',
                        v_inode.id_inode,
                        v_inode.treepath,
                        v_inode.id_inode::text;

                    v_doomed            := true;
                    v_inode.treepath    := v_inode.id_inode::text::ltree;
                END IF;

                v_done              := true;
                a_id_inode_parent2  := ARRAY[v_inode.id_inode];
            -- not root
            ELSE
                a_id_inode_parent2 := array_append(a_id_inode_parent2, v_inode.id_inode);

                SELECT
                    path || '/' || v_inode.name                 AS path,
                    treepath || v_inode.id_inode::text::ltree   AS treepath
                    INTO v_inode2
                FROM mike.directory
                WHERE
                    id_user     = in_id_user AND
                    id_inode    = v_inode.id_inode_parent;

                -- path
                IF v_inode.path != v_inode2.path THEN
                    RAISE WARNING 'inode % path is doomed (''%'' instead of ''%'')',
                        v_inode.id_inode,
                        v_inode.path,
                        v_inode2.path;

                    v_doomed        := true;
                    v_inode.path    := v_inode2.path;
                END IF;

                -- treepath
                IF v_inode.treepath != v_inode2.treepath THEN
                    RAISE WARNING 'inode % treepath is doomed (''%'' instead of ''%'')',
                        v_inode.id_inode,
                        v_inode.treepath,
                        v_inode2.treepath;

                    v_doomed            := true;
                    v_inode.treepath    := v_inode2.treepath;
                END IF;
            END IF;

            -- update
            IF v_doomed THEN
                UPDATE mike.inode SET
                    path        = v_inode.path,
                    treepath    = v_inode.treepath
                WHERE
                    id_user     = in_id_user AND
                    id_inode    = v_inode.id_inode;
            END IF;
        END LOOP;

        a_id_inode_parent   := a_id_inode_parent2;
        a_id_inode_parent2  := NULL;

        -- break loop
        IF a_id_inode_parent IS NULL THEN
            EXIT;
        END IF;
    END LOOP;

    -- files -------------------------------------------------------------------

    FOR v_file IN SELECT
        file.*,
        coalesce(
            (SELECT size
            FROM mike.as_file_xfile
            JOIN mike.xfile USING (id_xfile)
            WHERE as_file_xfile.id_inode = file.id_inode
            ORDER BY as_file_xfile.ctime DESC, id_xfile DESC LIMIT 1),
            0
        ) AS calculated_size,
        coalesce(
            (SELECT sum(size) FROM mike.xfile WHERE id_xfile IN
                (SELECT DISTINCT id_xfile FROM mike.as_file_xfile WHERE id_inode = file.id_inode)
            ),
            0
        ) AS calculated_versioning_size
        FROM mike.file
        WHERE
            id_user = in_id_user AND
            state   = 0
    LOOP
        v_doomed := false;

        -- size
        IF v_file.size != v_file.calculated_size THEN
            RAISE WARNING 'file % size is doomed (% instead of %)',
                v_file.id_inode,
                v_file.size,
                v_file.calculated_size;

            v_doomed := true;
        END IF;

        -- versioning size
        IF v_file.versioning_size != v_file.calculated_versioning_size THEN
            RAISE WARNING 'file % versioning size is doomed (% instead of %)',
                v_file.id_inode,
                v_file.versioning_size,
                v_file.calculated_versioning_size;

            v_doomed := true;
        END IF;

        -- updating
        IF v_doomed THEN
            UPDATE mike.file SET
                size            = v_file.calculated_size,
                versioning_size = v_file.calculated_versioning_size
            WHERE
                id_user     = in_id_user AND
                id_inode    = v_file.id_inode;
        END IF;
    END LOOP;

    -- directories -------------------------------------------------------------

    FOR v_directory IN SELECT *
        FROM mike.directory
        WHERE
            id_user = in_id_user AND
            state   = 0
        ORDER BY nlevel(treepath) DESC
    LOOP
        v_doomed := false;

        -- files ---------------------------------------------------------------

        SELECT
            coalesce(sum(size), 0)              AS calculated_size,
            coalesce(sum(versioning_size), 0)   AS calculated_versioning_size,
            count(id_inode)                     AS calculated_file_count
            INTO v_record
        FROM mike.file
        WHERE
            id_user = in_id_user AND
            state  = 0 AND
            id_inode_parent = v_directory.id_inode;

        -- file count
        IF v_directory.file_count != v_record.calculated_file_count THEN
            RAISE WARNING 'directory % file count is doomed % instead of %',
                v_directory.id_inode,
                v_directory.file_count,
                v_record.calculated_file_count;

                v_doomed := true;
        END IF;

        -- size
        IF v_directory.size != v_record.calculated_size THEN
            RAISE WARNING 'directory % size is doomed % instead of %',
                v_directory.id_inode,
                v_directory.size,
                v_record.calculated_size;

            v_doomed := true;
        END IF;

        -- versioning size
        IF v_directory.versioning_size != v_record.calculated_versioning_size THEN
            RAISE WARNING 'directory % versioning size is doomed % instead of %',
                v_directory.id_inode,
                v_directory.versioning_size,
                v_record.calculated_versioning_size;

            v_doomed := true;
        END IF;

        -- directory -----------------------------------------------------------

        SELECT
            coalesce(sum(inner_size), 0) + coalesce(v_record.calculated_size, 0)                        AS calculated_inner_size,
            coalesce(sum(inner_versioning_size), 0) + coalesce(v_record.calculated_versioning_size, 0)  AS calculated_inner_versioning_size,
            count(id_inode)                                                                             AS calculated_dir_count,
            coalesce(sum(inner_dir_count), 0) + count(id_inode)                                         AS calculated_inner_dir_count,
            coalesce(sum(inner_file_count), 0) + coalesce(v_record.calculated_file_count, 0)            AS calculated_inner_file_count
            INTO v_record2
        FROM mike.directory
        WHERE
            id_user         = in_id_user AND
            state           = 0 AND
            id_inode_parent = v_directory.id_inode;

        -- inner size
        IF v_directory.inner_size != v_record2.calculated_inner_size THEN
            RAISE WARNING 'directory % inner size is doomed (% instead of %)',
                v_directory.id_inode,
                v_directory.inner_size,
                v_record2.calculated_inner_size;

            v_doomed := true;
        END IF;

        -- inner versioning size
        IF v_directory.inner_versioning_size != v_record2.calculated_inner_versioning_size THEN
            RAISE WARNING 'directory % inner versioning size is doomed (% instead of %)',
                v_directory.id_inode,
                v_directory.inner_versioning_size,
                v_record2.calculated_inner_versioning_size;

            v_doomed := true;
        END IF;

        -- dir count
        IF v_directory.dir_count != v_record2.calculated_dir_count THEN
            RAISE WARNING 'directory % dir count is doomed (% instead of %)',
                v_directory.id_inode,
                v_directory.dir_count,
                v_record2.calculated_dir_count;

            v_doomed := true;
        END IF;

        -- inner dir count
        IF v_directory.inner_dir_count != v_record2.calculated_inner_dir_count THEN
            RAISE WARNING 'directory % inner dir count is doomed (% instead of %)',
                v_directory.id_inode,
                v_directory.inner_dir_count,
                v_record2.calculated_inner_dir_count;

            v_doomed := true;
        END IF;

        -- inner file count
        IF v_directory.inner_file_count != v_record2.calculated_inner_file_count THEN
            RAISE WARNING 'directory % inner file count is doomed (% instead of %)',
                v_directory.id_inode,
                v_directory.inner_file_count,
                v_record2.calculated_inner_file_count;

            v_doomed := true;
        END IF;

        IF v_doomed THEN
            UPDATE mike.directory SET
                file_count              = v_record.calculated_file_count,
                inner_file_count        = v_record2.calculated_inner_file_count,
                size                    = v_record.calculated_size,
                inner_size              = v_record2.calculated_inner_size,
                versioning_size         = v_record.calculated_versioning_size,
                inner_versioning_size   = v_record2.calculated_inner_versioning_size,
                dir_count               = v_record2.calculated_dir_count,
                inner_dir_count         = v_record2.calculated_inner_dir_count
            WHERE
                id_user     = in_id_user AND
                id_inode    = v_directory.id_inode;
        END IF;
    END LOOP;

    -- dry-run -----------------------------------------------------------------

    IF in_dry_run THEN
        RAISE query_canceled USING MESSAGE = 'THIS WAS A DRY RUN !';
    END IF;
END;

$__$ LANGUAGE plpgsql VOLATILE;
