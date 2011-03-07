-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

CREATE INDEX xfile_sha1_btree_idx   ON mike.xfile   USING btree (sha1)  WITH (fillfactor = 95);
CREATE INDEX xfile_md5_btree_idx    ON mike.xfile   USING btree (md5)   WITH (fillfactor = 95);
