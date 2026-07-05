SET client_min_messages TO NOTICE; 

DO $$
DECLARE
	message VARCHAR(20) := 'Hello, World';
BEGIN
	RAISE NOTICE '%', message;
END $$;

--
DO $$
DECLARE
	customer_name VARCHAR := 'Rina';
	salary INTEGER := 9000000;
BEGIN
	RAISE NOTICE 'Customer: %, Salary %', customer_name, salary;
	RAISE NOTICE 'Thank you';
END $$;
