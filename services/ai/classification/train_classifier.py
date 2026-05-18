"""
train_classifier.py
===================
Training script for the SEPMS pitch trust/quality classifier.

Usage
-----
    cd services/ai/classification
    python train_classifier.py

    # Or point to a different CSV:
    python train_classifier.py --csv ../startup_pitches_5000.csv

What it does
------------
1. Loads startup_pitches_5000.csv — columns map directly to the Submission schema.
2. Creates a binary label y from the "status" column:
       y = 1  ("High Quality / Approved")   if status == "approved"
       y = 0  ("Low Quality / Rejected")    if status == "rejected"
       rows with status == "pending" are dropped (ambiguous — not useful for training)
3. Builds a rich feature text X by combining multiple pitch fields:
       title + summary + problem_statement + solution_description +
       businessModel_revenueStreams
   This mirrors exactly what buildSubmissionText() does in matching.service.ts,
   so the classifier evaluates the same text the embedding model sees.
4. Trains a scikit-learn Pipeline:
       TfidfVectorizer(stop_words='english', max_features=5000, ngram_range=(1,2))
       → LogisticRegression(max_iter=1000, class_weight='balanced')
5. Prints a classification_report on the held-out test set.
6. Saves the fitted pipeline as trust_score_model.pkl (joblib).

CSV column contract (startup_pitches_5000.csv)
----------------------------------------------
  title                         — pitch title
  summary                       — one-line executive summary
  sector                        — business sector enum
  stage                         — funding stage enum
  targetAmount                  — funding target (numeric)
  currency                      — currency code
  problem_statement             — Submission.problem.statement
  problem_targetMarket          — Submission.problem.targetMarket
  problem_marketSize            — Submission.problem.marketSize
  solution_description          — Submission.solution.description
  solution_uniqueValue          — Submission.solution.uniqueValue
  solution_competitiveAdvantage — Submission.solution.competitiveAdvantage
  businessModel_revenueStreams  — Submission.businessModel.revenueStreams
  businessModel_pricingStrategy — Submission.businessModel.pricingStrategy
  businessModel_customerAcquisition
  financials_currentRevenue     — Submission.financials.currentRevenue
  financials_projectedRevenue   — Submission.financials.projectedRevenue
  financials_burnRate           — Submission.financials.burnRate
  financials_runway             — Submission.financials.runway
  status                        — "approved" | "rejected" | "pending"
"""

import argparse
import os
import sys

import joblib
import pandas as pd
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import classification_report
from sklearn.model_selection import train_test_split
from sklearn.pipeline import Pipeline

# ── Paths ─────────────────────────────────────────────────────────────────────

SCRIPT_DIR  = os.path.dirname(os.path.abspath(__file__))
DEFAULT_CSV = os.path.join(SCRIPT_DIR, "..", "startup_pitches_5000.csv")
MODEL_OUT   = os.path.join(SCRIPT_DIR, "trust_score_model.pkl")

# ── Feature columns used to build the training text ──────────────────────────
# These mirror buildSubmissionText() in matching.service.ts so the classifier
# evaluates the same combined text that the embedding model sees.
FEATURE_COLS = [
    "title",
    "summary",
    "problem_statement",
    "solution_description",
    "businessModel_revenueStreams",
]


def build_feature_text(row: pd.Series) -> str:
    """
    Combine multiple pitch fields into a single text string for TF-IDF.
    Mirrors buildSubmissionText() in apps/api/src/services/matching.service.ts.
    """
    parts = []
    for col in FEATURE_COLS:
        val = str(row.get(col, "")).strip()
        if val and val.lower() not in ("nan", "none", ""):
            parts.append(val)
    return " | ".join(parts)


def create_label(status: str) -> int | None:
    """
    Binary quality label from the status column.
      "approved" → 1 (High Quality)
      "rejected" → 0 (Low Quality)
      "pending"  → None (drop — ambiguous, not useful for training)
    """
    s = str(status).strip().lower()
    if s == "approved":
        return 1
    if s == "rejected":
        return 0
    return None  # pending — will be dropped


# ── Main ──────────────────────────────────────────────────────────────────────

def main(csv_path: str) -> None:
    # ── 1. Load data ──────────────────────────────────────────────────────────
    print(f"Loading data from: {csv_path}")
    df = pd.read_csv(csv_path)

    required_cols = {"title", "summary", "status"}
    missing = required_cols - set(df.columns)
    if missing:
        print(f"ERROR: CSV is missing required columns: {missing}")
        print(f"Available columns: {list(df.columns)}")
        sys.exit(1)

    print(f"Total rows loaded: {len(df)}")

    # ── 2. Drop rows with missing title or summary ────────────────────────────
    before = len(df)
    df = df.dropna(subset=["title", "summary"])
    df = df[df["title"].str.strip().str.len() > 0]
    df = df[df["summary"].str.strip().str.len() > 0]
    print(f"Rows after dropping empty title/summary: {len(df)} (dropped {before - len(df)})")

    # ── 3. Create labels from status column ───────────────────────────────────
    df["y"] = df["status"].apply(create_label)

    # Drop pending rows (y is None)
    before = len(df)
    df = df.dropna(subset=["y"])
    df["y"] = df["y"].astype(int)
    print(f"Rows after dropping 'pending' status: {len(df)} (dropped {before - len(df)})")

    label_counts = df["y"].value_counts()
    print(f"\nLabel distribution:")
    print(f"  Approved / High Quality (1): {label_counts.get(1, 0)}")
    print(f"  Rejected / Low Quality  (0): {label_counts.get(0, 0)}")

    # ── 4. Build feature text ─────────────────────────────────────────────────
    # Fill NaN in feature columns with empty string before combining
    for col in FEATURE_COLS:
        if col in df.columns:
            df[col] = df[col].fillna("").astype(str)

    df["feature_text"] = df.apply(build_feature_text, axis=1)

    # Drop rows where feature text is empty after combining
    df = df[df["feature_text"].str.strip().str.len() > 0]
    print(f"Rows with non-empty feature text: {len(df)}")

    X = df["feature_text"].tolist()
    y = df["y"].tolist()

    # ── 5. Train / test split ─────────────────────────────────────────────────
    X_train, X_test, y_train, y_test = train_test_split(
        X, y, test_size=0.2, random_state=42, stratify=y
    )
    print(f"\nTrain size: {len(X_train)}  |  Test size: {len(X_test)}")

    # ── 6. Build pipeline ─────────────────────────────────────────────────────
    # max_features increased to 5000 because the combined text is much richer
    # than a single one-line pitch — more vocabulary is meaningful here.
    pipeline = Pipeline([
        ("tfidf", TfidfVectorizer(
            stop_words="english",
            max_features=5000,
            ngram_range=(1, 2),
        )),
        ("clf", LogisticRegression(
            max_iter=1000,
            class_weight="balanced",
            random_state=42,
        )),
    ])

    # ── 7. Fit ────────────────────────────────────────────────────────────────
    print("\nTraining pipeline...")
    pipeline.fit(X_train, y_train)

    # ── 8. Evaluate ───────────────────────────────────────────────────────────
    y_pred = pipeline.predict(X_test)
    print("\nClassification Report (test set):")
    print(classification_report(
        y_test, y_pred,
        target_names=["Rejected / Low Quality (0)", "Approved / High Quality (1)"],
        zero_division=0,
    ))

    # ── 9. Save model ─────────────────────────────────────────────────────────
    joblib.dump(pipeline, MODEL_OUT)
    print(f"Model saved to: {MODEL_OUT}")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Train the SEPMS pitch trust/quality classifier."
    )
    parser.add_argument(
        "--csv",
        default=DEFAULT_CSV,
        help="Path to the startup pitches CSV file.",
    )
    args = parser.parse_args()
    main(args.csv)
