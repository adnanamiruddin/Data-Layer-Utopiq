SET search_path TO fifapp_credit_dashboard;

-- =====================================================
-- 1. CUSTOMERS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_customers_city
ON fifapp_credit_dashboard.customers (city);

CREATE INDEX IF NOT EXISTS idx_customers_income_range
ON fifapp_credit_dashboard.customers (income_range);

CREATE INDEX IF NOT EXISTS idx_customers_created_at
ON fifapp_credit_dashboard.customers (created_at);

CREATE INDEX IF NOT EXISTS idx_customers_updated_at
ON fifapp_credit_dashboard.customers (updated_at);


-- =====================================================
-- 2. DEALERS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_dealers_city_region
ON fifapp_credit_dashboard.dealers (city, region);

CREATE INDEX IF NOT EXISTS idx_dealers_is_active
ON fifapp_credit_dashboard.dealers (is_active);

CREATE INDEX IF NOT EXISTS idx_dealers_created_at
ON fifapp_credit_dashboard.dealers (created_at);

CREATE INDEX IF NOT EXISTS idx_dealers_updated_at
ON fifapp_credit_dashboard.dealers (updated_at);


-- =====================================================
-- 3. VEHICLES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_vehicles_dealer_id
ON fifapp_credit_dashboard.vehicles (dealer_id);

CREATE INDEX IF NOT EXISTS idx_vehicles_brand_model
ON fifapp_credit_dashboard.vehicles (brand, model);

CREATE INDEX IF NOT EXISTS idx_vehicles_vehicle_type_vehicle_category
ON fifapp_credit_dashboard.vehicles (vehicle_type, vehicle_category);

CREATE INDEX IF NOT EXISTS idx_vehicles_is_new
ON fifapp_credit_dashboard.vehicles (is_new);

CREATE INDEX IF NOT EXISTS idx_vehicles_price
ON fifapp_credit_dashboard.vehicles (price);

CREATE INDEX IF NOT EXISTS idx_vehicles_created_at
ON fifapp_credit_dashboard.vehicles (created_at);

CREATE INDEX IF NOT EXISTS idx_vehicles_updated_at
ON fifapp_credit_dashboard.vehicles (updated_at);


-- =====================================================
-- 4. CREDIT APPLICATIONS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_credit_applications_customer_id
ON fifapp_credit_dashboard.credit_applications (customer_id);

CREATE INDEX IF NOT EXISTS idx_credit_applications_vehicle_id
ON fifapp_credit_dashboard.credit_applications (vehicle_id);

CREATE INDEX IF NOT EXISTS idx_credit_applications_branch_id
ON fifapp_credit_dashboard.credit_applications (branch_id);

CREATE INDEX IF NOT EXISTS idx_credit_applications_created_by
ON fifapp_credit_dashboard.credit_applications (created_by);

CREATE INDEX IF NOT EXISTS idx_credit_applications_application_date
ON fifapp_credit_dashboard.credit_applications (application_date);

CREATE INDEX IF NOT EXISTS idx_credit_applications_status
ON fifapp_credit_dashboard.credit_applications (status);

CREATE INDEX IF NOT EXISTS idx_credit_applications_branch_id_application_date_status
ON fifapp_credit_dashboard.credit_applications (branch_id, application_date, status);

CREATE INDEX IF NOT EXISTS idx_credit_applications_status_application_date
ON fifapp_credit_dashboard.credit_applications (status, application_date);

CREATE INDEX IF NOT EXISTS idx_credit_applications_created_by_application_date
ON fifapp_credit_dashboard.credit_applications (created_by, application_date);

CREATE INDEX IF NOT EXISTS idx_credit_applications_created_at
ON fifapp_credit_dashboard.credit_applications (created_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_updated_at
ON fifapp_credit_dashboard.credit_applications (updated_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_submitted_at
ON fifapp_credit_dashboard.credit_applications (submitted_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_approved_at
ON fifapp_credit_dashboard.credit_applications (approved_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_rejected_at
ON fifapp_credit_dashboard.credit_applications (rejected_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_manual_review_at
ON fifapp_credit_dashboard.credit_applications (manual_review_at);

CREATE INDEX IF NOT EXISTS idx_credit_applications_cancelled_at
ON fifapp_credit_dashboard.credit_applications (cancelled_at);


-- =====================================================
-- 5. RISK ASSESSMENTS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_risk_assessments_assessed_by
ON fifapp_credit_dashboard.risk_assessments (assessed_by);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_decision
ON fifapp_credit_dashboard.risk_assessments (decision);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_risk_level
ON fifapp_credit_dashboard.risk_assessments (risk_level);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_assessed_at
ON fifapp_credit_dashboard.risk_assessments (assessed_at);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_decision_assessed_at
ON fifapp_credit_dashboard.risk_assessments (decision, assessed_at);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_risk_level_assessed_at
ON fifapp_credit_dashboard.risk_assessments (risk_level, assessed_at);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_created_at
ON fifapp_credit_dashboard.risk_assessments (created_at);

CREATE INDEX IF NOT EXISTS idx_risk_assessments_updated_at
ON fifapp_credit_dashboard.risk_assessments (updated_at);


-- =====================================================
-- 6. INSTALLMENTS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_installments_credit_application_id
ON fifapp_credit_dashboard.installments (credit_application_id);

CREATE INDEX IF NOT EXISTS idx_installments_due_date
ON fifapp_credit_dashboard.installments (due_date);

CREATE INDEX IF NOT EXISTS idx_installments_status
ON fifapp_credit_dashboard.installments (status);

CREATE INDEX IF NOT EXISTS idx_installments_status_due_date
ON fifapp_credit_dashboard.installments (status, due_date);

CREATE INDEX IF NOT EXISTS idx_installments_payment_date
ON fifapp_credit_dashboard.installments (payment_date);

CREATE INDEX IF NOT EXISTS idx_installments_days_overdue
ON fifapp_credit_dashboard.installments (days_overdue);

CREATE INDEX IF NOT EXISTS idx_installments_created_at
ON fifapp_credit_dashboard.installments (created_at);

CREATE INDEX IF NOT EXISTS idx_installments_updated_at
ON fifapp_credit_dashboard.installments (updated_at);

CREATE INDEX IF NOT EXISTS idx_installments_unpaid_due_date
ON fifapp_credit_dashboard.installments (due_date)
WHERE status IN ('UNPAID', 'PARTIAL_PAID', 'LATE', 'DEFAULTED');

CREATE INDEX IF NOT EXISTS idx_installments_overdue
ON fifapp_credit_dashboard.installments (days_overdue, due_date)
WHERE days_overdue > 0;


-- =====================================================
-- 7. PAYMENTS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_payments_installment_id
ON fifapp_credit_dashboard.payments (installment_id);

CREATE INDEX IF NOT EXISTS idx_payments_paid_by
ON fifapp_credit_dashboard.payments (paid_by);

CREATE INDEX IF NOT EXISTS idx_payments_payment_date
ON fifapp_credit_dashboard.payments (payment_date);

CREATE INDEX IF NOT EXISTS idx_payments_payment_method_payment_channel
ON fifapp_credit_dashboard.payments (payment_method, payment_channel);

CREATE INDEX IF NOT EXISTS idx_payments_payment_channel_payment_date
ON fifapp_credit_dashboard.payments (payment_channel, payment_date);

CREATE INDEX IF NOT EXISTS idx_payments_payment_method_payment_date
ON fifapp_credit_dashboard.payments (payment_method, payment_date);

CREATE INDEX IF NOT EXISTS idx_payments_created_at
ON fifapp_credit_dashboard.payments (created_at);


-- =====================================================
-- 8. AUDIT LOGS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_audit_logs_user_id
ON fifapp_credit_dashboard.audit_logs (user_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_name_entity_id
ON fifapp_credit_dashboard.audit_logs (entity_name, entity_id);

CREATE INDEX IF NOT EXISTS idx_audit_logs_action
ON fifapp_credit_dashboard.audit_logs (action);

CREATE INDEX IF NOT EXISTS idx_audit_logs_created_at
ON fifapp_credit_dashboard.audit_logs (created_at);

CREATE INDEX IF NOT EXISTS idx_audit_logs_action_created_at
ON fifapp_credit_dashboard.audit_logs (action, created_at);

CREATE INDEX IF NOT EXISTS idx_audit_logs_entity_name_created_at
ON fifapp_credit_dashboard.audit_logs (entity_name, created_at);


-- =====================================================
-- 9. BRANCHES
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_branches_region_city
ON fifapp_credit_dashboard.branches (region, city);

CREATE INDEX IF NOT EXISTS idx_branches_created_at
ON fifapp_credit_dashboard.branches (created_at);

CREATE INDEX IF NOT EXISTS idx_branches_updated_at
ON fifapp_credit_dashboard.branches (updated_at);


-- =====================================================
-- 10. USERS
-- =====================================================

CREATE INDEX IF NOT EXISTS idx_users_branch_id
ON fifapp_credit_dashboard.users (branch_id);

CREATE INDEX IF NOT EXISTS idx_users_role_is_active
ON fifapp_credit_dashboard.users (role, is_active);

CREATE INDEX IF NOT EXISTS idx_users_created_at
ON fifapp_credit_dashboard.users (created_at);

CREATE INDEX IF NOT EXISTS idx_users_updated_at
ON fifapp_credit_dashboard.users (updated_at);