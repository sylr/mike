-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 27/11/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.touch(
    IN  in_id_user          bigint,
    IN  in_id_inode_parent  bigint,
    IN  in_name             text,
    IN  in_datec            timestamptz,
    OUT out_id_inode        bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.touch(
    IN  in_id_user          bigint,
    IN  in_id_inode_parent  bigint,
    IN  in_name             text,
    IN  in_datec            timestamptz DEFAULT now(),
    OUT out_id_inode        bigint
) RETURNS bigint AS $__$

DECLARE
    v_id_inode              bigint;
    v_directory             mike.directory%rowtype;
BEGIN
    -- check id_inode_parent
    SELECT * INTO v_directory FROM mike.directory WHERE id_inode = in_id_inode_parent;
    IF NOT FOUND THEN RAISE EXCEPTION 'directory ''%'' not found', in_id_inode_parent; END IF;

    -- check name unicity
    SELECT id_inode INTO v_id_inode FROM inode WHERE id_user = in_id_user AND id_inode_parent = in_id_inode_parent AND name = in_name;
    IF FOUND THEN RAISE EXCEPTION 'inode name ''%'' already exists in directory ''%''', in_name, in_id_inode_parent; END IF;

    -- select id_inode
    SELECT nextval('inode_id_inode_seq'::regclass) INTO out_id_inode;

    -- insert into mike.file
    INSERT INTO mike.file (
        id_inode,
        id_user,
        id_inode_parent,
        name,
        path,
        treepath,
        datec
    )
    VALUES (
        out_id_inode,
        in_id_user,
        in_id_inode_parent,
        in_name,
        v_directory.path || '/' || in_name,
        v_directory.treepath || out_id_inode::text::ltree,
        in_datec
    );

    -- update parent directory
    UPDATE mike.directory SET
        file_count              = file_count + 1,
        inner_file_count        = inner_file_count + 1,
        datem                   = greatest(datem, in_datec),
        inner_datem             = greatest(inner_datem, in_datec)
    WHERE
        id_inode = in_id_inode_parent;

    -- update great parents directories
    UPDATE mike.directory SET
        inner_file_count    = inner_file_count + 1,
        inner_datem         = greatest(inner_datem, in_datec)
    WHERE
        treepath @> subpath(v_directory.treepath, 0, nlevel(v_directory.treepath) - 1);
END;

$__$ LANGUAGE plpgsql VOLATILE COST 1000;
