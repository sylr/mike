#!/usr/bin/env sh
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
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

# -- trim function -------------------------------------------------------------

trim()
{
    echo "$1" | sed -e "s/^ *//" -e "s/ *$//"
}

# -- parse tag function --------------------------------------------------------

parse_tag()
{
    echo $1 | \
    grep -E "^v([0-9]+)\.([0-9]+)\.([0-9]+)(-rc([0-9]+))?" | \
    sed "s/^v\([0-9]*\).\([0-9]*\).\([0-9]*\)\(-rc\([0-9]*\)\)\?$/\1 \2 \3 \5/" | \
    sed -e "s/^ *//" -e "s/ *$//"
}

# -- die if non zero function --------------------------------------------------

dieifnzero()
{
    if [ "$1" -ne "0" ]; then
        die "$2" $1
    fi

    if [ -n "$3" ]; then
        echo "$3"
    fi
}

# -- strrpad -------------------------------------------------------------------

strrpad()
{
    FULL_LENGTH=$(echo -n "$1" | wc -m)
    PAD_LENGTH=$2
    PAD_CHAR=$3

    if [ "$FULL_LENGTH" -lt "$PAD_LENGTH" ]; then
        REMAINDER=$(($PAD_LENGTH - FULL_LENGTH))
        S_PAD=$(printf "%${REMAINDER}s")
        PAD=${S_PAD// /$PAD_CHAR}

        echo ${1}${PAD}
    fi
}
