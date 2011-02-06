-- Mike
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 06/02/2011
-- copyright: All rights reserved

INSERT INTO volume (path) VALUES ('/exports/nas01/enclosure01/');
INSERT INTO volume (path) VALUES ('/exports/nas01/enclosure02/');
INSERT INTO volume (path) VALUES ('/exports/nas01/enclosure03/');
UPDATE volume SET state = 0, max_size = 123456789;

SELECT * FROM mkdir(1, 'root');
SELECT * FROM xtouch(123456, 56);
SELECT * FROM touch(1, 1, 'test');
