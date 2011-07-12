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
        if [ -n "$1" ]; then
            die "$1"
        else
            die "aborting ..."
        fi
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

# -- die if zero function ------------------------------------------------------

dieifzero()
{
    if [ "$1" -eq "0" ]; then
        die "$2" $1
    fi

    if [ -n "$3" ]; then
        echo "$3"
    fi
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
    local FULL_LENGTH=$(echo -n "$1" | wc -m)
    local PAD_LENGTH=$2
    local PAD_CHAR=$3

    if [ "$FULL_LENGTH" -lt "$PAD_LENGTH" ]; then
        local REMAINDER=$(($PAD_LENGTH - FULL_LENGTH))
        local S_PAD=$(printf "%${REMAINDER}s")
        local PAD=${S_PAD// /$PAD_CHAR}

        if [ "$PAD_CHAR" != "" ]; then
            PAD=${S_PAD// /$PAD_CHAR}
        else
            PAD=" "
        fi

        echo -n "${1}${PAD}"
    else
        echo -n "${1}"
    fi
}

# -- strlpad -------------------------------------------------------------------

strlpad()
{
    local FULL_LENGTH=$(echo -n "$1" | wc -m)
    local PAD_LENGTH=$2
    local PAD_CHAR=$3

    if [ "$FULL_LENGTH" -lt "$PAD_LENGTH" ]; then
        local REMAINDER=$(($PAD_LENGTH - FULL_LENGTH))
        local S_PAD=$(printf "%${REMAINDER}s")

        if [ "$PAD_CHAR" != "" ]; then
            PAD=${S_PAD// /$PAD_CHAR}
        else
            PAD=" "
        fi

        echo -n "${PAD}${1}"
    else
        echo -n "${1}"
    fi
}
