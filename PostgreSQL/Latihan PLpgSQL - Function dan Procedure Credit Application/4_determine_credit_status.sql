CREATE OR REPLACE FUNCTION fifapp_credit_db.determine_credit_status(
	p_dbr_percentage NUMERIC,
	p_customer_age INTEGER,
	p_monthly_salary NUMERIC
)
RETURNS VARCHAR
LANGUAGE plpgsql
AS $$
DECLARE
	v_status VARCHAR;
	v_minimum_dbr_to_approved NUMERIC := 35;
	v_minimum_dbr_to_manual_review NUMERIC := 50;
BEGIN
    v_status := CASE
        WHEN p_customer_age < 21 OR p_monthly_salary < 3000000
			THEN 'REJECTED'
        WHEN p_dbr_percentage <= v_minimum_dbr_to_approved
			THEN 'APPROVED'
        WHEN p_dbr_percentage > v_minimum_dbr_to_approved
				AND p_dbr_percentage <= v_minimum_dbr_to_manual_review
			THEN 'MANUAL_REVIEW'
        WHEN p_dbr_percentage > v_minimum_dbr_to_manual_review
			THEN 'REJECTED'
        ELSE 'REJECTED'
    END;
    RETURN v_status;
END;
$$;

--
SELECT fifapp_credit_db.determine_credit_status(0.45, 22, 5000000);