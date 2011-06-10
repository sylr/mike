-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__trigger_as_file_xfile_before_insert(
) RETURNS trigger AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_lv    text;
BEGIN
    SELECT lv INTO v_lv FROM mike.user WHERE id_user = NEW.id_user;

    EXECUTE $$
        INSERT INTO $$ || ('mike.as_file_xfile_' || v_lv)::regclass || $$ VALUES (
            $1, $2, $3, $4
        )
    $$ USING
        NEW.id_user,
        NEW.id_inode,
        NEW.id_xfile,
        NEW.ctime;

    RETURN null;
END;

$__$ LANGUAGE plpgsql;
