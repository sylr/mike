-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.inode_pkey SET (fillfactor = 95);

CREATE INDEX inode_id_inode_parent_btree_idx    ON mike.inode   USING btree (id_inode_parent)       WITH (fillfactor = 95);
CREATE INDEX inode_id_user_btree_idx            ON mike.inode   USING btree (id_user)               WITH (fillfactor = 95);
CREATE INDEX inode_id_mimetype_btree_idx        ON mike.inode   USING btree (id_user, id_mimetype)  WITH (fillfactor = 95);
CREATE INDEX inode_name_btree_idx               ON mike.inode   USING btree (id_user, name)         WITH (fillfactor = 95);
CREATE INDEX inode_treepath_gist_idx            ON mike.inode   USING gist  (treepath)              WITH (fillfactor = 95);

#ifdef INODE_RAND_COLUMN
CREATE INDEX inode_rand_btree_idx               ON mike.inode   USING btree (rand)                  WITH (fillfactor = 95);
#endif /* INODE_RAND_COLUMN */

#ifndef INODE_RAND_COLUMN
CLUSTER mike.inode USING inode_id_user_btree_idx;
#else
CLUSTER mike.inode USING inode_rand_btree_idx;
#endif /* INODE_RAND_COLUMN */
