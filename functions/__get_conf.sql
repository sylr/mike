-- Mike's Function
-- vim: set tabstop=4 expandtab autoindent smartindent:
-- author: Sylvain Rabot <sylvain@abstraction.fr>
-- date: 10/03/2011
-- copyright: All rights reserved

DROP FUNCTION IF EXISTS mike.__get_conf(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      text
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf(
    IN  in_key          text,
    IN  in_mandatory    boolean DEFAULT true,
    IN  in_default      text    DEFAULT NULL
) RETURNS text AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     text;
BEGIN
    SELECT value INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      text
) IS 'get configuration';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.__get_conf_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      text[]
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf_array(
    IN  in_key          text,
    IN  in_mandatory    boolean DEFAULT true,
    IN  in_default      text[]  DEFAULT NULL
) RETURNS text[] AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     text[];
BEGIN
    SELECT value::text[] INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      text[]
) IS 'get configuration and cast it to text array';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.__get_conf_int(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      integer
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf_int(
    IN  in_key          text,
    IN  in_mandatory    boolean DEFAULT true,
    IN  in_default      integer DEFAULT NULL
) RETURNS integer AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     integer;
BEGIN
    SELECT value::integer INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf_int(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      integer
) IS 'get configuration and cast it to integer';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.__get_conf_int_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      integer[]
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf_int_array(
    IN  in_key          text,
    IN  in_mandatory    boolean     DEFAULT true,
    IN  in_default      integer[]   DEFAULT NULL
) RETURNS integer[] AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     integer[];
BEGIN
    SELECT value::integer[] INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf_int_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      integer[]
) IS 'get configuration and cast it to integer array';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.__get_conf_bigint(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      bigint
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf_bigint(
    IN  in_key          text,
    IN  in_mandatory    boolean DEFAULT true,
    IN  in_default      bigint  DEFAULT NULL
) RETURNS bigint AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     bigint;
BEGIN
    SELECT value::bigint INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf_bigint(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      bigint
) IS 'get configuration and cast it to bigint';

--------------------------------------------------------------------------------

DROP FUNCTION IF EXISTS mike.__get_conf_bigint_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      bigint[]
) CASCADE;

CREATE OR REPLACE FUNCTION mike.__get_conf_bigint_array(
    IN  in_key          text,
    IN  in_mandatory    boolean     DEFAULT true,
    IN  in_default      bigint[]    DEFAULT NULL
) RETURNS bigint[] AS $__$

-- Version: MIKE_VERSION

DECLARE
    v_value     bigint[];
BEGIN
    SELECT value::bigint[] INTO v_value FROM mike.conf WHERE key = $1;

    IF FOUND THEN
        RETURN v_value;
    END IF;

    IF in_mandatory THEN
        RAISE EXCEPTION 'configuration ''%'' not found', in_key;
    END IF;

    RETURN in_default;
END;

$__$ LANGUAGE plpgsql STABLE COST 10;

COMMENT ON FUNCTION mike.__get_conf_bigint_array(
    IN  in_key          text,
    IN  in_mandatory    boolean,
    IN  in_default      bigint[]
) IS 'get configuration and cast it to bigint array';
