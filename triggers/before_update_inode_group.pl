
DROP FUNCTION IF EXISTS mike.before_update_inode_group() CASCADE;

CREATE OR REPLACE FUNCTION mike.before_update_inode_group(
) RETURNS trigger AS $__$

if ($_TD->{old}{group_readable} ne $_TD->{new}{group_readable})
{
    my @old_array;
    my @new_array;

    if (length($_TD->{old}{group_readable}))
    {
        my $old_group_readable  = $_TD->{old}{group_readable};
        $old_group_readable     = substr $old_group_readable, 1;
        $old_group_readable     = substr $old_group_readable, 0, -1;
        @old_array              = sort(split(',', $old_group_readable));
    }
    else
    {
        @old_array = ();
    }

    if (length($_TD->{new}{group_readable}))
    {
        my $new_group_readable  = $_TD->{new}{group_readable};
        $new_group_readable     = substr $new_group_readable, 1;
        $new_group_readable     = substr $new_group_readable, 0, -1;
        @new_array              = sort(split(',', $new_group_readable));
    }
    else
    {
        @new_array = ();
    }

    for my $new (@new_array)
    {
        if (!grep $_ eq $new, @old_array)
        {
            my $check_group_sql     = "SELECT * FROM mike.group WHERE id_group = $new AND id_user = $_TD->{new}{id_user}";
            my $check_group_request = spi_exec_query($check_group_sql);   

            if (!$check_group_request->{processed})
            {
                elog(ERROR, "id_group '$new' unknown or not associated to user $_TD->{new}{id_user}");
            }
        }
    }
}

return undef;

$__$ LANGUAGE plperl;

CREATE TRIGGER before_update_inode_group BEFORE UPDATE ON mike.inode
FOR EACH ROW EXECUTE PROCEDURE mike.before_update_inode_group();

CREATE TRIGGER before_update_directory_group BEFORE UPDATE ON mike.directory
FOR EACH ROW EXECUTE PROCEDURE mike.before_update_inode_group();

CREATE TRIGGER before_update_file_group BEFORE UPDATE ON mike.file
FOR EACH ROW EXECUTE PROCEDURE mike.before_update_inode_group();

