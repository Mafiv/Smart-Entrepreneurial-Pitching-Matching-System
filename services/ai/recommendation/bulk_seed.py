"""
bulk_seed.py
============
Seed startup_pitches_5000.csv into SEPMS via the recommendation service.

Usage:
    cd services/ai/recommendation
    python bulk_seed.py --csv ../startup_pitches_5000.csv

Steps per row:
  1. Build a combined text string (mirrors buildSubmissionText in matching.service.ts)
  2. POST /vectorize  →  get 384-dim embedding
  3. POST http://localhost:5000/api/submissions/seed  →  create full submission in Node

CSV column → Submission schema mapping
---------------------------------------
  title                         → Submission.title
  summary                       → Submission.summary
  sector                        → Submission.sector  (already uses exact enum values)
  stage                         → Submission.stage
  targetAmount                  → Submission.targetAmount
  currency                      → Submission.currency
  problem_statement             → Submission.problem.statement
  problem_targetMarket          → Submission.problem.targetMarket
  problem_marketSize            → Submission.problem.marketSize
  solution_description          → Submission.solution.description
  solution_uniqueValue          → Submission.solution.uniqueValue
  solution_competitiveAdvantage → Submission.solution.competitiveAdvantage
  businessModel_revenueStreams  → Submission.businessModel.revenueStreams
  businessModel_pricingStrategy → Submission.businessModel.pricingStrategy
  businessModel_customerAcquisition → Submission.businessModel.customerAcquisition
  financials_currentRevenue     → Submission.financials.currentRevenue
  financials_projectedRevenue   → Submission.financials.projectedRevenue
  financials_burnRate           → Submission.financials.burnRate
  financials_runway             → Submission.financials.runway
  status                        → Submission.status (approved/rejected/pending)
"""

import argparse
import time

import pandas as pd
import requests

VECTORIZE_URL = "http://localhost:8000/vectorize"
SEED_URL      = "http://localhost:5000/api/submissions/seed"
MAX_ROWS      = 5000
SLEEP_SEC     = 0.2  # throttle between requests

# Submission.sector valid enum values (matches Submission.ts)
VALID_SECTORS = {
    "technology", "healthcare", "fintech", "education",
    "agriculture", "energy", "real_estate", "manufacturing",
    "retail", "other",
}

# Submission.stage valid enum values
VALID_STAGES = {"mvp", "early-revenue", "scaling"}


def safe_str(val: object, fallback: str = "") -> str:
    """Convert a value to string, returning fallback for NaN/None/empty."""
    s = str(val).strip()
    return fallback if s.lower() in ("nan", "none", "") else s


def load_csv(path: str) -> pd.DataFrame:
    df = pd.read_csv(path, low_memory=False)
    required = {"title", "summary", "sector"}
    missing = required - set(df.columns)
    if missing:
        raise ValueError(f"CSV missing required columns: {missing}. Found: {list(df.columns)}")
    df = df.dropna(subset=["title", "summary"])
    df = df[df["title"].str.strip().str.len() > 0]
    df = df[df["summary"].str.strip().str.len() > 0]
    df = df.head(MAX_ROWS).reset_index(drop=True)
    print(f"Loaded {len(df)} rows after filtering.")
    return df


def map_sector(val: object) -> str:
    """Map CSV sector value to Submission.sector enum. Already uses correct values."""
    s = safe_str(val, "other").lower().replace(" ", "_")
    return s if s in VALID_SECTORS else "other"


def map_stage(val: object) -> str:
    """Map CSV stage value to Submission.stage enum."""
    s = safe_str(val, "mvp").lower()
    return s if s in VALID_STAGES else "mvp"


def build_text(row: pd.Series) -> str:
    """
    Build the combined text string for embedding generation.
    Mirrors buildSubmissionText() in apps/api/src/services/matching.service.ts:
      title + summary + sector + stage +
      problem.statement + solution.description + businessModel.revenueStreams
    """
    parts = [
        safe_str(row.get("title")),
        safe_str(row.get("summary")),
        safe_str(row.get("sector")),
        safe_str(row.get("stage")),
        safe_str(row.get("problem_statement")),
        safe_str(row.get("solution_description")),
        safe_str(row.get("businessModel_revenueStreams")),
    ]
    return "\n".join(p for p in parts if p)


def build_payload(row: pd.Series, embedding: list[float]) -> dict:
    """Build the full submission payload matching the Submission mongoose schema."""
    return {
        "title":   safe_str(row.get("title"), "Untitled"),
        "summary": safe_str(row.get("summary")),
        "sector":  map_sector(row.get("sector")),
        "stage":   map_stage(row.get("stage")),
        "targetAmount": _safe_number(row.get("targetAmount")),
        "currency": safe_str(row.get("currency"), "USD").upper(),
        "problem": {
            "statement":   safe_str(row.get("problem_statement")),
            "targetMarket": safe_str(row.get("problem_targetMarket")),
            "marketSize":  safe_str(row.get("problem_marketSize")),
        },
        "solution": {
            "description":          safe_str(row.get("solution_description")),
            "uniqueValue":          safe_str(row.get("solution_uniqueValue")),
            "competitiveAdvantage": safe_str(row.get("solution_competitiveAdvantage")),
        },
        "businessModel": {
            "revenueStreams":      safe_str(row.get("businessModel_revenueStreams")),
            "pricingStrategy":    safe_str(row.get("businessModel_pricingStrategy")),
            "customerAcquisition": safe_str(row.get("businessModel_customerAcquisition")),
        },
        "financials": {
            "currentRevenue":   safe_str(row.get("financials_currentRevenue")),
            "projectedRevenue": safe_str(row.get("financials_projectedRevenue")),
            "burnRate":         safe_str(row.get("financials_burnRate")),
            "runway":           safe_str(row.get("financials_runway")),
        },
        "status":    safe_str(row.get("status"), "approved"),
        "embedding": embedding,
    }


def _safe_number(val: object) -> float | None:
    try:
        n = float(str(val).replace(",", "").strip())
        return n if n > 0 else None
    except (ValueError, TypeError):
        return None


def main(csv_path: str) -> None:
    df = load_csv(csv_path)
    ok, fail = 0, 0

    for idx, row in df.iterrows():
        title = safe_str(row.get("title"), f"Startup #{idx}")
        text  = build_text(row)

        try:
            # Step 1: generate embedding
            vec_res = requests.post(VECTORIZE_URL, json={"text": text}, timeout=30)
            vec_res.raise_for_status()
            embedding = vec_res.json()["vector"]

            # Step 2: seed full submission into Node backend
            payload = build_payload(row, embedding)
            seed_res = requests.post(SEED_URL, json=payload, timeout=30)
            seed_res.raise_for_status()

            ok += 1
            print(f"[{idx+1}/{len(df)}] ✅  {title[:60]}")
        except Exception as e:
            fail += 1
            print(f"[{idx+1}/{len(df)}] ❌  {title[:50]} — {e}")

        time.sleep(SLEEP_SEC)

    print(f"\nDone. {ok} seeded, {fail} failed.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Seed startup_pitches_5000.csv into SEPMS."
    )
    parser.add_argument(
        "--csv",
        default="../startup_pitches_5000.csv",
        help="Path to the startup pitches CSV file.",
    )
    main(parser.parse_args().csv)
