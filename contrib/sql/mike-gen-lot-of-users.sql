-- Mike's Misc
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 09/03/2011
-- copyright: All rights reserved

INSERT INTO mike.user (id_user_sso, nickname)
WITH last_user_seq AS (
    (
        SELECT 0::bigint AS last
    )
    UNION ALL
    (
        SELECT
            substring(id_user_sso, 6)::bigint AS last
        FROM mike.user
        WHERE
            id_user_sso LIKE 'mike-%'
        ORDER BY __natsort(id_user_sso) DESC
        LIMIT 1
    )
    ORDER BY last DESC
    LIMIT 1
)
SELECT
    'mike-' || generate_series,
    'mike-' || generate_series
FROM generate_series(
    (SELECT last + 1 FROM last_user_seq),
    (SELECT last + 100 FROM last_user_seq)
);
