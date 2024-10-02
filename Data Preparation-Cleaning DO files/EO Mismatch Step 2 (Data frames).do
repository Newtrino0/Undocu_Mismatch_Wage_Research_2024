global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"

*** SET CODE ***
cap log close
set more off, perm

cd $rawdata
use "EO_Step_1.dta", clear

/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People born in the US (excluding US territories like Puerto Rico)
4.) People who are employed

*/

********* Observe only U.S. born sample (excluding those not in main territory)***********
drop if bpl >=100
******************************************************************************************

					*******************************************************************
************************ Data frame 1: EO Summary Statistics Tables, by occuption ************************
					*******************************************************************
sort occ edu_cat
by occ: egen mode_cat = mode(edu_cat)
sort occ edu_att
by occ: egen mode_att = mode(edu_att)
keep occ yrsed degfield degfieldd incwage mode_cat mode_att adj_hourly

sort occ degfield
by occ: egen namode1_deg = mode(degfield), maxmode missing
by occ: egen namode2_deg = mode(degfield) if degfield!=namode1_deg, maxmode missing
by occ: egen namode1_degd = mode(degfieldd), maxmode missing
by occ: egen namode2_degd = mode(degfieldd) if degfieldd!=namode1_degd, maxmode missing
*Keeping workers that have matched degfield for occ


*collapse so that there is one row per occupational code
collapse (median)med_yrs_by_occ=yrsed (mean)namode1_deg (mean)namode2_deg (mean)namode1_degd (mean)namode2_degd (median)med_wage_by_occ=incwage (median)med_hourly_occ=adj_hourly (mean)mode_att, by(occ)
*merge this information back to the Shih sample by occ

save "EO_Table_by_occ.dta",replace
************************************************************************************************************


********* Observe only U.S. born sample (excluding those not in main territory)***********
use "EO_Step_1.dta", clear
drop if bpl >=100
keep occ yrsed degfield incwage adj_hourly
******************************************************************************************
					*******************************************************************
************************ Data frame 2: EO Summary Statistics Tables, by degree field ************************
					*******************************************************************
sort degfield occ
by degfield: egen mode1_occ = mode(occ) if occ!=0, maxmode missing
by degfield: egen mode2_occ = mode(occ) if occ!=mode1_occ & occ!=0, maxmode missing
					
collapse (median)med_yrs=yrsed (mean)mode1_occ (mean)mode2_occ (median)med_wage_by_degfield=incwage (median)med_hourly_degfield=adj_hourly, by(degfield)
drop med_yrs

save "EO_Table_by_degfield".dta, replace
*************************************************************************************************************


********* Observe only U.S. born sample (excluding those not in main territory)***********
use "EO_Step_1.dta".dta, clear
sort degfield
save "EO_Step_1.dta", replace

use "EO_Table_by_degfield".dta, clear
sort degfield

merge 1:m degfield using "EO_Step_1.dta"
drop _merge

save "EO_Step_2.dta", replace

**2nd merge: by degfieldd**
use "EO_Table_by_occ", clear
sort occ

merge 1:m occ using "EO_Step_2.dta"
drop _merge

save "EO_Step_2.dta", replace
******************************************************************************************




