CREATE OR REPLACE FUNCTION say_hello()
RETURNS TEXT
LANGUAGE plpgsql
AS $$
BEGIN 
	RETURN 'Hello from PostgreSQL';
END;
$$;

SELECT say_hello();

--
CREATE OR REPLACE FUNCTION calculate_max_installment(
	monthly_income NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN 
	RETURN monthly_income * 0.3;
END;
$$;

SELECT calculate_max_installment(7900000);

--
CREATE OR REPLACE FUNCTION calculate_down_payment(
	vehicle_price NUMERIC,
	dp_percentage NUMERIC
)
RETURNS NUMERIC
LANGUAGE plpgsql
AS $$
BEGIN 
	RETURN vehicle_price * dp_percentage / 100;
END;
$$;

SELECT calculate_down_payment(10000000, 20);

--
CREATE OR REPLACE client_min_messages TO NOTICE;
DO $$
DECLARE
	score INT := 80;
BEGIN
	IF score >= 75 THEN
		RAISE NOTICE 'Lulus';
	ELSE
		RAISE NOTICE 'Tidak Lulus';
	END IF;
END $$;








