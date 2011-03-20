-- Mike's Configuration
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/03/2011
-- copyright: All rights reserved

#ifdef TREE_MAX_DEPTH
SELECT * FROM mike.__set_conf('tree_max_depth', TREE_MAX_DEPTH::text);
ALTER TABLE mike.inode DROP CONSTRAINT inode_treepath_check;
ALTER TABLE mike.inode ADD  CONSTRAINT inode_treepath_check CHECK (nlevel(treepath) <= mike.__get_conf_int('tree_max_depth'));
#endif
