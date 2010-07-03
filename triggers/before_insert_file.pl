
DROP FUNCTION IF EXISTS mike.before_insert_file() CASCADE;

CREATE OR REPLACE FUNCTION mike.before_insert_file(
) RETURNS trigger AS $__$

# checking name
if (!defined($_TD->{new}{name}) || length($_TD->{new}{name}) == 0 || $_TD->{new}{name} =~ m#^.*/.*$#)
{
    elog(ERROR, "directory name '$_TD->{new}{name}' not compliant");
}

# input
my $id_inode_parent = $_TD->{new}{id_inode_parent};
my $path;
my $treepath;

if (defined($id_inode_parent))
{
    # folder depth check
    my $sql     = "SELECT treepath, path FROM mike.directory WHERE id_inode = $id_inode_parent";
    my $request = spi_exec_query($sql);

    if ($request->{processed} == 0)
    {
        elog(ERROR, "id_inode_parent '$id_inode_parent' does not exist");
    }
    else
    {
        $path           = $request->{rows}[0]{path};
        $treepath       = $request->{rows}[0]{treepath};
        my @id_inodes   = split('.', $treepath);
        
        if ($id_inodes >= 20)
        {
            elog(ERROR, "treepath too deep");
        }
        
        $treepath   .= ".";
    }
}
else
{
    $path       = "";
    $treepath   = "";
}

# id_inode
my $id_inode_sql                = "SELECT nextval('inode_id_inode_seq'::regclass) AS id_inode;";
my $id_inode_request            = spi_exec_query($id_inode_sql);
my $id_inode                    = $id_inode_request->{rows}[0]{id_inode};

# update trigger values
$_TD->{new}{id_inode}           = $id_inode;
$_TD->{new}{path}               = $path."/".$_TD->{new}{name};
$_TD->{new}{treepath}           = $treepath.$_TD->{new}{id_inode};

return "MODIFY";

$__$ LANGUAGE plperl;

CREATE TRIGGER before_insert_file BEFORE INSERT ON mike.file
FOR EACH ROW EXECUTE PROCEDURE mike.before_insert_file();


