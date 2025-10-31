	
********************************************************************************
**************** DACA Individual Mismatch regressions (ML) *********************
********************************************************************************
// Vertical Mismatch 
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
	
