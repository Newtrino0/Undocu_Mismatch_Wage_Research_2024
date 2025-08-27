global data "G:/Shared drives/Undocu Research/Data"	
global dofiles "G:/Shared drives/Undocu Research/Code"

*** SET CODE ***
cap log close
set more off, perm

cd "$data"
use "EO_A.dta", clear

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
use "EO_A.dta", clear
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

save "EO_Table_by_degfield.dta", replace
*************************************************************************************************************


*********Merging data frames with our sample****************************
use "EO_A.dta", clear
sort degfield
save "EO_A.dta", replace

use "EO_Table_by_degfield.dta", clear
sort degfield

merge 1:m degfield using "EO_A.dta"
drop _merge

save "EO_B.dta", replace

**2nd merge: by degfieldd**
use "EO_Table_by_occ.dta", clear
sort occ

merge 1:m occ using "EO_B.dta"
drop _merge

save "EO_B.dta", replace

**Check why some states and years did not have a name match
import delimited "IPC Final Full Data 2024 Update.csv", clear 

gen statefip = 1 if state == "Alabama"
replace statefip = 2 if state == "Alaska"
replace statefip = 4 if state == "Arizona"
replace statefip = 5 if state == "Arkansas"
replace statefip = 6 if state == "California"
replace statefip = 8 if state == "Colorado"
replace statefip = 9 if state == "Connecticut"
replace statefip = 10 if state == "Delaware"
replace statefip = 11 if state == "DC"
replace statefip = 12 if state == "Florida"
replace statefip = 13 if state == "Georgia"
replace statefip = 15 if state == "Hawaii"
replace statefip = 16 if state == "Idaho"
replace statefip = 17 if state == "Illinois"
replace statefip = 18 if state == "Indiana"
replace statefip = 19 if state == "Iowa"
replace statefip = 20 if state == "Kansas"
replace statefip = 21 if state == "Kentucky"
replace statefip = 22 if state == "Louisiana"
replace statefip = 23 if state == "Maine"
replace statefip = 24 if state == "Maryland"
replace statefip = 25 if state == "Massachusetts"
replace statefip = 26 if state == "Michigan"
replace statefip = 27 if state == "Minnesota"
replace statefip = 28 if state == "Mississippi"
replace statefip = 29 if state == "Missouri"
replace statefip = 30 if state == "Montana"
replace statefip = 31 if state == "Nebraska"
replace statefip = 32 if state == "Nevada"
replace statefip = 33 if state == "New Hampshire"
replace statefip = 34 if state == "New Jersey"
replace statefip = 35 if state == "New Mexico"
replace statefip = 36 if state == "New York"
replace statefip = 37 if state == "North Carolina"
replace statefip = 38 if state == "North Dakota"
replace statefip = 39 if state == "Ohio"
replace statefip = 40 if state == "Oklahoma"
replace statefip = 41 if state == "Oregon"
replace statefip = 42 if state == "Pennsylvania"
replace statefip = 44 if state == "Rhode Island"
replace statefip = 45 if state == "South Carolina"
replace statefip = 46 if state == "South Dakota"
replace statefip = 47 if state == "Tennessee"
replace statefip = 48 if state == "Texas"
replace statefip = 49 if state == "Utah"
replace statefip = 50 if state == "Vermont"
replace statefip = 51 if state == "Virginia"
replace statefip = 53 if state == "Washington"
replace statefip = 54 if state == "West Virginia"
replace statefip = 55 if state == "Wisconsin"
replace statefip = 56 if state == "Wyoming"
replace statefip = 61 if state == "Maine-New Hampshire-Vermont"
replace statefip = 62 if state == "Massachusetts-Rhode Island"
replace statefip = 63 if state == "Minnesota-Iowa-Missouri-Kansas-Nebraska-S. Dakota-N. Dakota"
replace statefip = 64 if state == "Maryland-Delaware"
replace statefip = 65 if state == "Montana-Idaho-Wyoming"
replace statefip = 66 if state == "Utah-Nevada"
replace statefip = 67 if state == "Arizona-New Mexico"
replace statefip = 68 if state == "Alaska-Hawaii"
replace statefip = 72 if state == "Puerto Rico"
replace statefip = 97 if state == "Overseas Military Installations"
replace statefip = 99 if state == "State not identified"

save "IPC Final Full Data 2024 Update.dta", replace
use "IPC Final Full Data 2024 Update.dta", clear


/*
replace pub_insurance_immigrant_kids = pub_insurance_immigrant_kids + 1
replace prenatal_care_pregnant_immigrant = prenatal_care_pregnant_immigrant + 1
replace pub_insurance_pregnant_immigrant = pub_insurance_pregnant_immigrant + 1
replace pub_insurance_immigrant_older_ad = pub_insurance_immigrant_older_ad + 1
replace food_assistance_for_lpr_adults = food_assistance_for_lpr_adults + 1
replace tuition_equity = tuition_equity + 1
replace financial_aid = financial_aid + 1
replace blocks_enrollment = blocks_enrollment + 1
replace professional_licensure = professional_licensure + 1
replace drivers_license = drivers_license + 1
replace secure_communities_participated = 0 if secure_communities=="NA"
replace secure_communities_participated = 0 if secure_communities=="-1"
replace secure_communities_participated = 1 if secure_communities=="0"
replace secure_communities_participated = 2 if secure_communities=="1"
replace omnibus = omnibus + 1
replace cooperation_federal_immigration = cooperation_federal_immigration + 1
replace e_verify = e_verify + 1
save "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\IPC Final Full Data 2024 Update.dta", replace
*/ 


sort statefip

merge 1:m statefip year using "EO_B.dta", keep(match)
drop _merge

save "EO_B.dta", replace