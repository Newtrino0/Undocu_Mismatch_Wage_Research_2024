# Methods Decision Log — ML Imputation of Undocumented Status

**Project:** Education-Occupation Mismatch for Undocumented College Graduates (Sovero & Arce Acosta)
**Purpose:** Record each open methodology decision for the ML imputation step, with rationale and citations, *before* any code changes. Entries move `proposed → agreed → implemented`. Nothing in the pipeline changes until the corresponding entry is marked **agreed** by both authors.
**How to use:** Edit inline; add your initials and date in the Status line. Text in the "Paper language" fields is drafted so it can be adapted into the methods section / referee responses.

---

## D1. Donor (training) sample: full possibly-undocumented pool vs. college-only

**Question.** Should the GBM/XGBoost model be trained on the full SIPP possibly-undocumented donor pool (employed, ages 18–55, all education levels) or restricted to college graduates to match the ACS target sample?

**Current state.** Leading files (`leading_gbm_model.qmd`, `leading_xgboost_model.qmd`) train on the full donor pool (employed, 18–55) and calibrate thresholds on the college-like test subsample. The older `Leading_ML_Model.qmd` contains a Full-to-Full / Full-to-College / College-to-College comparison, but that comparison is invalidated by a partitioning bug (see Known Issues B1).

**Proposed decision.** Train on the full donor pool. Justify with (a) direct precedent and (b) an in-paper robustness ladder.

**Rationale.**
- Cengiz, Dube, Lindner & Zentler-Munro (JOLE 2022) train their boosted-trees model on the full CPS working population and apply predictions to subgroups; they report that estimating separate prediction models per subgroup produced *negligible changes*. This is the direct precedent for training broad and deploying to a subpopulation.
- Statistical power: the SIPP college-graduate possibly-undocumented subsample is small; a depth-6, ~3,500-tree boosted model trained on it alone is at high risk of overfitting. The full model can still learn education-specific structure because `yrsed` is a predictor.
- The claim becomes testable, not assumed, via the donor ladder (Implementation Plan step 3): full → HS+ → some-college+ → college-only, all evaluated on the identical target-like college holdout.

**Citations.** Cengiz et al. 2022 (JOLE; NBER WP 28399), incl. their subgroup-model robustness finding.

**Paper language (sketch).** "Following Cengiz et al. (2022), we train the model on the full donor sample rather than on college graduates alone; Cengiz et al. report that subgroup-specific prediction models yield negligible differences, and we confirm this in our setting (Appendix Table X, which compares donor samples of varying breadth evaluated on the college-graduate validation sample)."

**Paper impact if adopted.** No headline results change by fiat; the donor-ladder appendix table is new. If the ladder unexpectedly favors a narrower donor sample, revisit this entry before proceeding.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D2. Model selection & evaluation metrics

**Question.** What metric should be used to tune hyperparameters and select among models, given that the deployment target is college graduates and the analysis groups are defined at specific operating points (top quartile; 75% recall)?

**Current state.** The XGBoost file tunes on cross-validated ROC-AUC over the full donor training sample. The paper's framing (Sections 1, 4.1) is precision-recall, following Cengiz et al. The new leading files report ROC-AUC and per-quartile precision/lift but no PR curves.

**Proposed decision.**
- Primary metric: PR-AUC (average precision) evaluated on the *target-like* college holdout (or cross-fitted college sample once D4 is adopted).
- Reported operating-point metrics: precision at recall = 0.75 (the `gbm_high_recall` group's operating point) and precision in the top quartile (the `gbm_high_prob` group), plus lift over base rate.
- ROC-AUC retained as a supplementary statistic only.
- Hyperparameter tuning: switch XGBoost `eval_metric` to PR-AUC (`aucpr`); select the winning grid row by target-like PR performance.

**Rationale.**
- Cengiz et al. select among algorithms with precision-recall curves and define their groups by recall targets (75% high-recall; top-of-distribution high-probability). Our groups are constructed the same way, so model selection should optimize the same frontier.
- Under class imbalance, ROC-AUC is dominated by ranking of the abundant negative class and can be misleadingly high; PR analysis is the standard remedy (Saito & Rehmsmeier 2015, PLOS ONE; Davis & Goadrich 2006, ICML).
- Evaluating on the target-like sample aligns the selection criterion with the deployment population (cross-survey transfer logic per Van Hook et al. 2015; Ruhnke et al. 2022).

**Citations.** Cengiz et al. 2022; Saito & Rehmsmeier 2015; Davis & Goadrich 2006; Van Hook et al. 2015 (Demography); Ruhnke, Wilson & Van Hook 2022 (SSM–Population Health).

**Paper impact if adopted.** Figure 1-style PR curves become the model-selection exhibit for the *college* validation sample; reported AUCs become supplementary. Selected hyperparameters may change, which can move imputed group assignments and therefore downstream estimates.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D3. Threshold and quartile calibration on the target-like SIPP test sample

**Question.** Where should the probability quartile breaks and the 75%-recall threshold be estimated?

**Current state.** Already implemented in the leading files: thresholds are defined on the target-like SIPP test subsample (college, employed, ages 22–55). The old file's full-sample and positives-only threshold variants are superseded (Known Issues B3, B4).

**Proposed decision.** Ratify the current approach and document it explicitly in the methods section as a deliberate cross-survey extension.

**Rationale.** Cengiz et al. define operating points on their target population directly; because our donor and target are different surveys and our target is a subpopulation, the closest analogue is the donor observations that match the target definition. This composes Cengiz et al.'s operating-point logic with the donor–target alignment principles of the cross-survey legal-status imputation literature (Van Hook et al. 2015; Ruhnke et al. 2022).

**Honest framing note.** No single prior paper does exactly this; it should be written as a (modest) methodological contribution, not attributed to a citation. The stability evidence from D4 (bootstrap CIs; group-assignment stability) is what makes this paragraph defensible.

**Citations.** Cengiz et al. 2022; Van Hook et al. 2015; Ruhnke et al. 2022.

**Paper impact if adopted.** Methods text only (plus the D4 stability exhibit); pipeline already conforms.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D4. Cross-fitted out-of-fold predictions for threshold estimation + bootstrap stability

**Question.** How do we address the small size of the target-like holdout (currently ~30% of an already-small college subsample), which makes the quartile breaks and especially the 75%-recall cutoff (a single order statistic of the positives) noisy? The observed sensitivity of ACS group assignment to ~0.02 movements in the cutoff (the "6,000-observation trap" diagnostic) is a symptom.

**Proposed decision.**
- Replace the single 70/30 split with K-fold cross-fitting (K = 5) over the full SIPP donor sample: every observation receives an out-of-fold (honest) predicted probability.
- Estimate quartile breaks, the 75%-recall threshold, and PR curves on the *entire* target-like college sample using out-of-fold predictions (~3.3× current calibration data; no leakage).
- Retrain on the full donor sample for the final model used to score ACS.
- Bootstrap the target-like sample to report CIs for precision-at-recall-0.75 and for the threshold; report stability of ACS group assignments across bootstrap draws.

**Rationale.** K-fold out-of-sample prediction is textbook (Hastie, Tibshirani & Friedman, ESL). Cross-fitting is the accepted standard in economics for honest ML predictions feeding downstream estimation (Chernozhukov et al. 2018, Econometrics Journal — double/debiased ML). Bootstrap CIs are standard (Efron & Tibshirani 1994).

**Citations.** Chernozhukov et al. 2018; Hastie et al. (ESL, 2nd ed.); Efron & Tibshirani 1994.

**Paper impact if adopted.** Thresholds (and thus `gbm_high_prob` / `gbm_high_recall` / `gbm_low_prob` membership in ACS) will shift somewhat; all downstream regression estimates re-run. Adds a stability appendix exhibit. This is the largest planned change; it happens *after* D1–D2 are settled so it is done once.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D5. Donor–target harmonization of `years_us` (and `years_us_missing`)

**Question.** SIPP `years_us` is derived from the binned `tmoveus` recode (mapped to representative years), while ACS `yrsusa1` is (near-)continuous. Years-in-US is one of the two most important predictors. Tree split points learned on the SIPP coding do not transfer cleanly to the ACS coding. Additionally, `years_us_missing` has different semantics in the two surveys.

**Proposed decision.** Coarsen both surveys' `years_us` to a common interval structure (map ACS years into the SIPP `tmoveus` bins) before training and scoring. Audit `years_us_missing` prevalence in both samples; drop the flag if it is degenerate (~always 0) in ACS.

**Rationale.** Variable harmonization between donor and target surveys is stated, standard practice in the cross-survey legal-status imputation literature (Ruhnke et al. 2022 harmonize SIPP→NHIS predictors; Van Hook et al. 2015 stress donor–target comparability). This is data construction, not new methodology.

**Citations.** Ruhnke et al. 2022; Van Hook et al. 2015.

**Paper impact if adopted.** Predictions in ACS change (likely modestly but pervasively); one sentence added to data section. Must be done before any retraining/tuning so results are not produced twice.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D6. Class imbalance: no upsampling for the boosted models

**Question.** Should the truly-undocumented class be upsampled for GBM/XGBoost training (as was done for the random forest)?

**Proposed decision.** No. Handle imbalance by choosing operating points on the PR curve (as in D2/D3), not by resampling.

**Rationale.** Bernoulli-loss boosting handles moderate imbalance; upsampling distorts predicted probabilities, and this design uses the probability *distribution* (quantile groups) directly, so calibration-adjacent distortion is costly. Cengiz et al. likewise select operating points rather than resampling. Note for internal consistency: the upsampled RF's probabilities are not directly comparable to the GBM's — relevant when presenting cross-model comparisons.

**Citations.** Cengiz et al. 2022 (operating-point approach); Saito & Rehmsmeier 2015 (PR framework under imbalance).

**Paper impact.** None (ratifies current practice); one clarifying sentence in methods.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## D7. Survey weights in threshold calibration (open question)

**Question.** Neither training nor threshold calibration currently uses SIPP person weights, while downstream ACS regressions use ACS weights. Should the quartile/threshold calibration be weighted so cutoffs reflect population quantiles?

**Proposed decision (weak).** Weight the *calibration* step (quartile breaks, recall threshold) by SIPP person weights; leave model training unweighted (standard in the ML-prediction literature; Cengiz et al. train unweighted but weight downstream regressions). Treat as a robustness check first: if weighted and unweighted cutoffs are similar, note it and move on.

**Citations.** Cengiz et al. 2022 (weighting practice in downstream estimation).

**Paper impact.** Possibly none (if robustness check shows insensitivity); otherwise thresholds shift.

**Status:** PROPOSED / OPEN — needs discussion.

---

## D8. Feature admissibility: exclude the worker's own labor-market outcomes from predictors

**Question.** Should log wage (or other own labor-market outcomes) be included as a predictor of undocumented status? In a previous attempt, adding log wage caused the model to concentrate nearly all importance on that single feature ("collapse").

**Current state.** The leading feature set excludes wage, occupation, and mismatch variables. The collapse was observed in an earlier experimental run; that specification is not in the pipeline.

**Proposed decision.** Adopt an explicit admissibility rule: predictors may not include the worker's *own* labor-market outcomes — wage, earnings, occupation, or mismatch status — because these are the dependent variables (or their direct determinants) in the downstream regressions. Income-linked *household/context* features already in the set (`poverty`, `medicaid`) remain admissible, with a robustness run excluding them.

**Rationale.**
- *Mechanics of the collapse.* Gradient-boosted trees split greedily; a continuous feature with many split points that is strongly correlated with the label absorbs most gain-based importance. The collapse is a symptom, not the disease.
- *The disease is target leakage / post-treatment bias.* Log wage is the dependent variable of the wage regressions. Classifying status partly from wages selects low-wage workers into the "undocumented" group by construction, making the estimated wage penalty (and, since wages sit downstream of mismatch, the mismatch estimates) partly circular. This is the classic "bad control" problem (Angrist & Pischke; Montgomery, Nyhan & Torres 2018) and, in ML terms, target leakage (Kaufman et al. 2012).
- *Direct precedent.* Cengiz et al. (2022) define their training label from wages (below 125% of the minimum wage) yet deliberately exclude wage from the predictor set, using demographics only — precisely because their downstream outcomes are labor-market outcomes. Our rule mirrors theirs.
- *Anticipated referee counterargument (congeniality).* Classical multiple-imputation theory (Meng 1994) recommends *including* the analysis outcome in imputation models, since excluding it attenuates associations toward zero. Response: (a) our design is hard group classification following Cengiz et al., not Rubin-style MI with proper draws and combining rules — with a single hard assignment, including the outcome manufactures the association through selection rather than preserving it; (b) the attenuation from excluding wage biases estimates *toward zero*, so reported penalties are conservative lower bounds. This framing goes in the paper.
- *Permitted uses of wage information.* Diagnostics and validation only (e.g., wage distributions by predicted-probability quartile as evidence the classifier separates meaningful groups); optionally, a clearly-labeled wage-inclusive model in an appendix as a bounding/sensitivity exercise that never feeds main results.

**Citations.** Cengiz et al. 2022 (wage-free predictor set); Angrist & Pischke, *Mostly Harmless Econometrics* (bad controls); Montgomery, Nyhan & Torres 2018 (*AJPS*, post-treatment bias); Kaufman, Rosset & Perlich 2012 (*ACM TKDD*, leakage in data mining); Meng 1994 (*Statistical Science*, congeniality — addressed, not followed).

**Paper language (sketch).** "Following Cengiz et al. (2022), our predictor set deliberately excludes the worker's own labor-market outcomes. Because wages and occupational placement are the dependent variables in our analysis, a classifier that conditions on them would mechanically select low-wage, mismatched workers into the imputed undocumented group, rendering the estimated penalties partly tautological. Excluding these variables, if anything, attenuates our estimates toward zero, so the reported penalties are conservative."

**Paper impact if adopted.** Ratifies the current feature set (no pipeline change); adds a methods paragraph and, optionally, a no-income-features robustness run (dropping `poverty`/`medicaid`) and a wage-by-quartile validation exhibit.

**Status:** PROPOSED — awaiting VS / MAA sign-off.

---

## Reference list for this log

- Cengiz, D., Dube, A., Lindner, A., & Zentler-Munro, D. (2022). Seeing Beyond the Trees: Using Machine Learning to Estimate the Impact of Minimum Wages on Labor Market Outcomes. *Journal of Labor Economics*, 40(S1). (NBER WP 28399.)
- Ruhnke, S. A., Wilson, F. A., & Van Hook, J. (2022). Using machine learning to impute legal status of immigrants in the National Health Interview Survey. *SSM – Population Health*, 19.
- Van Hook, J., Bachmeier, J. D., Coffman, D. L., & Harel, O. (2015). Can We Spin Straw Into Gold? An Evaluation of Immigrant Legal Status Imputation Approaches. *Demography*, 52(1).
- Saito, T., & Rehmsmeier, M. (2015). The Precision-Recall Plot Is More Informative than the ROC Plot When Evaluating Binary Classifiers on Imbalanced Datasets. *PLOS ONE*, 10(3).
- Davis, J., & Goadrich, M. (2006). The Relationship Between Precision-Recall and ROC Curves. *ICML 2006*.
- Chernozhukov, V., Chetverikov, D., Demirer, M., Duflo, E., Hansen, C., Newey, W., & Robins, J. (2018). Double/debiased machine learning for treatment and structural parameters. *Econometrics Journal*, 21(1).
- Hastie, T., Tibshirani, R., & Friedman, J. (2009). *The Elements of Statistical Learning* (2nd ed.). Springer.
- Efron, B., & Tibshirani, R. (1994). *An Introduction to the Bootstrap*. Chapman & Hall.
- Angrist, J. D., & Pischke, J.-S. (2009). *Mostly Harmless Econometrics: An Empiricist's Companion*. Princeton University Press. (Ch. 3.2.3, bad controls.)
- Montgomery, J. M., Nyhan, B., & Torres, M. (2018). How Conditioning on Posttreatment Variables Can Ruin Your Experiment and What to Do about It. *American Journal of Political Science*, 62(3).
- Kaufman, S., Rosset, S., & Perlich, C. (2012). Leakage in Data Mining: Formulation, Detection, and Avoidance. *ACM Transactions on Knowledge Discovery from Data*, 6(4).
- Meng, X.-L. (1994). Multiple-Imputation Inferences with Uncongenial Sources of Input. *Statistical Science*, 9(4).
