# Mike's Makefile
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 22/04/2011
# copyright: All rights reserved

DATABASE_C_FUNCTIONS    = mike.c
DATABASE_C_FUNCTIONS   += __natsort.c
ifneq ($(X86_64),yes)
DATABASE_C_FUNCTIONS   += __natsort_asm.c
endif
