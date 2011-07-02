# Mike's Makefile
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 22/04/2011
# copyright: All rights reserved

ifneq ($(X86_64),yes)
DATABASE_ASM_FUNCTIONS  = __natsort_asm.asm
endif
