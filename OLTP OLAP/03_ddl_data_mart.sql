-- =====================================================
-- 03. Data Mart DDL
-- Case: Ready-to-consume summary tables for dashboards
-- Database: PostgreSQL
-- Purpose: fast BI/dashboard query, not raw transaction storage
-- =====================================================

DROP SCHEMA IF EXISTS mart CASCADE;
CREATE SCHEMA mart;
SET search_path TO mart;

-- Dashboard 1: daily application summary by branch
CREATE TABLE mart_application_daily_summary (
    summary_date            DATE NOT NULL,
    branch_name             VARCHAR(100) NOT NULL,
    total_applications      INT NOT NULL,
    approved_applications   INT NOT NULL,
    rejected_applications   INT NOT NULL,
    disbursed_applications  INT NOT NULL,
    total_requested_amount  NUMERIC(15,2) NOT NULL,
    PRIMARY KEY (summary_date, branch_name)
);

-- Dashboard 2: monthly collection summary by branch
CREATE TABLE mart_collection_monthly_summary (
    month_start_date    DATE NOT NULL,
    branch_name         VARCHAR(100) NOT NULL,
    total_due_amount    NUMERIC(15,2) NOT NULL,
    total_paid_amount   NUMERIC(15,2) NOT NULL,
    payment_ratio_pct   NUMERIC(7,2) NOT NULL,
    PRIMARY KEY (month_start_date, branch_name)
);

-- Dashboard 3: payment amount by channel
CREATE TABLE mart_payment_channel_summary (
    payment_date        DATE NOT NULL,
    payment_channel     VARCHAR(30) NOT NULL,
    total_payments      INT NOT NULL,
    total_paid_amount   NUMERIC(15,2) NOT NULL,
    PRIMARY KEY (payment_date, payment_channel)
);
