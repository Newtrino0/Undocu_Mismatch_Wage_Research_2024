# Known Issues Audit — ML Imputation Pipeline

**Purpose:** Separates *bugs* (things that are wrong and must be fixed regardless of methodology decisions) from *methodology choices* (tracked in `00_methods_decisions.md`). Each issue lists severity, whether it can affect anything in the current paper draft, and the fix owner/step.

**Severity key:** HIGH = can change reported results or invalidate a comparison; MED = affects robustness/validity of a supporting exhibit; LOW = hygiene, no result impact if leading files are used.

---

## B1. Partition overwrite invalidates the Full-vs-College comparison — HIGH

**File:** `(Step 3) Machine Learning Estimations/Leading_ML_Model.qmd`
**Where:** "Training and Test datasets" chunk vs. "GBM Library (College Training Sample)" chunk.
**Problem:** The first chunk correctly derives `train_college`/`test_college` from the master 70/30 split. The college-model chunk then *overwrites* both with a fresh, independent `createDataPartition` of `sipp08_2_college`. Rows of the new `test_college` can therefore appear inside `train_gbm` — so the Full-to-College evaluation partially tests the full model on its own training rows, mechanically inflating it relative to College-to-College.
**Draft exposure:** Any figure/claim built on the FF/FC/CC comparison (Figure 3 area; Section 4.1 text choosing the training sample).
**Fix:** Superseded by the donor-ladder design (Implementation Plan Step 3) using one shared master split. Do not regenerate the old comparison.

## B2. `gbm_high_recall_college` computed from the wrong variable — HIGH (if old file used)

**File:** `Leading_ML_Model.qmd`, imputation chunk (~line 693).
**Problem:** `gbm_high_recall_college = ifelse(college_undocu_q > threshold_75_num_college, 1, 0)` compares a quartile *label* ("Q1"–"Q4") to a numeric probability threshold; R's coercion makes the result meaningless. Should be `college_gbm_undocu_p >= threshold_75_num_college`.
**Draft exposure:** Only if any college-model high-recall results in the draft came from this file.
**Fix:** None needed if file is retired (Step 5); flagged so no one copies the line forward.

## B3. Boundary values silently assigned "Unknown" in quartile case_when — MED

**File:** `Leading_ML_Model.qmd`, imputation chunk.
**Problem:** Strict `<` / `>` on both sides of each quartile condition means observations exactly equal to a cutoff fall through to `"Unknown"`.
**Status:** FIXED in leading files via `cut()` with ±Inf breaks. Listed to confirm the old file is not used.

## B4. Quartile thresholds computed on positives only — MED

**File:** `Leading_ML_Model.qmd` ("Thersholds on undocu likely sample (BUG????)" — the in-code flag was correct).
**Problem:** `quartile_thresholds_gbm` was computed from `undocu_likely == 1` observations only, then applied to the full ACS distribution.
**Status:** FIXED in leading files (quartiles from the full target-like test sample). Confirm no draft exhibit still uses old thresholds.

## B5. `years_us` measured differently in donor vs. target — HIGH

**Files:** `(Step 1) .../Part C (Variable selection).do` (SIPP: binned `tmoveus` → representative years); `(Step 2) .../ACS Part C (create estimation samples).do` (ACS: near-continuous `yrsusa1`).
**Problem:** One of the two most important predictors has a different measurement structure across surveys; tree split points learned on SIPP coding transfer imperfectly to ACS.
**Draft exposure:** Pervasive but unquantified — affects every ML-imputed group.
**Fix:** Decision D5 / Implementation Step 1 (common bins).

## B6. `years_us_missing` semantics differ across surveys — MED

**Problem:** In SIPP the flag marks missing `tmoveus`; in the foreign-born ACS sample `yrsusa1` is essentially never missing, so the flag is ~always 0 in the target while the model may have learned splits on it in the donor.
**Fix:** Audit prevalence in both (Step 1); drop the feature if degenerate in ACS.

## B7. `employed` used as a predictor in the old file — LOW

**Problem:** `Leading_ML_Model.qmd` includes `employed` as a feature; the ACS target is all-employed, so the feature is degenerate at deployment.
**Status:** FIXED in leading files (donor restricted to employed; predictor dropped). Listed for provenance: draft exhibits must come from the leading files.

## B8. No survey weights in training or threshold calibration — MED

**Problem:** SIPP person weights unused throughout the ML step while ACS regressions are weighted; quartile cutoffs are sample, not population, quantiles.
**Fix:** Decision D7 (weight calibration; robustness check first).

## B9. H-1B occupation filter applied to ACS target but not SIPP donor — LOW/MED

**Problem:** The ACS possibly-undocumented target excludes likely-H-1B occupations (per Borjas & Cassidy-style filter, broadened); the SIPP donor and target-like calibration sample do not (paper footnote 7 explains the occupation-coding obstacle). Donor and target populations therefore differ slightly in composition, which can shift calibration.
**Fix:** Not fixable cleanly (coding discrepancy is real); add explicitly to limitations (Step 5). Optional robustness: recompute thresholds excluding SIPP respondents in approximable H-1B-like occupation groups, if feasible.

## B10. Exhibit provenance not recorded — MED (process risk)

**Problem:** Two generations of model files (old `Leading_ML_Model.qmd` vs. leading GBM/XGBoost files) write to overlapping outputs (`ACS_SIPP_gbm.csv`); it is not documented which script produced each draft figure/table. Both leading files export to the *same* CSV path, so whichever ran last silently wins.
**Fix:** Step 5 provenance table; consider distinct export filenames per model with an explicit "official" pointer.

---

## Summary table

| ID  | Severity | Affects current draft? | Resolution |
|-----|----------|------------------------|------------|
| B1  | HIGH     | Yes — FF/FC/CC comparison | Plan Step 3 (supersede) |
| B2  | HIGH     | Only if old file used  | Retire file (Step 5) |
| B3  | MED      | No (fixed in leading)  | Confirm retirement |
| B4  | MED      | Check exhibits         | Confirm retirement |
| B5  | HIGH     | Yes — all ML groups    | Plan Step 1 (D5) |
| B6  | MED      | Possibly               | Plan Step 1 audit |
| B7  | LOW      | No (fixed in leading)  | Provenance check |
| B8  | MED      | Thresholds             | D7 robustness |
| B9  | LOW/MED  | Limitations text       | Plan Step 5 |
| B10 | MED      | Process risk           | Plan Step 5 |
