-- =============================================================================
-- claim_analysis.sql
-- Insurance Claims Analytics — Claim Outcome Analysis Queries
--
-- Purpose : Drill into claim outcomes across policy types, demographics,
--           and financial dimensions to support business decision-making.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Claim Status Distribution by Policy Type
-- -----------------------------------------------------------------------------
SELECT
    PolicyType,
    ClaimStatus,
    COUNT(*)                                                    AS claim_count,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (PARTITION BY PolicyType), 2
    )                                                           AS status_pct_within_type
FROM insurance_data
GROUP BY PolicyType, ClaimStatus
ORDER BY PolicyType, ClaimStatus;


-- -----------------------------------------------------------------------------
-- Rejection Rate by Policy Type — Ranked
-- -----------------------------------------------------------------------------
SELECT
    PolicyType,
    COUNT(*)                                                        AS total_policies,
    SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END)      AS rejected_count,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                                               AS rejection_rate_pct
FROM insurance_data
GROUP BY PolicyType
ORDER BY rejection_rate_pct DESC;


-- -----------------------------------------------------------------------------
-- Claim Status by Age Group
-- -----------------------------------------------------------------------------
SELECT
    AgeGroup,
    ClaimStatus,
    COUNT(*)                                                    AS claim_count,
    ROUND(AVG(ClaimAmount), 2)                                  AS avg_claim_amount,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (PARTITION BY AgeGroup), 2
    )                                                           AS status_pct_within_age
FROM insurance_data
GROUP BY AgeGroup, ClaimStatus
ORDER BY AgeGroup, ClaimStatus;


-- -----------------------------------------------------------------------------
-- Claim Status by Gender
-- -----------------------------------------------------------------------------
SELECT
    Gender,
    ClaimStatus,
    COUNT(*)                                                    AS claim_count,
    ROUND(AVG(ClaimAmount), 2)                                  AS avg_claim_amount,
    ROUND(
        100.0 * COUNT(*)
        / SUM(COUNT(*)) OVER (PARTITION BY Gender), 2
    )                                                           AS status_pct_within_gender
FROM insurance_data
GROUP BY Gender, ClaimStatus
ORDER BY Gender, ClaimStatus;


-- -----------------------------------------------------------------------------
-- Average Claim Amount by Status — Financial Exposure Comparison
-- -----------------------------------------------------------------------------
SELECT
    ClaimStatus,
    COUNT(*)                            AS claim_count,
    ROUND(AVG(ClaimAmount), 2)          AS avg_claim_amount,
    ROUND(MIN(ClaimAmount), 2)          AS min_claim_amount,
    ROUND(MAX(ClaimAmount), 2)          AS max_claim_amount,
    ROUND(SUM(ClaimAmount), 2)          AS total_claim_exposure
FROM insurance_data
WHERE ClaimAmount > 0
GROUP BY ClaimStatus
ORDER BY avg_claim_amount DESC;


-- -----------------------------------------------------------------------------
-- High-Value Claims — Top 20 by Claim Amount
-- -----------------------------------------------------------------------------
SELECT
    PolicyNumber,
    CustomerID,
    Gender,
    Age,
    PolicyType,
    PremiumAmount,
    CoverageAmount,
    ClaimAmount,
    ClaimStatus,
    ROUND(ClaimAmount / NULLIF(PremiumAmount, 0), 2) AS claim_to_premium_ratio,
    ROUND(ClaimAmount / NULLIF(CoverageAmount, 0), 4) AS utilization_rate
FROM insurance_data
WHERE ClaimAmount > 0
ORDER BY ClaimAmount DESC
LIMIT 20;


-- -----------------------------------------------------------------------------
-- Pending Claims Ageing — Claims Filed But Not Yet Resolved
-- -----------------------------------------------------------------------------
SELECT
    PolicyType,
    COUNT(*)                                AS pending_count,
    ROUND(AVG(ClaimAmount), 2)              AS avg_pending_claim_amount,
    ROUND(SUM(ClaimAmount), 2)              AS total_pending_exposure,
    ROUND(AVG(Days_to_Claim), 1)            AS avg_days_to_file
FROM insurance_data
WHERE ClaimStatus = 'Pending'
GROUP BY PolicyType
ORDER BY total_pending_exposure DESC;
