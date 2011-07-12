#!/usr/bin/env bash
# vim: set tabstop=4 expandtab autoindent smartindent:
# author: Sylvain Rabot <sylvain@abstraction.fr>
# date: 12/07/2011
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

$PSQL_FULL_CMD -c "SELECT * FROM __stream(1, ARRAY[2, 2, 2], ARRAY[3, 3, 3], true);" > /dev/null
dieifnzero $? "something went wrong when streaming"

ID_DIRECTORY_SOURCE=$($PSQL_FULL_CMD -c "SELECT id_inode FROM directory WHERE id_user = 1 AND treepath ~ '*{2}' LIMIT 1;")
dieifnzero $? "something went wrong when selecting source directory"

ID_DIRECTORY_TARGET=$($PSQL_FULL_CMD -c "SELECT out_id_inode FROM mkdir(
    1,
    (SELECT id_inode FROM directory WHERE id_user = 1 AND id_inode_parent IS NULL),
    'target'
);")

dieifnzero $? "something went wrong when creating target directory"

# moving directory inside another one
$PSQL_FULL_CMD -c "SELECT * FROM mvdir(1, $ID_DIRECTORY_SOURCE, $ID_DIRECTORY_TARGET);" > /dev/null
dieifnzero $? "something went wrong when moving"

# moving directory inside the same one with a new name
$PSQL_FULL_CMD -c "SELECT * FROM mvdir(1, $ID_DIRECTORY_SOURCE, $ID_DIRECTORY_TARGET, 'pwet');" > /dev/null
dieifnzero $? "something went wrong when moving in the same directory with a new name"

# moving directory inside the same one with a new name
$PSQL_FULL_CMD -c "SELECT * FROM mvdir(1, $ID_DIRECTORY_SOURCE, $ID_DIRECTORY_TARGET, 'pwet');" > /dev/null 2>&1
dieifzero $? "something went wrong when moving in the same directory with the same name"

FSCK=$($PSQL_FULL_CMD -c "SELECT * FROM __fsck(1);")
DOOMED_DIRS=$(echo "$FSCK" | cut -d '|' -f2);
DOOMED_FILES=$(echo "$FSCK" | cut -d '|' -f3);

dieifnzero $(($DOOMED_DIRS + $DOOMED_FILES)) "fsck found something wrong"

exit 0
