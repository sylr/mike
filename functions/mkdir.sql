-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.mkdir(
    IN  in_id_user          integer,
    IN  in_name             text,
    OUT out_id_inode        bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.mkdir(
    IN  in_id_user          integer,
    IN  in_name             text,
    OUT out_id_inode        bigint
) AS $__$

DECLARE
    v_directory             mike.directory%rowtype;
    v_parent_treepath       ltree;
BEGIN
    -- select id_inode
    SELECT nextval('inode_id_inode_seq'::regclass) INTO out_id_inode;

    -- insert into mike.directory
    INSERT INTO mike.directory (
        id_inode,
        id_user,
        id_inode_parent,
        name,
        path,
        treepath
     )
     VALUES (
        out_id_inode,
        in_id_user,
        NULL,
        in_name,
        '/' || in_name,
        out_id_inode::text::ltree
     );
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.mkdir(
    IN  id_user             integer,
    IN  name                text,
    OUT id_inode            bigint
) IS 'create a directory which does not have an id_inode_parent, root folder';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.mkdir(
    IN  in_id_user              integer,
    IN  in_id_inode_parent      bigint,
    IN  in_name                 text,
    IN  in_return_if_exists     boolean,
    OUT out_id_inode            bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.mkdir(
    IN  in_id_user              integer,
    IN  in_id_inode_parent      bigint,
    IN  in_name                 text,
    IN  in_return_if_exists     boolean DEFAULT false,
    OUT out_id_inode            bigint
) AS $__$

DECLARE
    v_directory     mike.directory%rowtype;
    v_treepath      ltree;
BEGIN
    -- check name unicity
    SELECT id_inode INTO out_id_inode FROM inode WHERE id_inode_parent = in_id_inode_parent AND name = in_name;

    IF FOUND THEN
        IF in_return_if_exists THEN
            RETURN;
        ELSE
            RAISE EXCEPTION 'inode name ''%'' already exists in directory %', in_name, in_id_inode_parent;
        END IF;
    END IF;

    -- select id_inode
    SELECT nextval('inode_id_inode_seq'::regclass) INTO out_id_inode;

    -- select id_inode_parent
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode_parent;

#ifdef TREE_MAX_DEPTH
    -- check parent inode depth
    IF nlevel(v_directory.treepath) >= mike.__get_conf_int('tree_max_depth') - 1 THEN
        RAISE 'parent inode depth too large to ';
    END IF;
#endif /* TREE_MAX_DEPTH */

    v_treepath := v_directory.treepath || out_id_inode::text::ltree;

    -- insert into mike.directory
    INSERT INTO mike.directory (
        id_inode,
        id_user,
        id_inode_parent,
        name,
        path,
        treepath
     )
     VALUES (
        out_id_inode,
        in_id_user,
        in_id_inode_parent,
        in_name,
        v_directory.path || '/' || in_name,
        v_treepath
     );

    -- update id_inode parent
    UPDATE mike.directory SET
        dir_count           = dir_count + 1,
        inner_dir_count     = inner_dir_count + 1,
        mtime               = greatest(mtime, now()),
        inner_mtime         = greatest(inner_mtime, now())
    WHERE
        id_inode = in_id_inode_parent;

    -- update ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count     = inner_dir_count + 1,
        inner_mtime         = greatest(inner_mtime, now())
    WHERE
        nlevel(v_treepath) > 2
        AND treepath @> subpath(v_treepath, 0, nlevel(v_treepath) - 2);
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;

COMMENT ON FUNCTION mike.mkdir(
    IN  id_user             integer,
    IN  name                text,
    OUT id_inode            bigint
) IS 'create a directory with an id_inode_parent';
