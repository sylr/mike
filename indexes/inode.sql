-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.inode_pkey SET (fillfactor = 95);

CREATE INDEX inode_id_inode_parent_btree_idx    ON mike.inode   USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX inode_id_user_btree_idx            ON mike.inode   USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX inode_id_mimetype_btree_idx        ON mike.inode   USING btree (id_mimetype)       WITH (fillfactor = 95);
CREATE INDEX inode_name_btree_idx               ON mike.inode   USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX inode_name_natsort_btree_idx       ON mike.inode   USING btree (__natsort(name))   WITH (fillfactor = 95);
CREATE INDEX inode_treepath_gist_idx            ON mike.inode   USING gist  (treepath)          WITH (fillfactor = 95);

CLUSTER mike.inode USING inode_id_user_btree_idx;
