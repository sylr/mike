-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.make_directory(
    IN  in_id_user          bigint,
    IN  in_name             text,
    OUT out_id_inode        bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.make_directory(
    IN  in_id_user          bigint,
    IN  in_name             text,
    OUT out_id_inode        bigint
) RETURNS bigint AS $__$

DECLARE
    v_directory         mike.directory%rowtype;
    v_parent_treepath   ltree;
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
        out_id_inode,
        in_name,
        '/' || in_name,
        out_id_inode::text::ltree
     );
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.make_directory(
    IN  id_user             bigint,
    IN  name                text,
    OUT id_inode            bigint
) IS 'create a directory which does not have an id_inode_parent, root folder';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.make_directory(
    IN  in_id_user              bigint,
    IN  in_id_inode_parent      bigint,
    IN  in_name                 text,
    OUT out_id_inode            bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.make_directory(
    IN  in_id_user              bigint,
    IN  in_id_inode_parent      bigint,
    IN  in_name                 text,
    OUT out_id_inode            bigint
) RETURNS bigint AS $__$

DECLARE
    v_directory     mike.directory%rowtype;
    v_treepath      ltree;
BEGIN
    -- select id_inode
    SELECT nextval('inode_id_inode_seq'::regclass) INTO out_id_inode;

    -- select id_inode_parent
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode_parent;

    v_treepath :=  v_directory.treepath || out_id_inode::text::ltree;

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
        datem               = greatest(datem, now()),
        inner_datem         = greatest(inner_datem, now())
    WHERE
        id_inode = in_id_inode_parent;

    -- update ancestors metadata
    UPDATE mike.directory SET
        inner_dir_count     = inner_dir_count + 1,
        inner_datem         = greatest(inner_datem, now())
    WHERE
        nlevel(v_treepath) > 2
        AND treepath @> subpath(v_treepath, 0, nlevel(v_treepath) - 2);
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.make_directory(
    IN  id_user             bigint,
    IN  name                text,
    OUT id_inode            bigint
) IS 'create a directory with an id_inode_parent';

