SET search_path TO fifapp_credit_db;

-- 1
CREATE OR REPLACE FUNCTION fifapp_credit_db.insert_or_update_loan_amount()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $$
BEGIN
    NEW.loan_amount := fifapp_credit_db.calculate_loan_amount(
        NEW.vehicle_price,
        NEW.dp_amount
    );
    RETURN NEW;
END;
$$;

CREATE OR REPLACE TRIGGER trigger_insert_or_update_calculated_loan_amount
--BEFORE INSERT OR UPDATE ON fifapp_credit_db.credit_applications
BEFORE INSERT OR UPDATE
	OF vehicle_price, dp_amount
	ON fifapp_credit_db.credit_applications
FOR EACH ROW
EXECUTE FUNCTION fifapp_credit_db.insert_or_update_loan_amount();

--DROP TRIGGER IF EXISTS trigger_insert_calculated_loan_amount 
--ON fifapp_credit_db.credit_applications;

INSERT INTO fifapp_credit_db.credit_applications (
    application_number,
    customer_id,
    vehicle_id,
    branch_id,
    created_by,
    application_date,
    vehicle_price,
    dp_amount,
    loan_amount,
    tenor_months,
    interest_rate,
    status
)
VALUES (
    'APP-009',
    1,
    101,
    10,
    1,
    CURRENT_DATE,
    32000000, -- vehicle_price
    12000000, -- dp_amount
    0, -- loan_amount
    12, -- tenor_months
    5.5, -- interest_rate
    'SUBMITTED'
);

UPDATE fifapp_credit_db.credit_applications
	SET dp_amount = 9000000, vehicle_price = 49000000
	WHERE application_number = 'APP-008';

SELECT * FROM fifapp_credit_db.credit_applications
	ORDER BY id DESC;









