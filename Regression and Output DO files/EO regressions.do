clear matrix
clear
set more off
ssc install coefplot, replace

global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"

cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "EO_Final_Sample", clear

********************************************************************************************************
*******************************************Descriptive Table********************************************
********************************************************************************************************
eststo clear


eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem  if elig==0 & bpl_usa==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj fem if elig==1 & bpl_usa==0 , statistics(mean sd) columns(statistics)  
esttab est* using dTable_status.tex, replace label main(mean) aux(sd) title("U.S. born workers and DACA eligible immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Total" "U.S. born citizens" "DACA eligibility noncitizens") note("Note: Log wage is adjusted for inflation with CPI valuesstarting January 2009, every year in January until January 2024.")

clear matrix

****************************************************************************************************************

***elig_year variable creation***
gen eventyear = year
label define eventyr 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" ///
	 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019"
label values eventyear eventyr

forvalues y=2009(1)2019 {
	gen elig_year`y' = elig*(eventyear==`y')
}
drop elig_year2011

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

clear matrix
set more off

xtset statefip
global covars i.age hisp male gov_worker bpl_foreign immig_by_ten nonfluent yrsed stem_deg i.race##i.year
save "Pre Regression sample", replace


****************************************************************************************	
********************************High-level Mismatch regressions************************************
****************************************************************************************
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
keep if twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal mismatch model***
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal undermatch model***
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Horizontal overmatch model***
reg hovermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

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
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using mismatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility on Education-Occupation Mismatch") ///
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
********************************Individual Mismatch regressions************************************
****************************************************************************************
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
**Complete V. mismatch model**
keep if twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states V. mismatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign V. mismatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican V. mismatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic V. mismatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using vmismatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Vmismatch") ///
mlabel("Complete Vmismatch" "Top 10 states Vmismatch"  "Foreign Vmismatch" "Mexican Vmismatch" "Hispanic V.mismatch" ) ///
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
use "Pre Regression sample",clear
**Complete H. mismatch model**
keep if twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states H. mismatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. mismatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. mismatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. mismatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using hmismatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Hmismatch") ///
mlabel("Complete Hmismatch" "Top 10 states Hmismatch"  "Foreign Hmismatch" "Mexican Hmismatch" "Hispanic Hmismatch" ) ///
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
use "Pre Regression sample",clear
**Complete H. undermatch model**
keep if twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states H. undermatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. undermatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. undermatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. undermatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_post $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using hundermatch_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post ) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Hundermatch") ///
mlabel("Complete Hundermatch" "Top 10 states Hundermatch"  "Foreign Hundermatch" "Mexican Hundermatch" "Hispanic Hundermatch" ) ///
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

*** THE COMPLETE WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
keep if twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Foreign born column***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Mexico born column***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo

**Hispanic column***
use "Pre Regression sample", clear
keep if hisp==1 & twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using demographic_wage_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Wages") ///
mlabel("Complete model" "Top 10 states with DACA recipients" "Foreign-born only" "Mexico-born only" "Hispanic only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")  	
	
**************************************************************************************	
****************Wage models with demographic columns/samples, without mismatch indicators**************************
**************************************************************************************
clear matrix
set more off
eststo clear

***"COMPLETE" WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
keep if twentytwo_by_2012==1
reg ln_adj elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg ln_adj elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Foreign born column***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg ln_adj elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Mexico born column***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg ln_adj elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo

**Hispanic column***
use "Pre Regression sample", clear
keep if hisp==1 & twentytwo_by_2012==1
reg ln_adj elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using demographic_wage_womismatch_regressions.tex, replace label booktabs keep (elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Wages without mismatch indicators") ///
mlabel("Complete model" "Top 10 states with DACA recipients" "Foreign-born only" "Mexico-born only" "Hispanic only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")  		

					 ***********************************************
************************ 			elig_year coefficient plots and table	 ************************
					 ***********************************************
clear matrix
set more off
eststo clear
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear

***COMPLETE WAGE MODEL***
keep if twentytwo_by_2012==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
set scheme s1mono
coefplot, keep(elig_year*) xline(0) ytitle(Eligible x Year) xtitle(Complete Model coefficients plot)
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
gr export "coefplot_elig_complete.png", replace 
***Vertical mismatch-elig_year model***
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
set scheme s1mono
coefplot, keep(elig_year*)  xline(0) ytitle(Eligible x Year) xtitle(V. mismatch Model coefficients plot)
gr export "coefplot_elig_vmismatch.png", replace  
***Horizontal mismatch-elig_year model***
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
set scheme s1mono
coefplot, keep(elig_year*)  xline(0) ytitle(Eligible x Year) xtitle(H. mismatch Model coefficients plot)
gr export "coefplot_elig_hmismatch.png", replace  
***Horizontal undermatch-elig_year model***
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
set scheme s1mono
coefplot, keep(elig_year*)  xline(0) ytitle(Eligible x Year) xtitle(H. undermatch Model coefficients plot)
gr export "coefplot_elig_hundermatch.png", replace  


esttab using elig_year_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
order(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA Eligibility x Year on Mismatch and Wage") ///
mlabel("Log wage" "Vrt. mismatch" "Horiz. mismatch"  "Horiz. undermatch" ) ///
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
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear


					 ***********************************************
************************ Individual elig_year coefficient plots and table ************************
					 ***********************************************
clear matrix
set more off
eststo clear

**************************Demographic elig_year COMPLETE WAGE Table********************
***"COMPLETE" WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
keep if twentytwo_by_2012==1
reg ln_adj elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg ln_adj elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Foreign born column***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg ln_adj elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Mexico born column***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg ln_adj elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm 
eststo

**Hispanic column***
use "Pre Regression sample", clear
keep if hisp==1 & twentytwo_by_2012==1
reg ln_adj elig elig_year* $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using demographic_eligyear_wage_regressions.tex, replace label booktabs keep (elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Wages (Eligible x Year)") ///
mlabel("Complete model" "Top 10 states with DACA recipients" "Foreign-born only" "Mexico-born only" "Hispanic only" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")

**************************Demographic elig_year Vmismatch Table********************
clear matrix
set more off
eststo clear

cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
**Complete elig_year V. mismatch model**
keep if twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states V. mismatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign V. mismatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican V. mismatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic V. mismatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg vmismatched hundermatched hovermatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using vmismatch_eligyear_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019 ) ///
order(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Vmismatch (Eligible x Year)") ///
mlabel("Complete Vmismatch" "Top 10 states Vmismatch"  "Foreign Vmismatch" "Mexican Vmismatch" "Hispanic Vmismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")	

**************************Demographic elig_year Hmismatch Table********************
***Horizontal mismatch table***	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
**Complete H. mismatch model**
keep if twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states H. mismatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. mismatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. mismatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. mismatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg hmismatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using hmismatch_eligyear_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019 ) ///
order(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Hmismatch (Eligible x Year)") ///
mlabel("Complete Hmismatch" "Top 10 states Hmismatch"  "Foreign Hmismatch" "Mexican Hmismatch" "Hispanic Hmismatch" ) ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")

	
**************************Demographic elig_year Hundermatch Table********************	
	
***Horizontal undermatch table***	
clear matrix
set more off
eststo clear
***Horizontal undermatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
**Complete H. undermatch model**
keep if twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Top 10 states H. undermatch model***
***Greatest number of DACA recipients column***
* California 165,090   | Texas 95,970
* Illinois 30,740      | New York 23,780
* Florida 22,750       | Arizona 21,990
* North Carolina 21,980| Georgia 19,040
* New Jersey 14,430    | Washington 14,310
use "Pre Regression sample",clear
keep if (statefip==06 | statefip==48 | statefip==17 | statefip==36 | statefip==12 | statefip==04 | statefip==37 | statefip==13 | statefip==34 | statefip==53) & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Foreign H. undermatch model***
use "Pre Regression sample",clear
keep if bpl_foreign==1 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Mexican H. undermatch model***
use "Pre Regression sample",clear
keep if bpl==200 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo
***Hispanic H. undermatch model***
use "Pre Regression sample",clear
keep if hisp==1 & twentytwo_by_2012==1
reg hundermatched vmismatched elig elig_year* $covars metropolitan i.statefip##i.year i.occ_category [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using hundermatch_eligyear_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019 ) ///
order(vmismatched hundermatched hovermatched elig elig_year2009 elig_year2010 elig_year2012 elig_year2013 elig_year2014 elig_year2015 elig_year2016 elig_year2017 elig_year2018 elig_year2019) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility, by demographic consisting of those 22 years old by 2012, on Hundermatch (Eligible x Year)") ///
mlabel("Complete Hundermatch" "Top 10 states Hundermatch"  "Foreign Hundermatch" "Mexican Hundermatch" "Hispanic Hundermatch" ) ///
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
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear

**************************Occupations of eligible Wage Table********************	
clear matrix
set more off
eststo clear
***Management, Business, and Financial Occ WAGE MODEL***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
keep if occ_category==1
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo		

***Education, Legal, Community Service, Ar WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==3
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Computer, Engineering, and Science Occu WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==2
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Healthcare Practitioners and Technical WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==4
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo			

***Office and Administrative Support Occup WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==7
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	

***Sales and Related Occupations WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==6
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Service Occupations WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==5
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Transportation and Material Moving Occu WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==12
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Production Occupations WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==11
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Construction and Extraction Occupations WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==9
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Installation, Maintenance, and Repair O WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==10
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo

***Farming, Fishing, and Forestry Occupati WAGE MODEL***
use "Pre Regression sample",clear
keep if occ_category==8
reg ln_adj vmismatched hundermatched hovermatched elig elig_post $covars metropolitan i.occ_category i.statefip##i.year [pweight=perwt], r cl(statefip)
estadd ysumm
eststo	
	
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures"
esttab using occ_subsamples_regressions.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_post) ///
order(vmismatched hundermatched hovermatched elig elig_post) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA eligibility (top occupations) on Wage") ///
mlabel("Management, Business, and Financial Occ" "Education, Legal, Community Service, Ar" "Computer, Engineering, and Science Occu" "Healthcare Practitioners and Technical" "Office and Administrative Support Occup" "Sales and Related Occupations" "Service Occupations" "Transportation and Material Moving Occu" "Production Occupations" "Construction and Extraction Occupations" "Installation, Maintenance, and Repair O" "Farming, Fishing, and Forestry Occupati") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, race/ethnicity, metropolitan residence, occupational category," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"STEM degree indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state. Li and Lu found that nativity and" ///
	"foreign credentials explained much of a worker's likelihood to be mismatched, potentially" ///
	"explaining the lack of statistical significance of covariates.")		
**************************Degree fields of eligible Wage Table********************	
	

clear matrix
set more off
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Pre Regression sample",clear
						 