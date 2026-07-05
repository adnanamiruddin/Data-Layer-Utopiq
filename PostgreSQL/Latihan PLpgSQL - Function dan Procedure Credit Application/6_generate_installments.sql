CREATE OR REPLACE PROCEDURE fifapp_credit_db.generate_installments(
	p_application_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_application_application_date DATE;
	v_application_loan_amount NUMERIC;
	v_application_tenor_months NUMERIC;
	v_application_status VARCHAR;

    v_existing_installments INTEGER;
	v_monthly_installment NUMERIC(18, 2);
	v_i INTEGER;
	v_due_date DATE;
BEGIN
	SELECT
		ca.application_date,
		ca.loan_amount,
		ca.tenor_months,
		ca.status
	INTO 
		V_application_application_date,
		v_application_loan_amount,
		v_application_tenor_months,
		v_application_status
	FROM fifapp_credit_db.credit_applications ca
	WHERE ca.id = p_application_id;

--	RAISE NOTICE 'v_application_application_date: %', v_application_application_date;
--	RAISE NOTICE 'v_application_loan_amount: %', v_application_loan_amount;
--	RAISE NOTICE 'v_application_tenor_months: %', v_application_tenor_months;
--	RAISE NOTICE 'v_application_status: %', v_application_status;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Credit application not found: %', p_application_id
            USING ERRCODE = 'P0002';
    END IF;

    IF v_application_status <> 'APPROVED' THEN
        RAISE EXCEPTION 'Installments can only be generated for APPROVED applications. Application ID %, current status: %',
            p_application_id,
            v_application_status
            USING ERRCODE = '23514';
    END IF;

    SELECT COUNT(*)
    INTO v_existing_installments
    FROM fifapp_credit_db.installments
    WHERE credit_application_id = p_application_id;

    IF v_existing_installments > 0 THEN
        RAISE EXCEPTION 'Installments already exist for application ID: %', p_application_id
            USING ERRCODE = '23505';
    END IF;

	v_monthly_installment := calculate_monthly_installment(
		v_application_loan_amount, v_application_tenor_months
	);

--	RAISE NOTICE 'v_monthly_installment: %', v_monthly_installment;

	LOCK TABLE fifapp_credit_db.installments IN EXCLUSIVE MODE;

	FOR v_i IN 1..v_application_tenor_months LOOP
		v_due_date := v_application_application_date + (v_i || 'month')::INTERVAL;
	
		INSERT INTO fifapp_credit_db.installments (
            credit_application_id,
            installment_number,
            due_date,
            amount,
            paid_amount,
            outstanding_amount,
            payment_date,
            days_overdue,
            status,
            created_at,
            updated_at
		) VALUES (
			p_application_id,
			v_i,
			v_due_date,
			v_monthly_installment,
			0,
			v_monthly_installment,
			NULL,
			0,
			'UNPAID',
			NOW(),
			NOW()
		);
	END LOOP;
END;
$$;

--
CALL fifapp_credit_db.generate_installments(40);

SELECT * FROM fifapp_credit_db.installments
	WHERE credit_application_id = 40;