-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

CREATE INDEX as_file_xfile_id_inode_btree_idx ON mike.as_file_xfile USING btree (id_inode) WITH (fillfactor = 95);

CLUSTER mike.as_file_xfile USING as_file_xfile_id_inode_btree_idx;
