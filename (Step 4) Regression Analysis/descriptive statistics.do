clear
eststo clear



global drive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu" //update this line with your folder 

cd "$drive/Shared drives/Undocu Research"
use "Data/EO_final.dta", clear

gen degree=degfield_broader
tab degfield_broader, gen(deg_cat)

label var deg_cat1 "STEM Major"
label var deg_cat2 "STEM Related Major"
label var deg_cat3 "Business Major"
label var deg_cat4 "Education Major"
label var deg_cat5 "Other Major"

global vars hisp white black asian  fem age   married nonfluent yrsusa1 deg_cat*

********************************************************************************
*********************** (ACS) P Quartiles Descriptive Table *******************************
********************************************************************************
eststo clear
eststo: estpost tabstat $vars if gbm_undocu_q== "Q1", statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_undocu_q== "Q2", statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_undocu_q== "Q3", statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_undocu_q=="Q4", statistics(mean sd) columns(statistics) 
esttab est* using "Output/Tables/dTable_pquartiles.tex", replace label main(mean) aux(sd) title("ACS Summary Statistics by Probability Quartiles  \label{tab:sum}") unstack mlabels("Q1 (Low)" "Q2" "Q3" "Q4 (High)") note("Note: Probability Quartile thresholds were defined based on SIPP quartile thresholds.")

********************************************************************************
*********************** (ACS) Probability Placebo Descriptive Table *******************************
********************************************************************************
global vars   hisp white  asian black fem age nonfluent deg_cat* vmismatched hmismatched hundermatched hovermatched  adj_hourly 


eststo clear
eststo: estpost tabstat $vars , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if undocu==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_high_recall== 1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_undocu_q=="Q4", statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if gbm_undocu_q== "Q1", statistics(mean sd) columns(statistics) 

esttab est* using "Output/Tables/dTable_placebo.tex", replace label main(mean) aux(sd) ///
 title("ACS Summary Statistics  \label{tab:sum}") unstack mlabels("All" "Logical Edits"  "High Recall" "High Prob" "Low Prob") ///
note("Note: Probability Quartiles and 75 percent of positive cases thresholds were defined based on SIPP thresholds.")      ///
addnote("The high recall group was defined by taking the predicted probability threshold " ///
 "that captured 75 percent of truly undocumented workers.")

/*


********************************************************************************
*********************** (ACS) Descriptive Table *******************************
********************************************************************************
eststo: estpost tabstat $vars if bpl_foreign==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if undocu==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if elig==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if undocu_knn==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $varsif undocu_rf==1 & bpl_foreign==1, statistics(mean sd) columns(statistics) 
esttab est* using "Output/Tables/dTable_status_ml.tex", replace label main(mean) aux(sd) title("ACS U.S. born workers and Undocumented immigrants Summary Statistics \label{tab:sum}") unstack mlabels("Foreign-born" "Undocumented (Logical edits)" "DACA-eligible" "Undocumented (KNN)" "Undocumented (RF)") note("Note: Log wage is adjusted for inflation with CPI values starting January 2009, every year in January until January 2019.")




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

