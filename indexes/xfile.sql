-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

CREATE INDEX xfile_id_mimetype_btree_idx    ON mike.xfile   USING btree (id_mimetype)   WITH (fillfactor = 95);
