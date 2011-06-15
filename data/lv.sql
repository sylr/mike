-- Mike's LVM
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/03/2011
-- copyright: All rights reserved

#ifdef LVM_SUPPORT
SELECT mike.__lvcreate('lv_' || generate_series) FROM generate_series(1, LVM_DEFAULT_LV_NUMBER);
#endif
