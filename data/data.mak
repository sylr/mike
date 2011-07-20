# Mike's Makefile
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 13/11/2010
# copyright: All rights reserved

DATABASE_DATA   = mimetypes.sql
DATABASE_DATA  += conf.sql
ifeq ($(LVM_SUPPORT),yes)
DATABASE_DATA  += lv.sql
endif
ifeq ($(DEFAULT_USERS),yes)
DATABASE_DATA  += users.sql
endif
