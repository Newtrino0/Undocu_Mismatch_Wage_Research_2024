# Implementation Plan — ML Imputation Pipeline Revisions

**Rule:** No step begins until its governing decision(s) in `00_methods_decisions.md` are marked **agreed**, and no step begins before the one above it is complete (exceptions noted). Each step lists the files it touches, its validation output, and — critically — which results in the current paper draft (Nov 10, 2025 version) are at risk of changing.

**Provenance rule adopted with this plan:** every figure/table in the draft must be traceable to one generating script; `Leading_ML_Model.qmd` is superseded and must not be used to regenerate anything (see `02_known_issues.md`, B1–B4, B7).

---

## Step 0 — Freeze and baseline (no decisions required)

**What:** Tag the current repo state in git (e.g., `pre-ml-revision`) and export one frozen copy of the current `ACS_SIPP_gbm.csv` predictions and current headline regression estimates. This is the before-snapshot every later step is compared against.

**Files touched:** none (git tag + one archived copy of outputs in Google Drive `Data/ML Outputs/archive/`).

**Validation output:** a one-page "baseline numbers" memo (headline coefficients: vertical mismatch 7.5pp / 3.0 / 3.1; horizontal undermatch 7.6 / 5.6 / 6.8; wage penalties 21% / 7.7% / 10%; low-prob placebo values) so drift is measurable.

**Draft results at risk:** none — this step protects them.

---

## Step 1 — Harmonize `years_us` between SIPP and ACS (governed by D5)

**What:** Define a single common bin structure for years-in-US (based on SIPP `tmoveus` intervals); recode ACS `yrsusa1` into it; audit `years_us_missing` in both surveys and drop if degenerate in ACS.

**Files touched:** `(Step 1) SIPP .../ SIPP 2008 Wave 2 Part C (Variable selection).do` (recode section only), `(Step 2) ACS .../ ACS Part C (create estimation samples).do`. Both leading QMD files then re-run unchanged.

**Why first:** it changes the data every subsequent model sees; anything tuned before this is discarded work.

**Validation output:** side-by-side distribution table of binned `years_us` in SIPP donor vs. ACS target; `years_us_missing` prevalence in both.

**Draft results at risk:** all ML-derived group assignments shift somewhat → all GBM-based columns in Tables 4–6 and the degree-field/IPC figures. (Logical-edits columns unaffected.)

---

## Step 2 — Metric switch for tuning and evaluation (governed by D2)

**What:** XGBoost `eval_metric` → `aucpr`; grid-row selection by target-like PR performance; add PR-AUC, precision@recall=0.75, Q4 precision (+ lift, base rate) computed on the target-like college holdout to both leading files' validation blocks. ROC-AUC demoted to supplementary.

**Files touched:** `leading_xgboost_model.qmd` (tuning + validation blocks), `leading_gbm_model.qmd` (validation block only).

**Validation output:** a small metrics table (per model: PR-AUC, precision@0.75 recall, Q4 precision, ROC-AUC) on the target-like sample; PR curve figure for the college validation sample.

**Draft results at risk:** if the selected hyperparameters change, group assignments move → same exposure as Step 1. Figure 1's model-comparison exhibit gains a college-sample counterpart.

---

## Step 3 — Donor-sample ladder with a single shared master split (governed by D1; depends on Steps 1–2)

**What:** One master 70/30 partition of the full donor pool. Train four models on nested donor samples drawn from the *same* master training rows: (a) full (employed 18–55), (b) HS+, (c) some college+, (d) college-only. Evaluate all four on the *identical* target-like college test set with Step-2 metrics. This supersedes — and fixes — the old Full-to-Full / Full-to-College / College-to-College comparison (bug B1).

**Files touched:** new file `(Step 3) .../donor_ladder_robustness.qmd` (self-contained; does not modify the leading files).

**Validation output:** the ladder table (4 rows × Step-2 metrics) + overlaid PR curves. **Decision gate:** if full-donor wins or ties (expected, per Cengiz et al.'s subgroup finding), D1 is confirmed and the table goes to the appendix. If a narrower donor wins meaningfully, return to D1 before proceeding.

**Draft results at risk:** none directly (robustness exhibit), but its outcome gates everything after.

---

## Step 4 — Cross-fitted thresholds + bootstrap stability (governed by D3, D4, D7; depends on Step 3's gate)

**What:** 5-fold cross-fitting over the full donor sample → out-of-fold probabilities for every SIPP observation → quartile breaks and 75%-recall threshold estimated on the *entire* target-like college sample (weighted per D7 if agreed); final model retrained on all of SIPP to score ACS; bootstrap CIs for the threshold and precision@0.75; ACS group-assignment stability across bootstrap draws.

**Files touched:** `leading_gbm_model.qmd` and/or `leading_xgboost_model.qmd` (split/threshold sections restructured); export format of `ACS_SIPP_gbm.csv` unchanged so `ML Part B (Reintroduce Results to ACS).do` and Step 4 Stata files need no edits.

**Validation output:** threshold point estimates with bootstrap CIs; share of ACS observations whose group assignment is stable across ≥90% of bootstrap draws; comparison of new vs. baseline (Step 0) group sizes.

**Draft results at risk:** the largest single change — all GBM-based estimates re-run once, after which numbers in Tables 4–6, Figures 5–6, and the abstract's headline percentages are updated together in one pass.

---

## Step 5 — Cleanup, provenance, and paper-stage items (governed by D3, D6; can overlap Step 4)

**What:**
- Mark `Leading_ML_Model.qmd` superseded (header banner + rename to `zz_superseded_Leading_ML_Model.qmd`); confirm no draft exhibit depends on it.
- Regenerate every ML figure/table from the leading files; record script→exhibit mapping in a `planning/exhibit_provenance.md` table.
- Methods-section text: D3's cross-survey threshold paragraph, D5's harmonization sentence, D6's imbalance sentence, D7's weighting note, H-1B asymmetry (issue B9) added to limitations.

**Files touched:** renames/comments only + paper text; no logic changes.

**Validation output:** exhibit-provenance table complete; grep of repo confirms no active script reads superseded outputs.

**Draft results at risk:** none beyond those already moved in Steps 1–4.

---

## Sequencing summary

```
Step 0 (freeze)
  └─ Step 1 (harmonize years_us)      [D5]
       └─ Step 2 (metrics)            [D2]
            └─ Step 3 (donor ladder)  [D1]  ← decision gate
                 └─ Step 4 (cross-fit thresholds) [D3, D4, D7]
                      └─ Step 5 (cleanup + paper text) [D3, D6]
```

**Estimated effort:** Steps 0–2: ~1 day combined. Step 3: ~1 day. Step 4: 2–3 days incl. re-running downstream Stata. Step 5: ~1 day, mostly writing.
