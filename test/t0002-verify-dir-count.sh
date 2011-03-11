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
else
    PSQL_FULL_CMD="$PSQL -U${DATABASE_USER} -d ${DATABASE_NAME} -h ${DATABASE_HOST} --tuples-only --no-align"
fi

# -- vars ----------------------------------------------------------------------

ID_USER=2
export PGOPTIONS="--client-min-messages=warning"

# -- truncate ------------------------------------------------------------------

TRUNCATE=$($PSQL_FULL_CMD -c "TRUNCATE directory CASCADE;")

# -- noise ---------------------------------------------------------------------

LOT_OF_DIR=$($PSQL_FULL_CMD -c "SELECT * FROM mike.__make_lot_of_directories($ID_USER, 5, 5);")
dieifnzero $? "something went wrong when making lot of directories"

RANDOM_DIR=$($PSQL_FULL_CMD -c "SELECT id_inode FROM mike.directory WHERE id_user = $ID_USER AND treepath ~ '*{3}' ORDER BY random() LIMIT 1;")
dieifnzero $? "something went wrong when chosing random directory"

cat <<EOT | $PSQL_FULL_CMD -f - --single-transaction > /dev/null
    -- removing some dir
    SELECT
        rmdir($ID_USER, id_inode)
    FROM mike.directory
    WHERE
        id_user = $ID_USER AND
        id_inode_parent IS NOT NULL AND
        treepath ~ '*.!${RANDOM_DIR}@.*' AND
        treepath ~ '*{4}' AND
        state = 0
     ORDER BY random()
     LIMIT 3;

    -- renaming random dir
    SELECT
        mike.rename($ID_USER, $RANDOM_DIR, 'pwet');

    -- moving random dir
    SELECT
        mike.mvdir($ID_USER,
                   $RANDOM_DIR,
                   (SELECT id_inode FROM directory WHERE id_user = $ID_USER AND id_inode_parent IS NULL AND state = 0));
EOT

dieifnzero $? "something went wrong when doing noise"

# -- test ----------------------------------------------------------------------

REAL=$($PSQL_FULL_CMD -c "SELECT count(*) FROM mike.directory WHERE state = 0")
ACCOUNTED=$($PSQL_FULL_CMD -c "SELECT count(*) + sum(inner_dir_count) FROM mike.directory WHERE id_inode_parent IS NULL;")
DELTA=$(($REAL - $ACCOUNTED))

dieifnzero $DELTA "accounted directories not equal to real number of directories, delta is $DELTA"
