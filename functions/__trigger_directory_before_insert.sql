-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/06/2011
-- copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__trigger_directory_before_insert(
) RETURNS trigger AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_lv    text;
BEGIN
    SELECT lv INTO v_lv FROM mike.user WHERE id_user = NEW.id_user;

    EXECUTE $$
        INSERT INTO $$ || ('mike.directory_' || v_lv)::regclass || $$ VALUES (
            $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
#ifndef INODE_RAND_COLUMN
            $12, $13, $14, $15, $16, $17, $18, $19
#else
            $12, $13, $14, $15, $16, $17, $18, $19, $20
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
        NEW.versioning_size,
        NEW.inner_mtime,
        NEW.inner_size,
        NEW.inner_versioning_size,
        NEW.dir_count,
        NEW.inner_dir_count,
        NEW.file_count,
        NEW.inner_file_count;

    RETURN null;
END;

$__$ LANGUAGE plpgsql;
