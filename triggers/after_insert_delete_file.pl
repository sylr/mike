
DROP FUNCTION IF EXISTS mike.after_insert_delete_file() CASCADE;

CREATE OR REPLACE FUNCTION mike.after_insert_delete_file(
) RETURNS trigger AS $__$

my $treepath;
$treepath = $_TD->{new}{treepath};
$treepath = $_TD->{old}{treepath} unless defined($treepath);

# recalculating directory size and sub inodes counts
my $select_inode_sql        = "SELECT id_inode FROM directory WHERE treepath @> subpath('$treepath'::ltree, 0, -1) ORDER BY nlevel(treepath) DESC";
my $select_inode_request    = spi_query($select_inode_sql);

while (defined($row = spi_fetchrow($select_inode_request)))
{
    my $file_data_sql       = <<SQL;

    SELECT
        COUNT(id_inode) AS count,
        COALESCE(SUM(size), 0) AS size,
        COALESCE(SUM(versioning_size), 0) AS versioning_size
    FROM mike.file
    WHERE id_inode_parent = $row->{id_inode}

SQL

    my $file_data_request   = spi_exec_query($file_data_sql);
    
    my $update_directory_sql = <<SQL;

    UPDATE mike.directory SET 
        dir_count               =
                (SELECT COUNT(id_inode) FROM mike.directory WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode),
        dir_inner_count         =
                (SELECT COALESCE(SUM(dir_inner_count), 0) + COUNT(id_inode) FROM mike.directory WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode),
        file_count              =
                $file_data_request->{rows}[0]{count},
        file_inner_count        =
                (SELECT COALESCE(SUM(file_inner_count), 0) + $file_data_request->{rows}[0]{count} FROM mike.directory WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode)
        size                    =
                $file_data_request->{rows}[0]{size},
        inner_size              =
                (SELECT COALESCE(SUM(inner_size), 0) + $file_data_request->{rows}[0]{size} FROM mike.directory WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode),
        versioning_size         =
                $file_data_request->{rows}[0]{versioning_size},
        versioning_inner_size   =
                (SELECT COALESCE(SUM(versioning_inner_size), 0) + $file_data_request->{rows}[0]{versioning_size} FROM mike.directory WHERE id_inode_parent = $row->{id_inode} AND id_inode_parent != id_inode),
    WHERE id_inode = $row->{id_inode};

SQL

    #elog(INFO, $update_directory_sql);
    spi_exec_query($update_directory_sql);
}

return undef;

$__$ LANGUAGE plperl;

CREATE TRIGGER after_insert_delete_file AFTER INSERT OR DELETE ON mike.file
FOR EACH ROW EXECUTE PROCEDURE mike.after_insert_delete_file();

