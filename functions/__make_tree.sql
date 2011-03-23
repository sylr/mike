-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__make_tree(
    in_id_user          integer,
    in_dirs_by_level    integer[] DEFAULT ARRAY[5, 5, 5],
    in_files_by_level   integer[] DEFAULT ARRAY[5, 5, 5],
    in_versioning       boolean   DEFAULT true
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
    v_mimetypes         text[] := ARRAY['text/plain', 'image/jpeg', 'audio/x-flac', 'text/x-shellscript', 'video/mkv'];
    v_extension         text;
    v_extensions        text[] := ARRAY['txt', 'jpg', 'flac', 'sh', 'mkv'];
BEGIN
    IF array_length(in_dirs_by_level, 1) != array_length(in_files_by_level, 1) AND
       array_length(in_dirs_by_level, 1)  < array_length(in_files_by_level, 1) THEN
        RAISE EXCEPTION 'dir level must be inferior or equal to file level';
    END IF;

    RAISE LOG '-- id_user : % -------------------------', in_id_user;

    SELECT id_inode INTO v_id_root_directory FROM mike.directory WHERE id_user = in_id_user AND id_inode = id_inode_parent;

    IF NOT FOUND THEN
        SELECT mike.mkdir(in_id_user, 'root') INTO v_id_root_directory;
    END IF;

    FOR v_i IN SELECT generate_series(1, array_length(in_dirs_by_level, 1)) LOOP
        RAISE LOG 'v_i  = %', v_i;

        FOR v_ij IN SELECT id_inode FROM mike.directory WHERE id_user = in_id_user AND nlevel(treepath) = v_i LOOP
            RAISE LOG 'v_ij = %', v_ij;

            FOR v_ijk IN SELECT generate_series(0, in_dirs_by_level[v_i] - 1) LOOP
                -- mkdir
                SELECT out_id_inode INTO v_id_inode_d FROM mike.mkdir(in_id_user, v_ij, 'dir-n' || v_i::text || '-' || v_ijk::text);

                -- make dir files
                IF in_files_by_level[v_i] IS NOT NULL AND
                   in_files_by_level[v_i] > 0 THEN
                    FOR v_ijkl IN SELECT generate_series(0, in_files_by_level[v_i] - 1) LOOP
                        v_rand      := (random() * 1000)::int;
                        v_size      := (random() * 1024 * 1024 * 17)::bigint;
                        v_mimetype  := out_id_mimetype FROM mike.__get_id_mimetype(v_mimetypes[v_rand  % 5 + 1]);
                        v_extension := v_extensions[v_rand  % 5 + 1];
                        v_md5       := encode(digest(random()::text, 'md5'), 'hex');
                        v_sha1      := encode(digest(random()::text, 'sha1'), 'hex');

                        SELECT out_id_inode INTO v_id_inode_f   FROM mike.touch(in_id_user, v_id_inode_d, 'file-n' || v_i::text || '-' || v_ijkl::text || '.' || v_extension);
                        SELECT out_id_xfile INTO v_id_xfile     FROM mike.xtouch(v_size, v_mimetype, v_md5, v_sha1);
                        PERFORM mike.xlink(v_id_inode_f, v_id_xfile);

                        IF in_versioning AND random()::integer = 1 THEN
                            v_size      := (random() * 1024 * 1024 * 17)::bigint;
                            v_md5       := encode(digest(random()::text, 'md5'), 'hex');
                            v_sha1      := encode(digest(random()::text, 'sha1'), 'hex');

                            SELECT out_id_xfile INTO v_id_xfile     FROM mike.xtouch(v_size, v_mimetype, v_md5, v_sha1);
                            PERFORM mike.xlink(v_id_inode_f, v_id_xfile);
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.__make_tree(
    in_id_user          integer,
    in_dirs_by_level    int[],
    in_files_by_level   int[],
    in_versioning       boolean
) IS 'create a tree on several level';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.__make_tree(
    in_id_user          integer,
    in_nb_level         integer DEFAULT 2,
    in_inode_by_level   integer DEFAULT 10,
    in_versioning       boolean DEFAULT true
) RETURNS void AS $__$

SELECT * FROM mike.__make_tree(
    $1,
    array_fill($3, ARRAY[$2]),
    array_fill($3, ARRAY[$2])
);

$__$ LANGUAGE SQL VOLATILE;

COMMENT ON FUNCTION mike.__make_tree(
    in_id_user          integer,
    in_dirs_by_level    int,
    in_files_by_level   int,
    in_versioning       boolean
) IS 'create a tree on several level with a fixed length of inodes by level';
