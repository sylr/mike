#!/usr/bin/env bash

# author: Sylvain Rabot <srabot@abstraction.fr>
# date: 03/07/2010
# copyright: All rights reserved

# -- die function --------------------------------------------------------------

die()
{
    echo >&2 $1;
    
    if [ -z "$2" ]; then
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

    if [ "$input" = "n" ]; then
        die "aborting ..."
    elif [ "$input" = "Y" ]; then
        return 0
    else
        abort
    fi
}

# -- parse tag function --------------------------------------------------------

parse_tag()
{
    echo $1 | \
    grep -E "^v([0-9]+)\.([0-9]+)\.([0-9]+)" | \
    sed "s/^v\([0-9]*\).\([0-9]*\).\([0-9]*\)$/\1 \2 \3/"
}

