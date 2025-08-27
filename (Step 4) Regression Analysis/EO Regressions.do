clear matrix
clear
set more off
// Install packages once
/*
ssc install coefplot, replace
ssc estout
*/

// Set paths/directories here
global data "G:/Shared drives/Undocu Research/Data"
global dofiles "G:/Shared drives/Undocu Research/Code"
global figures "G:/Shared drives/Undocu Research/Output/Figures"
global tables "G:/Shared drives/Undocu Research/Output/Tables"

cd "$data"
use "EO_Final", clear

xtset statefip
// Different than vs version
global covars i.age hisp male gov_worker immig_by_ten nonfluent yrsed i.degfield_broader metropolitan medicaid
global individual_ipc b1.pub_insurance_immigrant_kids 	b1.prenatal_care_pregnant_immigrant 	b1.pub_insurance_pregnant_immigrant 	b1.pub_insurance_immigrant_older_ad 	b1.food_assistance_for_lpr_adults 	b1.tuition_equity 	b1.financial_aid 	b1.blocks_enrollment 	b1.professional_licensure 	b1.drivers_license	b1.omnibus 	b1.cooperation_federal_immigration 	b1.e_verify b1.secure_communities_participated

********************************************************************************
*************************** (ACS) Descriptive Table ****************************
********************************************************************************
eststo clear
cd "$data"
use "EO_Final",clear
cd "$tables"


eststo: estpost tabstat age fem vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj white black asian hisp if bpl_foreign==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj white black asian hisp if undocu==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj white black asian hisp if elig==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj white black asian hisp if undocu_knn==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem vmismatched hmismatched hundermatched hovermatched nonfluent stem_deg adj_hourly ln_adj white black asian hisp if undocu_rf==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
esttab est* using dTable_status_ml.tex, replace label main(mean) aux(sd) title("ACS U.S. born workers and Undocumented immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Foreign-born" "Undocumented (Logical edits)" "DACA-eligible" "Undocumented (KNN)" "Undocumented (RF)") note("Note: Log wage is adjusted for inflation with CPI values starting January 2009, every year in January until January 2019.")

********************************************************************************
*********************** (SIPP) Descriptive Table *******************************
********************************************************************************
clear
eststo clear
cd "$data"
import delimited "SIPP_dTable.csv", clear 



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

cd "$tables"
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16, statistics(mean sd) columns(statistics)
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & undocu_likely==1, statistics(mean sd) columns(statistics)   
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & sipp_knn==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat age fem married nonfluent  household_size poverty asian black white other_race bpl_asia central_latino spanish_hispanic_latino  employed years_us yrsed undocu_likely if yrsed>=16 & sipp_rf==1, statistics(mean sd) columns(statistics) 
esttab est* using dTable_SIPP_ml.tex, replace label main(mean) aux(sd) title("SIPP Summary Statistics of Undocumented Imputation Methods \label{tab:sum}") unstack mlabels("Undocumented (Logical edits)" "Undocumented (Actual)" "Undocumented (KNN)" "Undocumented (RF)")


*Add bar graphs (for mismatch across majors), coefficient plots*
**(IN PROGRESS)Start writing, add IPC table last
**(IN PROGRESS)Conduct literature review (Van Hook, Stimpson, )
**Rename interaction effects, do for hunder, hmismatch, wage what was done on vmismatch on individual labor policies
**Plop in Dr. Sovero's code**

********************************************************************************
***************** Undocumented Individual Mismatch regressions *****************
********************************************************************************
// Vertical Mismatch figure
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "$data"
use "EO_Final",clear

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

cd "$figures"
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
	

// Horizontal Mismatch figure
clear matrix
set more off
eststo clear

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
	

// Horizontal Undermatch figure
clear matrix
set more off
eststo clear

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
	
	
********************************************************************************
**************** DACA Individual Mismatch regressions (ML) *********************
********************************************************************************
// Vertical Mismatch figure
clear matrix
set more off
eststo clear
***Vertical mismatch model***
cd "$data"
use "EO_Final",clear

***Logical edits V. mismatch model***
reg vmismatched hundermatched hovermatched elig $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN V. mismatch model***
reg vmismatched hundermatched hovermatched elig_knn $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***RF V. mismatch model***
reg vmismatched hundermatched hovermatched elig_rf $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

cd "$figures"
esttab using daca_vmismatch_regressions_ml.tex, replace label booktabs keep(hundermatched hovermatched elig elig_knn elig_rf ) ///
order(hundermatched hovermatched elig elig_knn elig_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA-eligible Status on Vmismatch") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")						
	

/*	
clear matrix
set more off
eststo clear
***Horizontal mismatch model***
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "(ML) Pre Regression sample",clear
***Logical edits H. mismatch model***
reg hmismatched vmismatched elig inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN H. mismatch model***
reg hmismatched vmismatched elig_knn inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***RF H. mismatch model***
reg hmismatched vmismatched elig_rf inclusive exclusive  $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

cd "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Undocu Research Figures ML"
esttab using daca_hmismatch_regressions_ml.tex, replace label booktabs keep(vmismatched elig elig_knn elig_rf ) ///
order(vmismatched elig elig_knn elig_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA-eligible Status on Hmismatch") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")			
*/	
	
// Horizontal Mismatch figure
***Horizontal undermatch model***
clear matrix
set more off
eststo clear

***Logical edits H. undermatch model***
reg hundermatched vmismatched elig $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***KNN H. undermatch model***
reg hundermatched vmismatched elig_knn $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
***RF H. undermatch model***
reg hundermatched vmismatched elig_rf $covars  i.statefip##i.year  [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

esttab using daca_hundermatch_regressions_ml.tex, replace label booktabs keep(vmismatched elig elig_knn elig_rf ) ///
order(vmismatched elig elig_knn elig_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA-eligible Status on H. undermatch") ///
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
***Logical edits column***
reg ln_adj vmismatched hundermatched hovermatched elig $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo 
**KNN column***
reg ln_adj vmismatched hundermatched hovermatched elig_knn $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
**RF column***
reg ln_adj vmismatched hundermatched hovermatched elig_rf  $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo

esttab using daca_wage_regressions_ml.tex, replace label booktabs keep(vmismatched hundermatched hovermatched elig elig_knn elig_rf ) ///
order(vmismatched hundermatched hovermatched elig elig_knn elig_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of DACA-eligible Status on Log-Wage") ///
mlabel("Logical edits" "KNN" "RF") ///
r2(4) b(4) se(4) brackets star(* .1 ** 0.05 *** 0.01) ///
note("Additional controls include:") ///
addn("dummy age indicators, gender, Medicaid reception, race/ethnicity, metropolitan residence," /// 
	"government occupation, English-speaking fluency, foreign born, immigration by age 10," ///
	"Broad degree category indicators, years of schooling, state and year interaction fixed effects." ///
	"Robust standard errors are all clustered by state.")			
	
	
**Coefficient Plots****
/* 
*vertical mismatch
coefplot (logical_vmismatch, label(Logical Edits) ) (knn_vmismatch, label(KNN) ) (rf_vmismatch, label(Random Forest) ) ///
 ||, drop($covars hundermatched hovermatched )  xline(0)   ///
rename(elig_rf = "DACA-eligible" elig= "DACA-eligible" elig_knn= "DACA-eligible") ///
 xline(0) title("Vertical Mismatch")
  graph save elig_ipc_vmismatch, replace

 
 *horizontal undermatch
coefplot (logical_hunder, label(Logical Edits) ) (knn_hunder, label(KNN) ) (rf_hunder, label(Random Forest) ) ///
 ||, drop($covars vmismatched)  xline(0)   ///
rename(elig_rf = "DACA-eligible" elig= "DACA-eligible" elig_knn= "DACA-eligible") ///
 xline(0) title("Horizontal Undermatch")
   graph save elig_ipc_hunder, replace

 *wages
coefplot (logical_wage, label(Logical Edits) ) (knn_wage, label(KNN) ) (rf_wage, label(Random Forest)) ///
||, drop($covars vmismatched hundermatched hovermatched)  xline(0)   ///
rename(elig_rf = "DACA-eligible" elig= "DACA-eligible" elig_knn= "DACA-eligible") ///
 xline(0) title("Log Wage")
   graph save elig_ipc_wage, replace

*all together
coefplot (logical_vmismatch, label(Logical Edits) ) (knn_vmismatch, label(KNN) ) (rf_vmismatch, label(Random Forest) ), bylabel(Vertical Mismatch)  ///
||  (logical_hunder, label(Logical Edits) ) (knn_hunder, label(KNN) ) (rf_hunder, label(Random Forest) ), bylabel(Horizontal Undermatch) ///
||  (logical_wage, label(Logical Edits) ) (knn_wage, label(KNN) ) (rf_wage, label(Random Forest)), bylabel(Log Wage) ///
||, drop($covars vmismatched hundermatched hovermatched)  xline(0)  ///
rename(elig_rf = "DACA-eligible" elig= "DACA-eligible" elig_knn= "DACA-eligible") 
graph export elig_ipc_coeff.png, replace			
	
*/
	

**********************************************************************************	
****************Wage models with demographic columns/samples**************************
**************************************************************************************
clear matrix
set more off
eststo clear
// Wage figure
cd "$data"
use "EO_Final",clear

***Logical edits column***
reg ln_adj vmismatched hundermatched hovermatched undocu inclusive exclusive  $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm 
eststo
**KNN column***
reg ln_adj vmismatched hundermatched hovermatched undocu_knn inclusive exclusive  $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo
**RF column***
reg ln_adj vmismatched hundermatched hovermatched undocu_rf inclusive exclusive  $covars   i.statefip##i.year [pweight=perwt] if year >= 2013, r cl(statefip)
estadd ysumm
eststo


cd "$figures"
esttab using wage_regressions_ml.tex, replace label booktabs keep(vmismatched hundermatched hovermatched undocu undocu_knn undocu_rf ) ///
order(vmismatched hundermatched hovermatched undocu undocu_knn undocu_rf ) ///
stats( ymean r2 N  , labels(  "Mean of Dep. Var." "R-squared" N ) fmt(    %9.2f %9.2f %9.0fc ) ) ///
title("Regressions of Undocumented Status on Log-Wage") ///
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


	
