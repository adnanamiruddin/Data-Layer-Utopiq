SET search_path TO fifapp_credit_db;

-- 1. Customers

-- Pertanyaan 1
EXPLAIN ANALYZE SELECT *
FROM customers
WHERE city = 'Bogor';
-- Buat index agar pencarian customer berdasarkan city lebih cepat
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_customers_city
	ON customers(city);

-- Pertanyaan 2
EXPLAIN ANALYZE SELECT *
FROM customers
WHERE income_range = 'HIGH';
-- Buat index agar filter berdasarkan income_range lebih cepat
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_customers_income_range
	ON customers(income_range);

-- 2. Dealers
-- Pertanyaan 3
EXPLAIN ANALYZE SELECT *
FROM dealers
WHERE city = 'Jakarta'
  AND region = 'Jabodetabek';
-- Buat composite index untuk mempercepat query tersebut
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_dealers_city_region
	ON dealers(city, region);

-- 3. Vehicles
-- Pertanyaan 4
EXPLAIN ANALYZE SELECT *
FROM vehicles
WHERE dealer_id = 10;
-- Buat index untuk mempercepat pencarian kendaraan berdasarkan dealer_id
-- Jawaban
--CREATE INDEX IF NOT EXISTS idx_vehicles_dealer_id
--	ON dealers(dealer_id);

-- Pertanyaan 5
EXPLAIN ANALYZE SELECT *
FROM vehicles
WHERE brand = 'Honda'
  AND model = 'Motor Model 2';
-- Buat composite index untuk mempercepat pencarian berdasarkan brand dan model.
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_vehicles_brand_model
	ON vehicles(brand, model);

-- Pertanyaan 6
EXPLAIN ANALYZE SELECT *
FROM vehicles
WHERE vehicle_type = 'Car'
  AND vehicle_category = 'MPV';
-- Buat composite index untuk mempercepat filter berdasarkan vehicle_type dan vehicle_category
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_vehicles_vehicle_type_vehicle_category
	ON vehicles(vehicle_type, vehicle_category);

-- 4. Credit Applications
-- Pertanyaan 7
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE customer_id = 1001;
-- Buat index untuk mempercepat pencarian berdasarkan customer_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_customer_id 
	ON credit_applications(customer_id);

-- Pertanyaan 8
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE vehicle_id = 501;
-- Buat index untuk mempercepat pencarian berdasarkan vehicle_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_vehicle_id
	ON credit_applications(vehicle_id);

-- Pertanyaan 9
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE branch_id = 3;
-- Buat index untuk mempercepat pencarian berdasarkan branch_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_branch_id
	ON credit_applications(branch_id);

-- Pertanyaan 10
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE created_by = 15;
-- Buat index untuk mempercepat pencarian berdasarkan created_by
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_created_by
	ON credit_applications(created_by);

-- Pertanyaan 11
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE application_date = DATE '2026-06-01';
-- Buat index untuk mempercepat pencarian berdasarkan application_date
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_application_date
	ON credit_applications(application_date);

-- Pertanyaan 12
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE status = 'REJECTED';
-- Buat index untuk mempercepat filter berdasarkan status
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_status
	ON credit_applications(status);

-- Pertanyaan 13
EXPLAIN ANALYZE SELECT *
FROM credit_applications
WHERE branch_id = 3
  AND application_date BETWEEN DATE '2026-06-01' AND DATE '2026-06-30'
  AND status = 'APPROVED';
-- Buat composite index untuk mempercepat query dashboard tersebut
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_credit_applications_branch_id_application_date_status
	ON credit_applications(branch_id, application_date, status);

-- 5. Risk Assessments
-- Pertanyaan 14
EXPLAIN ANALYZE SELECT *
FROM risk_assessments
WHERE assessed_by = 7;
-- Buat index untuk mempercepat pencarian berdasarkan assessed_by
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_risk_assessments_assessed_by
	ON risk_assessments(assessed_by);

-- Pertanyaan 15
EXPLAIN ANALYZE SELECT *
FROM risk_assessments
WHERE decision = 'APPROVED';
-- Buat index untuk mempercepat filter berdasarkan decision
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_risk_assessments_decision
	ON risk_assessments(decision);

-- Pertanyaan 16
EXPLAIN ANALYZE SELECT *
FROM risk_assessments
WHERE risk_level = 'HIGH';
-- Buat index untuk mempercepat filter berdasarkan risk_level
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_risk_assessments_risk_level
	ON risk_assessments(risk_level);

-- Pertanyaan 17
EXPLAIN ANALYZE SELECT *
FROM risk_assessments
WHERE assessed_at >= TIMESTAMP '2026-06-01 00:00:00';
-- Buat index untuk mempercepat pencarian berdasarkan assessed_at
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_risk_assessments_assessed_at
	ON risk_assessments(assessed_at);

-- 6. Installments
-- Pertanyaan 18
EXPLAIN ANALYZE SELECT *
FROM installments
WHERE credit_application_id = 1001;
-- Buat index untuk mempercepat pencarian berdasarkan credit_application_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_installments_credit_application_id
	ON installments(credit_application_id);

-- Pertanyaan 19
EXPLAIN ANALYZE SELECT *
FROM installments
WHERE due_date = DATE '2026-06-25';
-- Buat index untuk mempercepat pencarian berdasarkan due_date
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_installments_due_date
	ON installments(due_date);

-- Pertanyaan 20
EXPLAIN ANALYZE SELECT *
FROM installments
WHERE status = 'UNPAID';
-- Buat index untuk mempercepat filter berdasarkan status
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_installments_status
	ON installments(status);

-- Pertanyaan 21
EXPLAIN ANALYZE SELECT *
FROM installments
WHERE status = 'UNPAID'
  AND due_date <= DATE '2026-06-25';
-- Buat composite index untuk mempercepat query berdasarkan status dan due_date
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_installments_status_due_date
	ON installments(status, due_date);

-- 7. Payments
-- Pertanyaan 22
EXPLAIN ANALYZE SELECT *
FROM payments
WHERE installment_id = 2001;
-- Buat index untuk mempercepat pencarian berdasarkan installment_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_payments_installment_id
	ON payments(installment_id);

-- Pertanyaan 23
EXPLAIN ANALYZE SELECT *
FROM payments
WHERE paid_by = 12;
-- Buat index untuk mempercepat pencarian berdasarkan paid_by
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_payments_paid_by
	ON payments(paid_by);

-- Pertanyaan 24
EXPLAIN ANALYZE SELECT *
FROM payments
WHERE payment_date = DATE '2026-06-25';
-- Buat index untuk mempercepat pencarian berdasarkan payment_date
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_payments_payment_date
	ON payments(payment_date);

-- Pertanyaan 25
EXPLAIN ANALYZE SELECT *
FROM payments
WHERE payment_method = 'TRANSFER'
  AND payment_channel = 'MOBILE_APP';
-- Buat composite index untuk mempercepat query berdasarkan payment_method dan payment_channel
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_payments_payment_method_payment_channel
	ON payments(payment_method, payment_channel);

-- 8. Audit Logs
-- Pertanyaan 26
EXPLAIN ANALYZE SELECT *
FROM audit_logs
WHERE user_id = 5;
-- Buat index untuk mempercepat pencarian berdasarkan payment_date
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id
	ON audit_logs(user_id);

-- Pertanyaan 27
EXPLAIN ANALYZE SELECT *
FROM audit_logs
WHERE entity_name = 'credit_applications'
  AND entity_id = 1001;
-- Buat composite index untuk mempercepat pencarian berdasarkan entity_name dan entity_id
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_name_entity_id
	ON audit_logs(entity_name, entity_id);

-- Pertanyaan 28
EXPLAIN ANALYZE SELECT *
FROM audit_logs
WHERE "action" = 'UPDATE';
-- Buat index untuk mempercepat filter berdasarkan action
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_audit_logs_action
	ON audit_logs("action");

-- Pertanyaan 29
EXPLAIN ANALYZE SELECT *
FROM audit_logs
WHERE created_at >= TIMESTAMP '2026-06-01 00:00:00';
-- Buat index untuk mempercepat pencarian berdasarkan created_at
-- Jawaban
CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
	ON audit_logs(created_at);







