
DROP FUNCTION IF EXISTS mike.after_insert_delete_file() CASCADE;

CREATE OR REPLACE FUNCTION mike.after_insert_delete_file(
) RETURNS trigger AS $__$

my $treepath;
$treepath = $_TD->{new}{treepath};
$treepath = $_TD->{old}{treepath} unless defined($treepath);

# selecting directories for recalculation
my $select_inode_sql        = <<SQL;

    SELECT id_inode
    FROM mike.directory
    WHERE
        treepath @> '$treepath'::ltree
        AND
        id_inode != id_inode_parent
    ORDER BY nlevel(treepath) DESC FOR UPDATE

SQL

my $select_inode_request    = spi_query($select_inode_sql);

my $row;
my $file_data_plan;
my $directory_data_plan;
my $directory_update_plan;

while (defined($row = spi_fetchrow($select_inode_request)))
{
    # plans
    if (!defined($file_data_plan))
    {
        # -- file data plan  ---------------------------------------------------

        my $file_data_sql = <<SQL;

    SELECT
        COUNT(id_inode)                     AS count,
        COALESCE(SUM(size), 0)              AS size,
        COALESCE(SUM(versioning_size), 0)   AS versioning_size
    FROM mike.file
    WHERE id_inode_parent = $row->{id_inode}

SQL

        $file_data_plan = spi_prepare($file_data_sql, 'bigint');

        # -- directory data plan  ----------------------------------------------

        my $directory_data_sql = <<SQL;

    SELECT
        COALESCE(SUM(file_inner_count), 0)          AS file_inner_count,
        COALESCE(SUM(inner_size), 0)                AS inner_size,
        COALESCE(SUM(versioning_inner_size), 0)     AS versioning_inner_size
    FROM mike.directory
    WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode

SQL

        $directory_data_plan = spi_prepare($directory_data_sql, 'bigint');

        # -- directory update plan ---------------------------------------------

        my $directory_update_sql = <<SQL;

    UPDATE mike.directory SET
        file_count              = \$2,
        file_inner_count        = \$3,
        size                    = \$4,
        inner_size              = \$5,
        versioning_size         = \$6,
        versioning_inner_size   = \$7
    WHERE id_inode = \$1;

SQL
        $directory_update_plan = spi_prepare($directory_update_sql,
            'bigint',   # id_inode
            'bigint',   # directory file count
            'bigint',   # directory file inner count
            'bigint',   # directory size
            'bigint',   # directory inner size
            'bigint',   # directory versioning size
            'bigint'    # directory versioning inner size
        );
    }

    # plans execution
    my $file_data_request           = spi_exec_prepared($file_data_plan, $row->{id_inode});
    my $directory_data_request      = spi_exec_prepared($directory_data_plan, $row->{id_inode});
    my $directory_update_request    = spi_exec_prepared($directory_update_plan,
        $row->{id_inode},
        $file_data_request->{rows}[0]{count},
        $file_data_request->{rows}[0]{count} + $directory_data_request->{rows}[0]{file_inner_count},
        $file_data_request->{rows}[0]{size},
        $file_data_request->{rows}[0]{size} + $directory_data_request->{rows}[0]{inner_size},
        $file_data_request->{rows}[0]{versioning_size},
        $file_data_request->{rows}[0]{versioning_size} + $directory_data_request->{rows}[0]{versioning_inner_size}
    );
}

return undef;

$__$ LANGUAGE plperl;

COMMENT ON FUNCTION mike.after_insert_delete_file() IS 'this function is called by the trigger on file when an insert or delete is made';

CREATE TRIGGER after_insert_delete_file AFTER INSERT OR DELETE ON mike.file
FOR EACH ROW EXECUTE PROCEDURE mike.after_insert_delete_file();

