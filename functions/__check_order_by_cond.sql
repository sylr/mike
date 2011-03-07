-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 04/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.__check_order_by_cond(
    in_order_by         text,
    in_relname          text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__check_order_by_cond(
    in_order_by         text,
    in_relname          text
) RETURNS void AS $__$

DECLARE
    v_cond          text;
    v_text_array    text[];
    v_schema        text;
    v_relname       text;
    v_column        text;
    v_sort          text;
BEGIN
    IF in_order_by IS NULL OR in_order_by = '' THEN
        RAISE EXCEPTION 'sort option can not be empty';
    END IF;

    FOR v_cond IN SELECT regexp_split_to_table(in_order_by, E'\\s*,\\s*') LOOP
        SELECT regexp_split_to_array(v_cond, E'\\s+') INTO v_text_array;

        v_column    := v_text_array[1];
        v_sort      := v_text_array[2];

        IF strpos(in_relname, '.') > 0 THEN
            v_schema    := substring(in_relname, 0, strpos(in_relname, '.'));
            v_relname   := substring(in_relname, strpos(in_relname, '.') + 1);
        ELSE
            v_schema    := 'mike';
            v_relname   := in_relname;
        END IF;

        PERFORM
            pg_catalog.pg_class.oid,
            pg_catalog.pg_namespace.nspname,
            pg_catalog.pg_class.relname,
            pg_catalog.pg_attribute.*
        FROM pg_catalog.pg_class
             LEFT JOIN pg_catalog.pg_namespace ON pg_catalog.pg_namespace.oid = pg_catalog.pg_class.relnamespace
             LEFT JOIN pg_catalog.pg_attribute ON pg_catalog.pg_attribute.attrelid = pg_catalog.pg_class.oid
        WHERE
            pg_catalog.pg_namespace.nspname = v_schema AND
            pg_catalog.pg_class.relname     = v_relname AND
            pg_catalog.pg_attribute.attname = v_column AND
            pg_catalog.pg_attribute.attnum  > 0;

        IF NOT FOUND THEN RAISE EXCEPTION 'column ''%'' not found in relation %', v_column, in_relname; END IF;

        IF v_sort IS NOT NULL AND v_sort NOT IN ('ASC', 'DESC') THEN
            RAISE EXCEPTION '''%'' not a valid sort option', v_sort;
        END IF;
    END LOOP;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;
