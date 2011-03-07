-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.directory_pkey SET (fillfactor = 95);

CREATE INDEX directory_id_inode_parent_btree_idx    ON mike.directory   USING btree (id_inode_parent)   WITH (fillfactor = 95);
CREATE INDEX directory_id_user_btree_idx            ON mike.directory   USING btree (id_user)           WITH (fillfactor = 95);
CREATE INDEX directory_name_btree_idx               ON mike.directory   USING btree (name)              WITH (fillfactor = 95);
CREATE INDEX directory_name_natsort_btree_idx       ON mike.directory   USING btree (__natsort(name))   WITH (fillfactor = 95);
CREATE INDEX directory_ctime_btree_idx              ON mike.directory   USING btree (ctime)             WITH (fillfactor = 95);
CREATE INDEX directory_treepath_gist_idx            ON mike.directory   USING gist  (treepath)          WITH (fillfactor = 95);

CLUSTER mike.directory USING directory_id_user_btree_idx;
