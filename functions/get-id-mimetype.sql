
CREATE OR REPLACE FUNCTION mike.get_id_mimetype(
    IN  in_mimetype         text,
    OUT out_id_mimetype     smallint
) RETURNS smallint AS $__$

BEGIN
    SELECT id_mimetype INTO out_id_mimetype FROM mimetype WHERE lower(mimetype) = lower(in_mimetype);

    IF NOT FOUND THEN
        SELECT nextval('inode_id_inode_seq'::regclass) INTO out_id_mimetype;

        INSERT INTO mimetype (
            id_mimetype,
            mimetype
        )
        VALUES (
            out_id_mimetype,
            lower(in_mimetype)
        );
    END IF;
END;

$__$ LANGUAGE plpgsql VOLATILE;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.get_id_mimetype_stable(
    IN  in_mimetype         text,
    OUT out_id_mimetype     smallint
) RETURNS smallint AS $__$

BEGIN
    SELECT id_mimetype INTO out_id_mimetype FROM mimetype WHERE mimetype = lower(in_mimetype);
END;

$__$ LANGUAGE plpgsql STABLE;
