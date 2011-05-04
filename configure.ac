#                                               -*- Autoconf -*-
# Process this file with autoconf to produce a configure script.
# vim: set tabstop=4 expandtab autoindent smartindent:

# -- init ----------------------------------------------------------------------

AC_PREREQ([2.61])
AC_INIT([Mike], [v0.4.0-rc3], [sylvain@abstraction.fr], , [https://git.abstraction.fr/~sylvain/])
AC_COPYRIGHT([All rights reserved to Sylvain Rabot])
AC_PREFIX_DEFAULT([$HOME])

CONFIGURE_INVOCATION="$0 $*"
AC_SUBST(CONFIGURE_INVOCATION)

# -- macros --------------------------------------------------------------------

AC_DEFUN([MIKE_ERROR_IF_EMPTY],
[if test -z "$1"; then
    AC_MSG_ERROR([$2])
fi
]) # MIKE_ERROR_IF_EMPTY

AC_DEFUN([MIKE_IF_EMPTY_DEFAULT],
[if test -z "$$1"; then
    $1="$2";
fi
]) # MIKE_ERROR_IF_EMPTY

AC_DEFUN([MIKE_PARSE_WITH],
[PACKAGE=m4_toupper($1); \
    if ! test -z "$withval"; then
        m4_toupper($1)_DIR=$(realpath $withval); \
        AC_MSG_NOTICE([setting m4_toupper($1)_DIR to $(realpath $withval)]); \
        unset withval; \
    else \
        m4_toupper($1)_DIR=$PATH
    fi
]) # MIKE_PARSE_WITH

AC_DEFUN([MIKE_ARG_SET_PATH],
[AC_ARG_WITH(
    [$1],
    [AS_HELP_STRING([--with-$1=PATH], [provide PATH to $1])],
    [m4_toupper($1)_DIR=$withval],
    [])
]) # MIKE_ARG_SET_PATH

# -- programs ------------------------------------------------------------------

# looking for echo
MIKE_ARG_SET_PATH(echo)
MIKE_PARSE_WITH(echo)
AC_PATH_PROG([ECHO], [echo], , [$ECHO_DIR])
MIKE_ERROR_IF_EMPTY([$ECHO], [echo not found])

# looking for cat
MIKE_ARG_SET_PATH(cat)
MIKE_PARSE_WITH(cat)
AC_PATH_PROG([CAT], [cat], , [$CAT_DIR])
MIKE_ERROR_IF_EMPTY([$CAT], [cat not found])

# looking for which
MIKE_ARG_SET_PATH(which)
MIKE_PARSE_WITH(which)
AC_PATH_PROG([WHICH], [which], , [$WHICH_DIR])
MIKE_ERROR_IF_EMPTY([$WHICH], [which not found])

# looking for basename
MIKE_ARG_SET_PATH(basename)
MIKE_PARSE_WITH(basename)
AC_PATH_PROG([BASENAME], [basename], , [$BASENAME_DIR])
MIKE_ERROR_IF_EMPTY([$BASENAME], [basename not found])

# looking for dirname
MIKE_ARG_SET_PATH(dirname)
MIKE_PARSE_WITH(dirname)
AC_PATH_PROG([DIRNAME], [dirname], , [$DIRNAME_DIR])
MIKE_ERROR_IF_EMPTY([$DIRNAME], [dirname not found])

# looking for realpath
MIKE_ARG_SET_PATH(realpath)
MIKE_PARSE_WITH(realpath)
AC_PATH_PROG([REALPATH], [realpath], , [$REALPATH_DIR])
MIKE_ERROR_IF_EMPTY([$REALPATH], [realpath not found])

# looking for rm
MIKE_ARG_SET_PATH(rm)
MIKE_PARSE_WITH(rm)
AC_PATH_PROG([RM], [rm], , [$RM_DIR])
MIKE_ERROR_IF_EMPTY([$RM], [rm not found])

# looking for cut
MIKE_ARG_SET_PATH(cut)
MIKE_PARSE_WITH(cut)
AC_PATH_PROG([CUT], [cut], , [$CUT_DIR])
MIKE_ERROR_IF_EMPTY([$CUT], [cut not found])

# looking for env
MIKE_ARG_SET_PATH(env)
MIKE_PARSE_WITH(env)
AC_PATH_PROG([ENV], [env], , [$ENV_DIR])
MIKE_ERROR_IF_EMPTY([$ENV], [ENV not found])

# looking for sleep
MIKE_ARG_SET_PATH(sleep)
MIKE_PARSE_WITH(sleep)
AC_PATH_PROG([SLEEP], [sleep], , [$SLEEP_DIR])
MIKE_ERROR_IF_EMPTY([$SLEEP], [sleep not found])

# looking for date
MIKE_ARG_SET_PATH(date)
MIKE_PARSE_WITH(date)
AC_PATH_PROG([DATE], [date], , [$DATE_DIR])
MIKE_ERROR_IF_EMPTY([$DATE], [date not found])

# looking for bash
MIKE_ARG_SET_PATH(bash)
MIKE_PARSE_WITH(bash)
AC_PATH_PROG([BASH], [bash], , [$BASH_DIR])
MIKE_ERROR_IF_EMPTY([$BASH], [bash not found])

# looking for test
MIKE_ARG_SET_PATH(test)
MIKE_PARSE_WITH(test)
AC_PATH_PROG([TEST], [test], , [$TEST_DIR])
MIKE_ERROR_IF_EMPTY([$TEST], [test not found])

# looking for getopt
MIKE_ARG_SET_PATH(getopt)
MIKE_PARSE_WITH(getopt)
AC_PATH_PROG([GETOPT], [getopt], , [$GETOPT_DIR])
MIKE_ERROR_IF_EMPTY([$GETOPT], [getopt not found])

# looking for sed
MIKE_ARG_SET_PATH(sed)
MIKE_PARSE_WITH(sed)
AC_PATH_PROG([SED], [sed], , [$SED_DIR])
MIKE_ERROR_IF_EMPTY([$SED], [sed not found])

# looking for awk
MIKE_ARG_SET_PATH(awk)
MIKE_PARSE_WITH(awk)
AC_PATH_PROG([AWK], [awk], , [$AWK_DIR])
MIKE_ERROR_IF_EMPTY([$AWK], [awk not found])

# looking for tee
MIKE_ARG_SET_PATH(tee)
MIKE_PARSE_WITH(tee)
AC_PATH_PROG([TEE], [tee], , [$TEE_DIR])
MIKE_ERROR_IF_EMPTY([$TEE], [tee not found])

# looking for make
MIKE_ARG_SET_PATH(make)
MIKE_PARSE_WITH(make)
AC_PATH_PROG([MAKE], [make], , [$MAKE_DIR])
MIKE_ERROR_IF_EMPTY([$MAKE], [make not found])

# looking for gcc
MIKE_ARG_SET_PATH(gcc)
MIKE_PARSE_WITH(gcc)
AC_PATH_PROG([GCC], [gcc], , [$GCC_DIR])
MIKE_ERROR_IF_EMPTY([$GCC], [gcc not found])

# looking for gcc
MIKE_ARG_SET_PATH(nasm)
MIKE_PARSE_WITH(nasm)
AC_PATH_PROG([NASM], [nasm], , [$NASM_DIR])
MIKE_ERROR_IF_EMPTY([$NASM], [nasm not found])

# looking for grep
MIKE_ARG_SET_PATH(grep)
MIKE_PARSE_WITH(grep)
AC_PATH_PROG([GREP], [grep], , [$GREP_DIR])
MIKE_ERROR_IF_EMPTY([$GREP], [grep not found])

# looking for tar
MIKE_ARG_SET_PATH(tar)
MIKE_PARSE_WITH(tar)
AC_PATH_PROG([TAR], [tar], , [$TAR_DIR])
MIKE_ERROR_IF_EMPTY([$TAR], [tar not found])

# looking for psql
MIKE_ARG_SET_PATH(psql)
MIKE_PARSE_WITH(psql)
AC_PATH_PROG([PSQL], [psql], , [$PSQL_DIR])
MIKE_ERROR_IF_EMPTY([$PSQL], [psql not found])

# looking for createdb
MIKE_ARG_SET_PATH(createdb)
MIKE_PARSE_WITH(createdb)
AC_PATH_PROG([CREATEDB], [createdb], , [$CREATEDB_DIR])
MIKE_ERROR_IF_EMPTY([$CREATEDB], [createdb not found])

# looking for dropdb
MIKE_ARG_SET_PATH(dropdb)
MIKE_PARSE_WITH(dropdb)
AC_PATH_PROG([DROPDB], [dropdb], , [$DROPDB_DIR])
MIKE_ERROR_IF_EMPTY([$DROPDB], [dropdb not found])

# looking for pg_config
MIKE_ARG_SET_PATH(pg_config)
MIKE_PARSE_WITH(pg_config)
AC_PATH_PROG([PG_CONFIG], [pg_config], , [$PG_CONFIG_DIR])
MIKE_ERROR_IF_EMPTY([$PG_CONFIG], [pg_config not found])

# looking for pg_dump
MIKE_ARG_SET_PATH(pg_dump)
MIKE_PARSE_WITH(pg_dump)
AC_PATH_PROG([PG_DUMP], [pg_dump], , [$PG_DUMP_DIR])

# looking for apgdiff
MIKE_ARG_SET_PATH(apgdiff)
MIKE_PARSE_WITH(apgdiff)
AC_PATH_PROG([APGDIFF], [apgdiff], , [$APGDIFF_DIR])

# looking for git
MIKE_ARG_SET_PATH(git)
MIKE_PARSE_WITH(git)
AC_PATH_PROG([GIT], [git], , [$GIT_DIR])

# looking for gitstats
MIKE_ARG_SET_PATH(gitstats)
MIKE_PARSE_WITH(gitstats)
AC_PATH_PROG([GITSTATS], [gitstats], , [$GITSTATS_DIR])

# looking for gource
MIKE_ARG_SET_PATH(gource)
MIKE_PARSE_WITH(gource)
AC_PATH_PROG([GOURCE], [gource], , [$GOURCE_DIR])

# looking for install
MIKE_ARG_SET_PATH(install)
MIKE_PARSE_WITH(install)
AC_PATH_PROG([INSTALL], [install], , [$INSTALL_DIR])
MIKE_ERROR_IF_EMPTY([$INSTALL], [install not found])

# looking for asciidoc
MIKE_ARG_SET_PATH(asciidoc)
MIKE_PARSE_WITH(asciidoc)
AC_PATH_PROG([ASCIIDOC], [asciidoc], , [$ASCIIDOC_DIR])

# looking for xmlto
MIKE_ARG_SET_PATH(xmlto)
MIKE_PARSE_WITH(xmlto)
AC_PATH_PROG([XMLTO], [xmlto], , [$XMLTO_DIR])

# looking for docbook2odf
MIKE_ARG_SET_PATH(docbook2odf)
MIKE_PARSE_WITH(docbook2odf)
AC_PATH_PROG([DOCBOOK2ODF], [docbook2odf], , [$DOCBOOK2ODF_DIR])

# looking for docbook2pdf
MIKE_ARG_SET_PATH(docbook2pdf)
MIKE_PARSE_WITH(docbook2pdf)
AC_PATH_PROG([DOCBOOK2PDF], [docbook2pdf], , [$DOCBOOK2PDF_DIR])

# looking for a2x
MIKE_ARG_SET_PATH(a2x)
MIKE_PARSE_WITH(a2x)
AC_PATH_PROG([A2X], [a2x], , [$A2X_DIR])

# -- postgresql ----------------------------------------------------------------

# postgresql version
PG_VERSION=$($PG_CONFIG | $GREP "VERSION" | $SED "s#VERSION = PostgreSQL \([0-9]*\)\(.[0-9]*\)\(.[0-9]*\)\?#\1\2\3#i")

AX_COMPARE_VERSION(
    [$PG_VERSION], [lt], [8.4.4],
    AC_MSG_ERROR([PostgreSQL version too old])
)

AX_COMPARE_VERSION(
    [$PG_VERSION], [ge], [9.0.0],
    [PG_VERSION_9=yes; PG_VERSION_9_0=yes; PG_VERSION_9_0_PLUS=yes],
    [PG_VERSION_9=no; PG_VERSION_9_0=no; PG_VERSION_9_0_PLUS=no]
)

AX_COMPARE_VERSION(
    [$PG_VERSION], [ge], [9.1.0],
    [PG_VERSION_9_1=yes; PG_VERSION_9_0=no; PG_VERSION_9_1_PLUS=yes],
    [PG_VERSION_9_1=no; PG_VERSION_9_1_PLUS=no]
)

AX_COMPARE_VERSION(
    [$PG_VERSION], [ge], [9.2.0],
    [PG_VERSION_9_2=yes; PG_VERSION_9_1=no; PG_VERSION_9_0=no; PG_VERSION_9_2_PLUS=yes],
    [PG_VERSION_9_2=no; PG_VERSION_9_2_PLUS=no]
)

AC_SUBST(PG_VERSION)
AC_SUBST(PG_VERSION_9)
AC_SUBST(PG_VERSION_9_0)
AC_SUBST(PG_VERSION_9_0_PLUS)
AC_SUBST(PG_VERSION_9_1)
AC_SUBST(PG_VERSION_9_1_PLUS)
AC_SUBST(PG_VERSION_9_2)
AC_SUBST(PG_VERSION_9_2_PLUS)

# postgresql sharedir
PG_SHAREDIR=$($PG_CONFIG --sharedir)
AC_SUBST(PG_SHAREDIR)

# postgresql includedir server
PG_INCLUDEDIR_SERVER=$($PG_CONFIG --includedir-server)
AC_SUBST(PG_INCLUDEDIR_SERVER)

# postgresql includedir server
PG_PKGLIBDIR_SERVER=$($PG_CONFIG --pkglibdir)
AC_SUBST(PG_PKGLIBDIR_SERVER)

# contribs / extensions
if test -n "$PG_VERSION_9_1"; then
    # ltree
    AC_CHECK_FILE(
        [$PG_SHAREDIR/extension/ltree--1.0.sql],
        [PG_CONTRIB_LTREE=$PG_SHAREDIR/contrib/ltree--1.0.sql],
        AC_MSG_ERROR([ltree extension not found in $PG_SHAREDIR/extension])
    )

    # pgcrypto
    AC_CHECK_FILE(
        [$PG_SHAREDIR/extension/pgcrypto--1.0.sql],
        [PG_CONTRIB_PGCRYPTO=$PG_SHAREDIR/extension/pgcrypto--1.0.sql],
        AC_MSG_ERROR([pgcrypto extension not found in $PG_SHAREDIR/extension])
    )
else
    # ltree
    AC_CHECK_FILE(
        [$PG_SHAREDIR/contrib/ltree.sql],
        [PG_CONTRIB_LTREE=$PG_SHAREDIR/contrib/ltree.sql],
        AC_MSG_ERROR([ltree contrib not found in $PG_SHAREDIR/contrib])
    )

    # pgcrypto
    AC_CHECK_FILE(
        [$PG_SHAREDIR/contrib/pgcrypto.sql],
        [PG_CONTRIB_PGCRYPTO=$PG_SHAREDIR/contrib/pgcrypto.sql],
        AC_MSG_ERROR([pgcrypto contrib not found in $PG_SHAREDIR/contrib])
    )
fi

AC_SUBST(PG_CONTRIB_LTREE)
AC_SUBST(PG_CONTRIB_PGCRYPTO)

# -- variables -----------------------------------------------------------------

AC_ARG_VAR(SLEEP_TIME, [sleep between each make action (default: 0.1)])
MIKE_IF_EMPTY_DEFAULT([SLEEP_TIME], [0.1])

AC_ARG_VAR(DATABASE_USER, [database user (default: mike)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_USER], [mike])

AC_ARG_VAR(DATABASE_NAME, [database name (default: mike)])
MIKE_IF_EMPTY_DEFAULT([DATABASE_NAME], [mike])

AC_ARG_VAR(DATABASE_HOST, [database host])

AC_ARG_VAR(DATABASE_PORT, [database port])

AC_ARG_ENABLE(
    [create-schema],
    AS_HELP_STRING([--enable-create-schema], [create mike schema in DATABASE_NAME]),
    [ENABLE_CREATE_SCHEMA=yes],
    [ENABLE_CREATE_SCHEMA=no]
)

AC_SUBST(ENABLE_CREATE_SCHEMA)

AC_ARG_ENABLE(
    [create-database],
    AS_HELP_STRING([--enable-create-database], [create DATABASE_NAME, imply --enable-create-schema]),
    [ENABLE_CREATE_DATABASE=yes; ENABLE_CREATE_SCHEMA=yes],
    [ENABLE_CREATE_DATABASE=no]
)

AC_SUBST(ENABLE_CREATE_DATABASE)

# -- cpp defines ---------------------------------------------------------------

AC_ARG_ENABLE(
    [tree-max-depth],
    AS_HELP_STRING([--enable-tree-max-depth], [enable tree maximum depth support (default: 24)]),
    [TREE_MAX_DEPTH=$enable_tree_max_depth],
    [TREE_MAX_DEPTH=24]
)

AC_SUBST(TREE_MAX_DEPTH)

AC_ARG_ENABLE(
    [inode-rand-column],
    AS_HELP_STRING([--enable-inode-rand-column], [add rand column for random clustering (default: no)]),
    [INODE_RAND_COLUMN=$enable_inode_rand_column],
    [INODE_RAND_COLUMN=no]
)

AC_SUBST(INODE_RAND_COLUMN)

AC_ARG_ENABLE(
    [no-atime],
    AS_HELP_STRING([--enable-no-atime], [disable atime support (default: no)]),
    [NO_ATIME=$enable_no_atime],
    [NO_ATIME=no]
)

AC_SUBST(NO_ATIME)

AC_ARG_ENABLE(
    [no-volume-lock],
    AS_HELP_STRING([--enable-no-volume-lock], [disable volume virtual size update support (default: no)]),
    [NO_VOLUME_LOCK=$enable_no_volume_lock],
    [NO_VOLUME_LOCK=no]
)

AC_SUBST(NO_VOLUME_LOCK)

AC_ARG_ENABLE(
    [dev-mode],
    AS_HELP_STRING([--enable-dev-mode], [enable development mode]),
    [DEV_MODE=$enable_dev_mode],
    [DEV_MODE=no]
)

AC_SUBST(DEV_MODE)

AC_ARG_VAR(NATSORT_PADDING, [padding size for natsorting (default: 8)])
MIKE_IF_EMPTY_DEFAULT([NATSORT_PADDING], [8])

if test $(uname --processor) == "x86_64"; then
    X86_64=yes
    AC_SUBST(X86_64)
fi

# -- output --------------------------------------------------------------------

AC_CONFIG_FILES([mike.conf Makefile test/Makefile documentation/Makefile])
AC_OUTPUT

