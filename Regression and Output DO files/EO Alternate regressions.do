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

gen eventyear = year
label define eventyr 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" ///
	 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019"
label values eventyear eventyr

forvalues y=2009(1)2019 {
	gen elig_year`y' = elig*(eventyear==`y')
}

gen hmatch = 1 if hundermatched==1
replace hmatch=2 if hundermatched==0 & hovermatched==0
replace hmatch=3 if  hovermatched==1

gen elig_stem=elig*stem_deg
gen post_stem=post*stem_deg
gen elig_post_stem=elig*post*stem_deg

gen vmatch=1 if edu_att<mode_att
replace vmatch=2 if edu_att==mode_att
replace vmatch=3 if edu_att>mode_att

label define hmatch_label 1 "Hundermatched" 2 "Hmatched" 3 "Hovermatched" 
label values hmatch hmatch_label 

label define vmatch_label 1 "Vertically mismatched (Overqualified)" 2 "Vertically matched" 3 "Vertically mismatched (Underqualified)" 
label values vmatch vmatch_label 


replace post=0 if year==2012
replace immig_by_ten=1 if bpl_foreign==0

global covars i.age hisp asian black other male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg 

clear matrix
set more off

save "Pre Regression alternate sample", replace

*wage regressions

reg ln_adj elig elig_post $covars metropolitan i.statefip##i.year  i.occ_category, r cl(statefip)
estadd ysumm
eststo



esttab using hs_wage_regressions.tex, replace label booktabs keep(immig_by_ten yrsed stem_deg elig elig_post ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Wages") ///
mlabel("Log Wage"   ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 
	
	
****************************************************************************************	
****************Wage models with HS/College comparison columns**************************
******************************************************************************************

****elig_year tables****
clear matrix
set more off
eststo clear

use "Pre Regression alternate sample",clear
keep if yrsed>=12
reg ln_adj b2.vmatch elig_year* $covars metropolitan i.statefip##i.year  i.occ_category, r cl(statefip)
estadd ysumm
eststo	

use "Pre Regression alternate sample",clear
keep if yrsed>=16
reg ln_adj b2.vmatch elig_year* $covars metropolitan i.statefip##i.year i.occ_category, r cl(statefip)
estadd ysumm
eststo

use "Pre Regression alternate sample",clear
keep if yrsed==12
reg ln_adj b2.vmatch elig_year* $covars metropolitan i.statefip##i.year i.occ_category, r cl(statefip)
estadd ysumm
eststo




esttab using education_wage_regressions.tex, replace label booktabs keep(1.vmatch 2.vmatch 3.vmatch elig_year2009 elig_year2010 elig_year2011 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by educational attainment, on Log Wages") ///
mlabel("HS and up only" "College and up only" "HS only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.") 	

	
****elig and elig_post tables****	
use "Pre Regression alternate sample",clear

clear matrix
set more off
eststo clear

keep if yrsed>=12
reg ln_adj b2.vmatch elig elig_post $covars metropolitan i.statefip##i.year  i.occ_category, r cl(statefip)
estadd ysumm
eststo

use "Pre Regression alternate sample",clear
keep if yrsed>=16
reg ln_adj b2.vmatch elig elig_post $covars metropolitan i.statefip##i.year i.occ_category, r cl(statefip)
estadd ysumm
eststo


use "Pre Regression alternate sample",clear
keep if yrsed==12
reg ln_adj b2.vmatch elig elig_post $covars metropolitan i.statefip##i.year i.occ_category, r cl(statefip)
estadd ysumm
eststo




esttab using education_eligpost_regressions.tex, replace label booktabs keep(1.vmatch 2.vmatch 3.vmatch elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by educational attainment, on Log Wages") ///
mlabel("HS and up only" "College and up only" "HS only"  ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include gender, race/ethnicity,  ") ///
addn("foreign born, immigration by age 10, STEM degree indicators," ///
	" years of schooling, state and year fixed effects." ///
	"Robust standard errors.")
	
*wage regressions with treatment effect by year



