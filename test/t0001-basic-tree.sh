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

ID_USER=1
export PGOPTIONS="--client-min-messages=warning"

# -- truncate ------------------------------------------------------------------

TRUNCATE=$($PSQL_FULL_CMD -c "TRUNCATE inode CASCADE")
TRUNCATE=$($PSQL_FULL_CMD -c "TRUNCATE volume CASCADE")

# -- volume --------------------------------------------------------------------

VOLUME=$($PSQL_FULL_CMD -c "INSERT INTO mike.volume (path, max_size, state) VALUES ('/storage/nas01/enclosure01/', '17592186044416', 0)")
VOLUME=$($PSQL_FULL_CMD -c "INSERT INTO mike.volume (path, max_size, state) VALUES ('/storage/nas01/enclosure02/', '17592186044416', 0)")
VOLUME=$($PSQL_FULL_CMD -c "INSERT INTO mike.volume (path, max_size, state) VALUES ('/storage/nas01/enclosure03/', '17592186044416', 0)")

# -- root ----------------------------------------------------------------------

ID_ROOT_DIR=$($PSQL_FULL_CMD  -c "SELECT out_id_inode FROM mike.mkdir($ID_USER, 'mike');")
dieifnzero $? "unable to create root" "root dir id ... $ID_ROOT_DIR"

# -- init ----------------------------------------------------------------------

INIT_DIR[0]="My Music"
INIT_DIR[1]="My Pictures"
INIT_DIR[2]="My Documents"
INIT_DIR[3]="My Videos"

for i in $(seq 0 3); do
    ID_DIR=$($PSQL_FULL_CMD -c "SELECT out_id_inode FROM mike.mkdir($ID_USER, $ID_ROOT_DIR, '${INIT_DIR[$i]}');")
    dieifnzero $? "unable to create dir ${INIT_DIR[$i]}" "${INIT_DIR[$i]} id ... $ID_DIR"

    ID_INIT_DIR[$i]=$ID_DIR
done

# -- files ---------------------------------------------------------------------

BASENAMES="pwet grosse-mite"

MIMETYPES[0]="audio"
MIMETYPES[1]="image"
MIMETYPES[2]="document"
MIMETYPES[3]="video"

EXTENSIONS[0]="mp3 wav"
EXTENSIONS[1]="jpg png"
EXTENSIONS[2]="txt xls"
EXTENSIONS[3]="avi mkv"

for dir in $(seq 0 3); do
    strrpad "-- ${INIT_DIR[dir]} " "40" "-"

    for ext in ${EXTENSIONS[$dir]}; do
        for base in ${BASENAMES}; do
            # mimetype
            ID_MIMETYPE=$($PSQL_FULL_CMD -c "SELECT out_id_mimetype FROM __get_id_mimetype('${MIMETYPES[$dir]}/$ext')")
            dieifnzero $? "unable to retrieve mimetype id '${MIMETYPES[$dir]}/$ext}"

            # xfile
            ID_XFILE=$($PSQL_FULL_CMD -c "SELECT out_id_xfile FROM xtouch($RANDOM, $ID_MIMETYPE)")
            dieifnzero $? "unable to create xfile" "xfile id ... $ID_XFILE"

            # file
            ID_FILE=$($PSQL_FULL_CMD -c "SELECT out_id_inode FROM touch($ID_USER, ${ID_INIT_DIR[$dir]}, '$base.$ext')")
            dieifnzero $? "unable to create file '$base.$ext'" "file '$base.$ext' id ... $ID_FILE"

            # link
            XLINK=$($PSQL_FULL_CMD -c "SELECT xlink($ID_FILE, $ID_XFILE)")
            dieifnzero $? "unable to link $ID_FILE to xfile $ID_XFILE"

            # xfile for overwrite
            ID_XFILE=$($PSQL_FULL_CMD -c "SELECT out_id_xfile FROM xtouch($RANDOM, $ID_MIMETYPE)")
            dieifnzero $? "unable to create xfile" "xfile id ... $ID_XFILE"

            # xlink for overwrite
            XLINK=$($PSQL_FULL_CMD -c "SELECT xlink($ID_FILE, $ID_XFILE)")
            dieifnzero $? "unable to link $ID_FILE to xfile $ID_XFILE for overwrite"
         done
    done
done

# -- truncate ------------------------------------------------------------------

#$PSQL_FULL_CMD -c "TRUNCATE inode CASCADE"
#$PSQL_FULL_CMD -c "TRUNCATE volume CASCADE"

# -- exit ----------------------------------------------------------------------

exit 0
