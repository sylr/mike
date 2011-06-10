-- Mike's Trigger
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 26/07/2010
-- copyright: All rights reserved

#ifdef LVM_SUPPORT
CREATE TRIGGER file_before_insert BEFORE INSERT ON mike.file FOR EACH ROW EXECUTE PROCEDURE mike.__trigger_file_before_insert();
#endif /* LVM_SUPPORT */
