-- # Mike's Function
-- # vim: set tabstop=4 expandtab autoindent smartindent:
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 04/03/2011
-- # copyright: All rights reserved

CREATE OR REPLACE FUNCTION mike.__natsort(
    in_text         text
) RETURNS text AS $__$

$_[0] =~ s/([0-9]+)/sprintf("%012d", $&)/eg;
return $_[0];

$__$ LANGUAGE plperl IMMUTABLE COST 1000;
