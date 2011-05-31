-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/12/2010
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__get_id_mimetype(
    IN  in_mimetype         text,
    OUT out_id_mimetype     smallint
) AS $__$

-- Version: MIKE_VERSION

BEGIN
    SELECT id_mimetype INTO out_id_mimetype FROM mimetype WHERE lower(mimetype) = lower(btrim(in_mimetype));

    IF NOT FOUND THEN
        SELECT nextval('mimetype_id_mimetype_seq'::regclass) INTO out_id_mimetype;

        INSERT INTO mimetype (
            id_mimetype,
            mimetype
        )
        VALUES (
            out_id_mimetype,
            lower(btrim(in_mimetype))
        );
    END IF;
END;

$__$ LANGUAGE plpgsql VOLATILE COST 10;

--------------------------------------------------------------------------------

CREATE OR REPLACE FUNCTION mike.__get_id_mimetype_stable(
    IN  in_mimetype         text,
    OUT out_id_mimetype     smallint
) AS $__$

-- Version: MIKE_VERSION

BEGIN
    SELECT id_mimetype INTO out_id_mimetype FROM mimetype WHERE mimetype = lower(btrim(in_mimetype));
END;

$__$ LANGUAGE plpgsql STABLE COST 10;
