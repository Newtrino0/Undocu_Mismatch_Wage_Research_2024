ssc install outreg2
ssc install tabout
ssc install estout
ssc install groups
global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"


cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"

use "(Undocu)EO_Final_Sample", clear

*Before tables creation*


***Top 10 occ by # of DACA eligible, then sorted by mismatch***
sort occ
keep if undocu==1

collapse (median)hmismatch_rate_occ=hmproportion (median)hunderproportion (median)hoverproportion (median)vmean_occ_yrs (median)vmismatched_att (median)undocu_occ_count, by(occ)
gsort -undocu_occ_count
keep if undocu_occ_count > 85
gsort -hmismatch_rate_occ
save ten_occ_undocu_table.dta, replace


***Top 10 deg, then sorted by mismatch
use "(Undocu)EO_Final_Sample", clear
sort degfield
keep if undocu==1

collapse (median)hmismatch_rate_deg=hmproportion_deg (median)hunderproportion_deg (median)hoverproportion_deg (median)vmean_deg_yrs (mean)vmismatched_att (median)undocu_deg_count, by(degfield)
gsort -undocu_deg_count
keep if undocu_deg_count > 172
gsort -hmismatch_rate_deg
save ten_deg_undocu_table.dta, replace
