-- Mike's Misc
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 23/03/2011
-- copyright: All rights reserved

LOAD 'auto_explain';
SET auto_explain.log_min_duration       = 1;
SET auto_explain.log_analyze            = true;
SET auto_explain.log_nested_statements  = true;
SET client_min_messages                 = 'log';
SET log_min_messages                    = 'log';

-- turn paging off to see logs and timing on
\pset pager off
\timing on
