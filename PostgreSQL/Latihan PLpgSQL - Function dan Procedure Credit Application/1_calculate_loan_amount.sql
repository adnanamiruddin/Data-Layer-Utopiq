CREATE OR REPLACE FUNCTION fifapp_credit_db.calculate_loan_amount(
	p_vehicle_price NUMERIC,
	p_dp_amount NUMERIC
)
RETURNS NUMERIC(18, 2)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN ROUND(p_vehicle_price - p_dp_amount, 2);
END;
$$;

--
SELECT fifapp_credit_db.calculate_loan_amount(8000000, 2000000);