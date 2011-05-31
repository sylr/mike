-- # Mike's Function
-- # vim: set tabstop=4 expandtab autoindent smartindent:
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 04/03/2011
-- # copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__natsort_pl(
    in_text         text
) RETURNS text AS $__$

# Version: MIKE_VERSION

$_[0] =~ s/([0-9]+)/sprintf("%012s", $&)/eg;
return $_[0];

$__$ LANGUAGE plperl IMMUTABLE COST 1000;
