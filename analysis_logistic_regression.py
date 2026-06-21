#!/usr/bin/env python3
"""Logistic regression fallback for Analysis 2 (BQML unavailable — 403)."""

import json
import math
import numpy as np
from sklearn.linear_model import LogisticRegression

def load_jsonl(path):
    with open(path) as f:
        return [json.loads(l) for l in f if l.strip()]

features = load_jsonl("logreg_features.jsonl")
behaviors = load_jsonl("logreg_behaviors.jsonl")
beh_lookup = {r["user_id"]: r for r in behaviors}

feature_names = ["active_days_14d", "acus_week1", "has_merge",
                 "has_mcp_tool", "has_playbook", "has_ci",
                 "completed_onboarding", "used_review"]

rows = []
for r in features:
    uid = r["user_id"]
    beh = beh_lookup.get(uid, {})
    rows.append({
        "converted": r["converted"],
        "active_days_14d": r["active_days_14d"],
        "acus_week1": r["acus_week1"],
        "has_merge": r["has_merge"],
        "has_mcp_tool": beh.get("has_mcp_tool", 0),
        "has_playbook": beh.get("has_playbook", 0),
        "has_ci": beh.get("has_ci", 0),
        "completed_onboarding": beh.get("completed_onboarding", 0),
        "used_review": beh.get("used_review", 0),
    })

X = np.array([[r[f] for f in feature_names] for r in rows], dtype=float)
y = np.array([r["converted"] for r in rows], dtype=float)

model = LogisticRegression(max_iter=1000, solver="lbfgs")
model.fit(X, y)

coefs = model.coef_[0]
probs = model.predict_proba(X)[:, 1]
XtWX = X.T @ (X * (probs * (1 - probs))[:, np.newaxis])
cov = np.linalg.inv(XtWX)
se = np.sqrt(np.diag(cov))

print(f"{'Feature':<25} {'Coef':>8} {'OR':>8} {'p-value':>10} {'Sig':>5}")
print("-" * 60)
for i, f in enumerate(feature_names):
    coef = coefs[i]
    odds_ratio = math.exp(coef)
    z = coef / se[i]
    from scipy.stats import norm
    p = 2 * norm.sf(abs(z))
    sig = "***" if p <= 0.001 else "**" if p <= 0.01 else "*" if p <= 0.05 else "ns"
    print(f"{f:<25} {coef:>8.4f} {odds_ratio:>8.4f} {p:>10.6f} {sig:>5}")
