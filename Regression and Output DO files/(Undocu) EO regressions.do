clear matrix
clear
set more off
ssc install coefplot, replace

global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"

cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu)EO_Final_Sample", clear



***elig_year variable creation***
gen eventyear = year
label define eventyr 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" ///
	 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019"
label values eventyear eventyr

forvalues y=2013(1)2019 {
	gen elig_year`y' = elig*(eventyear==`y')
}
drop elig_year2016

forvalues y=2013(1)2019 {
	gen undocu_year`y' = undocu*(eventyear==`y')
}
drop undocu_year2016

***Mismatch and other regression covariate modifications/labeling***
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

gen annual_total_dummy = 0 if annual_total<0
replace annual_total_dummy = 1 if annual_total==0
replace annual_total_dummy = 2 if annual_total>0

label define annual_total_label 0 "Exclusive" 1 "Neutral" 2 "Inclusive" 
label values annual_total_dummy annual_total_label 

gen exclusive = 1 if annual_total<0
replace exclusive = 0 if annual_total>=0

gen inclusive = 1 if annual_total>0
replace inclusive = 0 if annual_total<=0

gen undocu_inclusive = undocu*inclusive
gen undocu_exclusive = undocu*exclusive

gen eighteen_by_arrival = (ageimmig<=18 | ageimmig==.)


clear matrix
set more off

xtset statefip
global covars i.age hisp male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg i.race##i.year
global individual_ipc b1.pub_insurance_immigrant_kids 	b1.prenatal_care_pregnant_immigrant 	b1.pub_insurance_pregnant_immigrant 	b1.pub_insurance_immigrant_older_ad 	b1.food_assistance_for_lpr_adults 	b1.tuition_equity 	b1.financial_aid 	b1.blocks_enrollment 	b1.professional_licensure 	b1.drivers_license	b1.omnibus 	b1.cooperation_federal_immigration 	b1.e_verify b1.secure_communities_participated
save "(Undocu) Pre Regression sample", replace

********************************************************************************************************
*******************************************Descriptive Table********************************************
********************************************************************************************************
eststo clear
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
keep if eighteen_by_arrival==1

eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem annual_total pos neg , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem annual_total pos neg if undocu==0 & bpl_usa==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem annual_total pos neg if undocu==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
esttab est* using dTable_status.tex, replace label main(mean) aux(sd) title("U.S. born workers and Undocumented immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Total" "U.S. born citizens" "Undocumented noncitizens") note("Note: Log wage is adjusted for inflation with CPI valuesstarting January 2009, every year in January until January 2024.")


****************************************************************************************************************

****************************************************************************************	
********************************High-level Mismatch regressions with total IPC indicator************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
keep if eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal mismatch model***
reg hmismatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal undermatch model***
reg hundermatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal overmatch model***
reg hovermatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo


cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using mismatch_regressions_total.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
order(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Education-Occupation Mismatch (with IPC total indicator)") ///
mlabel("Vrt. mismatch" "Horiz. mismatch"  "Horiz. undermatch" "Horiz. overmatch") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")	
	

****************************************************************************************	
********************************Individual Mismatch regressions (Total IPC) ************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete V. mismatch model**
keep if eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using vmismatch_regressions_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive) ///
order(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Vmismatch (IPC)") ///
mlabel("Complete Vmismatch"  "Foreign Vmismatch" "Mexican Vmismatch" "Hispanic V.mismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")		
	
	
	
***Horizontal mismatch table***	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete H. mismatch model**
keep if eighteen_by_arrival==1
reg hmismatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using hmismatch_regressions_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive) ///
order(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hmismatch (IPC)") ///
mlabel("Complete Hmismatch"  "Foreign Hmismatch" "Mexican Hmismatch" "Hispanic Hmismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")	
	
	
	
	
***Horizontal undermatch table***	
clear matrix
set more off
eststo clear
***Horizontal undermatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete H. undermatch model**
keep if eighteen_by_arrival==1
reg hundermatched vmismatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using hundermatch_regressions_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
order(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hundermatch (IPC)") ///
mlabel("Complete Hundermatch"  "Foreign Hundermatch" "Mexican Hundermatch" "Hispanic Hundermatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")  		
	
	
	
****************************************************************************************	
********************************Individual Mismatch regressions (Labor IPC) ************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete V. mismatch model**
keep if eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic V. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using vmismatch_regressions_labor_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
order(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Vmismatch (Labor IPC)") ///
mlabel("Complete Vmismatch"  "Foreign Vmismatch" "Mexican Vmismatch" "Hispanic V.mismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")		
	
	
	
***Horizontal mismatch table***	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete H. mismatch model**
keep if eighteen_by_arrival==1
reg hmismatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. mismatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg hmismatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using hmismatch_regressions_labor_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
order(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hmismatch (Labor IPC)") ///
mlabel("Complete Hmismatch"  "Foreign Hmismatch" "Mexican Hmismatch" "Hispanic Hmismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")	
	
	
	
	
***Horizontal undermatch table***	
clear matrix
set more off
eststo clear
***Horizontal undermatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
**Complete H. undermatch model**
keep if eighteen_by_arrival==1
reg hundermatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. undermatch model***
use "(Undocu) Pre Regression sample",clear
keep if hisp==1 & eighteen_by_arrival==1
reg hundermatched vmismatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using hundermatch_regressions_labor_ipc.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
order(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hundermatch (Labor IPC)") ///
mlabel("Complete Hundermatch"  "Foreign Hundermatch" "Mexican Hundermatch" "Hispanic Hundermatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")  			
	
					 ***********************************************
************************ 			elig_year and table (IPC total)	 ************************
/*					 ***********************************************
clear matrix
set more off
eststo clear
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear

***COMPLETE WAGE MODEL***
keep if twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched undocu undocu_year* $covars metropolitan i.occ_category i.statefip##i.year b1.annual_total_dummy [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Vertical mismatch-elig_year model***
reg vmismatched hundermatched hovermatched undocu undocu_year* $covars metropolitan i.statefip##i.year i.occ_category b1.annual_total_dummy [pweight=perwt], r cl(statefip)
estadd ysumm
eststo 
***Horizontal mismatch-elig_year model***
reg hmismatched vmismatched undocu undocu_year* $covars metropolitan i.statefip##i.year i.occ_category b1.annual_total_dummy [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal undermatch-elig_year model***
reg hundermatched vmismatched undocu undocu_year* $covars metropolitan i.statefip##i.year i.occ_category b1.annual_total_dummy [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using undocu_year_regressions_ipc_total.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu undocu_year2013 undocu_year2014 undocu_year2015 undocu_year2017 undocu_year2018 undocu_year2019 0.annual_total_dummy 2.annual_total_dummy) ///
order(vmismatched hundermatched hovermatched elig undocu_year2013 undocu_year2014 undocu_year2015 undocu_year2017 undocu_year2018 undocu_year2019 0.annual_total_dummy 2.annual_total_dummy) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status x Year on Mismatch and Wage (total IPC)") ///
mlabel("Log wage" "Vrt. mismatch" "Horiz. mismatch"  "Horiz. undermatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")  	 
*/

**********************************************************************************	
****************Wage models with demographic columns/samples**************************
**************************************************************************************
clear matrix
set more off
eststo clear

*** THE COMPLETE WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
keep if eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign born column***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Mexico born column***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu inclusive	exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo

**Hispanic column***
use "(Undocu) Pre Regression sample", clear
keep if hisp==1 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using demographic_wage_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
order(vmismatched hundermatched hovermatched undocu inclusive exclusive undocu_inclusive undocu_exclusive) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status, by demographic, on Wages") ///
mlabel("Complete model" "Foreign-born only" "Mexico-born only" "Hispanic only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.") 
	
**********************************************************************************	
****************Wage models with demographic columns/samples (Labor IPC)**************************
**************************************************************************************
clear matrix
set more off
eststo clear

*** THE COMPLETE WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(Undocu) Pre Regression sample",clear
keep if eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign born column***
use "(Undocu) Pre Regression sample",clear
keep if bpl_foreign==1 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify  $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Mexico born column***
use "(Undocu) Pre Regression sample",clear
keep if bpl==200 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify  $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo

**Hispanic column***
use "(Undocu) Pre Regression sample", clear
keep if hisp==1 & eighteen_by_arrival==1
reg ln_adj vmismatched hundermatched hovermatched undocu b1.drivers_license b1.professional_licensure b1.e_verify  $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures 2.0"
esttab using demographic_wage_regressions_labor.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
order(vmismatched hundermatched hovermatched undocu 0.drivers_license 2.drivers_license 0.professional_licensure 2.professional_licensure  0.e_verify 2.e_verify) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status, by demographic, on Wages (Labor IPC)") ///
mlabel("Complete model" "Foreign-born only" "Mexico-born only" "Hispanic only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.") 	