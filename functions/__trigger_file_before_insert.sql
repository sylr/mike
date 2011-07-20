-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__trigger_file_before_insert(
) RETURNS trigger AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_lv    text;
BEGIN
    SELECT lv INTO v_lv FROM mike.user WHERE id_user = NEW.id_user;

    EXECUTE $$
        INSERT INTO $$ || ('mike.file_' || v_lv)::regclass || $$ VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10,
#ifdef INODE_RAND_COLUMN
#ifndef NO_ATIME
            $11, $12, $13, $14
#else
            $11, $12, $13
#endif /* NO_ATIME */
#else
#ifndef NO_ATIME
            $11, $12
#else
            $11
#endif /* NO_ATIME */
#endif /* INODE_RAND_COLUMN */
        )
    $$ USING
        NEW.id_inode,
        NEW.id_inode_parent,
        NEW.id_user,
        NEW.state,
        NEW.id_mimetype,
        NEW.name,
        NEW.path,
        NEW.treepath,
        NEW.ctime,
        NEW.mtime,
#ifdef INODE_RAND_COLUMN
        NEW.rand,
#endif /* INODE_RAND_COLUMN */
        NEW.size,
#ifndef NO_ATIME
        NEW.versioning_size,
        NEW.atime;
#else
        NEW.atime;
#endif /* NO_ATIME */

    RETURN null;
END;

$__$ LANGUAGE plpgsql;
