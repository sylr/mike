-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.inode_pkey SET (fillfactor = 95);

CREATE INDEX inode_id_inode_parent_btree_idx    ON mike.inode   USING btree (id_inode_parent)       WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX inode_id_user_btree_idx            ON mike.inode   USING btree (id_user)               WITH (fillfactor = 95)  WHERE state = 0;

#ifdef INODE_RAND_COLUMN
CREATE INDEX inode_rand_btree_idx               ON mike.inode   USING btree (rand)                  WITH (fillfactor = 95);
CLUSTER mike.inode USING inode_rand_btree_idx;
#endif /* INODE_RAND_COLUMN */
