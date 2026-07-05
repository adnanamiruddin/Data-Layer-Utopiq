SET search_path TO fifapp_credit_db;

SELECT tablename
FROM pg_tables 
WHERE schemaname = 'fifapp_credit_db';

SELECT *
FROM information_schema.columns
WHERE table_name = 'customers';

--
EXPLAIN SELECT full_name FROM customers
	WHERE full_name = 'customers 1';

EXPLAIN SELECT COUNT(*) FROM customers;

-- Comparasi durasi ada index vs tidak ada index
-- index untuk mempercepat pencarian
EXPLAIN ANALYZE SELECT full_name FROM customers
	WHERE full_name = 'Customer 3';
-- -> Execution Time: 1.533 ms

CREATE INDEX idx_customers_full_name
	ON customers(full_name);

EXPLAIN ANALYZE SELECT full_name FROM customers
	WHERE full_name = 'Customer 3';
-- -> Execution Time: 0.096 ms

DROP INDEX idx_customers_full_name;

-- Exercise 1
EXPLAIN ANALYZE SELECT * FROM installments
	WHERE status = 'PAID'
		AND due_date = '2024-09-20'
-- -> Execution Time: 38.665 ms
		
CREATE INDEX idx_installments_status
	ON installments(status);
CREATE INDEX idx_installments_due_date
	ON installments(due_date);
--
DROP INDEX IF EXISTS idx_installments_status;
DROP INDEX IF EXISTS idx_installments_due_date;

CREATE INDEX idx_installments_status_due_date
	ON installments(status, due_date);
--
DROP INDEX IF EXISTS idx_installments_status_due_date;

CREATE INDEX idx_installments_due_date_status
	ON installments(due_date, status);
--
DROP INDEX IF EXISTS idx_installments_due_date_status;

EXPLAIN ANALYZE SELECT * FROM installments
	WHERE status = 'PAID'
		AND due_date = '2024-09-20'
-- -> Execution Time: 1.818 ms (single)
-- -> Execution Time: 0.405 ms (composit (status, due_date))
-- -> Execution Time: 0.321 ms (composit (due_date, status))







