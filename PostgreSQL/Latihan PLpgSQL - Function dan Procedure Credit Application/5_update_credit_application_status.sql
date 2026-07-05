CREATE OR REPLACE PROCEDURE fifapp_credit_db.update_credit_application_status(
	p_application_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_customer_birth_date DATE;
	v_customer_monthly_income NUMERIC;
	v_application_loan_amount NUMERIC;
	v_application_tenor_months NUMERIC;

	v_customer_age INTEGER;
	v_monthly_installment NUMERIC(18, 2);
	v_dbr_percentage NUMERIC(18, 2);
	v_credit_status VARCHAR;
BEGIN
	SELECT
		c.birth_date,
		c.monthly_income,
		ca.loan_amount,
		ca.tenor_months
	INTO 
		v_customer_birth_date,
		v_customer_monthly_income,
		v_application_loan_amount,
		v_application_tenor_months
	FROM fifapp_credit_db.credit_applications ca
	JOIN fifapp_credit_db.customers c
		ON ca.customer_id = c.id
	WHERE ca.id = p_application_id;

	v_customer_age := EXTRACT(YEAR FROM AGE(v_customer_birth_date))::INTEGER;
	v_monthly_installment := calculate_monthly_installment(
		v_application_loan_amount, v_application_tenor_months
	);
	v_dbr_percentage := calculate_dbr(
		v_monthly_installment, v_customer_monthly_income
	);
	v_credit_status := determine_credit_status(
		v_dbr_percentage, v_customer_age, v_customer_monthly_income
	);

--	RAISE NOTICE 'v_customer_age: %', v_customer_age;
--	RAISE NOTICE 'v_monthly_installment: %', v_monthly_installment;
--	RAISE NOTICE 'v_dbr_percentage: %', v_dbr_percentage;
--	RAISE NOTICE 'v_credit_status: %', v_credit_status;

	UPDATE fifapp_credit_db.credit_applications uca
		SET
			status = v_credit_status,
			approved_at = CASE
				WHEN v_credit_status = 'APPROVED' THEN NOW()
				ELSE NULL
			END,
		    rejected_at = CASE 
		        WHEN v_credit_status = 'REJECTED' THEN NOW()
		        ELSE NULL
		    END,
		    manual_review_at = CASE 
		        WHEN v_credit_status = 'MANUAL_REVIEW' THEN NOW()
		        ELSE NULL
		    END,
		    cancelled_at = CASE 
		        WHEN v_credit_status = 'CANCELLED' THEN NOW()
		        ELSE NULL
		    END,
		    decision_reason = CASE
		        WHEN v_credit_status = 'APPROVED' THEN 'Meets all criteria'
		        WHEN v_credit_status = 'REJECTED' THEN 'High DBR or not eligible'
		        WHEN v_credit_status = 'MANUAL_REVIEW' THEN 'Needs further review'
		        WHEN v_credit_status = 'CANCELLED' THEN 'Application cancelled'
		        ELSE NULL
		    END,
		    updated_at = NOW()
		WHERE uca.id = p_application_id;
END;
$$;

--
CALL fifapp_credit_db.update_credit_application_status(40);

SELECT status, approved_at, rejected_at, manual_review_at, decision_reason
FROM fifapp_credit_db.credit_applications
WHERE id = 40;