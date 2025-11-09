clear matrix
clear mata
clear
set more off
set scheme s1color

set maxvar 30000
set matsize 11000
set segmentsize 2g
set memory 8g
mata: mata set matafavor speed


global drive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu" //update this line with your folder 

cd "$drive/Shared drives/Undocu Research"
use "Data/EO_final.dta", clear


global covars hisp asian black male gov_worker bpl_foreign immig_by_ten nonfluent yrsed  metropolitan medicaid 


****************************************************************************************	
******Individual Mismatch regressions with IPC Interactions *************************
****************************************************************************************


clear matrix
set more off
eststo clear

*Vertical
reghdfe vmismatched hundermatched hovermatched undocu undocu_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_vmismatch


esttab logical_vmismatch gbmhigh_vmismatch gbmrecall_vmismatch gbmlow_vmismatch using "Output/Appendix/vmismatch_regressions_ipc.tex", ///
    replace label booktabs drop($covars _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_inclusive "Undocumented × Inclusive" ///
           gbm_high_prob_inclusive "Undocumented × Inclusive" ///
           gbm_high_recall_inclusive "Undocumented × Inclusive" ///
           gbm_low_prob_inclusive "Undocumented × Inclusive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Vmismatch (IPC Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")


*Horizontal
reghdfe hundermatched vmismatched undocu undocu_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_hunder

reghdfe hundermatched vmismatched gbm_high_prob gbm_high_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_hunder

reghdfe hundermatched vmismatched gbm_high_recall gbm_high_recall_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_hunder

reghdfe hundermatched vmismatched gbm_low_prob gbm_low_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmrecall_hunder gbmlow_hunder ///
    using "Output/Appendix/hunder_regressions_ipc.tex", replace ///
    label booktabs drop($covars _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_inclusive "Undocumented × Inclusive" ///
           gbm_high_prob_inclusive "Undocumented × Inclusive" ///
           gbm_high_recall_inclusive "Undocumented × Inclusive" ///
           gbm_low_prob_inclusive "Undocumented × Inclusive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Horizontal Undermatch (IPC Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")


*Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu undocu_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmrecall_wage gbmlow_wage ///
    using "Output/Appendix/wage_regressions_ipc.tex", replace ///
    label booktabs drop($covars  _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_inclusive "Undocumented × Inclusive" ///
           gbm_high_prob_inclusive "Undocumented × Inclusive" ///
           gbm_high_recall_inclusive "Undocumented × Inclusive" ///
           gbm_low_prob_inclusive "Undocumented × Inclusive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Log Wages (IPC Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")



coefplot ///
    (logical_vmismatch,  label("Logical Edits")) ///
    (gbmhigh_vmismatch,  label("High Prob")) ///
    (gbmrecall_vmismatch,label("High Recall")) ///
    (gbmlow_vmismatch,   label("Low Prob")),      bylabel("Vertical Mismatch") ///
||  (logical_hunder,     label("Logical Edits")) ///
    (gbmhigh_hunder,     label("High Prob")) ///
    (gbmrecall_hunder,   label("High Recall")) ///
    (gbmlow_hunder,      label("Low Prob")),     bylabel("Horizontal Undermatch") ///
||  (logical_wage,       label("Logical Edits")) ///
    (gbmhigh_wage,       label("High Prob")) ///
    (gbmrecall_wage,     label("High Recall")) ///
    (gbmlow_wage,        label("Low Prob")),     bylabel("Log Wages") ///
    rename(undocu = "Undocumented" ///
           gbm_high_prob = "Undocumented" ///
           gbm_high_recall = "Undocumented" ///
           gbm_low_prob = "Undocumented" ///
           undocu_inclusive = "Undocumented × Inclusive" ///
           gbm_high_prob_inclusive = "Undocumented × Inclusive" ///
           gbm_high_recall_inclusive = "Undocumented × Inclusive" ///
           gbm_low_prob_inclusive = "Undocumented × Inclusive") ///
    order("Undocumented" "Undocumented × Inclusive") ///
    drop($covars vmismatched hundermatched hovermatched _cons) ///
    xline(0, lcolor(gs10)) ///
    byopts(cols(2) xrescale) ///
    scheme(s1color)
graph export "Output/Figures/ipc_coeff.png", replace



****************************************************************************************	
******Individual Mismatch regressions with Individual Policy Interactions *************************
****************************************************************************************
clear matrix
set more off
eststo clear

*Vertical
reghdfe vmismatched hundermatched hovermatched undocu undocu_everify undocu_license undocu_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_everify gbm_high_recall_license gbm_high_recall_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_vmismatch

esttab logical_vmismatch gbmhigh_vmismatch gbmrecall_vmismatch gbmlow_vmismatch ///
    using "Output/Appendix/vmismatch_regressions_policies.tex", replace ///
    label booktabs drop($covars  _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_everify "Undocumented × Inclusive Everify" ///
           gbm_high_prob_everify "Undocumented × Inclusive Everify" ///
           gbm_high_recall_everify "Undocumented × Inclusive Everify" ///
           gbm_low_prob_everify "Undocumented × Inclusive Everify" ///
           undocu_license "Undocumented × Inclusive OCC" ///
           gbm_high_prob_license "Undocumented × Inclusive OCC" ///
           gbm_high_recall_license "Undocumented × Inclusive OCC" ///
           gbm_low_prob_license "Undocumented × Inclusive OCC" ///
           undocu_drive "Undocumented × Inclusive Drive" ///
           gbm_high_prob_drive "Undocumented × Inclusive Drive" ///
           gbm_high_recall_drive "Undocumented × Inclusive Drive" ///
           gbm_low_prob_drive "Undocumented × Inclusive Drive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Vmismatch (Policy Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")


*Horizontal
reghdfe hundermatched vmismatched undocu undocu_everify undocu_license undocu_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_hunder

reghdfe hundermatched vmismatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_hunder

reghdfe hundermatched vmismatched gbm_high_recall gbm_high_recall_everify gbm_high_recall_license gbm_high_recall_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_hunder

reghdfe hundermatched vmismatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmrecall_hunder gbmlow_hunder ///
    using "Output/Appendix/hunder_regressions_policies.tex", replace ///
    label booktabs drop($covars  _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_everify "Undocumented × Inclusive Everify" ///
           gbm_high_prob_everify "Undocumented × Inclusive Everify" ///
           gbm_high_recall_everify "Undocumented × Inclusive Everify" ///
           gbm_low_prob_everify "Undocumented × Inclusive Everify" ///
           undocu_license "Undocumented × Inclusive OCC" ///
           gbm_high_prob_license "Undocumented × Inclusive OCC" ///
           gbm_high_recall_license "Undocumented × Inclusive OCC" ///
           gbm_low_prob_license "Undocumented × Inclusive OCC" ///
           undocu_drive "Undocumented × Inclusive Drive" ///
           gbm_high_prob_drive "Undocumented × Inclusive Drive" ///
           gbm_high_recall_drive "Undocumented × Inclusive Drive" ///
           gbm_low_prob_drive "Undocumented × Inclusive Drive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Horizontal Undermatch (Policy Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")


*Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu undocu_everify undocu_license undocu_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_everify gbm_high_recall_license gbm_high_recall_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmrecall_wage gbmlow_wage ///
    using "Output/Appendix/wage_regressions_policies.tex", replace ///
    label booktabs drop($covars  _cons) ///
    rename(undocu "Undocumented" ///
           gbm_high_prob "Undocumented" ///
           gbm_high_recall "Undocumented" ///
           gbm_low_prob "Undocumented" ///
           undocu_everify "Undocumented × Inclusive Everify" ///
           gbm_high_prob_everify "Undocumented × Inclusive Everify" ///
           gbm_high_recall_everify "Undocumented × Inclusive Everify" ///
           gbm_low_prob_everify "Undocumented × Inclusive Everify" ///
           undocu_license "Undocumented × Inclusive OCC" ///
           gbm_high_prob_license "Undocumented × Inclusive OCC" ///
           gbm_high_recall_license "Undocumented × Inclusive OCC" ///
           gbm_low_prob_license "Undocumented × Inclusive OCC" ///
           undocu_drive "Undocumented × Inclusive Drive" ///
           gbm_high_prob_drive "Undocumented × Inclusive Drive" ///
           gbm_high_recall_drive "Undocumented × Inclusive Drive" ///
           gbm_low_prob_drive "Undocumented × Inclusive Drive") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Log Wages (Policy Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01) ///
    note("Additional controls include:") ///
    addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, statefip##year age," ///
         " government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
         " STEM degree indicators, years of schooling, and state×year interaction fixed effects." ///
         " Robust standard errors are all clustered by state.")



coefplot ///
    (logical_vmismatch,  label("Logical Edits")) ///
    (gbmhigh_vmismatch,  label("High Prob")) ///
    (gbmrecall_vmismatch,label("High Recall")) ///
    (gbmlow_vmismatch,   label("Low Prob")),      bylabel("Vertical Mismatch") ///
||  (logical_hunder,     label("Logical Edits")) ///
    (gbmhigh_hunder,     label("High Prob")) ///
    (gbmrecall_hunder,   label("High Recall")) ///
    (gbmlow_hunder,      label("Low Prob")),     bylabel("Horizontal Undermatch") ///
||  (logical_wage,       label("Logical Edits")) ///
    (gbmhigh_wage,       label("High Prob")) ///
    (gbmrecall_wage,     label("High Recall")) ///
    (gbmlow_wage,        label("Low Prob")),     bylabel("Log Wages") ///
    rename(undocu = "Undocumented" ///
           gbm_high_prob = "Undocumented" ///
           gbm_high_recall = "Undocumented" ///
           gbm_low_prob = "Undocumented" ///
           undocu_everify = "Undocumented × Inclusive E-Verify" ///
           gbm_high_prob_everify = "Undocumented × Inclusive E-Verify" ///
           gbm_high_recall_everify = "Undocumented × Inclusive E-Verify" ///
           gbm_low_prob_everify = "Undocumented × Inclusive E-Verify" ///
           undocu_license = "Undocumented × Inclusive OCC" ///
           gbm_high_prob_license = "Undocumented × Inclusive OCC" ///
           gbm_high_recall_license = "Undocumented × Inclusive OCC" ///
           gbm_low_prob_license = "Undocumented × Inclusive OCC" ///
           undocu_drive = "Undocumented × Inclusive Drive" ///
           gbm_high_prob_drive = "Undocumented × Inclusive Drive" ///
           gbm_high_recall_drive = "Undocumented × Inclusive Drive" ///
           gbm_low_prob_drive = "Undocumented × Inclusive Drive") ///
    order("Undocumented" ///
          "Undocumented × Inclusive E-Verify" ///
          "Undocumented × Inclusive OCC" ///
          "Undocumented × Inclusive Drive") ///
    drop($covars vmismatched hundermatched hovermatched _cons) ///
    xline(0, lcolor(gs10)) ///
    byopts(cols(2) xrescale) ///
    scheme(s1color)
graph export "Output/Figures/policy_coeff.png", replace




****************************************************************************************	
******Individual Mismatch regressions with Degree Interactions *************************
****************************************************************************************
clear matrix
set more off
eststo clear

* Vmismatch
reghdfe vmismatched hundermatched hovermatched undocu undocu_deg1 undocu_deg2 undocu_deg3 undocu_deg4 $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo logical_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_deg1 gbm_high_prob_deg2 gbm_high_prob_deg3 gbm_high_prob_deg4 $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_deg1 gbm_high_recall_deg2 gbm_high_recall_deg3 gbm_high_recall_deg4  $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmrecall_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_deg1 gbm_low_prob_deg2 gbm_low_prob_deg3 gbm_low_prob_deg4 $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
estadd ysumm
eststo gbmlow_vmismatch

esttab logical_vmismatch gbmhigh_vmismatch gbmrecall_vmismatch gbmlow_vmismatch ///
    using "Output/Appendix/vmismatch_regressions_degree.tex", replace ///
    label booktabs drop($covars _cons ) ///
    rename( ///
        undocu                 "Undocumented" ///
        gbm_high_prob          "Undocumented" ///
        gbm_high_recall        "Undocumented" ///
        gbm_low_prob           "Undocumented" ///
        undocu_deg1            "Undocumented × STEM" ///
        gbm_high_prob_deg1     "Undocumented × STEM" ///
        gbm_high_recall_deg1   "Undocumented × STEM" ///
        gbm_low_prob_deg1      "Undocumented × STEM" ///
        undocu_deg2            "Undocumented × STEM Related" ///
        gbm_high_prob_deg2     "Undocumented × STEM Related" ///
        gbm_high_recall_deg2   "Undocumented × STEM Related" ///
        gbm_low_prob_deg2      "Undocumented × STEM Related" ///
        undocu_deg3            "Undocumented × Business" ///
        gbm_high_prob_deg3     "Undocumented × Business" ///
        gbm_high_recall_deg3   "Undocumented × Business" ///
        gbm_low_prob_deg3      "Undocumented × Business" ///
        undocu_deg4            "Undocumented × Education" ///
        gbm_high_prob_deg4     "Undocumented × Education" ///
        gbm_high_recall_deg4   "Undocumented × Education" ///
        gbm_low_prob_deg4      "Undocumented × Education" ///
    ) ///
    order("Undocumented" "Undocumented × STEM" "Undocumented × STEM Related" "Undocumented × Business" "Undocumented × Education") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Vmismatch (Degree Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)


*Horizontal Undermatch
reghdfe hundermatched vmismatched undocu undocu_deg1 undocu_deg2 undocu_deg3 undocu_deg4 ///
        $covars [pweight=perwt], absorb(statefip##year age ) vce(cluster statefip )
estadd ysumm
eststo logical_hunder

reghdfe hundermatched vmismatched gbm_high_prob gbm_high_prob_deg1 gbm_high_prob_deg2 gbm_high_prob_deg3 gbm_high_prob_deg4 ///
        $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmhigh_hunder

reghdfe hundermatched vmismatched gbm_high_recall gbm_high_recall_deg1 gbm_high_recall_deg2 gbm_high_recall_deg3 gbm_high_recall_deg4 ///
         $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmrecall_hunder

reghdfe hundermatched vmismatched gbm_low_prob gbm_low_prob_deg1 gbm_low_prob_deg2 gbm_low_prob_deg3 gbm_low_prob_deg4 ///
       $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmrecall_hunder gbmlow_hunder ///
    using "Output/Appendix/hunder_regressions_degree.tex", replace ///
    label booktabs drop($covars _cons ) ///
    rename( ///
        undocu                 "Undocumented" ///
        gbm_high_prob          "Undocumented" ///
        gbm_high_recall        "Undocumented" ///
        gbm_low_prob           "Undocumented" ///
        undocu_deg1            "Undocumented × STEM" ///
        gbm_high_prob_deg1     "Undocumented × STEM" ///
        gbm_high_recall_deg1   "Undocumented × STEM" ///
        gbm_low_prob_deg1      "Undocumented × STEM" ///
        undocu_deg2            "Undocumented × STEM Related" ///
        gbm_high_prob_deg2     "Undocumented × STEM Related" ///
        gbm_high_recall_deg2   "Undocumented × STEM Related" ///
        gbm_low_prob_deg2      "Undocumented × STEM Related" ///
        undocu_deg3            "Undocumented × Business" ///
        gbm_high_prob_deg3     "Undocumented × Business" ///
        gbm_high_recall_deg3   "Undocumented × Business" ///
        gbm_low_prob_deg3      "Undocumented × Business" ///
        undocu_deg4            "Undocumented × Education" ///
        gbm_high_prob_deg4     "Undocumented × Education" ///
        gbm_high_recall_deg4   "Undocumented × Education" ///
        gbm_low_prob_deg4      "Undocumented × Education" ///
    ) ///
    order("Undocumented" "Undocumented × STEM" "Undocumented × STEM Related" "Undocumented × Business" "Undocumented × Education") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Horizontal Undermatch (Degree Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)


*Log Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu undocu_deg1 undocu_deg2 undocu_deg3 undocu_deg4 ///
       $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo logical_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_deg1 gbm_high_prob_deg2 gbm_high_prob_deg3 gbm_high_prob_deg4 ///
        $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmhigh_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_recall gbm_high_recall_deg1 gbm_high_recall_deg2 gbm_high_recall_deg3 gbm_high_recall_deg4 ///
         $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmrecall_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_deg1 gbm_low_prob_deg2 gbm_low_prob_deg3 gbm_low_prob_deg4 ///
         $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip )
estadd ysumm
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmrecall_wage gbmlow_wage ///
    using "Output/Appendix/wage_regressions_degree.tex", replace ///
    label booktabs drop($covars _cons) ///
    rename( ///
        undocu                 "Undocumented" ///
        gbm_high_prob          "Undocumented" ///
        gbm_high_recall        "Undocumented" ///
        gbm_low_prob           "Undocumented" ///
        undocu_deg1            "Undocumented × STEM" ///
        gbm_high_prob_deg1     "Undocumented × STEM" ///
        gbm_high_recall_deg1   "Undocumented × STEM" ///
        gbm_low_prob_deg1      "Undocumented × STEM" ///
        undocu_deg2            "Undocumented × STEM Related" ///
        gbm_high_prob_deg2     "Undocumented × STEM Related" ///
        gbm_high_recall_deg2   "Undocumented × STEM Related" ///
        gbm_low_prob_deg2      "Undocumented × STEM Related" ///
        undocu_deg3            "Undocumented × Business" ///
        gbm_high_prob_deg3     "Undocumented × Business" ///
        gbm_high_recall_deg3   "Undocumented × Business" ///
        gbm_low_prob_deg3      "Undocumented × Business" ///
        undocu_deg4            "Undocumented × Education" ///
        gbm_high_prob_deg4     "Undocumented × Education" ///
        gbm_high_recall_deg4   "Undocumented × Education" ///
        gbm_low_prob_deg4      "Undocumented × Education" ///
    ) ///
    order("Undocumented" "Undocumented × STEM" "Undocumented × STEM Related" "Undocumented × Business" "Undocumented × Education") ///
    stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" "N") fmt(%9.2f %9.2f %9.0fc)) ///
    title("Regressions of Undocumented Status on Log Wages (Degree Interaction Terms)") ///
    mlabel("Logical Edits" "High Prob" "High Recall" "Low Prob") ///
    r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)

********************************************************************************
* Coefficient Plot: Degree Interaction Effects (manual interactions)
********************************************************************************

coefplot ///
    (logical_vmismatch,  label("Logical Edits")) ///
    (gbmhigh_vmismatch,  label("High Prob")) ///
    (gbmrecall_vmismatch,label("High Recall")) ///
    (gbmlow_vmismatch,   label("Low Prob")),      bylabel("Vertical Mismatch") ///
||  (logical_hunder,     label("Logical Edits")) ///
    (gbmhigh_hunder,     label("High Prob")) ///
    (gbmrecall_hunder,   label("High Recall")) ///
    (gbmlow_hunder,      label("Low Prob")),     bylabel("Horizontal Undermatch") ///
||  (logical_wage,       label("Logical Edits")) ///
    (gbmhigh_wage,       label("High Prob")) ///
    (gbmrecall_wage,     label("High Recall")) ///
    (gbmlow_wage,        label("Low Prob")),     bylabel("Log Wages") ///
    rename( ///
        undocu               = "Undocumented" ///
        gbm_high_prob        = "Undocumented" ///
        gbm_high_recall      = "Undocumented" ///
        gbm_low_prob         = "Undocumented" ///
        undocu_deg1          = "Undocumented × STEM" ///
        gbm_high_prob_deg1   = "Undocumented × STEM" ///
        gbm_high_recall_deg1 = "Undocumented × STEM" ///
        gbm_low_prob_deg1    = "Undocumented × STEM" ///
        undocu_deg2          = "Undocumented × STEM Related" ///
        gbm_high_prob_deg2   = "Undocumented × STEM Related" ///
        gbm_high_recall_deg2 = "Undocumented × STEM Related" ///
        gbm_low_prob_deg2    = "Undocumented × STEM Related" ///
        undocu_deg3          = "Undocumented × Business" ///
        gbm_high_prob_deg3   = "Undocumented × Business" ///
        gbm_high_recall_deg3 = "Undocumented × Business" ///
        gbm_low_prob_deg3    = "Undocumented × Business" ///
        undocu_deg4          = "Undocumented × Education" ///
        gbm_high_prob_deg4   = "Undocumented × Education" ///
        gbm_high_recall_deg4 = "Undocumented × Education" ///
        gbm_low_prob_deg4    = "Undocumented × Education" ///
    ) ///
    order("Undocumented" ///
          "Undocumented × STEM" ///
          "Undocumented × STEM Related" ///
          "Undocumented × Business" ///
          "Undocumented × Education") ///
    drop($covars vmismatched hundermatched hovermatched _cons) ///
    xline(0, lcolor(gs10)) ///
    byopts(cols(2) xrescale) ///
    scheme(s1color)
graph export "Output/Figures/degree_coeff.png", replace
