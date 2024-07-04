*** SET DIRECTORIES
global dofiles "C:\Users\XCITE-admin\Documents\GitHub\Stata_Work\MSRIP Data prep"

/*global figures /disk/homedirs/nber/ekuka/DACA/Replication/figures
global tables /disk/homedirs/nber/ekuka/DACA/Replication/tables
*/
global rawdata "C:\Users\XCITE-admin\Documents\Local_XCITE_MSRIP"
*global prepdata "C:\Users\mario\Documents\Local_Mario_MSRIP\data\Replication\prepdata"

*** SET CODE
cap log close
set more off, perm

/*log using $dofiles/clean_data.log, replace
cd $dofiles/ */


					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

******************************
*** READ DATA
******************************
cd $rawdata
use "usa_00011.dta", clear
*cd $dofiles/
describe

*sample: people aged 20-44 who are US born workers




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

*educational attainment requirements for an occupation
*create a categorical variable of the educational attainment categories

gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12


keep edu_cat occ yrsed degfield


sort occ edu_cat 

by occ edu_cat: gen count=_N
by occ : gen total=_N

gen proportion=count/total

by occ: egen median_yrs= median(yrsed)

*collapse the data by occ code, keep (or construct when you collapse) the median yrs of education for the occ, the most frequent degfield



*college degree requirements for an occupation



sort occ degfield

by occ degfield: gen count2=_N

*Table of occupations, and the average years of education for that occupation
table occ, stat(freq) stat(mean yrsed)

*filter for largest two values by occ
gen meanyrs = mean(yrsed), by(occ)

egen medyrs = median(yrsed), by(occ)

egen moded = mode(edu_cat), by(occ) missing maxmode

egen tag = tag(occ), missing

sort occ

list occ meanyrs medyrs moded if tag, sepby(occ) noobs

*collapse so that there is one row per occupational code


*merge this information back to the Shih sample by occ
