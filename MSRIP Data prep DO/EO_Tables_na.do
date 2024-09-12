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
by occ: egen namode1_deg = mode(degfield), maxmode missing
by occ: egen namode2_deg = mode(degfield) if degfield!=namode1_deg, maxmode missing
by occ: egen namode1_degd = mode(degfieldd), maxmode missing
by occ: egen namode2_degd = mode(degfieldd) if degfieldd!=namode1_degd, maxmode missing
*Keeping workers that have matched degfield for occ


*collapse so that there is one row per occupational code
collapse (median)med_yrs_by_occ=yrsed (mean)namode1_deg (mean)namode2_deg (mean)namode1_degd (mean)namode2_degd (median)med_wage_by_occ=incwage (mean)mode_att, by(occ)
*merge this information back to the Shih sample by occ
