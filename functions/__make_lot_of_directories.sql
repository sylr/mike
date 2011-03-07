-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION __make_lot_of_directories(
    in_id_user      integer,
    in_level        integer DEFAULT 2,
    in_nb_by_level  integer DEFAULT 10
) RETURNS void AS $__$

DECLARE
    v_id_root_directory bigint;
    v_id_directory      bigint;
    v_start_level       bigint;
    v_i                 bigint;
    v_ij                bigint;
    v_ijk               bigint;
BEGIN
    SELECT id_inode INTO v_id_root_directory FROM directory WHERE id_user = in_id_user AND id_inode = id_inode_parent;

    IF NOT FOUND THEN
        SELECT mkdir(in_id_user, 'root') INTO v_id_root_directory;
    END IF;

    SELECT nlevel(treepath) INTO v_start_level FROM directory WHERE id_user = in_id_user ORDER BY treepath DESC LIMIT 1;

    FOR v_i IN SELECT generate_series(v_start_level, in_level - 1) LOOP
        RAISE NOTICE 'v_i = %', v_i;

        FOR v_ij IN SELECT id_inode FROM directory WHERE id_user = in_id_user AND nlevel(treepath) = v_i LOOP
            RAISE NOTICE 'v_ij = %', v_ij;

            FOR v_ijk IN SELECT generate_series(0, in_nb_by_level - 1) LOOP
                PERFORM mkdir(in_id_user, v_ij, v_ijk::text);
            END LOOP;
        END LOOP;
    END LOOP;
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.__make_lot_of_directories(
    in_id_user      integer,
    in_level        integer,
    in_nb_by_level  integer
) IS 'create a tree on several level';
