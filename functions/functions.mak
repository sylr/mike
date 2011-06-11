# Mike's Makefile
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 13/11/2010
# copyright: All rights reserved

DATABASE_FUNCTIONS   = __array_unset.sql
DATABASE_FUNCTIONS  += __check_order_by_cond.sql
DATABASE_FUNCTIONS  += __get_conf.sql
DATABASE_FUNCTIONS  += __set_conf.sql
DATABASE_FUNCTIONS  += __get_id_mimetype.sql
DATABASE_FUNCTIONS  += __get_mimetype.sql
DATABASE_FUNCTIONS  += __get_random_volume.sql
DATABASE_FUNCTIONS  += __mod_cons_hash.sql
DATABASE_FUNCTIONS  += __make_lot_of_directories.sql
DATABASE_FUNCTIONS  += __natsort.pl
DATABASE_FUNCTIONS  += __natsort.sql
DATABASE_FUNCTIONS  += __perform.sql
DATABASE_FUNCTIONS  += __fsck.sql
DATABASE_FUNCTIONS  += __stream.sql
ifeq ($(LVM_SUPPORT),yes)
DATABASE_FUNCTIONS  += __get_least_used_lv.sql
DATABASE_FUNCTIONS  += __lvcreate.sql
DATABASE_FUNCTIONS  += __lvmvuser.sql
DATABASE_FUNCTIONS  += __lvusers.sql
DATABASE_FUNCTIONS  += __trigger_as_file_xfile_before_insert.sql
DATABASE_FUNCTIONS  += __trigger_directory_before_insert.sql
DATABASE_FUNCTIONS  += __trigger_file_before_insert.sql
endif
DATABASE_FUNCTIONS  += adduser.sql
DATABASE_FUNCTIONS  += cpdir.sql
DATABASE_FUNCTIONS  += ls.sql
DATABASE_FUNCTIONS  += mkdir.sql
DATABASE_FUNCTIONS  += mvdir.sql
DATABASE_FUNCTIONS  += rename.sql
DATABASE_FUNCTIONS  += rmdir.sql
DATABASE_FUNCTIONS  += touch.sql
DATABASE_FUNCTIONS  += xtouch.sql
DATABASE_FUNCTIONS  += xlink.sql
DATABASE_FUNCTIONS  += stat.sql
DATABASE_FUNCTIONS  += statd.sql
DATABASE_FUNCTIONS  += statf.sql
DATABASE_FUNCTIONS  += xstat.sql
DATABASE_FUNCTIONS  += xstatd.sql
DATABASE_FUNCTIONS  += xstatf.sql
