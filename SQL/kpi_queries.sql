-- =============================================================================
-- kpi_queries.sql
-- Insurance Claims Analytics — Portfolio KPI Queries
--
-- Purpose : Compute top-level business KPIs for the executive dashboard.
-- Context : These queries assume the cleaned dataset has been loaded into
--           a relational database or query engine (e.g. SQLite, PostgreSQL,
--           DuckDB). Column names match the cleaned_data.csv output.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- KPI 1 — Total Portfolio Size
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*)                                        AS total_policies,
    COUNT(DISTINCT CustomerID)                      AS unique_customers,
    COUNT(DISTINCT PolicyType)                      AS product_lines
FROM insurance_data;


-- -----------------------------------------------------------------------------
-- KPI 2 — Premium & Coverage Summary
-- -----------------------------------------------------------------------------
SELECT
    ROUND(SUM(PremiumAmount), 2)                    AS total_premium_collected,
    ROUND(AVG(PremiumAmount), 2)                    AS avg_premium_per_policy,
    ROUND(SUM(CoverageAmount), 2)                   AS total_coverage_issued,
    ROUND(AVG(CoverageAmount), 2)                   AS avg_coverage_per_policy,
    ROUND(SUM(CoverageAmount) / SUM(PremiumAmount), 2) AS portfolio_coverage_ratio
FROM insurance_data;


-- -----------------------------------------------------------------------------
-- KPI 3 — Claim Volume & Settlement Rate
-- -----------------------------------------------------------------------------
SELECT
    COUNT(*)                                                    AS total_policies,
    SUM(CASE WHEN ClaimAmount > 0 THEN 1 ELSE 0 END)           AS total_claims_filed,
    SUM(CASE WHEN ClaimStatus = 'Settled' THEN 1 ELSE 0 END)   AS claims_settled,
    SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END)  AS claims_rejected,
    SUM(CASE WHEN ClaimStatus = 'Pending'  THEN 1 ELSE 0 END)  AS claims_pending,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimStatus = 'Settled' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                                           AS settlement_rate_pct,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                                           AS rejection_rate_pct
FROM insurance_data;


-- -----------------------------------------------------------------------------
-- KPI 4 — Total Claims Financial Exposure
-- -----------------------------------------------------------------------------
SELECT
    ROUND(SUM(ClaimAmount), 2)                      AS total_claim_amount,
    ROUND(AVG(ClaimAmount), 2)                      AS avg_claim_amount,
    ROUND(MAX(ClaimAmount), 2)                      AS max_claim_amount,
    ROUND(MIN(CASE WHEN ClaimAmount > 0 THEN ClaimAmount END), 2) AS min_claim_amount,
    ROUND(SUM(ClaimAmount) / NULLIF(SUM(PremiumAmount), 0), 4)   AS loss_ratio
FROM insurance_data;


-- -----------------------------------------------------------------------------
-- KPI 5 — Portfolio Age Profile
-- -----------------------------------------------------------------------------
SELECT
    ROUND(AVG(Age), 1)      AS avg_customer_age,
    MIN(Age)                AS youngest_customer,
    MAX(Age)                AS oldest_customer,
    SUM(CASE WHEN Age < 30             THEN 1 ELSE 0 END) AS age_under_30,
    SUM(CASE WHEN Age BETWEEN 30 AND 59 THEN 1 ELSE 0 END) AS age_30_to_59,
    SUM(CASE WHEN Age >= 60            THEN 1 ELSE 0 END) AS age_60_plus
FROM insurance_data;
