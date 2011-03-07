-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

CREATE INDEX group_id_user_btree_idx ON mike.group USING btree (id_user) WITH (fillfactor = 95);
