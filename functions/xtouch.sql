-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 05/02/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.xtouch(
    IN  in_size             bigint,
    IN  in_id_mimetype      integer,
    IN  in_md5              text,
    IN  in_sha1             text,
    OUT out_id_xfile        bigint,
    OUT out_id_volume       smallint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.xtouch(
    IN  in_size             bigint,
    IN  in_id_mimetype      integer,
    IN  in_md5              text DEFAULT NULL,
    IN  in_sha1             text DEFAULT NULL,
    OUT out_id_xfile        bigint,
    OUT out_id_volume       smallint
) AS $__$

BEGIN
    -- select id_volume
    SELECT mike.__get_least_used_active_volume() INTO out_id_volume;

    -- select id_inode
    SELECT nextval('xfile_id_xfile_seq'::regclass) INTO out_id_xfile;

    -- insert into mike.xfile
    INSERT INTO mike.xfile (
        id_xfile,
        id_mimetype,
        id_volume,
        size,
        md5,
        sha1
    )
    VALUES (
        out_id_xfile,
        in_id_mimetype,
        out_id_volume,
        in_size,
        in_md5,
        in_sha1
    );

    -- update volume
    UPDATE mike.volume SET used_size = used_size + in_size WHERE id_volume = out_id_volume;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 10;
