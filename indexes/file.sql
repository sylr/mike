-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.file_pkey SET (fillfactor = 95);

CREATE INDEX file_id_inode_parent_btree_idx     ON mike.file    USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX file_id_user_btree_idx             ON mike.file    USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX file_id_mimetype_btree_idx         ON mike.file    USING btree (id_mimetype)       WITH (fillfactor = 95);
CREATE INDEX file_name_btree_idx                ON mike.file    USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX file_ctime_btree_idx               ON mike.file    USING btree (ctime)             WITH (fillfactor = 95);
CREATE INDEX file_treepath_gist_idx             ON mike.file    USING gist  (treepath)          WITH (fillfactor = 95);
#ifdef INODE_RAND_COLUMN
CREATE INDEX file_rand_btree_idx                ON mike.file    USING btree (rand)              WITH (fillfactor = 95);
#endif /* INODE_RAND_COLUMN */

#ifndef INODE_RAND_COLUMN
CLUSTER mike.file USING file_id_inode_parent_btree_idx;
#else
CLUSTER mike.file USING file_rand_btree_idx;
#endif /* INODE_RAND_COLUMN */
