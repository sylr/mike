#!/usr/bin/env sh
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 03/07/2010
# copyright: All rights reserved

# -- die function --------------------------------------------------------------

die()
{
    echo >&2 $1;
    
    if test -z "$2"; then
        exit 1
    else
        exit $2
    fi
}

# -- abort function ------------------------------------------------------------

abort()
{
    echo -n "Do you want to continue [Y/n]? "
    read input

    if test "$input" = "n"; then
        die "aborting ..."
    elif test "$input" = "Y"; then
        return 0
    else
        abort
    fi
}

# -- trim function -------------------------------------------------------------

trim()
{
    echo $1 | sed -e "s/^ *//" -e "s/ *$//"
}

# -- parse tag function --------------------------------------------------------

parse_tag()
{
    echo $1 | \
    grep -E "^v([0-9]+)\.([0-9]+)\.([0-9]+)(-rc([0-9]+))?" | \
    sed "s/^v\([0-9]*\).\([0-9]*\).\([0-9]*\)\(-rc\([0-9]*\)\)\?$/\1 \2 \3 \5/" | \
    sed -e "s/^ *//" -e "s/ *$//"
}
