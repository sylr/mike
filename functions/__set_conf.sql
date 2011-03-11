-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.__set_conf(
    IN  in_key      text,
    IN  in_value    text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__set_conf(
    IN  in_key      text,
    IN  in_value    text
) RETURNS void AS $__$

BEGIN
    PERFORM * FROM mike.conf WHERE key = in_key;

    IF FOUND THEN
        UPDATE mike.conf SET value = in_value, mtime = now() WHERE key = in_key;
    ELSE
        INSERT INTO mike.conf (key, value) VALUES (in_key, in_value);
    END IF;
END

$__$ LANGUAGE plpgsql VOLATILE COST 10;
