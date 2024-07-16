global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"
cd $rawdata

use eo_degfield_merged.dta, clear
sort occ
save eo_degfield_merged.dta, replace

use eo_table_by_occ.dta, clear
sort occ

merge 1:m occ using eo_degfield_merged.dta

drop _merge
**Dropping many variables for smoother code**
drop mode1_occ mode2_occ degfield degfield2 degfieldd degfield2d occ
drop if incwage==0


sort occS incwage

gen hmatched = 1 if degfieldS==mode1_degS | degfieldS==mode2_degS

*Generates needed wage but only attaches to hmatched observations
by occS: egen med_wage_hmatched_occ = median(incwage) if degfieldS == mode1_degS | degfieldS == mode2_degS
*Next line of code extends the med_wage to other observations with the same occ
egen med_wage_occ_hmatched = mean(med_wage_hmatched_occ), by (occS)

drop med_wage_hmatched_occ
*Still missing med_wage_occ_hmatched due to missing mode1&mode2 degfields

