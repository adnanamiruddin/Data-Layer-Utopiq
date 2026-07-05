CREATE OR REPLACE FUNCTION fifapp_credit_db.count_credit_applications_by_status(
	p_status VARCHAR,
	p_schema VARCHAR,
	p_table VARCHAR
)
RETURNS BIGINT
LANGUAGE plpgsql
AS $$
DECLARE
	v_sql TEXT;
	v_total_applications BIGINT;
BEGIN
	IF p_status IS NULL THEN
			RAISE EXCEPTION 'Status cannot be null'
				USING ERRCODE = '22004';
	END IF;

--	v_sql := FORMAT(
--		'SELECT COUNT(*) FROM %I.%I WHERE status = $1',
--		'fifapp_credit_db',
--		'credit_applications'
--	);

	v_sql := FORMAT(
		'SELECT COUNT(*) FROM %I.%I WHERE status = $1',
		p_schema,
		p_table
	);
	
	EXECUTE v_sql
	INTO v_total_applications
	USING p_status;
	
	RETURN v_total_applications;
END;
$$;

COMMENT ON FUNCTION fifapp_credit_db.count_credit_applications_by_status(VARCHAR)
IS 'Simple dynamic demo that counts credit applications by status';





