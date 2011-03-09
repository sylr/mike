-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION __make_tree(
    in_id_user      integer,
    in_level        integer DEFAULT 2,
    in_nb_by_level  integer DEFAULT 10
) RETURNS void AS $__$

DECLARE
    v_id_inode_d        bigint;
    v_id_inode_f        bigint;
    v_id_xfile          bigint;
    v_id_root_directory bigint;
    v_id_directory      bigint;
    v_start_level       bigint;
    v_i                 bigint;
    v_ij                bigint;
    v_ijk               bigint;
    v_ijkl              bigint;
    v_size              bigint;
    v_md5               text;
    v_sha1              text;
    v_rand              integer;
    v_mimetype          smallint;
    v_mimetypes         text[] := ARRAY['text/plain', 'image/jpg', 'audio/x-flac', 'text/x-shellscript', 'video/mkv'];
    v_extension         text;
    v_extensions        text[] := ARRAY['txt', 'jpg', 'flac', 'sh', 'mkv'];
BEGIN
    SELECT id_inode INTO v_id_root_directory FROM mike.directory WHERE id_user = in_id_user AND id_inode = id_inode_parent;

    IF NOT FOUND THEN
        SELECT mike.mkdir(in_id_user, 'root') INTO v_id_root_directory;
    END IF;

    SELECT nlevel(treepath) INTO v_start_level FROM mike.directory WHERE id_user = in_id_user ORDER BY treepath DESC LIMIT 1;

    FOR v_i IN SELECT generate_series(v_start_level, in_level - 1) LOOP
        RAISE NOTICE 'v_i = %', v_i;

        FOR v_ij IN SELECT id_inode FROM mike.directory WHERE id_user = in_id_user AND nlevel(treepath) = v_i LOOP
            RAISE NOTICE 'v_ij = %', v_ij;

            FOR v_ijk IN SELECT generate_series(0, in_nb_by_level - 1) LOOP
                -- mkdir
                SELECT out_id_inode INTO v_id_inode_d FROM mike.mkdir(in_id_user, v_ij, 'dir-n' || v_i::text || '-' || v_ijk::text);

                -- make dir files
                FOR v_ijkl IN SELECT generate_series(0, in_nb_by_level - 1) LOOP
                    v_rand      := (random() * 1000)::int;
                    v_size      := (random() * 10000)::bigint;
                    v_mimetype  := out_id_mimetype FROM mike.__get_id_mimetype(v_mimetypes[v_rand  % 4 + 1]);
                    v_extension := v_extensions[v_rand  % 4 + 1];
                    v_md5       := encode(digest(random()::text, 'md5'), 'hex');
                    v_sha1      := encode(digest(random()::text, 'sha1'), 'hex');

                    SELECT out_id_inode INTO v_id_inode_f   FROM mike.touch(in_id_user, v_id_inode_d, 'file-n' || v_i::text || '-' || v_ijkl::text || '.' || v_extension);
                    SELECT out_id_xfile INTO v_id_xfile     FROM mike.xtouch(v_size, v_mimetype, v_md5, v_sha1);
                    PERFORM mike.xlink(v_id_inode_f, v_id_xfile);
                END LOOP;
            END LOOP;
        END LOOP;
    END LOOP;
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.__make_tree(
    in_id_user      integer,
    in_level        integer,
    in_nb_by_level  integer
) IS 'create a tree on several level';
