#!/usr/bin/env sh
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 03/07/2010
# copyright: All rights reserved

# -- die function --------------------------------------------------------------

# die "epitaph" ["exit code"]
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

# abort ["outpout if aborting"]
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

# dieifzero $var "error message" "success message"
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

# dieifnzero $var "error message" "success message"
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

# nstrrpad "string" "output string length" ["padding char"]
nstrrpad()
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

# strrpad "string" "output string length" ["padding char"]
strrpad()
{
    nstrrpad "$1" "$2" "$3"
    echo
}

# -- strlpad -------------------------------------------------------------------

# nstrlpad "string" "output string length" ["padding char"]
nstrlpad()
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

# strlpad "string" "output string length" ["padding char"]
strlpad()
{
    nstrlpad "$1" "$2" "$3"
    echo
}

# -- red -----------------------------------------------------------------------

red()
{
    echo -e "\e[0;31m$1\e[0m"
}

nred()
{
    echo -ne "\e[0;31m$1\e[0m"
}

# -- green ---------------------------------------------------------------------

green()
{
    echo -e "\e[0;32m$1\e[0m"
}

ngreen()
{
    echo -ne "\e[0;32m$1\e[0m"
}

# -- yellow --------------------------------------------------------------------

yellow()
{
    echo -e "\e[0;33m$1\e[0m"
}

nyellow()
{
    echo -ne "\e[0;33m$1\e[0m"
}

# -- git_describe_no_rc --------------------------------------------------------

git_describe_no_rc()
{
    unset before;

    while true; do
        tag=$(git describe --no-abbrev --match 'v[0-9]*.[0-9]*.[0-9]*' $before);

        if [ -z $(echo $tag | grep -v '\-rc') ]; then
            before="$tag^";
        else
            echo $tag;
            break;
        fi;
    done
}
