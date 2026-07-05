CREATE OR REPLACE PROCEDURE fifapp_credit_db.finalize_credit_application(
	p_application_id BIGINT,
	p_processed_by_user_id BIGINT
)
LANGUAGE plpgsql
AS $$
DECLARE
	v_customer_birth_date DATE;
	v_customer_monthly_income NUMERIC;
	v_application_vehicle_price NUMERIC;
	v_application_dp_amount NUMERIC;
	v_application_loan_amount NUMERIC;
	v_application_tenor_months INTEGER;
	-- For audit_logs
	v_application_status VARCHAR;

	v_customer_age INTEGER;
	v_monthly_installment NUMERIC(18, 2);
	v_dbr_percentage NUMERIC(18, 2);
	v_credit_status VARCHAR;

	v_income_score INTEGER;
	v_age_score INTEGER;
	v_loan_amount_score INTEGER;
	v_dbr_score INTEGER;
	v_raw_risk_score INTEGER;

	v_risk_score INTEGER;
	v_risk_level VARCHAR;
	v_risk_notes TEXT;
	v_risk_assessment_id BIGINT;
	v_stored_dbr_percentage NUMERIC(5, 2);
	v_decision_reason TEXT;

	-- For audit_logs
	v_audit_action VARCHAR;
BEGIN
	IF p_application_id IS NULL	
		THEN RAISE EXCEPTION 'Application ID cannot be null'
			USING ERRCODE = '22004';
	END IF;

	IF p_processed_by_user_id IS NULL
		THEN RAISE EXCEPTION 'Processed by user ID cannot be null'
			USING ERRCODE = '22004';
	END IF;

	IF NOT EXISTS (
		SELECT 1
		FROM fifapp_credit_db.users
		WHERE id = p_processed_by_user_id
	) THEN RAISE EXCEPTION 'Processed by user not found: %', p_processed_by_user_id
		USING ERRCODE = 'P0002';
	END IF;

	-- MUST HAVE
    IF EXISTS (
        SELECT 1
        FROM fifapp_credit_db.risk_assessments
        WHERE credit_application_id = p_application_id
    ) THEN
		RAISE EXCEPTION 'Risk assessment already exists for application ID: %', p_application_id
			USING ERRCODE = '23505';
    END IF;

	SELECT
		c.birth_date,
		c.monthly_income,
		ca.status,
		ca.vehicle_price,
		ca.dp_amount,
		ca.loan_amount,
		ca.tenor_months
	INTO
		v_customer_birth_date,
		v_customer_monthly_income,
		v_application_status,
		v_application_vehicle_price,
		v_application_dp_amount,
		v_application_loan_amount,
		v_application_tenor_months
	FROM fifapp_credit_db.credit_applications ca
	JOIN fifapp_credit_db.customers c
		ON ca.customer_id = c.id
    WHERE ca.id = p_application_id
	FOR UPDATE OF ca;

	IF v_customer_birth_date IS NULL
		THEN RAISE EXCEPTION 'Customer birth date cannot be null for application ID: %', p_application_id
			USING ERRCODE = '22004';
	END IF;

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

	v_income_score := CASE
		WHEN v_customer_monthly_income < 3000000 THEN 0
		WHEN v_customer_monthly_income < 5000000 THEN 60
		ELSE 100
		END;
	v_age_score := CASE
		WHEN v_customer_age < 21 THEN 0
		WHEN v_customer_age < 25 THEN 60
		ELSE 100
		END;
	v_loan_amount_score := CASE
		WHEN v_application_loan_amount <= (v_customer_monthly_income * 12) THEN 100
		WHEN v_application_loan_amount <= (v_customer_monthly_income * 36) THEN 60
		ELSE 30
		END;
	v_dbr_score := CASE
		WHEN v_dbr_percentage <= 35 THEN 100
		WHEN v_dbr_percentage <= 50 THEN 60
		ELSE 0
		END;

	v_raw_risk_score := ROUND(
	    (v_income_score + v_age_score + v_loan_amount_score + v_dbr_score) / 4.0
	)::INTEGER;

	v_risk_score := CASE
	    WHEN v_credit_status = 'APPROVED'
	        THEN GREATEST(v_raw_risk_score, 70)
	    WHEN v_credit_status = 'MANUAL_REVIEW'
	        THEN LEAST(GREATEST(v_raw_risk_score, 45), 69)
	    ELSE LEAST(v_raw_risk_score, 44)
	END;
	v_risk_level := CASE
	    WHEN v_risk_score >= 70 THEN 'LOW'
	    WHEN v_risk_score >= 45 THEN 'MEDIUM'
	    ELSE 'HIGH'
	END;
	v_stored_dbr_percentage := LEAST(v_dbr_percentage, 999.99)::NUMERIC(5, 2);
	
	v_decision_reason := CASE
	    WHEN v_customer_age < 21
	        THEN 'Rejected due to minimum age policy'
	    WHEN v_customer_monthly_income < 3000000
	        THEN 'Rejected due to minimum salary policy'
	    WHEN v_dbr_percentage <= 35
	        THEN 'Eligible based on age, salary, and DBR policy'
	    WHEN v_dbr_percentage <= 50
	        THEN 'Needs analyst review due to DBR policy'
	    ELSE 'Rejected due to DBR policy'
	END;
    v_risk_notes := FORMAT(
        'Finalized by procedure. Monthly installment: %s, actual DBR: %s%%, stored DBR: %s%%.',
        v_monthly_installment,
        v_dbr_percentage,
        v_stored_dbr_percentage
    );

--	RAISE NOTICE 'v_raw_risk_score: %', v_raw_risk_score;
--	RAISE NOTICE 'v_risk_level: %', v_risk_level;

	INSERT INTO fifapp_credit_db.risk_assessments (
        credit_application_id,
        assessed_by,
        risk_score,
        risk_level,
        decision,
        income_score,
        age_score,
        loan_amount_score,
        dbr_score,
        previous_payment_score,
        dbr_percentage,
        notes,
        assessed_at,
        created_at,
        updated_at
    ) VALUES (
        p_application_id,
        p_processed_by_user_id,
        v_risk_score,
        v_risk_level,
        v_credit_status,
        v_income_score,
        v_age_score,
        v_loan_amount_score,
        v_dbr_score,
        NULL,
        v_stored_dbr_percentage,
        v_risk_notes,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP,
        CURRENT_TIMESTAMP
    )
    RETURNING id INTO v_risk_assessment_id;

	UPDATE fifapp_credit_db.credit_applications
	SET
		loan_amount = v_application_loan_amount,
		approved_amount = CASE
			WHEN v_credit_status = 'APPROVED' THEN v_application_loan_amount
			ELSE NULL
		END,
		status = v_credit_status,
		approved_at = CASE
			WHEN v_credit_status = 'APPROVED' THEN CURRENT_TIMESTAMP
			ELSE NULL
		END,
		rejected_at = CASE
			WHEN v_credit_status = 'REJECTED' THEN CURRENT_TIMESTAMP
			ELSE NULL
		END,
		manual_review_at = CASE
			WHEN v_credit_status = 'MANUAL_REVIEW' THEN CURRENT_TIMESTAMP
			ELSE NULL
		END,
		cancelled_at = NULL,
		decision_reason = v_decision_reason,
		updated_at = CURRENT_TIMESTAMP
	WHERE id = p_application_id;

	IF v_credit_status = 'APPROVED'
		THEN CALL generate_installments(p_application_id);
	END IF;

	v_audit_action := CASE
		WHEN v_credit_status = 'APPROVED' THEN 'APPROVE'
		WHEN v_credit_status = 'REJECTED' THEN 'REJECT'
		ELSE 'UPDATE'
	END;

	INSERT INTO fifapp_credit_db.audit_logs (
		user_id,
		entity_name,
		entity_id,
		"action",
		old_value,
		new_value,
		created_at
	) VALUES (
		p_processed_by_user_id,
		'credit_applications',
		p_application_id,
		v_audit_action,
		JSON_BUILD_OBJECT(
			'status', v_application_status,
			'loan_amount', v_application_loan_amount
		)::TEXT,
		JSON_BUILD_OBJECT(
			'status', v_credit_status,
			'loan_amount', v_loan_amount,
			'monthly_installment', v_monthly_installment,
			'dbr_percentage', v_dbr_percentage,
			'risk_assessment_id', v_risk_assessment_id
		)::TEXT,
		CURRENT_TIMESTAMP
	);
END;
$$;

--
CALL fifapp_credit_db.finalize_credit_application(392052, 1);

SELECT * FROM fifapp_credit_db.risk_assessments
WHERE credit_application_id = 1;
--
DELETE FROM fifapp_credit_db.risk_assessments
WHERE credit_application_id = 1;

SELECT * FROM fifapp_credit_db.credit_applications
WHERE id = 392052;
--
DELETE FROM fifapp_credit_db.installments 
WHERE credit_application_id = 1;