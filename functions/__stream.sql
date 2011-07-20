-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

DROP TYPE IF EXISTS mike.__stream_t CASCADE;

CREATE TYPE mike.__stream_t AS (
    id_user         integer,
    directories     integer,
    files           integer,
    xfiles          integer
);

CREATE OR REPLACE FUNCTION mike.__stream(
    in_id_user          integer,
    in_dirs_by_level    integer[] DEFAULT ARRAY[5, 5, 5],
    in_files_by_level   integer[] DEFAULT ARRAY[5, 5, 5],
    in_versioning       boolean   DEFAULT true
) RETURNS mike.__stream_t AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_id_inode_d        bigint;
    v_id_inode_f        bigint;
    v_id_xfile          bigint;
    v_id_root_directory bigint;
    v_id_directory      bigint;
    v_i                 bigint;
    v_ij                bigint;
    v_ijk               bigint;
    v_ijkl              bigint;
    v_size              bigint;
    v_md5               text;
    v_sha1              text;
    v_rand              integer;
    v_rand_f            float;
    v_mimetype          smallint;
    v_extension         text;
    v_return            mike.__stream_t;
    v_mimetypes         text[] := ARRAY['text/plain', 'text/x-perl', 'text/x-shellscript'] ||
                                  ARRAY['image/jpeg', 'image/png', 'image/tiff', 'image/svg+xml'] ||
                                  ARRAY['audio/x-flac', 'audio/mpeg', 'audio/x-wav'] ||
                                  ARRAY['video/x-matroska', 'video/x-flv', 'video/x-msvideo'];
    v_extensions        text[] := ARRAY['txt', 'pl', 'sh'] ||
                                  ARRAY['jpg', 'png', 'tiff', 'svg'] ||
                                  ARRAY['flac', 'mp3', 'wav'] ||
                                  ARRAY['mkv', 'flv', 'avi'];
BEGIN
    IF array_length(in_dirs_by_level, 1) != array_length(in_files_by_level, 1) AND
       array_length(in_dirs_by_level, 1)  < array_length(in_files_by_level, 1) THEN
        RAISE EXCEPTION 'dir level number must be superior or equal to file level number';
    END IF;

    v_return.id_user        := in_id_user;
    v_return.directories    := 0;
    v_return.files          := 0;
    v_return.xfiles         := 0;

    RAISE DEBUG '-- id_user : % -------------------------', in_id_user;

    SELECT id_inode INTO v_id_root_directory FROM mike.directory WHERE id_user = in_id_user AND id_inode = id_inode_parent AND state = 0;

    IF NOT FOUND THEN
        SELECT mike.mkdir(in_id_user, 'root') INTO v_id_root_directory;
        v_return.directories := v_return.directories + 1;
    END IF;

    FOR v_i IN SELECT generate_series(1, array_length(in_dirs_by_level, 1)) LOOP
        RAISE DEBUG 'v_i  = %', v_i;

        FOR v_ij IN SELECT id_inode FROM mike.directory WHERE id_user = in_id_user AND nlevel(treepath) = v_i AND state = 0 LOOP
            RAISE DEBUG 'v_ij = %', v_ij;

            FOR v_ijk IN SELECT generate_series(0, in_dirs_by_level[v_i] - 1) LOOP
                -- mkdir
                SELECT out_id_inode INTO v_id_inode_d FROM mike.mkdir(in_id_user, v_ij, 'directory-level-' || v_i::text || '-' || v_ijk::text);
                v_return.directories := v_return.directories + 1;

                -- make dir files
                IF in_files_by_level[v_i] IS NOT NULL AND
                   in_files_by_level[v_i] > 0 THEN
                    FOR v_ijkl IN SELECT generate_series(0, in_files_by_level[v_i] - 1) LOOP
                        v_rand_f    := random();
                        v_rand      := (v_rand_f * 1000)::int;
                        v_size      := (v_rand_f * 1024 * 1024 * 17)::bigint;
                        v_mimetype  := out_id_mimetype FROM mike.__get_id_mimetype(v_mimetypes[v_rand % array_length(v_mimetypes, 1) + 1]);
                        v_extension := v_extensions[v_rand  % array_length(v_mimetypes, 1) + 1];
                        v_md5       := encode(digest(v_rand_f::text, 'md5'), 'hex');
                        v_sha1      := encode(digest(v_rand_f::text, 'sha1'), 'hex');

                        -- touch and xtouch
                        SELECT out_id_inode INTO v_id_inode_f   FROM mike.touch(in_id_user, v_id_inode_d, 'file-level-' || (v_i + 1)::text || '-' || v_ijkl::text || '.' || v_extension);
                        SELECT out_id_xfile INTO v_id_xfile     FROM mike.xtouch(v_size, v_mimetype, v_md5, v_sha1);
                        PERFORM mike.xlink(in_id_user, v_id_inode_f, v_id_xfile);

                        v_return.files  := v_return.files + 1;
                        v_return.xfiles := v_return.xfiles + 1;

                        -- versioning randomly
                        IF in_versioning AND v_rand_f::integer = 1 THEN
                            v_rand_f    := random();
                            v_size      := (v_rand_f * 1024 * 1024 * 17)::bigint;
                            v_md5       := encode(digest(v_rand_f::text, 'md5'), 'hex');
                            v_sha1      := encode(digest(v_rand_f::text, 'sha1'), 'hex');

                            SELECT out_id_xfile INTO v_id_xfile FROM mike.xtouch(v_size, v_mimetype, v_md5, v_sha1);
                            PERFORM mike.xlink(in_id_user, v_id_inode_f, v_id_xfile);

                            v_return.xfiles := v_return.xfiles + 1;
                        END IF;
                    END LOOP;
                END IF;
            END LOOP;
        END LOOP;
    END LOOP;

    RETURN v_return;
END;

$__$ LANGUAGE plpgsql VOLATILE;

COMMENT ON FUNCTION mike.__stream(
    in_id_user          integer,
    in_dirs_by_level    int[],
    in_files_by_level   int[],
    in_versioning       boolean
) IS 'create a tree on several level';

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.__stream(
    in_id_user          integer,
    in_nb_level         integer DEFAULT 2,
    in_inode_by_level   integer DEFAULT 10,
    in_versioning       boolean DEFAULT true
) RETURNS mike.__stream_t AS $__$

-- Version: MIKE_VERSION

SELECT * FROM mike.__stream(
    $1,
    array_fill($3, ARRAY[$2]),
    array_fill($3, ARRAY[$2])
);

$__$ LANGUAGE SQL VOLATILE;

COMMENT ON FUNCTION mike.__stream(
    in_id_user          integer,
    in_dirs_by_level    int,
    in_files_by_level   int,
    in_versioning       boolean
) IS 'create a tree on several level with a fixed length of inodes by level';
