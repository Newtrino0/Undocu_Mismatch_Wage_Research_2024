*** SET DIRECTORIES
global dofiles "C:\Users\XCITE-admin\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

/*global figures /disk/homedirs/nber/ekuka/DACA/Replication/figures
global tables /disk/homedirs/nber/ekuka/DACA/Replication/tables
*/
global rawdata "C:\Users\XCITE-admin\Documents\Local_XCITE_MSRIP\MSRIP_Data"
*global prepdata "C:\Users\mario\Documents\Local_Mario_MSRIP\data\Replication\prepdata"

*** SET CODE
cap log close
set more off, perm

*ssc install hsmode

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

replace degfield =0 if degfield==.
gen degfieldS = string(degfield)

**Run this after edits are made since makes the runs longer**
/*
replace degfieldS = "N/A" if degfieldS ==	"0"
replace degfieldS = "Agriculture" if degfieldS ==	"11"
replace degfieldS = "Environment and Natural Resources" if degfieldS ==	"13"
replace degfieldS = "Architecture" if degfieldS ==	"14"
replace degfieldS = "Area, Ethnic, and Civilization Studies" if degfieldS ==	"15"
replace degfieldS = "Communications" if degfieldS ==	"19"
replace degfieldS = "Communication Technologies" if degfieldS ==	"20"
replace degfieldS = "Computer and Information Sciences" if degfieldS ==	"21"
replace degfieldS = "Cosmetology Services and Culinary Arts" if degfieldS ==	"22"
replace degfieldS = "Education Administration and Teaching" if degfieldS ==	"23"
replace degfieldS = "Engineering" if degfieldS ==	"24"
replace degfieldS = "Engineering Technologies" if degfieldS ==	"25"
replace degfieldS = "Linguistics and Foreign Languages" if degfieldS ==	"26"
replace degfieldS = "Family and Consumer Sciences" if degfieldS ==	"29"
replace degfieldS = "Law" if degfieldS ==	"32"
replace degfieldS = "English Language, Literature, and Composition" if degfieldS ==	"33"
replace degfieldS = "Liberal Arts and Humanities" if degfieldS ==	"34"
replace degfieldS = "Library Science" if degfieldS ==	"35"
replace degfieldS = "Biology and Life Sciences" if degfieldS ==	"36"
replace degfieldS = "Mathematics and Statistics" if degfieldS ==	"37"
replace degfieldS = "Military Technologies" if degfieldS ==	"38"
replace degfieldS = "Interdisciplinary and Multi-Disciplinary Studies (General)" if degfieldS ==	"40"
replace degfieldS = "Physical Fitness, Parks, Recreation, and Leisure" if degfieldS ==	"41"
replace degfieldS = "Philosophy and Religious Studies" if degfieldS ==	"48"
replace degfieldS = "Theology and Religious Vocations" if degfieldS ==	"49"
replace degfieldS = "Physical Sciences" if degfieldS ==	"50"
replace degfieldS = "Nuclear, Industrial Radiology, and Biological Technologies" if degfieldS ==	"51"
replace degfieldS = "Psychology" if degfieldS ==	"52"
replace degfieldS = "Criminal Justice and Fire Protection" if degfieldS ==	"53"
replace degfieldS = "Public Affairs, Policy, and Social Work" if degfieldS ==	"54"
replace degfieldS = "Social Sciences" if degfieldS ==	"55"
replace degfieldS = "Construction Services" if degfieldS ==	"56"
replace degfieldS = "Electrical and Mechanic Repairs and Technologies" if degfieldS ==	"57"
replace degfieldS = "Precision Production and Industrial Arts" if degfieldS ==	"58"
replace degfieldS = "Transportation Sciences and Technologies" if degfieldS ==	"59"
replace degfieldS = "Fine Arts" if degfieldS ==	"60"
replace degfieldS = "Medical and Health Sciences and Services" if degfieldS ==	"61"
replace degfieldS = "Business" if degfieldS ==	"62"
replace degfieldS = "History" if degfieldS ==	"64"
*/

*Remove empty fields for occupation denoted by a 0, and empty fields for yrsed denoted by 0 and 999
replace occ=. if occ==0
drop if missing(occ)

replace yrsed=. if yrsed==1 | yrsed==999
drop if missing(yrsed)

					 ***********************************************
************************ STEP 2: Create relevant variables ************************
					 ***********************************************
					 
***Educational attainment category variable, requirements for an occupation***
*create a categorical variable of the educational attainment categories
gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12

gen edu_att = "College Diploma" if educd>=101
replace edu_att = "HS Diploma and some college" if educd<101
replace edu_att = "HS Diploma" if educd<65
replace edu_att = "No HS Diploma" if educd<62

keep edu_cat edu_att occ yrsed degfield degfieldS


sort occ edu_cat 

by occ edu_cat : gen count=_N
by occ : gen total=_N
gen proportion=count/total

*collapse the data by occ code, keep (or construct when you collapse) the median yrs of education for the occ, the most frequent degfield
table occ, stat(freq) stat(median yrsed)


*college degree requirements for an occupation

sort occ degfieldS

by occ degfieldS: gen count2=_N



*filter for largest two values by occ

*finding mode of degfield
/*
egen mod_degS = mode(degfieldS), by(occ) missing maxmode
egen med_yrs = median(yrsed), by(occ)
*/


*collapse so that there is one row per occupational code
*collapse (median)yrsed, by(occ)

* Subset the data for the specific group

by occ: egen mode_deg = mode(degfield)
*collapse (median)yrsed mode_deg, by(occ)
list




*merge this information back to the Shih sample by occ
