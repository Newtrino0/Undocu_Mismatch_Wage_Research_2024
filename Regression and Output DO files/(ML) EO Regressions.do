clear matrix
clear
set more off
ssc install coefplot, replace

global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"

cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML)EO_Final_Sample", clear



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
	gen undocu_year`y' = undocu_logit*(eventyear==`y')
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

/*
gen annual_total_dummy = 0 if annual_total<0
replace annual_total_dummy = 1 if annual_total==0
replace annual_total_dummy = 2 if annual_total>0

label define annual_total_label 0 "Exclusive" 1 "Neutral" 2 "Inclusive" 
label values annual_total_dummy annual_total_label 

gen exclusive = 1 if annual_total<0
replace exclusive = 0 if annual_total>=0

gen inclusive = 1 if annual_total>0
replace inclusive = 0 if annual_total<=0

gen undocu_inclusive = undocu_logit*inclusive
gen undocu_exclusive = undocu_logit*exclusive

gen undocu_annual_total = undocu_logit*annual_total
*/


clear matrix
set more off

xtset statefip
global covars i.age hisp male gov_worker immig_by_ten nonfluent yrsed stem_deg i.race##i.year
/*global individual_ipc b1.pub_insurance_immigrant_kids 	b1.prenatal_care_pregnant_immigrant 	b1.pub_insurance_pregnant_immigrant 	b1.pub_insurance_immigrant_older_ad 	b1.food_assistance_for_lpr_adults 	b1.tuition_equity 	b1.financial_aid 	b1.blocks_enrollment 	b1.professional_licensure 	b1.drivers_license	b1.omnibus 	b1.cooperation_federal_immigration 	b1.e_verify b1.secure_communities_participated
*/
save "(ML) Pre Regression sample", replace

********************************************************************************************************
*******************************************Descriptive Table********************************************
********************************************************************************************************
eststo clear
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"

eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if bpl_foreign==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if bpl_foreign==1 & citizen==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_logit==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_knn==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_rf==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
esttab est* using dTable_status_ml.tex, replace label main(mean) aux(sd) title("U.S. born workers and Undocumented immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Foreign-born" "Foreign-born citizens" "Undocumented noncitizens" "Undocu_logit" "Undocu_knn" "Undocu_rf") note("Note: Log wage is adjusted for inflation with CPI valuesstarting January 2009, every year in January until January 2024.")


****************************************************************************************************************
********************************************************************************************************
*******************************************Descriptive Table (SIPP)********************************************
********************************************************************************************************
eststo clear
import delimited "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\ACS_SIPP_rf.csv", clear 

eststo: estpost tabstat undocu_likely if bpl_foreign==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if bpl_foreign==1 & citizen==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_logit==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_knn==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem white black asian hisp if undocu_rf==1 & bpl_usa==0 , statistics(mean sd) columns(statistics) 
esttab est* using dTable_status_ml.tex, replace label main(mean) aux(sd) title("U.S. born workers and Undocumented immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Foreign-born" "Foreign-born citizens" "Undocumented noncitizens" "Undocu_logit" "Undocu_knn" "Undocu_rf") note("Note: Log wage is adjusted for inflation with CPI valuesstarting January 2009, every year in January until January 2024.")


****************************************************************************************************************

****************************************************************************************	
********************************High-level Mismatch regressions with total IPC indicator************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
***Horizontal mismatch model***
reg hmismatched vmismatched bpl_foreign $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal undermatch model***
reg hundermatched vmismatched bpl_foreign $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal overmatch model***
reg hovermatched vmismatched bpl_foreign $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo


 cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using mismatch_regressions_total.tex, replace label booktabs keep(vmismatched hundermatched hovermatched bpl_foreign) ///
order(vmismatched hundermatched hovermatched bpl_foreign) ///
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
********************************Individual Mismatch regressions (ML) ************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
keep if bpl_foreign == 1
***Logical edits V. mismatch model***
reg vmismatched hundermatched hovermatched undocu $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Logistic Regression (Classifier) V. mismatch model***
reg vmismatched hundermatched hovermatched undocu_logit $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***KNN V. mismatch model***
reg vmismatched hundermatched hovermatched undocu_knn $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***RF V. mismatch model***
reg vmismatched hundermatched hovermatched undocu_rf $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using vmismatch_regressions_ml.tex, replace label booktabs keep(hundermatched hovermatched undocu undocu_logit undocu_knn undocu_rf) ///
order(hundermatched hovermatched undocu undocu_logit undocu_knn undocu_rf) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Vmismatch (ML)") ///
mlabel("Logical edits Vmismatch" "Logistic classifier Vmismatch" "KNN Vmismatch" "RF Vmismatch") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")		
	

	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
keep if bpl_foreign == 1
***Logical edits H. mismatch model***
reg hmismatched vmismatched undocu $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Logistic Regression (Classifier) H. mismatch model***
reg hmismatched vmismatched undocu_logit $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***KNN H. mismatch model***
reg hmismatched vmismatched undocu_knn $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***RF H. mismatch model***
reg hmismatched vmismatched undocu_rf $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using hmismatch_regressions_ml.tex, replace label booktabs keep(vmismatched undocu undocu_logit undocu_knn undocu_rf) ///
order(vmismatched undocu undocu_logit undocu_knn undocu_rf) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hmismatch (ML)") ///
mlabel("Logical edits Hmismatch" "Logistic classifier Hmismatch" "KNN Hmismatch" "RF Hmismatch") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")	
	
	
clear matrix
set more off
eststo clear
***Horizontal undermatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
keep if bpl_foreign == 1
***Logical edits H. undermatch model***
reg hundermatched vmismatched undocu $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Logistic Regression (Classifier) H. undermatch model***
reg hundermatched vmismatched undocu_logit $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***KNN H. undermatch model***
reg hundermatched vmismatched undocu_knn $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***RF H. undermatch model***
reg hundermatched vmismatched undocu_rf $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using hundermatch_regressions_ml.tex, replace label booktabs keep(vmismatched undocu undocu_logit undocu_knn undocu_rf) ///
order(vmismatched undocu undocu_logit undocu_knn undocu_rf) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on H. undermatch (ML)") ///
mlabel("Logical edits Hundermatch" "Logistic classifier Hundermatch" "KNN Hundermatch" "RF Hundermatch") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")		
	
			
	
	
	

**********************************************************************************	
****************Wage models with demographic columns/samples**************************
**************************************************************************************
clear matrix
set more off
eststo clear

*** WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
keep if bpl_foreign == 1
***Logical edits column***
reg ln_adj vmismatched hundermatched hovermatched undocu $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo
**Logistic classifier column***
reg ln_adj vmismatched hundermatched hovermatched undocu_logit $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
**KNN column***
reg ln_adj vmismatched hundermatched hovermatched undocu_knn $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
**RF column***
reg ln_adj vmismatched hundermatched hovermatched undocu_rf $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo


cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using wage_regressions_ml.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu undocu_logit undocu_knn undocu_rf) ///
order(vmismatched hundermatched hovermatched undocu undocu_logit undocu_knn undocu_rf) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status, by demographic, on Wages") ///
mlabel("Logical edits model" "Logistic Classifier model" "KNN model" "RF model") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.") 
	
