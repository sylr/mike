-- # Mike's Trigger
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 16/07/2010
-- # copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.after_insert_delete_directory() CASCADE;

CREATE OR REPLACE FUNCTION mike.after_insert_delete_directory(
) RETURNS trigger AS $__$

my $id_inode;
my $treepath;
my $operand;

$treepath   = $_TD->{new}{treepath};
$treepath   = $_TD->{old}{treepath} unless defined($treepath);
$id_inode   = $_TD->{new}{id_inode};
$id_inode   = $_TD->{old}{id_inode} unless defined($id_inode);

# selecting directories for recalculation
my $select_inode_sql = <<SQL;

    SELECT id_inode
    FROM mike.directory
    WHERE
        treepath @> '$treepath'::ltree
        AND
        id_inode != $id_inode
    ORDER BY nlevel(treepath) DESC FOR UPDATE

SQL

my $select_inode_request = spi_query($select_inode_sql);

if ($_TD->{new}{treepath} eq 'DELETE')
{
    $operand = '-';
}

my $directory_update_sql = <<SQL;

    UPDATE mike.directory SET
        dir_count               = dir_count + ${operand}1,
        dir_inner_count         = dir_inner_count + ${operand}1
    WHERE id_inode_parent = \$1

SQL

my $row;
my $directory_data_plan;
my $directory_update_plan;

while (defined($row = spi_fetchrow($select_inode_request)))
{
    # plans
    if (!defined($directory_update_plan))
    {
        # -- directory update plan ---------------------------------------------

        my $directory_update_sql = <<SQL;

    UPDATE mike.directory SET
        dir_count               = dir_count + ${operand}1,
        dir_inner_count         = dir_inner_count + ${operand}1
    WHERE id_inode_parent = \$1;

SQL
        $directory_update_plan = spi_prepare($directory_update_sql, 'bigint');
    }

    # plans execution
    my $directory_update_request = spi_exec_prepared($directory_update_plan, $row->{id_inode});
}

return undef;

$__$ LANGUAGE plperl;

COMMENT ON FUNCTION mike.after_insert_delete_directory() IS 'this function is called by the trigger on directory when an insert or delete is made';

CREATE TRIGGER after_insert_delete_directory AFTER INSERT OR DELETE ON mike.directory
FOR EACH ROW EXECUTE PROCEDURE mike.after_insert_delete_directory();

