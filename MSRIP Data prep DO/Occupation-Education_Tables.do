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
use "usa_00015.dta", clear
describe

********* Clean data ***********
replace occ=. if occ==0
drop if missing(occ)

replace degfield =0 if degfield==.

drop if incwage == 999999
drop if bpl >=100
drop if empstat !=1
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People born in the US (excluding US territories like Puerto Rico)
4.) People who are employed

*/


					 ***********************************************
************************ STEP 2: Create relevant variables (VERTICAL MISMATCH) ************************
					 ***********************************************
*** Years of Education
gen yrsed = 0 if educd==2 | educd==11 | educd==12 			// 0 ed
replace yrsed = 2 if educd==10 									// nursery to grade 4
replace yrsed = 2.5 if educd==13 								// 1-4
replace yrsed = 1 if educd==14 									// 1
replace yrsed = 2 if educd==15 									// 2
replace yrsed = 3 if educd==16 									// 3
replace yrsed = 4 if educd==17 									// 4
replace yrsed = 6.5 if educd==20 								// 5-8
replace yrsed = 5.5 if educd==21 								// 5-6
replace yrsed = 5 if educd==22 									// 5
replace yrsed = 6 if educd==23 									// 6
replace yrsed = 7.5 if educd==24 								// 7-8
replace yrsed = 7 if educd==25 									// 7
replace yrsed = 8 if educd==26 									// 8
replace yrsed = 9 if educd==30 									// 9
replace yrsed = 10 if educd==40 									// 10
replace yrsed = 11 if educd==50 									// 11
replace yrsed = 12 if educd==60 | educd==61 | educd==62 | educd==63 | educd==64
replace yrsed = 12.5 if educd==65 								// less than a year of college
replace yrsed = 13 if educd==70 | educd==71 					// 13
replace yrsed = 14 if educd==80 | educd==81 | educd==82 | educd==83 // 14
replace yrsed = 15 if educd==90 									// 15
replace yrsed = 16 if educd==100 | educd==101 				// 16
replace yrsed = 17 if educd==110 								// 17
replace yrsed = 18 if educd==111 | educd==114 				// 18
replace yrsed = 19 if educd==112 | educd==115 				// 19
replace yrsed = 21 if educd==116 								// 21
label var yrsed "Years of Education"

*Remove empty fields for occupation denoted by a 0, and empty fields for yrsed denoted by 0 and 999
replace yrsed=. if yrsed==1 | yrsed==999
drop if missing(yrsed)
					 
***********Educational attainment category variable, requirements for an occupation***************
*create a categorical variable of the educational attainment categories
gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12

gen edu_att = 4 if educd>=101
replace edu_att = 3 if educd<101
replace edu_att = 2 if educd<65
replace edu_att = 1 if educd<62

sort occ edu_cat

by occ edu_cat : gen count=_N
by occ : gen total=_N
gen proportion=count/total

by occ: egen mode_cat = mode(edu_cat)
by occ: egen mode_att = mode(edu_att)

keep occ yrsed degfield incwage mode_cat mode_att
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

replace degfield=9999 if degfield==0

by occ: egen mode1_deg = mode(degfield) if degfield!=9999, maxmode missing
by occ: egen mode2_deg = mode(degfield) if degfield!=mode1_deg & degfield!=9999, maxmode missing
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
collapse (median)med_yrs_by_occ=yrsed (mean)mode1_deg (mean)mode2_deg (median)med_wage_by_occ=incwage (mean)mode_att, by(occ)
*merge this information back to the Shih sample by occ
