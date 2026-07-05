CREATE OR REPLACE FUNCTION fifapp_credit_db.calculate_dbr(
	p_monthly_installment NUMERIC,
	p_monthly_income NUMERIC
)
RETURNS NUMERIC(18, 2)
LANGUAGE plpgsql
AS $$
DECLARE
    dbr_percentage NUMERIC(18,2);
BEGIN
    dbr_percentage := ROUND(
        (p_monthly_installment / p_monthly_income) * 100, 
        2
    );
    RETURN dbr_percentage;
END;
$$;

--
SELECT fifapp_credit_db.calculate_dbr(3000000, 8000000);