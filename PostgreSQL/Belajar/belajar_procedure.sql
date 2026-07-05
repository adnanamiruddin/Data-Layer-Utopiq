CREATE OR REPLACE PROCEDURE show_customer_income(
	p_customer_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_customer_name VARCHAR;
	v_monthly_income NUMERIC;
BEGIN
	SELECT full_name, monthly_income
		INTO v_customer_name, v_monthly_income
	FROM fifapp_credit_db.customers
	WHERE id = p_customer_id;

	RAISE NOTICE 'Customer: %, Income: %', v_customer_name, v_monthly_income;
END;
$$;

CALL show_customer_income(1);







