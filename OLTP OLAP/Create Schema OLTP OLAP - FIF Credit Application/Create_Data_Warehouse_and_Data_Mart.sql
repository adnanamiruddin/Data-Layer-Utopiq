-- =====================================================
-- FIF Credit Application - Data Mart / OLAP Schema
-- Source OLTP Schema : fifapp_credit_dashboard
-- Target Mart Schema : fifapp_credit_data_mart
-- PostgreSQL
-- =====================================================

CREATE SCHEMA IF NOT EXISTS fifapp_credit_data_mart;

SET search_path TO fifapp_credit_data_mart;

-- =====================================================
-- DROP EXISTING OBJECTS
-- =====================================================

DROP VIEW IF EXISTS fifapp_credit_data_mart.vw_payment_dashboard CASCADE;
DROP VIEW IF EXISTS fifapp_credit_data_mart.vw_collection_dashboard CASCADE;
DROP VIEW IF EXISTS fifapp_credit_data_mart.vw_application_dashboard CASCADE;

DROP TABLE IF EXISTS fifapp_credit_data_mart.fact_payment CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.fact_installment CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.fact_risk_assessment CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.fact_credit_application CASCADE;

DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_user CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_vehicle CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_dealer CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_customer CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_branch CASCADE;
DROP TABLE IF EXISTS fifapp_credit_data_mart.dim_date CASCADE;

-- =====================================================
-- DIMENSION TABLES
-- =====================================================

-- =====================================================
-- 1. DIM DATE
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_date (
    date_key INT PRIMARY KEY,
    full_date DATE NOT NULL UNIQUE,

    day_of_month INT NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    day_of_week INT NOT NULL,
    week_of_year INT NOT NULL,

    month_number INT NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    month_year VARCHAR(20) NOT NULL,

    quarter_number INT NOT NULL,
    quarter_name VARCHAR(10) NOT NULL,

    year_number INT NOT NULL,

    is_weekend BOOLEAN NOT NULL
);

-- =====================================================
-- 2. DIM BRANCH
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_branch (
    branch_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    branch_id BIGINT NOT NULL UNIQUE,
    branch_code VARCHAR(20) NOT NULL,
    branch_name VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100),
    address TEXT,

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mart_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. DIM CUSTOMER
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_customer (
    customer_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_id BIGINT NOT NULL UNIQUE,
    customer_number VARCHAR(30) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    nik VARCHAR(30),

    birth_date DATE,
    gender VARCHAR(20),
    phone_number VARCHAR(30),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(100),

    occupation VARCHAR(100),
    monthly_income NUMERIC(18,2),
    income_range VARCHAR(50),

    customer_age INT,
    age_group VARCHAR(30),

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mart_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. DIM DEALER
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_dealer (
    dealer_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    dealer_id BIGINT NOT NULL UNIQUE,
    dealer_code VARCHAR(30) NOT NULL,
    dealer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    is_active BOOLEAN,

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mart_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 5. DIM VEHICLE
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_vehicle (
    vehicle_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    vehicle_id BIGINT NOT NULL UNIQUE,
    dealer_key BIGINT REFERENCES fifapp_credit_data_mart.dim_dealer(dealer_key),

    vehicle_code VARCHAR(30) NOT NULL,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    vehicle_type VARCHAR(50),
    vehicle_category VARCHAR(50),
    production_year INT,
    is_new BOOLEAN,
    price NUMERIC(18,2),

    vehicle_age INT,
    price_segment VARCHAR(30),

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mart_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 6. DIM USER
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.dim_user (
    user_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT NOT NULL UNIQUE,
    branch_key BIGINT REFERENCES fifapp_credit_data_mart.dim_branch(branch_key),

    employee_number VARCHAR(30) NOT NULL,
    username VARCHAR(50) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    is_active BOOLEAN,

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    mart_updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- FACT TABLES
-- =====================================================

-- =====================================================
-- 1. FACT CREDIT APPLICATION
-- Grain: 1 row per credit application
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.fact_credit_application (
    credit_application_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    credit_application_id BIGINT NOT NULL UNIQUE,
    application_number VARCHAR(30) NOT NULL,

    customer_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_customer(customer_key),
    vehicle_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_vehicle(vehicle_key),
    branch_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_branch(branch_key),
    created_by_user_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_user(user_key),

    application_date_key INT NOT NULL REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    submitted_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    approved_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    rejected_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    manual_review_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    cancelled_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    created_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    updated_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),

    application_date DATE NOT NULL,
    submitted_at TIMESTAMP,
    approved_at TIMESTAMP,
    rejected_at TIMESTAMP,
    manual_review_at TIMESTAMP,
    cancelled_at TIMESTAMP,

    vehicle_price NUMERIC(18,2) NOT NULL,
    dp_amount NUMERIC(18,2) NOT NULL,
    loan_amount NUMERIC(18,2) NOT NULL,
    approved_amount NUMERIC(18,2),

    tenor_months INT NOT NULL,
    interest_rate NUMERIC(5,2),

    status VARCHAR(30) NOT NULL,
    decision_reason TEXT,

    is_draft BOOLEAN NOT NULL,
    is_submitted BOOLEAN NOT NULL,
    is_approved BOOLEAN NOT NULL,
    is_rejected BOOLEAN NOT NULL,
    is_manual_review BOOLEAN NOT NULL,
    is_cancelled BOOLEAN NOT NULL,

    approval_sla_hours NUMERIC(18,2),
    decision_sla_hours NUMERIC(18,2),

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 2. FACT RISK ASSESSMENT
-- Grain: 1 row per risk assessment
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.fact_risk_assessment (
    risk_assessment_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    risk_assessment_id BIGINT NOT NULL UNIQUE,
    credit_application_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.fact_credit_application(credit_application_key),
    assessed_by_user_key BIGINT REFERENCES fifapp_credit_data_mart.dim_user(user_key),

    assessed_date_key INT NOT NULL REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    created_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    updated_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),

    risk_score INT,
    risk_level VARCHAR(30),
    decision VARCHAR(30) NOT NULL,

    income_score INT,
    age_score INT,
    loan_amount_score INT,
    dbr_score INT,
    previous_payment_score INT,

    dbr_percentage NUMERIC(5,2),
    notes TEXT,

    assessed_at TIMESTAMP NOT NULL,

    is_low_risk BOOLEAN,
    is_medium_risk BOOLEAN,
    is_high_risk BOOLEAN,

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 3. FACT INSTALLMENT
-- Grain: 1 row per installment schedule
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.fact_installment (
    installment_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    installment_id BIGINT NOT NULL UNIQUE,
    credit_application_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.fact_credit_application(credit_application_key),

    -- Direct branch key agar filter Power BI dari dim_branch langsung sampai ke fact_installment
    branch_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_branch(branch_key),

    due_date_key INT NOT NULL REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    payment_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    created_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    updated_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),

    installment_number INT NOT NULL,
    due_date DATE NOT NULL,
    payment_date DATE,

    amount NUMERIC(18,2) NOT NULL,
    paid_amount NUMERIC(18,2) NOT NULL,
    outstanding_amount NUMERIC(18,2),

    days_overdue INT NOT NULL,
    status VARCHAR(30) NOT NULL,

    is_paid BOOLEAN NOT NULL,
    is_unpaid BOOLEAN NOT NULL,
    is_partial_paid BOOLEAN NOT NULL,
    is_late BOOLEAN NOT NULL,
    is_defaulted BOOLEAN NOT NULL,
    is_overdue BOOLEAN NOT NULL,

    overdue_bucket VARCHAR(30),

    source_created_at TIMESTAMP,
    source_updated_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- 4. FACT PAYMENT
-- Grain: 1 row per payment transaction
-- =====================================================

CREATE TABLE fifapp_credit_data_mart.fact_payment (
    payment_key BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    payment_id BIGINT NOT NULL UNIQUE,
    installment_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.fact_installment(installment_key),
    credit_application_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.fact_credit_application(credit_application_key),

    -- Direct branch key agar payment juga mudah difilter per branch di Power BI
    branch_key BIGINT NOT NULL REFERENCES fifapp_credit_data_mart.dim_branch(branch_key),

    paid_by_user_key BIGINT REFERENCES fifapp_credit_data_mart.dim_user(user_key),

    payment_date_key INT NOT NULL REFERENCES fifapp_credit_data_mart.dim_date(date_key),
    created_date_key INT REFERENCES fifapp_credit_data_mart.dim_date(date_key),

    payment_number VARCHAR(30) NOT NULL,
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(18,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_channel VARCHAR(50),

    is_cash BOOLEAN,
    is_transfer BOOLEAN,
    is_virtual_account BOOLEAN,
    is_autodebit BOOLEAN,

    source_created_at TIMESTAMP,

    mart_created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- =====================================================
-- LOAD DIM DATE
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_date (
    date_key,
    full_date,
    day_of_month,
    day_name,
    day_of_week,
    week_of_year,
    month_number,
    month_name,
    month_year,
    quarter_number,
    quarter_name,
    year_number,
    is_weekend
)
WITH date_bounds AS (
    SELECT
        LEAST(
            COALESCE((SELECT MIN(application_date) FROM fifapp_credit_dashboard.credit_applications), DATE '2024-01-01'),
            COALESCE((SELECT MIN(due_date) FROM fifapp_credit_dashboard.installments), DATE '2024-01-01'),
            COALESCE((SELECT MIN(payment_date) FROM fifapp_credit_dashboard.payments), DATE '2024-01-01'),
            COALESCE((SELECT MIN(created_at)::date FROM fifapp_credit_dashboard.audit_logs), DATE '2024-01-01')
        ) AS min_date,

        GREATEST(
            COALESCE((SELECT MAX(application_date) FROM fifapp_credit_dashboard.credit_applications), DATE '2026-12-31'),
            COALESCE((SELECT MAX(due_date) FROM fifapp_credit_dashboard.installments), DATE '2026-12-31'),
            COALESCE((SELECT MAX(payment_date) FROM fifapp_credit_dashboard.payments), DATE '2026-12-31'),
            COALESCE((SELECT MAX(created_at)::date FROM fifapp_credit_dashboard.audit_logs), DATE '2026-12-31')
        ) AS max_date
),
date_series AS (
    SELECT generate_series(min_date, max_date, interval '1 day')::date AS full_date
    FROM date_bounds
)
SELECT
    TO_CHAR(full_date, 'YYYYMMDD')::INT AS date_key,
    full_date,
    EXTRACT(DAY FROM full_date)::INT AS day_of_month,
    TRIM(TO_CHAR(full_date, 'Day')) AS day_name,
    EXTRACT(ISODOW FROM full_date)::INT AS day_of_week,
    EXTRACT(WEEK FROM full_date)::INT AS week_of_year,
    EXTRACT(MONTH FROM full_date)::INT AS month_number,
    TRIM(TO_CHAR(full_date, 'Month')) AS month_name,
    TO_CHAR(full_date, 'YYYY-MM') AS month_year,
    EXTRACT(QUARTER FROM full_date)::INT AS quarter_number,
    'Q' || EXTRACT(QUARTER FROM full_date)::INT AS quarter_name,
    EXTRACT(YEAR FROM full_date)::INT AS year_number,
    CASE WHEN EXTRACT(ISODOW FROM full_date)::INT IN (6, 7) THEN TRUE ELSE FALSE END AS is_weekend
FROM date_series;

-- =====================================================
-- LOAD DIM BRANCH
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_branch (
    branch_id,
    branch_code,
    branch_name,
    region,
    city,
    address,
    source_created_at,
    source_updated_at
)
SELECT
    id,
    branch_code,
    branch_name,
    region,
    city,
    address,
    created_at,
    updated_at
FROM fifapp_credit_dashboard.branches;

-- =====================================================
-- LOAD DIM CUSTOMER
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_customer (
    customer_id,
    customer_number,
    full_name,
    nik,
    birth_date,
    gender,
    phone_number,
    email,
    address,
    city,
    occupation,
    monthly_income,
    income_range,
    customer_age,
    age_group,
    source_created_at,
    source_updated_at
)
SELECT
    id,
    customer_number,
    full_name,
    nik,
    birth_date,
    gender,
    phone_number,
    email,
    address,
    city,
    occupation,
    monthly_income,
    income_range,

    CASE
        WHEN birth_date IS NOT NULL
        THEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date))::INT
        ELSE NULL
    END AS customer_age,

    CASE
        WHEN birth_date IS NULL THEN 'UNKNOWN'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) < 25 THEN '<25'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) BETWEEN 25 AND 34 THEN '25-34'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) BETWEEN 35 AND 44 THEN '35-44'
        WHEN EXTRACT(YEAR FROM AGE(CURRENT_DATE, birth_date)) BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,

    created_at,
    updated_at
FROM fifapp_credit_dashboard.customers;

-- =====================================================
-- LOAD DIM DEALER
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_dealer (
    dealer_id,
    dealer_code,
    dealer_name,
    city,
    region,
    is_active,
    source_created_at,
    source_updated_at
)
SELECT
    id,
    dealer_code,
    dealer_name,
    city,
    region,
    is_active,
    created_at,
    updated_at
FROM fifapp_credit_dashboard.dealers;

-- =====================================================
-- LOAD DIM VEHICLE
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_vehicle (
    vehicle_id,
    dealer_key,
    vehicle_code,
    brand,
    model,
    vehicle_type,
    vehicle_category,
    production_year,
    is_new,
    price,
    vehicle_age,
    price_segment,
    source_created_at,
    source_updated_at
)
SELECT
    v.id,
    dd.dealer_key,
    v.vehicle_code,
    v.brand,
    v.model,
    v.vehicle_type,
    v.vehicle_category,
    v.production_year,
    v.is_new,
    v.price,

    CASE
        WHEN v.production_year IS NOT NULL
        THEN EXTRACT(YEAR FROM CURRENT_DATE)::INT - v.production_year
        ELSE NULL
    END AS vehicle_age,

    CASE
        WHEN v.price IS NULL THEN 'UNKNOWN'
        WHEN v.vehicle_type = 'MOTORCYCLE' AND v.price < 25000000 THEN 'MOTOR_LOW'
        WHEN v.vehicle_type = 'MOTORCYCLE' AND v.price < 35000000 THEN 'MOTOR_MEDIUM'
        WHEN v.vehicle_type = 'MOTORCYCLE' THEN 'MOTOR_HIGH'
        WHEN v.vehicle_type = 'CAR' AND v.price < 250000000 THEN 'CAR_LOW'
        WHEN v.vehicle_type = 'CAR' AND v.price < 350000000 THEN 'CAR_MEDIUM'
        WHEN v.vehicle_type = 'CAR' THEN 'CAR_HIGH'
        ELSE 'UNKNOWN'
    END AS price_segment,

    v.created_at,
    v.updated_at
FROM fifapp_credit_dashboard.vehicles v
LEFT JOIN fifapp_credit_data_mart.dim_dealer dd
    ON dd.dealer_id = v.dealer_id;

-- =====================================================
-- LOAD DIM USER
-- =====================================================

INSERT INTO fifapp_credit_data_mart.dim_user (
    user_id,
    branch_key,
    employee_number,
    username,
    full_name,
    role,
    is_active,
    source_created_at,
    source_updated_at
)
SELECT
    u.id,
    db.branch_key,
    u.employee_number,
    u.username,
    u.full_name,
    u.role,
    u.is_active,
    u.created_at,
    u.updated_at
FROM fifapp_credit_dashboard.users u
LEFT JOIN fifapp_credit_data_mart.dim_branch db
    ON db.branch_id = u.branch_id;

-- =====================================================
-- LOAD FACT CREDIT APPLICATION
-- =====================================================

INSERT INTO fifapp_credit_data_mart.fact_credit_application (
    credit_application_id,
    application_number,

    customer_key,
    vehicle_key,
    branch_key,
    created_by_user_key,

    application_date_key,
    submitted_date_key,
    approved_date_key,
    rejected_date_key,
    manual_review_date_key,
    cancelled_date_key,
    created_date_key,
    updated_date_key,

    application_date,
    submitted_at,
    approved_at,
    rejected_at,
    manual_review_at,
    cancelled_at,

    vehicle_price,
    dp_amount,
    loan_amount,
    approved_amount,

    tenor_months,
    interest_rate,

    status,
    decision_reason,

    is_draft,
    is_submitted,
    is_approved,
    is_rejected,
    is_manual_review,
    is_cancelled,

    approval_sla_hours,
    decision_sla_hours,

    source_created_at,
    source_updated_at
)
SELECT
    ca.id,
    ca.application_number,

    dc.customer_key,
    dv.vehicle_key,
    db.branch_key,
    du.user_key,

    TO_CHAR(ca.application_date, 'YYYYMMDD')::INT AS application_date_key,
    CASE WHEN ca.submitted_at IS NOT NULL THEN TO_CHAR(ca.submitted_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.approved_at IS NOT NULL THEN TO_CHAR(ca.approved_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.rejected_at IS NOT NULL THEN TO_CHAR(ca.rejected_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.manual_review_at IS NOT NULL THEN TO_CHAR(ca.manual_review_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.cancelled_at IS NOT NULL THEN TO_CHAR(ca.cancelled_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.created_at IS NOT NULL THEN TO_CHAR(ca.created_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ca.updated_at IS NOT NULL THEN TO_CHAR(ca.updated_at::date, 'YYYYMMDD')::INT END,

    ca.application_date,
    ca.submitted_at,
    ca.approved_at,
    ca.rejected_at,
    ca.manual_review_at,
    ca.cancelled_at,

    ca.vehicle_price,
    ca.dp_amount,
    ca.loan_amount,
    ca.approved_amount,

    ca.tenor_months,
    ca.interest_rate,

    ca.status,
    ca.decision_reason,

    CASE WHEN ca.status = 'DRAFT' THEN TRUE ELSE FALSE END,
    CASE WHEN ca.status <> 'DRAFT' THEN TRUE ELSE FALSE END,
    CASE WHEN ca.status = 'APPROVED' THEN TRUE ELSE FALSE END,
    CASE WHEN ca.status = 'REJECTED' THEN TRUE ELSE FALSE END,
    CASE WHEN ca.status = 'MANUAL_REVIEW' THEN TRUE ELSE FALSE END,
    CASE WHEN ca.status = 'CANCELLED' THEN TRUE ELSE FALSE END,

    CASE
        WHEN ca.submitted_at IS NOT NULL AND ca.approved_at IS NOT NULL
        THEN ROUND((EXTRACT(EPOCH FROM (ca.approved_at - ca.submitted_at)) / 3600)::numeric, 2)
        ELSE NULL
    END AS approval_sla_hours,

    CASE
        WHEN ca.submitted_at IS NOT NULL
         AND COALESCE(ca.approved_at, ca.rejected_at, ca.manual_review_at, ca.cancelled_at) IS NOT NULL
        THEN ROUND(
            (
                EXTRACT(
                    EPOCH FROM (
                        COALESCE(ca.approved_at, ca.rejected_at, ca.manual_review_at, ca.cancelled_at)
                        - ca.submitted_at
                    )
                ) / 3600
            )::numeric,
            2
        )
        ELSE NULL
    END AS decision_sla_hours,

    ca.created_at,
    ca.updated_at
FROM fifapp_credit_dashboard.credit_applications ca
JOIN fifapp_credit_data_mart.dim_customer dc
    ON dc.customer_id = ca.customer_id
JOIN fifapp_credit_data_mart.dim_vehicle dv
    ON dv.vehicle_id = ca.vehicle_id
JOIN fifapp_credit_data_mart.dim_branch db
    ON db.branch_id = ca.branch_id
JOIN fifapp_credit_data_mart.dim_user du
    ON du.user_id = ca.created_by;

-- =====================================================
-- LOAD FACT RISK ASSESSMENT
-- =====================================================

INSERT INTO fifapp_credit_data_mart.fact_risk_assessment (
    risk_assessment_id,
    credit_application_key,
    assessed_by_user_key,

    assessed_date_key,
    created_date_key,
    updated_date_key,

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

    is_low_risk,
    is_medium_risk,
    is_high_risk,

    source_created_at,
    source_updated_at
)
SELECT
    ra.id,
    fca.credit_application_key,
    du.user_key,

    TO_CHAR(ra.assessed_at::date, 'YYYYMMDD')::INT,
    CASE WHEN ra.created_at IS NOT NULL THEN TO_CHAR(ra.created_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN ra.updated_at IS NOT NULL THEN TO_CHAR(ra.updated_at::date, 'YYYYMMDD')::INT END,

    ra.risk_score,
    ra.risk_level,
    ra.decision,

    ra.income_score,
    ra.age_score,
    ra.loan_amount_score,
    ra.dbr_score,
    ra.previous_payment_score,

    ra.dbr_percentage,
    ra.notes,
    ra.assessed_at,

    CASE WHEN ra.risk_level = 'LOW' THEN TRUE ELSE FALSE END,
    CASE WHEN ra.risk_level = 'MEDIUM' THEN TRUE ELSE FALSE END,
    CASE WHEN ra.risk_level = 'HIGH' THEN TRUE ELSE FALSE END,

    ra.created_at,
    ra.updated_at
FROM fifapp_credit_dashboard.risk_assessments ra
JOIN fifapp_credit_data_mart.fact_credit_application fca
    ON fca.credit_application_id = ra.credit_application_id
LEFT JOIN fifapp_credit_data_mart.dim_user du
    ON du.user_id = ra.assessed_by;

-- =====================================================
-- LOAD FACT INSTALLMENT
-- =====================================================

INSERT INTO fifapp_credit_data_mart.fact_installment (
    installment_id,
    credit_application_key,
    branch_key,

    due_date_key,
    payment_date_key,
    created_date_key,
    updated_date_key,

    installment_number,
    due_date,
    payment_date,

    amount,
    paid_amount,
    outstanding_amount,

    days_overdue,
    status,

    is_paid,
    is_unpaid,
    is_partial_paid,
    is_late,
    is_defaulted,
    is_overdue,

    overdue_bucket,

    source_created_at,
    source_updated_at
)
SELECT
    i.id,
    fca.credit_application_key,
    fca.branch_key,

    TO_CHAR(i.due_date, 'YYYYMMDD')::INT,
    CASE WHEN i.payment_date IS NOT NULL THEN TO_CHAR(i.payment_date, 'YYYYMMDD')::INT END,
    CASE WHEN i.created_at IS NOT NULL THEN TO_CHAR(i.created_at::date, 'YYYYMMDD')::INT END,
    CASE WHEN i.updated_at IS NOT NULL THEN TO_CHAR(i.updated_at::date, 'YYYYMMDD')::INT END,

    i.installment_number,
    i.due_date,
    i.payment_date,

    i.amount,
    i.paid_amount,
    i.outstanding_amount,

    i.days_overdue,
    i.status,

    CASE WHEN i.status = 'PAID' THEN TRUE ELSE FALSE END,
    CASE WHEN i.status = 'UNPAID' THEN TRUE ELSE FALSE END,
    CASE WHEN i.status = 'PARTIAL_PAID' THEN TRUE ELSE FALSE END,
    CASE WHEN i.status = 'LATE' THEN TRUE ELSE FALSE END,
    CASE WHEN i.status = 'DEFAULTED' THEN TRUE ELSE FALSE END,
    CASE WHEN i.days_overdue > 0 THEN TRUE ELSE FALSE END,

    CASE
        WHEN i.days_overdue = 0 THEN 'CURRENT'
        WHEN i.days_overdue BETWEEN 1 AND 30 THEN 'DPD_1_30'
        WHEN i.days_overdue BETWEEN 31 AND 60 THEN 'DPD_31_60'
        WHEN i.days_overdue BETWEEN 61 AND 90 THEN 'DPD_61_90'
        ELSE 'DPD_90_PLUS'
    END AS overdue_bucket,

    i.created_at,
    i.updated_at
FROM fifapp_credit_dashboard.installments i
JOIN fifapp_credit_data_mart.fact_credit_application fca
    ON fca.credit_application_id = i.credit_application_id;

-- =====================================================
-- LOAD FACT PAYMENT
-- =====================================================

INSERT INTO fifapp_credit_data_mart.fact_payment (
    payment_id,
    installment_key,
    credit_application_key,
    branch_key,
    paid_by_user_key,

    payment_date_key,
    created_date_key,

    payment_number,
    payment_date,
    payment_amount,
    payment_method,
    payment_channel,

    is_cash,
    is_transfer,
    is_virtual_account,
    is_autodebit,

    source_created_at
)
SELECT
    p.id,
    fi.installment_key,
    fi.credit_application_key,
    fi.branch_key,
    du.user_key,

    TO_CHAR(p.payment_date, 'YYYYMMDD')::INT,
    CASE WHEN p.created_at IS NOT NULL THEN TO_CHAR(p.created_at::date, 'YYYYMMDD')::INT END,

    p.payment_number,
    p.payment_date,
    p.payment_amount,
    p.payment_method,
    p.payment_channel,

    CASE WHEN p.payment_method = 'CASH' THEN TRUE ELSE FALSE END,
    CASE WHEN p.payment_method = 'TRANSFER' THEN TRUE ELSE FALSE END,
    CASE WHEN p.payment_method = 'VIRTUAL_ACCOUNT' THEN TRUE ELSE FALSE END,
    CASE WHEN p.payment_method = 'AUTODEBIT' THEN TRUE ELSE FALSE END,

    p.created_at
FROM fifapp_credit_dashboard.payments p
JOIN fifapp_credit_data_mart.fact_installment fi
    ON fi.installment_id = p.installment_id
LEFT JOIN fifapp_credit_data_mart.dim_user du
    ON du.user_id = p.paid_by;

-- =====================================================
-- INDEXES FOR DATA MART
-- =====================================================

-- DIMENSION INDEXES

CREATE INDEX IF NOT EXISTS idx_dim_date_full_date
ON fifapp_credit_data_mart.dim_date (full_date);

CREATE INDEX IF NOT EXISTS idx_dim_date_month_year
ON fifapp_credit_data_mart.dim_date (month_year);

CREATE INDEX IF NOT EXISTS idx_dim_branch_region_city
ON fifapp_credit_data_mart.dim_branch (region, city);

CREATE INDEX IF NOT EXISTS idx_dim_customer_city
ON fifapp_credit_data_mart.dim_customer (city);

CREATE INDEX IF NOT EXISTS idx_dim_customer_income_range
ON fifapp_credit_data_mart.dim_customer (income_range);

CREATE INDEX IF NOT EXISTS idx_dim_customer_age_group
ON fifapp_credit_data_mart.dim_customer (age_group);

CREATE INDEX IF NOT EXISTS idx_dim_dealer_region_city
ON fifapp_credit_data_mart.dim_dealer (region, city);

CREATE INDEX IF NOT EXISTS idx_dim_vehicle_type_category
ON fifapp_credit_data_mart.dim_vehicle (vehicle_type, vehicle_category);

CREATE INDEX IF NOT EXISTS idx_dim_vehicle_brand_model
ON fifapp_credit_data_mart.dim_vehicle (brand, model);

CREATE INDEX IF NOT EXISTS idx_dim_user_role
ON fifapp_credit_data_mart.dim_user (role);

CREATE INDEX IF NOT EXISTS idx_dim_user_branch_key
ON fifapp_credit_data_mart.dim_user (branch_key);

-- FACT CREDIT APPLICATION INDEXES

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_date_key
ON fifapp_credit_data_mart.fact_credit_application (application_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_status
ON fifapp_credit_data_mart.fact_credit_application (status);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_branch_date
ON fifapp_credit_data_mart.fact_credit_application (branch_key, application_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_customer_key
ON fifapp_credit_data_mart.fact_credit_application (customer_key);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_vehicle_key
ON fifapp_credit_data_mart.fact_credit_application (vehicle_key);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_user_key
ON fifapp_credit_data_mart.fact_credit_application (created_by_user_key);

CREATE INDEX IF NOT EXISTS idx_fact_credit_application_status_date
ON fifapp_credit_data_mart.fact_credit_application (status, application_date_key);

-- FACT RISK ASSESSMENT INDEXES

CREATE INDEX IF NOT EXISTS idx_fact_risk_assessment_application_key
ON fifapp_credit_data_mart.fact_risk_assessment (credit_application_key);

CREATE INDEX IF NOT EXISTS idx_fact_risk_assessment_assessed_date
ON fifapp_credit_data_mart.fact_risk_assessment (assessed_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_risk_assessment_risk_level
ON fifapp_credit_data_mart.fact_risk_assessment (risk_level);

CREATE INDEX IF NOT EXISTS idx_fact_risk_assessment_decision
ON fifapp_credit_data_mart.fact_risk_assessment (decision);

CREATE INDEX IF NOT EXISTS idx_fact_risk_assessment_level_date
ON fifapp_credit_data_mart.fact_risk_assessment (risk_level, assessed_date_key);

-- FACT INSTALLMENT INDEXES

CREATE INDEX IF NOT EXISTS idx_fact_installment_application_key
ON fifapp_credit_data_mart.fact_installment (credit_application_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_branch_key
ON fifapp_credit_data_mart.fact_installment (branch_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_branch_due_date
ON fifapp_credit_data_mart.fact_installment (branch_key, due_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_due_date
ON fifapp_credit_data_mart.fact_installment (due_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_payment_date
ON fifapp_credit_data_mart.fact_installment (payment_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_status
ON fifapp_credit_data_mart.fact_installment (status);

CREATE INDEX IF NOT EXISTS idx_fact_installment_status_due_date
ON fifapp_credit_data_mart.fact_installment (status, due_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_installment_overdue_bucket
ON fifapp_credit_data_mart.fact_installment (overdue_bucket);

CREATE INDEX IF NOT EXISTS idx_fact_installment_overdue
ON fifapp_credit_data_mart.fact_installment (days_overdue)
WHERE days_overdue > 0;

-- FACT PAYMENT INDEXES

CREATE INDEX IF NOT EXISTS idx_fact_payment_installment_key
ON fifapp_credit_data_mart.fact_payment (installment_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_application_key
ON fifapp_credit_data_mart.fact_payment (credit_application_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_branch_key
ON fifapp_credit_data_mart.fact_payment (branch_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_branch_date
ON fifapp_credit_data_mart.fact_payment (branch_key, payment_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_paid_by_user_key
ON fifapp_credit_data_mart.fact_payment (paid_by_user_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_date_key
ON fifapp_credit_data_mart.fact_payment (payment_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_channel_date
ON fifapp_credit_data_mart.fact_payment (payment_channel, payment_date_key);

CREATE INDEX IF NOT EXISTS idx_fact_payment_method_date
ON fifapp_credit_data_mart.fact_payment (payment_method, payment_date_key);

-- =====================================================
-- DASHBOARD VIEWS
-- =====================================================

-- =====================================================
-- 1. APPLICATION DASHBOARD VIEW
-- Grain: 1 row per credit application
-- =====================================================

CREATE OR REPLACE VIEW fifapp_credit_data_mart.vw_application_dashboard AS
SELECT
    fca.credit_application_key,
    fca.credit_application_id,
    fca.application_number,

    dd.full_date AS application_date,
    dd.year_number AS application_year,
    dd.quarter_name AS application_quarter,
    dd.month_number AS application_month_number,
    dd.month_name AS application_month_name,
    dd.month_year AS application_month_year,

    db.branch_code,
    db.branch_name,
    db.region AS branch_region,
    db.city AS branch_city,

    dc.customer_number,
    dc.full_name AS customer_name,
    dc.gender,
    dc.city AS customer_city,
    dc.occupation,
    dc.income_range,
    dc.age_group,

    dv.vehicle_code,
    dv.brand,
    dv.model,
    dv.vehicle_type,
    dv.vehicle_category,
    dv.production_year,
    dv.is_new,
    dv.price_segment,

    ddr.dealer_code,
    ddr.dealer_name,
    ddr.region AS dealer_region,
    ddr.city AS dealer_city,

    du.employee_number AS created_by_employee_number,
    du.full_name AS created_by_name,
    du.role AS created_by_role,

    fca.status,
    fca.decision_reason,

    fca.vehicle_price,
    fca.dp_amount,
    fca.loan_amount,
    fca.approved_amount,
    fca.tenor_months,
    fca.interest_rate,

    fca.is_draft,
    fca.is_submitted,
    fca.is_approved,
    fca.is_rejected,
    fca.is_manual_review,
    fca.is_cancelled,

    fca.approval_sla_hours,
    fca.decision_sla_hours,

    fra.risk_score,
    fra.risk_level,
    fra.decision AS risk_decision,
    fra.dbr_percentage,

    1 AS total_application,
    CASE WHEN fca.is_approved THEN 1 ELSE 0 END AS approved_application,
    CASE WHEN fca.is_rejected THEN 1 ELSE 0 END AS rejected_application,
    CASE WHEN fca.is_manual_review THEN 1 ELSE 0 END AS manual_review_application,
    CASE WHEN fca.is_cancelled THEN 1 ELSE 0 END AS cancelled_application

FROM fifapp_credit_data_mart.fact_credit_application fca
JOIN fifapp_credit_data_mart.dim_date dd
    ON dd.date_key = fca.application_date_key
JOIN fifapp_credit_data_mart.dim_branch db
    ON db.branch_key = fca.branch_key
JOIN fifapp_credit_data_mart.dim_customer dc
    ON dc.customer_key = fca.customer_key
JOIN fifapp_credit_data_mart.dim_vehicle dv
    ON dv.vehicle_key = fca.vehicle_key
LEFT JOIN fifapp_credit_data_mart.dim_dealer ddr
    ON ddr.dealer_key = dv.dealer_key
JOIN fifapp_credit_data_mart.dim_user du
    ON du.user_key = fca.created_by_user_key
LEFT JOIN fifapp_credit_data_mart.fact_risk_assessment fra
    ON fra.credit_application_key = fca.credit_application_key;

-- =====================================================
-- 2. COLLECTION DASHBOARD VIEW
-- Grain: 1 row per installment
-- =====================================================

CREATE OR REPLACE VIEW fifapp_credit_data_mart.vw_collection_dashboard AS
SELECT
    fi.installment_key,
    fi.installment_id,

    fca.credit_application_id,
    fca.application_number,

    dd_due.full_date AS due_date,
    dd_due.year_number AS due_year,
    dd_due.quarter_name AS due_quarter,
    dd_due.month_number AS due_month_number,
    dd_due.month_name AS due_month_name,
    dd_due.month_year AS due_month_year,

    dd_pay.full_date AS payment_date,
    dd_pay.month_year AS payment_month_year,

    db.branch_code,
    db.branch_name,
    db.region AS branch_region,
    db.city AS branch_city,

    dc.customer_number,
    dc.full_name AS customer_name,
    dc.gender,
    dc.city AS customer_city,
    dc.income_range,
    dc.age_group,

    dv.vehicle_code,
    dv.brand,
    dv.model,
    dv.vehicle_type,
    dv.vehicle_category,

    fi.installment_number,
    fi.amount,
    fi.paid_amount,
    fi.outstanding_amount,
    fi.days_overdue,
    fi.status,
    fi.overdue_bucket,

    fi.is_paid,
    fi.is_unpaid,
    fi.is_partial_paid,
    fi.is_late,
    fi.is_defaulted,
    fi.is_overdue,

    1 AS total_installment,
    CASE WHEN fi.is_paid THEN 1 ELSE 0 END AS paid_installment,
    CASE WHEN fi.is_unpaid THEN 1 ELSE 0 END AS unpaid_installment,
    CASE WHEN fi.is_partial_paid THEN 1 ELSE 0 END AS partial_paid_installment,
    CASE WHEN fi.is_late THEN 1 ELSE 0 END AS late_installment,
    CASE WHEN fi.is_defaulted THEN 1 ELSE 0 END AS defaulted_installment,
    CASE WHEN fi.is_overdue THEN 1 ELSE 0 END AS overdue_installment

FROM fifapp_credit_data_mart.fact_installment fi
JOIN fifapp_credit_data_mart.fact_credit_application fca
    ON fca.credit_application_key = fi.credit_application_key
JOIN fifapp_credit_data_mart.dim_date dd_due
    ON dd_due.date_key = fi.due_date_key
LEFT JOIN fifapp_credit_data_mart.dim_date dd_pay
    ON dd_pay.date_key = fi.payment_date_key
JOIN fifapp_credit_data_mart.dim_branch db
    ON db.branch_key = fi.branch_key
JOIN fifapp_credit_data_mart.dim_customer dc
    ON dc.customer_key = fca.customer_key
JOIN fifapp_credit_data_mart.dim_vehicle dv
    ON dv.vehicle_key = fca.vehicle_key;

-- =====================================================
-- 3. PAYMENT DASHBOARD VIEW
-- Grain: 1 row per payment
-- =====================================================

CREATE OR REPLACE VIEW fifapp_credit_data_mart.vw_payment_dashboard AS
SELECT
    fp.payment_key,
    fp.payment_id,
    fp.payment_number,

    dd.full_date AS payment_date,
    dd.year_number AS payment_year,
    dd.quarter_name AS payment_quarter,
    dd.month_number AS payment_month_number,
    dd.month_name AS payment_month_name,
    dd.month_year AS payment_month_year,

    fca.credit_application_id,
    fca.application_number,
    fi.installment_number,

    db.branch_code,
    db.branch_name,
    db.region AS branch_region,
    db.city AS branch_city,

    dc.customer_number,
    dc.full_name AS customer_name,
    dc.gender,
    dc.city AS customer_city,
    dc.income_range,
    dc.age_group,

    dv.vehicle_code,
    dv.brand,
    dv.model,
    dv.vehicle_type,
    dv.vehicle_category,

    du.employee_number AS paid_by_employee_number,
    du.full_name AS paid_by_name,
    du.role AS paid_by_role,

    fp.payment_amount,
    fp.payment_method,
    fp.payment_channel,

    fp.is_cash,
    fp.is_transfer,
    fp.is_virtual_account,
    fp.is_autodebit,

    1 AS total_payment_transaction

FROM fifapp_credit_data_mart.fact_payment fp
JOIN fifapp_credit_data_mart.dim_date dd
    ON dd.date_key = fp.payment_date_key
JOIN fifapp_credit_data_mart.fact_installment fi
    ON fi.installment_key = fp.installment_key
JOIN fifapp_credit_data_mart.fact_credit_application fca
    ON fca.credit_application_key = fp.credit_application_key
JOIN fifapp_credit_data_mart.dim_branch db
    ON db.branch_key = fp.branch_key
JOIN fifapp_credit_data_mart.dim_customer dc
    ON dc.customer_key = fca.customer_key
JOIN fifapp_credit_data_mart.dim_vehicle dv
    ON dv.vehicle_key = fca.vehicle_key
LEFT JOIN fifapp_credit_data_mart.dim_user du
    ON du.user_key = fp.paid_by_user_key;

-- =====================================================
-- REFRESH STATISTICS
-- =====================================================

ANALYZE fifapp_credit_data_mart.dim_date;
ANALYZE fifapp_credit_data_mart.dim_branch;
ANALYZE fifapp_credit_data_mart.dim_customer;
ANALYZE fifapp_credit_data_mart.dim_dealer;
ANALYZE fifapp_credit_data_mart.dim_vehicle;
ANALYZE fifapp_credit_data_mart.dim_user;

ANALYZE fifapp_credit_data_mart.fact_credit_application;
ANALYZE fifapp_credit_data_mart.fact_risk_assessment;
ANALYZE fifapp_credit_data_mart.fact_installment;
ANALYZE fifapp_credit_data_mart.fact_payment;

-- =====================================================
-- VALIDATION - ROW COUNT
-- =====================================================

SELECT 'dim_date' AS table_name, COUNT(*) AS total_rows
FROM fifapp_credit_data_mart.dim_date

UNION ALL SELECT 'dim_branch', COUNT(*)
FROM fifapp_credit_data_mart.dim_branch

UNION ALL SELECT 'dim_customer', COUNT(*)
FROM fifapp_credit_data_mart.dim_customer

UNION ALL SELECT 'dim_dealer', COUNT(*)
FROM fifapp_credit_data_mart.dim_dealer

UNION ALL SELECT 'dim_vehicle', COUNT(*)
FROM fifapp_credit_data_mart.dim_vehicle

UNION ALL SELECT 'dim_user', COUNT(*)
FROM fifapp_credit_data_mart.dim_user

UNION ALL SELECT 'fact_credit_application', COUNT(*)
FROM fifapp_credit_data_mart.fact_credit_application

UNION ALL SELECT 'fact_risk_assessment', COUNT(*)
FROM fifapp_credit_data_mart.fact_risk_assessment

UNION ALL SELECT 'fact_installment', COUNT(*)
FROM fifapp_credit_data_mart.fact_installment

UNION ALL SELECT 'fact_payment', COUNT(*)
FROM fifapp_credit_data_mart.fact_payment

ORDER BY table_name;

-- =====================================================
-- VALIDATION - BRANCH FILTER TEST FOR POWER BI
-- Jika hasil per branch berbeda, relationship branch ke installment sudah aman.
-- =====================================================

SELECT
    db.branch_name,
    COUNT(fi.installment_key) AS total_installment,
    SUM(CASE WHEN fi.is_overdue THEN 1 ELSE 0 END) AS overdue_installment,
    ROUND(
        SUM(CASE WHEN fi.is_overdue THEN 1 ELSE 0 END)::numeric
        / NULLIF(COUNT(fi.installment_key), 0) * 100,
        2
    ) AS overdue_rate_percent
FROM fifapp_credit_data_mart.dim_branch db
LEFT JOIN fifapp_credit_data_mart.fact_installment fi
    ON fi.branch_key = db.branch_key
GROUP BY
    db.branch_name
ORDER BY
    db.branch_name;