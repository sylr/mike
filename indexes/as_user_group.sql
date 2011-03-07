-- Mike's Index
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 07/03/2011
-- copyright: All rights reserved

CREATE INDEX as_user_group_id_user_btree_idx    ON mike.as_user_group   USING btree (id_user);
CREATE INDEX as_user_group_id_group_btree_idx   ON mike.as_user_group   USING btree (id_group);
