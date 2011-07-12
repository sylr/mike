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

TRUNCATE=$($PSQL_FULL_CMD -c "TRUNCATE directory, file, xfile, as_file_xfile CASCADE;")

# -- test ----------------------------------------------------------------------

$PSQL_FULL_CMD -c "SELECT * FROM __stream(1, ARRAY[1, 1, 1, 2, 3], ARRAY[1, 1, 1, 2, 3], true);"  > /dev/null

dieifnzero $? "something went wrong when streaming"

$PSQL_FULL_CMD -c "SELECT * FROM mkdir(
    1,
    (SELECT id_inode FROM directory WHERE id_user = 1 AND id_inode_parent IS NULL),
    'target'
);" > /dev/null

dieifnzero $? "something went wrong when creating target directory"

$PSQL_FULL_CMD -c "SELECT * FROM cpdir(
    1,
    (SELECT id_inode FROM directory WHERE id_user = 1 AND treepath ~ '*{2}' AND name != 'target'),
    (SELECT id_inode FROM directory WHERE id_user = 1 AND treepath ~ '*{2}' AND name = 'target')
);" > /dev/null

dieifnzero $? "something went wrong when copying"

$PSQL_FULL_CMD -c "SELECT * FROM cpdir(
    1,
    (SELECT id_inode FROM directory WHERE id_user = 1 AND treepath ~ '*{2}' AND name != 'target'),
    (SELECT id_inode FROM directory WHERE id_user = 1 AND treepath ~ '*{2}' AND name = 'target'),
    'new-directory-name'
);" > /dev/null

dieifnzero $? "something went wrong when copying with a new name"

FSCK=$($PSQL_FULL_CMD -c "SELECT * FROM __fsck(1);")
DOOMED_DIRS=$(echo "$FSCK" | cut -d '|' -f2);
DOOMED_FILES=$(echo "$FSCK" | cut -d '|' -f3);

dieifnzero $(($DOOMED_DIRS + $DOOMED_FILES)) "fsck found something wrong"

exit 0
