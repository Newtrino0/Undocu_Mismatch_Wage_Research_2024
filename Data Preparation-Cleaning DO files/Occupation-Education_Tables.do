*** SET DIRECTORIES
**Copy and paste the following User tags
*XCITE-admin
*mario

global dofiles "C:\Users\mario\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"

*** SET CODE
cap log close
set more off, perm

					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

******************************
*** READ DATA
******************************
*sample: people aged 20-44 who are US born workers
cd $rawdata
use "shih_prepped.dta", clear
describe

********* Clean data ***********
drop if bpl >=100
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People born in the US (excluding US territories like Puerto Rico)
4.) People who are employed

*/


					 ***********************************************
************************ STEP 2: Create attainment by occupation ************************
					 ***********************************************
gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12

sort occ edu_cat
by occ: egen mode_cat = mode(edu_cat)
sort occ edu_att
by occ: egen mode_att = mode(edu_att)

keep occ yrsed degfield degfieldd incwage mode_cat mode_att
***************************************************************************************************

*collapse the data by occ code, keep (or construct when you collapse) the median yrs of education for the occ, the most frequent degfield
*college degree requirements for an occupation





*filter for largest two values by occ
* Subset the data for the specific group

					 ***********************************************
************************ STEP 2: Create relevant variables (HORIZONTAL MISMATCH) ************************
					 ***********************************************
*egen method*
sort occ degfield
by occ: egen mode1_deg = mode(degfield) if degfield!=9999, maxmode missing
by occ: egen mode2_deg = mode(degfield) if degfield!=9999 & degfield!=mode1_deg, maxmode missing
by occ: egen mode1_degd = mode(degfieldd) if degfieldd!=9999, maxmode missing
by occ: egen mode2_degd = mode(degfieldd) if degfieldd!=9999 & degfieldd!=mode1_degd, maxmode missing
*Keeping workers that have matched degfield for occ

*Count method*
/*
local v = 1
while `v' <= 2 {
    by occ degfield, sort: gen `count' = _N
	egen `max_count' = max(`count')
    local ++v
}
foreach newlist count01-count02 {
	by occ degfield, sort: gen `count' = _N
	egen `max_count' = max(`count')
}

*Correctly counts number of occurences of degfield for each occ
by occ degfield, sort: gen count2=_N
*Creates column with max value of count2
egen max_count2 = max(count2)
*Correctly tabulates frequencies of degfield for occ
list occ degfield count2 max_count2
*/



*collapse so that there is one row per occupational code
collapse (median)med_yrs_by_occ=yrsed (mean)mode1_deg (mean)mode2_deg (mean)mode1_degd (mean)mode2_degd (median)med_wage_by_occ=incwage (mean)mode_att, by(occ)
*merge this information back to the Shih sample by occ