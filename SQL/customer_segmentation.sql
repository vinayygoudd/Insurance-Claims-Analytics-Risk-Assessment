-- =============================================================================
-- customer_segmentation.sql
-- Insurance Claims Analytics — Customer Segmentation Queries
--
-- Purpose : Segment customers by demographics, policy behaviour, and
--           financial exposure to support underwriting and retention strategy.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Customer Profile by Age Group and Policy Type
-- -----------------------------------------------------------------------------
SELECT
    AgeGroup,
    PolicyType,
    COUNT(*)                                AS customer_count,
    ROUND(AVG(PremiumAmount), 2)            AS avg_premium,
    ROUND(AVG(CoverageAmount), 2)           AS avg_coverage,
    ROUND(AVG(ClaimAmount), 2)              AS avg_claim_amount,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimStatus = 'Settled' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                       AS settlement_rate_pct
FROM insurance_data
GROUP BY AgeGroup, PolicyType
ORDER BY AgeGroup, PolicyType;


-- -----------------------------------------------------------------------------
-- Gender vs Policy Type Cross-Segmentation
-- -----------------------------------------------------------------------------
SELECT
    Gender,
    PolicyType,
    COUNT(*)                                AS policy_count,
    ROUND(AVG(PremiumAmount), 2)            AS avg_premium,
    ROUND(AVG(CoverageAmount), 2)           AS avg_coverage,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimAmount > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                       AS claim_filing_rate_pct
FROM insurance_data
GROUP BY Gender, PolicyType
ORDER BY Gender, PolicyType;


-- -----------------------------------------------------------------------------
-- High-Value Customers — Top Premium Payers
-- (Retention priority: highest revenue contribution)
-- -----------------------------------------------------------------------------
SELECT
    CustomerID,
    Gender,
    Age,
    PolicyType,
    ROUND(PremiumAmount, 2)             AS premium_amount,
    ROUND(CoverageAmount, 2)            AS coverage_amount,
    ClaimStatus,
    ROUND(ClaimAmount, 2)               AS claim_amount
FROM insurance_data
ORDER BY PremiumAmount DESC
LIMIT 50;


-- -----------------------------------------------------------------------------
-- Customer Lifetime Value Proxy
-- (Customers who paid high premiums with no or low claims = most profitable)
-- -----------------------------------------------------------------------------
SELECT
    CustomerID,
    Gender,
    Age,
    PolicyType,
    ROUND(PremiumAmount, 2)                                     AS premium_paid,
    ROUND(ClaimAmount, 2)                                       AS claim_amount,
    ROUND(PremiumAmount - ClaimAmount, 2)                       AS net_contribution,
    ClaimStatus
FROM insurance_data
ORDER BY net_contribution DESC
LIMIT 100;


-- -----------------------------------------------------------------------------
-- Multi-Policy Customers (if applicable)
-- Identifies customers appearing more than once
-- -----------------------------------------------------------------------------
SELECT
    CustomerID,
    COUNT(*)                            AS policy_count,
    COUNT(DISTINCT PolicyType)          AS distinct_policy_types,
    ROUND(SUM(PremiumAmount), 2)        AS total_premium_paid,
    ROUND(SUM(ClaimAmount), 2)          AS total_claimed
FROM insurance_data
GROUP BY CustomerID
HAVING COUNT(*) > 1
ORDER BY policy_count DESC;


-- -----------------------------------------------------------------------------
-- Age Group Financial Summary
-- -----------------------------------------------------------------------------
SELECT
    AgeGroup,
    COUNT(*)                                AS total_policies,
    ROUND(AVG(PremiumAmount), 2)            AS avg_premium,
    ROUND(AVG(CoverageAmount), 2)           AS avg_coverage,
    ROUND(AVG(Coverage_Ratio), 2)           AS avg_coverage_ratio,
    ROUND(AVG(Utilization), 4)              AS avg_utilization,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimAmount > 0 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                       AS claim_filing_rate_pct,
    ROUND(SUM(ClaimAmount), 2)              AS total_claim_exposure
FROM insurance_data
GROUP BY AgeGroup
ORDER BY AgeGroup;
