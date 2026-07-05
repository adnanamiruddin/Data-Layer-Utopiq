CREATE OR REPLACE FUNCTION fifapp_credit_db.calculate_monthly_installment(
	p_loan_amount NUMERIC,
	p_tenor_months INTEGER
)
RETURNS NUMERIC(18, 2)
LANGUAGE plpgsql
AS $$
BEGIN
	RETURN ROUND(p_loan_amount / p_tenor_months, 2);
END;
$$;

--
SELECT fifapp_credit_db.calculate_monthly_installment(8000000, 12);