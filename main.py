"""
main.py
-------
Orchestration entry point for the Insurance Claims Analytics pipeline.

Executes all analytical modules in sequence. Each module is independently
runnable, but this script provides a single command to reproduce the
complete project end-to-end.

Usage:
    python main.py
"""

import logging
import sys
import time
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s | %(levelname)s | %(message)s",
    datefmt="%H:%M:%S",
)
logger = logging.getLogger(__name__)


def _run_step(step_name: str, func, *args, **kwargs):
    """Execute a pipeline step with timing and error handling."""
    logger.info("=" * 60)
    logger.info("STEP: %s", step_name)
    logger.info("=" * 60)
    start = time.time()
    try:
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        logger.info("COMPLETED: %s (%.1fs)", step_name, elapsed)
        return result
    except Exception as exc:
        logger.error("FAILED: %s — %s", step_name, exc)
        raise


def main():
    """Run the complete Insurance Claims Analytics pipeline."""
    logger.info("Insurance Claims Analytics & Risk Assessment")
    logger.info("Pipeline started")
    pipeline_start = time.time()

    # Step 1 — Data Preparation
    from src.data_preparation import run_data_preparation
    df_clean = _run_step("Data Preparation", run_data_preparation)

    # Step 2 — Exploratory Data Analysis
    from src.eda import run_eda
    _run_step("Exploratory Data Analysis", run_eda, df_clean)

    # Step 3 — Statistical Testing
    from src.statistical_testing import run_statistical_testing
    stats_summary = _run_step("Statistical Testing", run_statistical_testing, df_clean)

    # Step 4 — Anomaly Detection
    from src.anomaly_detection import run_anomaly_detection
    df_flagged = _run_step("Anomaly Detection", run_anomaly_detection, df_clean)

    # Step 5 — Risk Profiling
    from src.risk_profiling import run_risk_profiling
    df_risk = _run_step("Customer Risk Profiling", run_risk_profiling, df_clean)

    # Step 6 — Claim Prediction
    from src.claim_prediction import run_claim_prediction
    model_results = _run_step("Claim Outcome Prediction", run_claim_prediction, df_clean)

    # Step 7 — Lifecycle Analysis
    from src.lifecycle_analysis import run_lifecycle_analysis
    lifecycle_summary = _run_step("Policy Lifecycle Analysis", run_lifecycle_analysis, df_clean)

    total_elapsed = time.time() - pipeline_start
    logger.info("=" * 60)
    logger.info("PIPELINE COMPLETE — Total runtime: %.1fs", total_elapsed)
    logger.info("=" * 60)

    # Summary
    logger.info("Outputs generated:")
    logger.info("  data/processed/   — 4 processed CSV files")
    logger.info("  visuals/          — Charts and dashboards")
    logger.info("  Statistical Tests — %d tests conducted", len(stats_summary))
    logger.info("  Model ROC-AUC     — %.4f", model_results["eval_results"]["roc_auc"])


if __name__ == "__main__":
    main()
