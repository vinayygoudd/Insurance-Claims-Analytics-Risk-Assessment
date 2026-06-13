-- =============================================================================
-- risk_analysis.sql
-- Insurance Claims Analytics — Risk & Anomaly Analysis Queries
--
-- Purpose : Identify high-risk policies and anomalous claims using
--           SQL-based rule application. Supports the Python anomaly
--           detection module with reproducible, auditable query logic.
-- =============================================================================


-- -----------------------------------------------------------------------------
-- Coverage Utilization Summary by Policy Type
-- (High utilization = insurer bears significant financial exposure)
-- -----------------------------------------------------------------------------
SELECT
    PolicyType,
    COUNT(*)                                        AS total_claims,
    ROUND(AVG(Utilization), 4)                      AS avg_utilization,
    ROUND(MAX(Utilization), 4)                      AS max_utilization,
    SUM(CASE WHEN Utilization >= 0.80 THEN 1 ELSE 0 END) AS high_utilization_count,
    ROUND(
        100.0 * SUM(CASE WHEN Utilization >= 0.80 THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                               AS high_utilization_rate_pct
FROM insurance_data
WHERE ClaimAmount > 0
GROUP BY PolicyType
ORDER BY avg_utilization DESC;


-- -----------------------------------------------------------------------------
-- Early Claims — Filed Within 30 Days of Policy Start
-- -----------------------------------------------------------------------------
SELECT
    PolicyType,
    COUNT(*)                                AS early_claim_count,
    ROUND(AVG(ClaimAmount), 2)              AS avg_claim_amount,
    ROUND(AVG(Days_to_Claim), 1)            AS avg_days_to_claim,
    SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END) AS rejected_count,
    ROUND(
        100.0 * SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END)
        / NULLIF(COUNT(*), 0), 2
    )                                       AS rejection_rate_pct
FROM insurance_data
WHERE Early_Claim_Flag = 1
GROUP BY PolicyType
ORDER BY early_claim_count DESC;


-- -----------------------------------------------------------------------------
-- High Claim-to-Premium Ratio — Potential Overexposure
-- (Threshold: Claim Amount > 3x Premium Amount)
-- -----------------------------------------------------------------------------
SELECT
    PolicyNumber,
    CustomerID,
    Age,
    Gender,
    PolicyType,
    ROUND(PremiumAmount, 2)                             AS premium_amount,
    ROUND(ClaimAmount, 2)                               AS claim_amount,
    ROUND(ClaimAmount / NULLIF(PremiumAmount, 0), 2)    AS claim_to_premium_ratio,
    ClaimStatus
FROM insurance_data
WHERE ClaimAmount > 0
  AND (ClaimAmount / NULLIF(PremiumAmount, 0)) > 3.0
ORDER BY claim_to_premium_ratio DESC
LIMIT 50;


-- -----------------------------------------------------------------------------
-- Risk Tier Summary — From risk_profiles.csv Output
-- (Run after Python risk profiling module)
-- -----------------------------------------------------------------------------
SELECT
    RiskSegment,
    COUNT(*)                                AS customer_count,
    ROUND(AVG(RiskScore), 4)                AS avg_risk_score,
    ROUND(AVG(ClaimAmount), 2)              AS avg_claim_amount,
    ROUND(AVG(PremiumAmount), 2)            AS avg_premium,
    ROUND(AVG(Age), 1)                      AS avg_age,
    ROUND(AVG(Utilization), 4)              AS avg_utilization,
    ROUND(SUM(ClaimAmount), 2)              AS total_claim_exposure
FROM risk_profiles
GROUP BY RiskSegment
ORDER BY avg_risk_score DESC;


-- -----------------------------------------------------------------------------
-- Anomaly Flag Summary — From anomaly_flagged.csv Output
-- (Run after Python anomaly detection module)
-- -----------------------------------------------------------------------------
SELECT
    AnomalyRisk,
    COUNT(*)                                AS record_count,
    ROUND(AVG(ClaimAmount), 2)              AS avg_claim_amount,
    ROUND(SUM(ClaimAmount), 2)              AS total_exposure,
    ROUND(AVG(total_flags), 2)              AS avg_flags_triggered,
    SUM(CASE WHEN ClaimStatus = 'Settled'  THEN 1 ELSE 0 END) AS settled,
    SUM(CASE WHEN ClaimStatus = 'Rejected' THEN 1 ELSE 0 END) AS rejected,
    SUM(CASE WHEN ClaimStatus = 'Pending'  THEN 1 ELSE 0 END) AS pending
FROM anomaly_flagged
GROUP BY AnomalyRisk
ORDER BY avg_claim_amount DESC;


-- -----------------------------------------------------------------------------
-- Top 20 Highest Risk Policies Requiring Manual Review
-- -----------------------------------------------------------------------------
SELECT
    PolicyNumber,
    CustomerID,
    Age,
    Gender,
    PolicyType,
    ROUND(PremiumAmount, 2)     AS premium_amount,
    ROUND(ClaimAmount, 2)       AS claim_amount,
    ROUND(Utilization, 4)       AS utilization_rate,
    total_flags,
    AnomalyRisk,
    ClaimStatus
FROM anomaly_flagged
WHERE AnomalyRisk = 'High Risk'
ORDER BY total_flags DESC, ClaimAmount DESC
LIMIT 20;
