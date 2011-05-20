-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

ALTER INDEX mike.file_pkey SET (fillfactor = 95);

CREATE INDEX file_id_inode_parent_alive_btree_idx   ON mike.file    USING btree (id_inode_parent)       WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX file_id_inode_parent_dead_btree_idx    ON mike.file    USING btree (id_inode_parent)       WITH (fillfactor = 99)  WHERE state > 0;
CREATE INDEX file_id_user_alive_btree_idx           ON mike.file    USING btree (id_user)               WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX file_id_user_dead_btree_idx            ON mike.file    USING btree (id_user)               WITH (fillfactor = 95)  WHERE state > 0;
CREATE INDEX file_id_mimetype_btree_idx             ON mike.file    USING btree (id_mimetype)           WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX file_ctime_btree_idx                   ON mike.file    USING btree (ctime)                 WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX file_treepath_alive_gist_idx           ON mike.file    USING gist  (treepath)              WITH (fillfactor = 95)  WHERE state = 0;
CREATE INDEX file_treepath_dead_gist_idx            ON mike.file    USING gist  (treepath)              WITH (fillfactor = 99)  WHERE state > 0;

#ifdef INODE_RAND_COLUMN
CREATE INDEX file_rand_btree_idx                    ON mike.file    USING btree (rand)                  WITH (fillfactor = 95);
CLUSTER mike.file USING file_rand_btree_idx;
#endif /* INODE_RAND_COLUMN */
