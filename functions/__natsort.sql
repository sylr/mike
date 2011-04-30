-- # Mike's Function
-- # vim: set tabstop=4 expandtab autoindent smartindent:
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 23/04/2011
-- # copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__natsort(
    in_text         text
) RETURNS text AS
    DATABASE_INSTALLED_SO, '__natsort'
LANGUAGE C STRICT IMMUTABLE COST 1000;

#ifndef X86_64
CREATE OR REPLACE FUNCTION mike.__natsort_asm(
    in_text         text
) RETURNS text AS
    DATABASE_INSTALLED_SO, '__natsort_asm'
LANGUAGE C STRICT IMMUTABLE COST 1000;
#endif
