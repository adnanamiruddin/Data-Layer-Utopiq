-- =====================================================
-- FIF Credit Application - PostgreSQL DB Schema
-- Schema: fifapp_credit_dashboard
-- =====================================================

-- CREATE USER and DB:
-- CREATE USER fifapp_admin WITH PASSWORD 'fifapp_admin';
-- CREATE DATABASE fifapp OWNER fifapp_admin;

-- Optional: keep objects isolated in one schema
CREATE SCHEMA IF NOT EXISTS fifapp_credit_dashboard;
SET search_path TO fifapp_credit_dashboard;

-- =====================================================
-- DROP TABLES - useful for lab reset
-- =====================================================
DROP TABLE IF EXISTS audit_logs CASCADE;
DROP TABLE IF EXISTS payments CASCADE;
DROP TABLE IF EXISTS installments CASCADE;
DROP TABLE IF EXISTS risk_assessments CASCADE;
DROP TABLE IF EXISTS credit_applications CASCADE;
DROP TABLE IF EXISTS vehicles CASCADE;
DROP TABLE IF EXISTS dealers CASCADE;
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS users CASCADE;
DROP TABLE IF EXISTS branches CASCADE;

-- =====================================================
-- OLTP TABLES
-- =====================================================

CREATE TABLE branches (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_code VARCHAR(20) NOT NULL UNIQUE,
    branch_name VARCHAR(100) NOT NULL,
    region VARCHAR(100),
    city VARCHAR(100),
    address TEXT,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE users (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    branch_id BIGINT REFERENCES branches(id),

    employee_number VARCHAR(30) NOT NULL UNIQUE,
    username VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_users_role CHECK (
        role IN ('AGENT', 'CREDIT_ANALYST', 'SUPERVISOR', 'ADMIN', 'COLLECTION')
    )
);

CREATE TABLE customers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    customer_number VARCHAR(30) NOT NULL UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    nik VARCHAR(30) NOT NULL UNIQUE,
    birth_date DATE,
    gender VARCHAR(20),
    phone_number VARCHAR(30),
    email VARCHAR(100),
    address TEXT,
    city VARCHAR(100),

    occupation VARCHAR(100),
    monthly_income NUMERIC(18,2),
    income_range VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_customers_gender CHECK (
        gender IS NULL OR gender IN ('MALE', 'FEMALE')
    ),
    CONSTRAINT chk_customers_income_range CHECK (
        income_range IS NULL OR income_range IN ('LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH')
    ),
    CONSTRAINT chk_customers_monthly_income CHECK (
        monthly_income IS NULL OR monthly_income >= 0
    )
);

CREATE TABLE dealers (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    dealer_code VARCHAR(30) NOT NULL UNIQUE,
    dealer_name VARCHAR(100) NOT NULL,
    city VARCHAR(100),
    region VARCHAR(100),
    is_active BOOLEAN NOT NULL DEFAULT TRUE,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE vehicles (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    dealer_id BIGINT REFERENCES dealers(id),

    vehicle_code VARCHAR(30) NOT NULL UNIQUE,
    brand VARCHAR(100) NOT NULL,
    model VARCHAR(100) NOT NULL,
    vehicle_type VARCHAR(50),
    vehicle_category VARCHAR(50),
    production_year INT,
    is_new BOOLEAN NOT NULL DEFAULT TRUE,
    price NUMERIC(18,2) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_vehicles_type CHECK (
        vehicle_type IS NULL OR vehicle_type IN ('MOTORCYCLE', 'CAR')
    ),
    CONSTRAINT chk_vehicles_category CHECK (
        vehicle_category IS NULL OR vehicle_category IN ('MATIC', 'SPORT', 'SUV', 'MPV', 'COMMERCIAL')
    ),
    CONSTRAINT chk_vehicles_price CHECK (price >= 0),
    CONSTRAINT chk_vehicles_production_year CHECK (
        production_year IS NULL OR production_year BETWEEN 1980 AND 2100
    )
);

CREATE TABLE credit_applications (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    application_number VARCHAR(30) NOT NULL UNIQUE,

    customer_id BIGINT NOT NULL REFERENCES customers(id),
    vehicle_id BIGINT NOT NULL REFERENCES vehicles(id),
    branch_id BIGINT NOT NULL REFERENCES branches(id),
    created_by BIGINT NOT NULL REFERENCES users(id),

    application_date DATE NOT NULL,

    vehicle_price NUMERIC(18,2) NOT NULL,
    dp_amount NUMERIC(18,2) NOT NULL,
    loan_amount NUMERIC(18,2) NOT NULL,
    approved_amount NUMERIC(18,2),

    tenor_months INT NOT NULL,
    interest_rate NUMERIC(5,2),

    status VARCHAR(30) NOT NULL,

    submitted_at TIMESTAMP,
    approved_at TIMESTAMP,
    rejected_at TIMESTAMP,
    manual_review_at TIMESTAMP,
    cancelled_at TIMESTAMP,

    decision_reason TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_credit_applications_status CHECK (
        status IN ('DRAFT', 'SUBMITTED', 'APPROVED', 'REJECTED', 'MANUAL_REVIEW', 'CANCELLED')
    ),
    CONSTRAINT chk_credit_applications_amounts CHECK (
        vehicle_price >= 0
        AND dp_amount >= 0
        AND loan_amount >= 0
        AND (approved_amount IS NULL OR approved_amount >= 0)
    ),
    CONSTRAINT chk_credit_applications_tenor CHECK (tenor_months > 0),
    CONSTRAINT chk_credit_applications_interest CHECK (
        interest_rate IS NULL OR interest_rate >= 0
    )
);

CREATE TABLE risk_assessments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    credit_application_id BIGINT NOT NULL UNIQUE REFERENCES credit_applications(id),
    assessed_by BIGINT REFERENCES users(id),

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
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_risk_assessments_risk_level CHECK (
        risk_level IS NULL OR risk_level IN ('LOW', 'MEDIUM', 'HIGH')
    ),
    CONSTRAINT chk_risk_assessments_decision CHECK (
        decision IN ('APPROVED', 'REJECTED', 'MANUAL_REVIEW')
    ),
    CONSTRAINT chk_risk_assessments_score CHECK (
        risk_score IS NULL OR risk_score BETWEEN 0 AND 100
    ),
    CONSTRAINT chk_risk_assessments_dbr CHECK (
        dbr_percentage IS NULL OR dbr_percentage >= 0
    )
);

CREATE TABLE installments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    credit_application_id BIGINT NOT NULL REFERENCES credit_applications(id),

    installment_number INT NOT NULL,
    due_date DATE NOT NULL,

    amount NUMERIC(18,2) NOT NULL,
    paid_amount NUMERIC(18,2) NOT NULL DEFAULT 0,
    outstanding_amount NUMERIC(18,2),

    payment_date DATE,
    days_overdue INT NOT NULL DEFAULT 0,

    status VARCHAR(30) NOT NULL,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT uq_installments_application_number UNIQUE (credit_application_id, installment_number),
    CONSTRAINT chk_installments_status CHECK (
        status IN ('UNPAID', 'PARTIAL_PAID', 'PAID', 'LATE', 'DEFAULTED')
    ),
    CONSTRAINT chk_installments_number CHECK (installment_number > 0),
    CONSTRAINT chk_installments_amount CHECK (
        amount >= 0
        AND paid_amount >= 0
        AND (outstanding_amount IS NULL OR outstanding_amount >= 0)
    ),
    CONSTRAINT chk_installments_days_overdue CHECK (days_overdue >= 0)
);

CREATE TABLE payments (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    installment_id BIGINT NOT NULL REFERENCES installments(id),
    paid_by BIGINT REFERENCES users(id),

    payment_number VARCHAR(30) NOT NULL UNIQUE,
    payment_date DATE NOT NULL,
    payment_amount NUMERIC(18,2) NOT NULL,
    payment_method VARCHAR(50),
    payment_channel VARCHAR(50),

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_payments_amount CHECK (payment_amount > 0),
    CONSTRAINT chk_payments_method CHECK (
        payment_method IS NULL OR payment_method IN ('CASH', 'TRANSFER', 'VIRTUAL_ACCOUNT', 'AUTODEBIT')
    ),
    CONSTRAINT chk_payments_channel CHECK (
        payment_channel IS NULL OR payment_channel IN ('BRANCH', 'MOBILE_APP', 'BANK', 'PARTNER')
    )
);

CREATE TABLE audit_logs (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,

    user_id BIGINT REFERENCES users(id),

    entity_name VARCHAR(100) NOT NULL,
    entity_id BIGINT NOT NULL,

    action VARCHAR(50) NOT NULL,

    old_value TEXT,
    new_value TEXT,

    ip_address VARCHAR(50),
    user_agent TEXT,

    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT chk_audit_logs_action CHECK (
        action IN ('CREATE', 'UPDATE', 'DELETE', 'SUBMIT', 'APPROVE', 'REJECT', 'LOGIN', 'PAYMENT')
    )
);

-- =====================================================
-- BASIC INDEXES FOR OLTP + ANALYTICAL QUERIES
-- =====================================================