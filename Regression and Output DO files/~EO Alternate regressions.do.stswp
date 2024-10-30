clear matrix
clear
set more off


global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"

use "EO_Final_Alternate_Sample", clear

********************************************************************************************************
*******************************************Descriptive Table********************************************
********************************************************************************************************
eststo clear


eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==0 & bpl_usa==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
esttab est* using hs_dTable_status.tex, replace label main(mean) aux(sd) title("U.S. born workers and DACA eligible immigrants Summary Statistics (HS and College graduates) \label{tab:sum}") unstack mlabels("Total" "U.S. born citizens" "DACA eligibility noncitizens") note("Note: Means and standard deviations compared against U.S. born workers")

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

global covars c.age##c.age hisp asian black other male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg 

clear matrix
set more off


*wage regressions

xtreg ln_adj elig elig_post  $covars metropolitan  i.year  i.occ_category, r fe
estadd ysumm
eststo
outreg2 using hs_wage_regressions.xls, append ctitle (Wage Model)



esttab using hs_wage_regressions.tex, replace label booktabs keep(immig_by_ten yrsed stem_deg elig elig_post ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Wages") ///
mlabel("Log Wage"   ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 
	
*wage regressions with treatment effect by year



