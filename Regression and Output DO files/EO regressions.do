clear matrix
clear
set more off


global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"

use "EO_Final_Sample", clear

********************************************************************************************************
*******************************************Descriptive Table********************************************
********************************************************************************************************
eststo clear


eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==0 & bpl_usa==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
esttab est* using dTable_status.tex, replace label main(mean) aux(sd) title("U.S. born workers and DACA eligible immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Total" "U.S. born citizens" "DACA eligibility noncitizens") note("Note: Means and standard deviations compared against U.S. born workers")

clear matrix
****************************************************************************************************************

xtset statefip


gen hmatch = 1 if hundermatched==1
replace hmatch=2 if hundermatched==0 & hovermatched==0
replace hmatch=3 if  hovermatched==1

gen elig_stem=elig*stem_deg
gen post_stem=post*stem_deg
gen elig_post_stem=elig*post*stem_deg


label define hmatch_label 1 "Hundermatched" 2 "Hmatched" 3 "Hovermatched" 
label values hmatch hmatch_label 


replace post=0 if year==2012
replace immig_by_ten=1 if bpl_foreign==0

save "Pre Regression sample", replace

global covars c.age##c.age hisp asian black other male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg 

clear matrix
set more off
*mismatch regressions

xtreg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mismatch_regressions.xls, replace ctitle (Vmismatch Model)

xtreg hmismatched vmismatched elig elig_post $covars metropolitan  i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mismatch_regressions.xls, append ctitle (Hmismatch Model)

xtreg hundermatched vmismatched elig elig_post $covars metropolitan  i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mismatch_regressions.xls, append ctitle (Hundermatch Model)


/*
logit vmismatched hundermatched hovermatched elig hisp asian black other male bpl_foreign nonfluent yrsed stem_deg i.metro  i.year i.statefip , r 
margins, dydx(hundermatched hovermatched elig) post
estadd ysumm
eststo

mlogit hmatch vmismatched  elig hisp asian black other male bpl_foreign nonfluent yrsed stem_deg i.metro  i.year i.statefip , r baseoutcome(2)
margins, dydx(vmismatched elig) predict(outcome(1)) post
estadd ysumm
eststo

margins, dydx(vmismatched elig) predict(outcome(3)) post
estadd ysumm
eststo
*/
esttab using mismatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Occupational Mismatch") ///
mlabel("Vrt. mismatch" "Horiz. mismatch"  "Horiz. undermatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 

clear matrix
set more off
*wage regressions

xtreg ln_adj vmismatched hundermatched hovermatched elig elig_post  $covars metropolitan  i.year  i.occ_category, r fe
estadd ysumm
eststo
outreg2 using wage_regressions.xls, append ctitle (Wage Model)



esttab using wage_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Wages") ///
mlabel("Log Wage"   ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 
	
*wage regressions with treatment effect by year

xtreg ln_adj vmismatched hundermatched hovermatched elig##ib2011.year $covars metropolitan i.occ_category, r fe
estadd ysumm
eststo


					 ***********************************************
************************ 			ROBUSTNESS CHECKS			 ************************
					 ***********************************************

******Mexican immigrants only for DACA eligible population Robustness check #1****
clear matrix
set more off
eststo clear


replace elig=0 if bpl!=200

***********************************************
****************Descriptive Table**************
***********************************************
eststo clear


eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==0 & bpl_usa==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
esttab est* using mex_dTable_status.tex, replace label main(mean) aux(sd) title("U.S. born workers and DACA eligible immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Total" "U.S. born citizens" "DACA eligibility noncitizens") note("Note: Means and standard deviations compared against U.S. born workers")

clear matrix
***********************************************

global covars c.age##c.age hisp asian black other male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg 

***Robustness
xtreg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mex_mismatch_regressions.xls, replace ctitle (Vmismatch Model)

xtreg hmismatched vmismatched elig elig_post $covars metropolitan  i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mex_mismatch_regressions.xls, append ctitle (Hmismatch Model)

xtreg hundermatched vmismatched elig elig_post $covars metropolitan  i.year i.occ_category , r fe
estadd ysumm
eststo
outreg2 using mex_mismatch_regressions.xls, append ctitle (Hundermatch Model)


esttab using mex_mismatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Occupational Mismatch") ///
mlabel("Vrt. mismatch" "Horiz. mismatch"  "Horiz. undermatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 

clear matrix
set more off
*wage regressions

xtreg ln_adj vmismatched hundermatched hovermatched elig elig_post  $covars metropolitan  i.year  i.occ_category, r fe
estadd ysumm
eststo
outreg2 using mex_wage_regressions.xls, append ctitle (Wage Model)



esttab using mex_wage_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Wages") ///
mlabel("Log Wage"   ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 

