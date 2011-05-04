-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.adduser(
    IN in_id_user_sso       text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.adduser(
    IN in_id_user_sso       text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) AS $__$

DECLARE
    v_id_user       integer;
BEGIN
    -- sso unicity check
    PERFORM id_user FROM mike.user WHERE id_user_sso = in_id_user_sso;
    IF FOUND THEN RAISE EXCEPTION 'id_user_sso ''%'' already exists', in_id_user_sso; END IF;

    -- select id_inode
    SELECT nextval('user_id_user_seq'::regclass) INTO out_id_user;

    -- insert
    INSERT INTO mike.user (
        id_user,
        id_user_sso,
        nickname,
        state
    )
    VALUES (
        out_id_user,
        in_id_user_sso,
        in_nickname,
        in_state
    );
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.adduser(
    IN in_id_user_sso       text,
    IN in_nickname          text,
    IN in_state             smallint,
    OUT out_id_user         integer
) IS 'this function add a user';
