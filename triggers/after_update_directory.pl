-- # Mike's Trigger
-- # author: Sylvain Rabot <sylvain@abstraction.fr>
-- # date: 16/07/2010
-- # copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.after_update_directory() CASCADE;

CREATE OR REPLACE FUNCTION mike.after_update_directory(
) RETURNS trigger AS $__$

# updating path
if ($_TD->{event} eq 'UPDATE' && $_TD->{old}{name} ne $_TD->{new}{name})
{
    my $new_path    = $_TD->{old}{path};
    $new_path       =~ s#^(.*)/([^/]+)#$1/$_TD->{new}{name}#;
    my $sql         = <<SQL;
        
    UPDATE mike.inode SET 
        path = regexp_replace(path, '^($_TD->{old}{path})(.*)\$', E'$new_path\\\\2') 
    WHERE treepath ~ '$_TD->{old}{treepath}.*';

SQL
    
    spi_exec_query($sql);

    return "MODIFY";
}

return undef;

$__$ LANGUAGE plperl;

CREATE TRIGGER after_update_directory AFTER UPDATE ON mike.directory
FOR EACH ROW EXECUTE PROCEDURE mike.after_update_directory();

