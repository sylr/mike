#!/usr/bin/env bash
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 28/02/2011
# copyright: All rights reserved

TEST_REALPATH=$(realpath $0)
TEST_PATH=$(dirname $TEST_REALPATH)
MIKE_PATH=$(dirname $TEST_PATH)

# -- mike.conf -----------------------------------------------------------------

if [ ! -f "$MIKE_PATH/mike.conf" ]; then
    echo >&2 "$MIKE_PATH/mike.conf not found"
    echo >&2 "You need to execute autoconf && ./configure"
    exit 1
fi

source "$MIKE_PATH/mike.conf"

# -- mike.sh -------------------------------------------------------------------

source "$MIKE_PATH/lib/mike.sh"

# -- config --------------------------------------------------------------------

if [ -z "${DATABASE_HOST}" ]; then
    PSQL_FULL_CMD="$PSQL -U${DATABASE_USER} -d ${DATABASE_NAME} --tuples-only --no-align"
    PSQL_FULL_CMD_ALIGNED="$PSQL -U${DATABASE_USER} -d ${DATABASE_NAME} --tuples-only"
else
    PSQL_FULL_CMD="$PSQL -U${DATABASE_USER} -d ${DATABASE_NAME} -h ${DATABASE_HOST} --tuples-only --no-align"
    PSQL_FULL_CMD_ALIGNED="$PSQL -U${DATABASE_USER} -d ${DATABASE_NAME} -h ${DATABASE_HOST}"
fi

# -- vars ----------------------------------------------------------------------

export PGOPTIONS="--client-min-messages=warning"

# -- truncate ------------------------------------------------------------------

TRUNCATE=$($PSQL_FULL_CMD -c "TRUNCATE inode, xfile CASCADE;")

# -- noise ---------------------------------------------------------------------

for id_user in $($PSQL_FULL_CMD -c "SELECT id_user FROM mike.user;"); do
    $PSQL_FULL_CMD -c "SELECT * FROM mike.__stream($id_user, 3, 3, true);" > /dev/null
    dieifnzero $? "something went wrong when streaming"
done

$PSQL_FULL_CMD_ALIGNED -c "SELECT * FROM mike.file ORDER BY id_inode; SELECT * FROM mike.directory ORDER BY id_inode;" > .t0003-good
dieifnzero $? "something went wrong when reading tables"

$PSQL_FULL_CMD -c "UPDATE mike.file SET
    id_mimetype     = 0,
    path            = '/pwet',
    treepath        = '1.3.3.7'::ltree,
    size            = 3487,
    versioning_size = 26487;" > /dev/null
dieifnzero $? "something went wrong when trashing mike.file"

$PSQL_FULL_CMD -c "UPDATE mike.directory SET
    id_mimetype             = 0,
    path                    = '/pwet',
    treepath                = '1.3.3.7'::ltree,
    size                    = 3487,
    versioning_size         = 26487,
    inner_size              = 789,
    inner_versioning_size   = 321,
    dir_count               = 456,
    inner_dir_count         = 786,
    file_count              = 126,
    inner_file_count        = 556;" > /dev/null
dieifnzero $? "something went wrong when trashing mike.directory"

export PGOPTIONS="--client-min-messages=error"

for id_user in $($PSQL_FULL_CMD -c "SELECT id_user FROM mike.user;"); do
    $PSQL_FULL_CMD -c "SELECT * FROM mike.__fsck($id_user);" > /dev/null
    dieifnzero $? "something went wrong when fscking"
done

$PSQL_FULL_CMD_ALIGNED -c "SELECT * FROM mike.file ORDER BY id_inode; SELECT * FROM mike.directory ORDER BY id_inode;" > .t0003-fsck

# -- test ----------------------------------------------------------------------

DELTA=$(diff -u .t0003-good .t0003-fsck | wc -l)
dieifnzero $DELTA "fsck did not restore initial state"
rm .t0003-good .t0003-fsck

exit 0
