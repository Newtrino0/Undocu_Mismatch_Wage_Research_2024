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
******Individual Mismatch regressions with Degree Interactions *************************
****************************************************************************************
clear matrix
set more off
eststo clear

*Vertical Mismatch
reghdfe vmismatched hundermatched hovermatched undocu##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo logical_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_high_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip year age) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_vmismatch

reghdfe vmismatched hundermatched hovermatched gbm_low_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip year age) vce(cluster statefip)
estadd ysumm
eststo gbmlow_vmismatch

esttab logical_vmismatch gbmhigh_vmismatch gbmlow_vmismatch using "/Output/Appendix/vmismatch_regressions_degree.tex", replace label booktabs drop($covars) ///
rename(1.degfield_broader "STEM" 2.degfield_broader "STEM Related" 3.degfield_broader "Business" 4.degfield_broader "Education" ///
1.gbm_low_prob "Undocu (low prob group)" 1.gbm_low_prob#2.degfield_broader "Low Prob x STEM Related" 1.gbm_low_prob#3.degfield_broader "Low Prob x Business" 1.gbm_low_prob#4.degfield_broader "Low Prob x Education" 1.gbm_low_prob#1.degfield_broader "Low Prob x STEM" ///
1.gbm_high_prob "Undocu (high prob group)" 1.gbm_high_prob#2.degfield_broader "High Prob x STEM Related" 1.gbm_high_prob#3.degfield_broader "High Prob x Business" 1.gbm_high_prob#4.degfield_broader "High Prob x Education" 1.gbm_high_prob#1.degfield_broader "High Prob x STEM" ///
1.undocu "Undocu (logical)" 1.undocu#2.degfield_broader "Undocu x STEM Related" 1.undocu#3.degfield_broader "Undocu x Business" 1.undocu#4.degfield_broader "Undocu x Education" 1.undocu#1.degfield_broader "Undocu x STEM") ///
stats(ymean r2 N, labels("Mean of Dep. Var." "R-squared" N) fmt(%9.2f %9.2f %9.0fc)) ///
title("Regressions of Undocumented Status on Vmismatch (Degree Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low") ///
r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)



*Horizontal Undermatch
reghdfe hundermatched vmismatched undocu##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo logical_hunder

reghdfe hundermatched vmismatched gbm_high_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_hunder

reghdfe hundermatched vmismatched gbm_low_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmlow_hunder "/Output/Appendix/using hunder_regressions_degree.tex", replace label booktabs drop($covars) ///
rename(1.degfield_broader "STEM" 2.degfield_broader "STEM Related" 3.degfield_broader "Business" 4.degfield_broader "Education" ///
1.gbm_low_prob "Undocu (low prob group)" 1.gbm_low_prob#2.degfield_broader "Low Prob x STEM Related" 1.gbm_low_prob#3.degfield_broader "Low Prob x Business" 1.gbm_low_prob#4.degfield_broader "Low Prob x Education" 1.gbm_low_prob#1.degfield_broader "Low Prob x STEM" ///
1.gbm_high_prob "Undocu (high prob group)" 1.gbm_high_prob#2.degfield_broader "High Prob x STEM Related" 1.gbm_high_prob#3.degfield_broader "High Prob x Business" 1.gbm_high_prob#4.degfield_broader "High Prob x Education" 1.gbm_high_prob#1.degfield_broader "High Prob x STEM" ///
1.undocu "Undocu (logical)" 1.undocu#2.degfield_broader "Undocu x STEM Related" 1.undocu#3.degfield_broader "Undocu x Business" 1.undocu#4.degfield_broader "Undocu x Education" 1.undocu#1.degfield_broader "Undocu x STEM") ///
title("Regressions of Undocumented Status on Horizontal Undermatch (Degree Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low") ///
r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)

*Log Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo logical_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo gbmhigh_wage

reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob##ib5.degfield_broader $covars [pweight=perwt], absorb(statefip##year age) vce(cluster statefip)
estadd ysumm
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmlow_wage using "/Output/Appendix/wage_regressions_degree.tex", replace label booktabs drop($covars) ///
rename(1.degfield_broader "STEM" 2.degfield_broader "STEM Related" 3.degfield_broader "Business" 4.degfield_broader "Education" ///
1.gbm_low_prob "Undocu (low prob group)" 1.gbm_low_prob#2.degfield_broader "Low Prob x STEM Related" 1.gbm_low_prob#3.degfield_broader "Low Prob x Business" 1.gbm_low_prob#4.degfield_broader "Low Prob x Education" 1.gbm_low_prob#1.degfield_broader "Low Prob x STEM" ///
1.gbm_high_prob "Undocu (high prob group)" 1.gbm_high_prob#2.degfield_broader "High Prob x STEM Related" 1.gbm_high_prob#3.degfield_broader "High Prob x Business" 1.gbm_high_prob#4.degfield_broader "High Prob x Education" 1.gbm_high_prob#1.degfield_broader "High Prob x STEM" ///
1.undocu "Undocu (logical)" 1.undocu#2.degfield_broader "Undocu x STEM Related" 1.undocu#3.degfield_broader "Undocu x Business" 1.undocu#4.degfield_broader "Undocu x Education" 1.undocu#1.degfield_broader "Undocu x STEM") ///
title("Regressions of Undocumented Status on Log Wages (Degree Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low") ///
r2(4) b(4) se(4) brackets star(* .1 ** .05 *** .01)

**Coefficient Plots****
coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), ///
keep(1.undocu* *.undocu*#*.degfield_broader) xline(0) byopts(cols(1)) title("Vertical Mismatch") ///
graph export "/Output/Figures/degree_vmismatch.png", replace

coefplot (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), ///
keep(1.undocu* *.undocu*#*.degfield_broader) xline(0) byopts(cols(1)) title("Horizontal Undermatch") ///
graph export "/Output/Appendix/degree_hunder.png", replace

coefplot (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), ///
keep(1.undocu* *.undocu*#*.degfield_broader) xline(0) byopts(cols(1)) title("Log Wages") ///
graph export "/Output/Appendix/degree_wage.png", replace

coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), bylabel(Vertical) ///
|| (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), bylabel(Horizontal) ///
|| (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), bylabel(Wage) ///
xline(0) graph export "/Output/Appendix/deg_coeff.png", replace

****************************************************************************************	
******Individual Mismatch regressions with IPC Interactions *************************
****************************************************************************************
clear matrix
set more off
eststo clear

*Vertical
reghdfe vmismatched hundermatched hovermatched undocu undocu_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_vmismatch
reghdfe vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_vmismatch
reghdfe vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_vmismatch

esttab logical_vmismatch gbmhigh_vmismatch gbmlow_vmismatch using vmismatch_regressions_ipc.tex, replace label booktabs drop($covars_reghdfe) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_inclusive "Undocu x Inclusive" gbm_high_prob_inclusive "High Prob x Inclusive" gbm_low_prob_inclusive "Low Prob x Inclusive") ///
title("Regressions of Undocumented Status on Vmismatch (IPC Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low") r2(4) b(4) se(4)

*Horizontal
reghdfe hundermatched vmismatched undocu undocu_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_hunder
reghdfe hundermatched vmismatched gbm_high_prob gbm_high_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_hunder
reghdfe hundermatched vmismatched gbm_low_prob gbm_low_prob_inclusive $covars [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmlow_hunder using hunder_regressions_ipc.tex, replace label booktabs drop($covars) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_inclusive "Undocu x Inclusive" gbm_high_prob_inclusive "High Prob x Inclusive" gbm_low_prob_inclusive "Low Prob x Inclusive") ///
title("Regressions of Undocumented Status on Horizontal Undermatch (IPC Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low")

*Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu undocu_inclusive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_wage
reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_inclusive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_wage
reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_inclusive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmlow_wage using wage_regressions_ipc.tex, replace label booktabs drop($covars_reghdfe) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_inclusive "Undocu x Inclusive" gbm_high_prob_inclusive "High Prob x Inclusive" gbm_low_prob_inclusive "Low Prob x Inclusive") ///
title("Regressions of Undocumented Status on Log Wages (IPC Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low")

coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), ///
drop($covars_reghdfe hundermatched hovermatched) xline(0) title("Vertical Mismatch") ///
graph export ipc_vmismatch.png, replace

coefplot (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), ///
drop($covars_reghdfe vmismatched) xline(0) title("Horizontal Undermatch") graph export ipc_hunder.png, replace

coefplot (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), ///
drop($covars_reghdfe vmismatched hundermatched hovermatched) xline(0) title("Log Wage") graph export ipc_wage.png, replace

coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), bylabel(Vertical) ///
|| (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), bylabel(Horizontal) ///
|| (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), bylabel(Wage) ///
drop($covars_reghdfe vmismatched hundermatched hovermatched) xline(0) graph export ipc_coeff.png, replace

****************************************************************************************	
******Individual Mismatch regressions with Individual Policy Interactions *************************
****************************************************************************************
clear matrix
set more off
eststo clear

*Vertical
reghdfe vmismatched hundermatched hovermatched undocu undocu_everify undocu_license undocu_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_vmismatch
reghdfe vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_vmismatch
reghdfe vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_vmismatch

esttab logical_vmismatch gbmhigh_vmismatch gbmlow_vmismatch using vmismatch_regressions_policies.tex, replace label booktabs drop($covars_reghdfe) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_everify "Undocu x Inclusive Everify" gbm_high_prob_everify "High Prob x Inclusive Everify" gbm_low_prob_everify "Low Prob x Inclusive Everify" ///
undocu_license "Undocu x Inclusive OCC" gbm_high_prob_license "High Prob x Inclusive OCC" gbm_low_prob_license "Low Prob x Inclusive OCC" ///
undocu_drive "Undocu x Inclusive Drive" gbm_high_prob_drive "High Prob x Inclusive Drive" gbm_low_prob_drive "Low Prob x Inclusive Drive") ///
title("Regressions of Undocumented Status on Vmismatch (Policy Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low")

*Horizontal
reghdfe hundermatched vmismatched undocu undocu_everify undocu_license undocu_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_hunder
reghdfe hundermatched vmismatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_hunder
reghdfe hundermatched vmismatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_hunder

esttab logical_hunder gbmhigh_hunder gbmlow_hunder using hunder_regressions_policies.tex, replace label booktabs drop($covars_reghdfe) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_everify "Undocu x Inclusive Everify" gbm_high_prob_everify "High Prob x Inclusive Everify" gbm_low_prob_everify "Low Prob x Inclusive Everify" ///
undocu_license "Undocu x Inclusive OCC" gbm_high_prob_license "High Prob x Inclusive OCC" gbm_low_prob_license "Low Prob x Inclusive OCC" ///
undocu_drive "Undocu x Inclusive Drive" gbm_high_prob_drive "High Prob x Inclusive Drive" gbm_low_prob_drive "Low Prob x Inclusive Drive") ///
title("Regressions of Undocumented Status on Horizontal Undermatch (Policy Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low")

*Wages
reghdfe ln_adj vmismatched hundermatched hovermatched undocu undocu_everify undocu_license undocu_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo logical_wage
reghdfe ln_adj vmismatched hundermatched hovermatched gbm_high_prob gbm_high_prob_everify gbm_high_prob_license gbm_high_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmhigh_wage
reghdfe ln_adj vmismatched hundermatched hovermatched gbm_low_prob gbm_low_prob_everify gbm_low_prob_license gbm_low_prob_drive $covars_reghdfe [pweight=perwt], absorb(statefip##year age degfield_broader) vce(cluster statefip)
eststo gbmlow_wage

esttab logical_wage gbmhigh_wage gbmlow_wage using wage_regressions_policies.tex, replace label booktabs drop($covars_reghdfe) ///
rename(undocu "Undocumented" gbm_high_prob "Undocu (high prob group)" gbm_low_prob "Undocu (low prob group)" ///
undocu_everify "Undocu x Inclusive Everify" gbm_high_prob_everify "High Prob x Inclusive Everify" gbm_low_prob_everify "Low Prob x Inclusive Everify" ///
undocu_license "Undocu x Inclusive OCC" gbm_high_prob_license "High Prob x Inclusive OCC" gbm_low_prob_license "Low Prob x Inclusive OCC" ///
undocu_drive "Undocu x Inclusive Drive" gbm_high_prob_drive "High Prob x Inclusive Drive" gbm_low_prob_drive "Low Prob x Inclusive Drive") ///
title("Regressions of Undocumented Status on Log Wages (Policy Interaction Terms)") ///
mlabel("Logical edits" "GBM High" "GBM Low")

coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), ///
drop($covars_reghdfe hundermatched hovermatched) xline(0) title("Vertical Mismatch") graph save policy_vmismatch, replace

coefplot (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), ///
drop($covars_reghdfe vmismatched) xline(0) title("Horizontal Undermatch") graph save policy_hunder, replace

coefplot (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), ///
drop($covars_reghdfe vmismatched hundermatched hovermatched) xline(0) title("Log Wage") graph save policy_wage, replace

coefplot (logical_vmismatch, label(Logical)) (gbmhigh_vmismatch, label(GBM High)) (gbmlow_vmismatch, label(GBM Low)), bylabel(Vertical) ///
|| (logical_hunder, label(Logical)) (gbmhigh_hunder, label(GBM High)) (gbmlow_hunder, label(GBM Low)), bylabel(Horizontal) ///
|| (logical_wage, label(Logical)) (gbmhigh_wage, label(GBM High)) (gbmlow_wage, label(GBM Low)), bylabel(Wage) ///
drop($covars_reghdfe vmismatched hundermatched hovermatched) xline(0) graph export policy_coeff.png, replace
