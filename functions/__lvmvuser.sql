-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 11/06/2011
-- copyright: All rights reserved

-- Version: MIKE_VERSION

CREATE OR REPLACE FUNCTION mike.__lvmvuser(
    in_id_user      integer,
    in_lv_name      text
) RETURNS void AS $__$

DECLARE
    v_user          mike.user%rowtype;
    v_lv_target     mike.lv%rowtype;
    v_lv_src_name   text;
BEGIN
    -- source lv name
    SELECT lv INTO v_lv_src_name FROM mike.user WHERE id_user = in_id_user FOR UPDATE;

    -- check target lv existence
    SELECT * INTO v_lv_target FROM mike.lv WHERE name = in_lv_name;
    IF NOT FOUND THEN RAISE EXCEPTION 'lv ''%'' does not exist', in_lv_name; END IF;

    -- check user lv
    SELECT * INTO v_user FROM mike.user WHERE id_user = in_id_user;
    IF NOT FOUND THEN RAISE EXCEPTION 'id_user ''%'' does not exist', in_id_user; END IF;

    IF v_user.lv = in_lv_name THEN
        RAISE EXCEPTION 'id_user ''%'' already in lv ''%''', in_id_user, in_lv_name;
    END IF;

    -- caching user data
    CREATE TEMPORARY TABLE lvmvuser_directory       ON COMMIT DROP AS SELECT * FROM mike.directory      WHERE id_user = in_id_user FOR UPDATE;
    CREATE TEMPORARY TABLE lvmvuser_file            ON COMMIT DROP AS SELECT * FROM mike.file           WHERE id_user = in_id_user FOR UPDATE;
    CREATE TEMPORARY TABLE lvmvuser_as_file_xfile   ON COMMIT DROP AS SELECT * FROM mike.as_file_xfile  WHERE id_user = in_id_user FOR UPDATE;

    -- deleting user data in source lv
    DELETE FROM mike.as_file_xfile  WHERE id_user = in_id_user;
    DELETE FROM mike.file           WHERE id_user = in_id_user;
    DELETE FROM mike.directory      WHERE id_user = in_id_user;

    -- updating user and lv
    UPDATE mike.user SET
        lv      = in_lv_name,
        mtime   = now()
    WHERE id_user = in_id_user;

    UPDATE mike.lv SET
        users   = mike.__array_unset(users, in_id_user),
        mtime   = now()
    WHERE name = v_lv_src_name;

    UPDATE mike.lv SET
        users   = array_append(users, in_id_user)::integer[],
        mtime   = now()
    WHERE name = v_lv_target.name;

    -- inserting data
    EXECUTE $$
        INSERT INTO $$ || ('mike.directory_' || in_lv_name)::regclass || $$
            SELECT * FROM lvmvuser_directory
            ORDER BY nlevel(treepath) ASC, id_inode_parent;
    $$;

    EXECUTE $$
        INSERT INTO $$ || ('mike.file_' || in_lv_name)::regclass || $$
            SELECT * FROM lvmvuser_file
            ORDER BY nlevel(treepath) ASC, id_inode_parent;
    $$;

    EXECUTE $$
        INSERT INTO $$ || ('mike.as_file_xfile_' || in_lv_name)::regclass || $$
            SELECT * FROM lvmvuser_as_file_xfile
            ORDER BY id_inode;
    $$;
END;

$__$ LANGUAGE plpgsql;
