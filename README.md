# Insurance Claims Analytics & Risk Assessment

> A data-driven analysis of claim outcomes, premium fairness, customer risk segmentation, and claim anomalies across a 10,000-policy insurance portfolio.

---

## Project Overview

This project delivers a complete insurance analytics solution structured around four core business questions:

1. **Why are claims being rejected** — and is the rejection pattern consistent across product lines and demographics?
2. **Is premium pricing aligned** with the coverage and risk profile of each product line?
3. **Which customers represent the highest financial risk** to the insurer?
4. **Which claims exhibit anomalous patterns** warranting investigation by the claims review team?

The analysis combines exploratory data analysis, formal statistical testing, rule-based and machine-learning anomaly detection, and a logistic regression model for claim outcome prediction — all framed around actionable business insights.

---

## Business Objective

Enable insurance operations and underwriting teams to:

- Identify structural inefficiencies in the claims adjudication process
- Quantify financial exposure by customer segment and product line
- Prioritise claims review resources using a data-driven risk tiering system
- Surface anomalous claims for investigation without relying solely on adjudicator judgment

---

## Dataset Description

| Attribute | Detail |
|---|---|
| **Source** | InsuranceData.csv |
| **Records** | 10,004 policies |
| **Features** | 13 raw + 8 engineered |
| **Policy Types** | Health, Life, Auto, Home, Travel |
| **Claim Statuses** | Settled, Rejected, Pending |
| **Date Range** | 2023–2025 |

**Key fields:** `PolicyNumber`, `CustomerID`, `Gender`, `Age`, `PolicyType`, `PremiumAmount`, `CoverageAmount`, `ClaimAmount`, `ClaimStatus`, `ClaimDate`

**Data Limitation:** The dataset does not contain claim reason, medical diagnosis, location, or income data. Anomaly detection findings are framed accordingly as candidates for investigation — not confirmed fraud.

---

## Methodology

| Phase | Description |
|---|---|
| **Data Preparation** | Schema validation, date parsing, feature engineering (Coverage_Ratio, Utilization, Days_to_Claim, AgeGroup, ClaimTiming) |
| **Exploratory Analysis** | Univariate and bivariate analysis across all key dimensions |
| **Statistical Testing** | Chi-Square, ANOVA, T-Test with full hypothesis framing and business interpretation |
| **Anomaly Detection** | IQR, Z-Score, percentile thresholds, early claim flag + Isolation Forest |
| **Risk Profiling** | Weighted risk score model validated by K-Means clustering |
| **Claim Prediction** | Logistic Regression — Settled vs Rejected binary classification |
| **Lifecycle Analysis** | Days-to-claim distribution and outcome analysis by timing bucket |

---

## Technology Stack

| Category | Tools |
|---|---|
| **Language** | Python 3.11 |
| **Data Manipulation** | pandas, numpy |
| **Visualisation** | matplotlib, seaborn |
| **Statistical Testing** | scipy.stats |
| **Machine Learning** | scikit-learn (LogisticRegression, KMeans, IsolationForest) |
| **Notebooks** | Jupyter |
| **Database Queries** | SQL (SQLite / DuckDB compatible) |
| **Dashboard** | Power BI (Insurance_Dashboard.pbix) |
| **Reporting** | fpdf2 |

---

## Key Findings

| Area | Finding |
|---|---|
| **Claim Outcomes** | Rejection rate of 43.5% uniformly distributed across product lines and demographics — no statistically significant product or gender bias detected |
| **Premium Pricing** | Premiums show no significant differentiation across product lines, suggesting a flat pricing structure that may not adequately reflect risk variation |
| **Anomaly Detection** | 103 High Risk and 1,714 Suspicious policies identified via composite 6-rule flagging model |
| **Risk Profiling** | Three balanced risk tiers; K-Means clustering independently validates the rule-based segmentation |
| **Claim Prediction** | Claim amount and coverage utilisation are the strongest predictors of claim outcome |
| **Lifecycle Analysis** | Early claims (filed within 30 days) represent a concentrated segment requiring monitoring |

---

## Project Structure

```
Insurance-Claims-Analytics-Risk-Assessment/
│
├── data/
│   ├── raw/
│   │   └── InsuranceData.csv
│   └── processed/
│       ├── cleaned_data.csv
│       ├── anomaly_flagged.csv
│       ├── risk_profiles.csv
│       └── top100_high_risk.csv
│
├── notebooks/
│   ├── 01_Data_Preparation.ipynb
│   ├── 02_EDA.ipynb
│   ├── 03_Statistical_Testing.ipynb
│   ├── 04_Anomaly_Detection.ipynb
│   ├── 05_Risk_Profiling.ipynb
│   ├── 06_Claim_Prediction.ipynb
│   └── 07_Policy_Lifecycle_Analysis.ipynb
│
├── src/
│   ├── data_preparation.py
│   ├── eda.py
│   ├── statistical_testing.py
│   ├── anomaly_detection.py
│   ├── risk_profiling.py
│   ├── claim_prediction.py
│   └── lifecycle_analysis.py
│
├── sql/
│   ├── kpi_queries.sql
│   ├── claim_analysis.sql
│   ├── customer_segmentation.sql
│   └── risk_analysis.sql
│
├── visuals/
│   └── (12 charts generated on pipeline run)
│
├── reports/
│   ├── Insurance_Analysis_Report.pdf
│   └── Executive_Summary.pdf
│
├── dashboard/
│   └── Insurance_Dashboard.pbix
│
├── config.py
├── main.py
├── requirements.txt
└── README.md
```

---

## Reproducing the Analysis

```bash
# 1. Clone the repository
git clone https://github.com/yourusername/Insurance-Claims-Analytics-Risk-Assessment.git
cd Insurance-Claims-Analytics-Risk-Assessment

# 2. Install dependencies
pip install -r requirements.txt

# 3. Run the full pipeline
python main.py

# 4. Launch notebooks
jupyter notebook notebooks/
```

---

## Results & Recommendations

**Claims Processing**
The uniform rejection rate across all segments suggests the rejection criteria may be structurally rigid rather than risk-differentiated. A review of rejection reason codes is recommended to determine whether high-value claims are disproportionately rejected.

**Premium Pricing**
The absence of statistically significant premium differentiation across product lines is a risk management concern. Actuarial repricing should be considered, particularly for high-utilisation segments identified in the risk profiling module.

**Claims Investigation**
The 103 High Risk records should be prioritised for manual review. The composite flagging model provides a transparent, auditable basis for triage decisions.

**Underwriting**
Early claims (filed within 30 days) warrant closer scrutiny at the underwriting stage. Strengthening pre-acceptance screening for high-risk profiles could reduce early claim frequency.

---

## Future Enhancements

- Integrate claim reason and diagnosis codes for fraud probability scoring
- Build a time-series model for claim frequency forecasting by product line
- Incorporate external data (postcode, income, health index) for richer risk profiling
- Automate pipeline execution with Apache Airflow or Prefect
- Deploy risk scoring API for real-time underwriting support
