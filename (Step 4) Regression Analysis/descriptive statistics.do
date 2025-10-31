
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

