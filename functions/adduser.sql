-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.adduser(
    IN in_id_sso            text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.adduser(
    IN in_id_sso            text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_id_user       integer;
    v_lv_name       text;
BEGIN
    -- sso unicity check
    PERFORM id_user FROM mike.user WHERE id_sso = in_id_sso;
    IF FOUND THEN RAISE EXCEPTION 'id_sso ''%'' already exists', in_id_sso; END IF;

    -- select id_inode
    SELECT nextval('user_id_user_seq'::regclass) INTO out_id_user;

#ifdef LVM_SUPPORT
    -- select lv
    SELECT mike.__get_least_used_lv() INTO v_lv_name;
#endif /* LVM_SUPPORT */

    -- insert
    INSERT INTO mike.user (
        id_user,
        id_sso,
        nickname,
#ifdef LVM_SUPPORT
        lv,
#endif /* LVM_SUPPORT */
        state
    )
    VALUES (
        out_id_user,
        in_id_sso,
        in_nickname,
#ifdef LVM_SUPPORT
        v_lv_name,
#endif /* LVM_SUPPORT */
        in_state
    );

#ifdef LVM_SUPPORT
    -- add user to lv
    UPDATE mike.lv SET
        users = array_append(users, out_id_user)::integer[],
        mtime = now()
    WHERE
        name = v_lv_name;
#endif /* LVM_SUPPORT */
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.adduser(
    IN in_id_sso            text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) IS 'this function add a user';
