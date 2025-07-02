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


gen annual_total_dummy = 0 if annual_total<0
replace annual_total_dummy = 1 if annual_total==0
replace annual_total_dummy = 2 if annual_total>0

label define annual_total_label 0 "Exclusive" 1 "Neutral" 2 "Inclusive" 
label values annual_total_dummy annual_total_label 

gen exclusive = 1 if annual_total<0
replace exclusive = 0 if annual_total>=0

gen inclusive = 1 if annual_total>0
replace inclusive = 0 if annual_total<=0


gen everify_inclusive=(e_verify==2)
gen undocu_everify=undocu*everify_inclusive
gen undocu_knn_everify=undocu_knn*everify_inclusive
gen undocu_rf_everify=undocu_rf*everify_inclusive
gen license_inclusive=(professional_licensure==2)
gen undocu_license=undocu*license_inclusive
gen undocu_knn_license=undocu_knn*license_inclusive
gen undocu_rf_license=undocu_rf*license_inclusive


gen elig_knn = (elig==1 & undocu_knn==1)
gen elig_rf = (elig==1 & undocu_rf==1)

label var undocu "Undocumented"
label var undocu_knn "Undocumented (KNN)"
label var undocu_rf "Undocumented (RF)"

label var elig "DACA-eligible"
label var elig_knn "DACA-eligible (KNN)"
label var elig_rf "DACA-eligible (RF)"

clear matrix
set more off

xtset statefip
*will be different than Dr. Sovero's code, 
global covars i.age hisp male gov_worker immig_by_ten nonfluent yrsed i.degfield_broader metropolitan medicaid
global individual_ipc b1.pub_insurance_immigrant_kids 	b1.prenatal_care_pregnant_immigrant 	b1.pub_insurance_pregnant_immigrant 	b1.pub_insurance_immigrant_older_ad 	b1.food_assistance_for_lpr_adults 	b1.tuition_equity 	b1.financial_aid 	b1.blocks_enrollment 	b1.professional_licensure 	b1.drivers_license	b1.omnibus 	b1.cooperation_federal_immigration 	b1.e_verify b1.secure_communities_participated

save "(ML) Pre Regression sample", replace



****************************************************************************************************************
********************************************************************************************************
*******************************************(SIPP) Descriptive Table********************************************
********************************************************************************************************
clear
eststo clear
import delimited "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\SIPP_dTable.csv", clear 
cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"


gen sipp_logit=0 if undocu_logit=="X0"
replace sipp_logit=1 if undocu_logit=="X1"

gen sipp_knn=0 if undocu_knn=="X0"
replace sipp_knn=1 if undocu_knn=="X1"

gen sipp_rf=0 if undocu_rf=="X0"
replace sipp_rf=1 if undocu_rf=="X1"

replace sipp_logit=0 if sipp_logit==.
replace sipp_knn=0 if sipp_knn==.
replace sipp_rf=0 if sipp_rf==.

label var undocu_likely "Undocumented (Actual)"
label var central_latino "Latino, born in Central America"

foreach var in fem bpl_foreign central_latino bpl_asia married nonfluent spanish_hispanic_latino poverty asian black white other_race employed {
 replace `var'=`var'-1
}

eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16, statistics(mean sd) columns(statistics)
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & undocu_likely==1, statistics(mean sd) columns(statistics)   
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & sipp_knn==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & sipp_rf==1, statistics(mean sd) columns(statistics) 
esttab est* using dTable_SIPP_ml.tex, replace label main(mean) aux(sd) title("SIPP Summary Statistics of Undocumented Imputation Methods \label{tab:sum}") unstack mlabels("Undocumented (Logical edits)" "Undocumented (Actual)" "Undocumented (KNN)" "Undocumented (RF)")



*Add bar graphs (for mismatch across majors), coefficient plots*

****************************************************************************************	
******************************** Undocumented Individual Mismatch regressions (ML) ************************************
****************************************************************************************
*Roselyn and arlington hotels

**(IN PROGRESS)Start writing, add IPC table last
**(DONE)RERUN TABLES 3-4 with new undocu measures
**(IN PROGRESS)Conduct literature review (Van Hook, Stimpson, )
**(DONE)UPDATES TO NOTES: Remove Li and Lu note, remove stem and replace with broad categories, no occupational categories
**(DONE)UPDATES TO LABELS: Undocu, logit, knn, rf: compact, remove undocumented from columns. Undocumented (RF) etc. to rows
**(DONE)RERUN TABLES 5-8 for DACA eligible
**(DONE)Remove by ML Methods text, clarify that is Log wages
**Rename interaction effects, do for hunder, hmismatch, wage what was done on vmismatch on individual labor policies
**Plop in Dr. Sovero's code**

**RERUN TABLES for SIPP panel data/model fix**

clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
***Logical edits V. mismatch model***
reg vmismatched hundermatched hovermatched undocu inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN V. mismatch model***
reg vmismatched hundermatched hovermatched undocu_knn inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

***RF V. mismatch model***
reg vmismatched hundermatched hovermatched undocu_rf inclusive exclusive $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using vmismatch_regressions_ml.tex, replace label booktabs keep(hundermatched hovermatched undocu undocu_knn undocu_rf ) ///
order(hundermatched hovermatched undocu undocu_knn undocu_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Vmismatch") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")		
	

	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
***Logical edits H. mismatch model***
reg hmismatched vmismatched undocu inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN H. mismatch model***
reg hmismatched vmismatched undocu_knn inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***RF H. mismatch model***
reg hmismatched vmismatched undocu_rf inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using hmismatch_regressions_ml.tex, replace label booktabs keep(vmismatched undocu undocu_knn undocu_rf ) ///
order(vmismatched undocu undocu_knn undocu_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Hmismatch") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")			
	
	
clear matrix
set more off
eststo clear
***Horizontal undermatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
***Logical edits H. undermatch model***
reg hundermatched vmismatched undocu inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN H. undermatch model***
reg hundermatched vmismatched undocu_knn inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***RF H. undermatch model***
reg hundermatched vmismatched undocu_rf inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using hundermatch_regressions_ml.tex, replace label booktabs keep(vmismatched undocu undocu_knn undocu_rf ) ///
order(vmismatched undocu undocu_knn undocu_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on H. undermatch") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")				
	