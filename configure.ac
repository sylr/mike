#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.

# -- init ----------------------------------------------------------------------

AC_PREREQ([2.61])
AC_INIT([Mike], [v0.1.0], [sylvain@abstraction.fr], , [https://git.abstraction.fr/~sylvain/])
AC_COPYRIGHT([All rights reserved to Sylvain Rabot])

# -- macros --------------------------------------------------------------------

AC_DEFUN([MIKE_ERROR_IF_EMPTY],
[if test -z "$1"; then
    AC_MSG_ERROR([$2])
fi \
]) # MIKE_ERROR_IF_EMPTY

AC_DEFUN([MIKE_IF_EMPTY_DEFAULT],
[if test -z "$$1"; then
    $1="$2";
fi \
]) # MIKE_ERROR_IF_EMPTY

AC_DEFUN([MIKE_PARSE_WITH],
[PACKAGE=m4_toupper($1); \
    if ! test -z "$withval"; then
	    m4_toupper($1)_DIR=$(realpath $withval); \
	    AC_MSG_NOTICE([setting m4_toupper($1)_DIR to $(realpath $withval)]); \
	    unset withval; \
	else \
	    m4_toupper($1)_DIR=$PATH
	fi \
]) # MIKE_PARSE_WITH

AC_DEFUN([MIKE_ARG_SET_PATH],
[AC_ARG_WITH(
    [$1],
    [AS_HELP_STRING([--with-$1=PATH], [provide PATH to $1])],
    [m4_toupper($1)_DIR=$withval],
    [])
]) # MIKE_ARG_SET_PATH

# -- binaries ------------------------------------------------------------------

# checking for echo
MIKE_ARG_SET_PATH(echo)
MIKE_PARSE_WITH(echo)
AC_PATH_PROG([ECHO], [echo], , [$ECHO_DIR])
MIKE_ERROR_IF_EMPTY([$ECHO], [echo not found])

# checking for cat
MIKE_ARG_SET_PATH(cat)
MIKE_PARSE_WITH(cat)
AC_PATH_PROG([CAT], [cat], , [$CAT_DIR])
MIKE_ERROR_IF_EMPTY([$CAT], [cat not found])

# checking for rm
MIKE_ARG_SET_PATH(rm)
MIKE_PARSE_WITH(rm)
AC_PATH_PROG([RM], [rm], , [$RM_DIR])
MIKE_ERROR_IF_EMPTY([$RM], [rm not found])

# checking for cut
MIKE_ARG_SET_PATH(cut)
MIKE_PARSE_WITH(cut)
AC_PATH_PROG([CUT], [cut], , [$CUT_DIR])
MIKE_ERROR_IF_EMPTY([$CUT], [cut not found])

# checking for sleep
MIKE_ARG_SET_PATH(sleep)
MIKE_PARSE_WITH(sleep)
AC_PATH_PROG([SLEEP], [sleep], , [$SLEEP_DIR])
MIKE_ERROR_IF_EMPTY([$SLEEP], [sleep not found])

# checking for date
MIKE_ARG_SET_PATH(date)
MIKE_PARSE_WITH(date)
AC_PATH_PROG([DATE], [date], , [$DATE_DIR])
MIKE_ERROR_IF_EMPTY([$DATE], [date not found])

# checking for bash
MIKE_ARG_SET_PATH(bash)
MIKE_PARSE_WITH(bash)
AC_PATH_PROG([BASH], [bash], , [$BASH_DIR])
MIKE_ERROR_IF_EMPTY([$BASH], [bash not found])

# checking for sed
MIKE_ARG_SET_PATH(sed)
MIKE_PARSE_WITH(sed)
AC_PATH_PROG([SED], [sed], , [$SED_DIR])
MIKE_ERROR_IF_EMPTY([$SED], [sed not found])

# checking for psql
MIKE_ARG_SET_PATH(psql)
MIKE_PARSE_WITH(psql)
AC_PATH_PROG([PSQL], [psql], , [$PSQL_DIR])
MIKE_ERROR_IF_EMPTY([$PSQL], [psql not found])

# checking for git
MIKE_ARG_SET_PATH(git)
MIKE_PARSE_WITH(git)
AC_PATH_PROG([GIT], [git], , [$GIT_DIR])
MIKE_ERROR_IF_EMPTY([$GIT], [git not found])

# checking for asciidoc
MIKE_ARG_SET_PATH(asciidoc)
MIKE_PARSE_WITH(asciidoc)
AC_PATH_PROG([ASCIIDOC], [asciidoc], , [$ASCIIDOC_DIR])

# checking for docbook2odf
MIKE_ARG_SET_PATH(docbook2odf)
MIKE_PARSE_WITH(docbook2odf)
AC_PATH_PROG([DOCBOOK2ODF], [docbook2odf], , [$DOCBOOK2ODF_DIR])

# checking for docbook2odf
MIKE_ARG_SET_PATH(docbook2pdf)
MIKE_PARSE_WITH(docbook2pdf)
AC_PATH_PROG([DOCBOOK2PDF], [docbook2pdf], , [$DOCBOOK2PDF_DIR])

# checking for docbook2odf
MIKE_ARG_SET_PATH(a2x)
MIKE_PARSE_WITH(a2x)
AC_PATH_PROG([A2X], [a2x], , [$A2X_DIR])

# -- variables -----------------------------------------------------------------

AC_ARG_VAR(DATABASE_USER, [database user (default: mike)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_USER], [mike])

AC_ARG_VAR(DATABASE_NAME, [database name (default: mike)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_NAME], [mike])

AC_ARG_VAR(DATABASE_HOST, [database host (default: localhost)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_HOST], [localhost])

AC_ARG_VAR(DATABASE_PORT, [database port (default: 5432)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_PORT], [5432])

# -- output --------------------------------------------------------------------

AC_CONFIG_FILES([Makefile documentation/Makefile])
AC_OUTPUT
