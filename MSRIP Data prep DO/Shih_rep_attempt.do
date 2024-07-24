*** SET DIRECTORIES
global dofiles "C:\Users\mario\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

/*global figures /disk/homedirs/nber/ekuka/DACA/Replication/figures
global tables /disk/homedirs/nber/ekuka/DACA/Replication/tables
*/
global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"

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
use "usa_00015.dta", clear
*cd $dofiles/
describe

********* Clean data ***********
replace occ=. if occ==0
drop if missing(occ)

replace degfield =0 if degfield==.

drop if incwage == 999999
drop if empstat !=1
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed

*/


******************************
*** EXTRACT NEEDED FAMILY INFO, THEN KEEP YOUNG ADULTS ONLY
******************************

*** Indicators for individual behaviors associated with legality
gen vet = (vetstat==2)					
	replace vet=. if vetstat==9 | vetstat==0
gen anywelfare = incwelfr>0
	replace anywelfare=. if incwelfr==99999
gen anyss = incss>0
	replace anyss=. if incss==99999
gen anyssi = incsupp>0
	replace anyssi=. if incsupp==99999
gen healthins = (hcovany==2)
replace foodstmp = foodstmp-1
label var foodstmp "Food Stamp Recipient in HH"
label var healthins "Health Insurance"

*** Aggregate them to household level
bysort serial sample year: egen hhvet = max(vet)
bysort serial sample year: egen hhwelf = max(anywelfare)
bysort serial sample year: egen hhss = max(anyss)
bysort serial sample year: egen hhssi = max(anyssi)
drop vetstat incwelfr incss incsupp vet anywelfare anyss anyssi

*** Legal if any of the above hold
egen hhlegal = rowtotal(hhvet hhwelf hhss hhssi)
tab hhlegal, m
replace hhlegal=1 if hhlegal>1 
drop hhvet hhwelf hhss hhssi 

*** Keep only our sample of 10-30 olds
sum age
keep if age>=20 & age<=43
sum age

******************************
*** CLEAN/CREATE CONTROL VARS
******************************
gen all=1

*** Demographic variables
* Race/ethnicity
gen hisp = (hispan!=0)
replace hisp=. if hispan==.
gen nonhisp = 1-hisp
drop hispan

gen white = race==1
gen black = race==2
gen asian = race==4 | race==5 | race==6
for any white black asian: replace X=0 if hisp==1
gen other = hisp!=1 & white!=1 & black!=1 & asian!=1

label var white "White"
label var black "Black"
label var asian "Asian"
label var other "Other Race"
label var hisp "Hispanic"
label var nonhisp "Non-Hispanic"

* Gender
tab sex, m
gen fem = sex==2
gen male = sex!=2
drop sex
label var fem "Female"
label var male "Male"

* Marital status
gen married = marst==1 | marst==2
label var married "Married"
drop marst

* Birthplace Indicators
gen usaborn = bpl>=100 & bpl<=120
gen bpl_mex = (bpl==200) 								// Mexico
gen bpl_othspan = (bpl>=210 & bpl<=300) 			// Central and South America
gen bpl_euraus = ((bpl>=410 & bpl<=419) | (bpl>=700 & bpl<=710) ) | (bpl>450 & bpl<=499) 	// UK and Ireland; Australia, NZ, and Pac Islands; Europe
gen bpl_asia = (bpl>=500 & bpl<=600) 				// Asia
gen bpl_oth = (bpl>=800 & bpl<=999) | bpl==600 	// Africa or other

/*gen bpl_sum = bpl_mex+ bpl_oth+ bpl_eur + bpl_as + bpl_othsp
sum bpl_sum, d
tab bpld if bpl_sum==2
tab bpld if bpl_sum==0
drop bpl_sum
*/

label var usaborn "Born in US Territory"
label var bpl_mex "Born in Mexico"
label var bpl_othspan "Born in Central/South America"
label var bpl_euraus "Born in Europe/Australia"
label var bpl_asia "Born in Asia"
label var bpl_oth "Born in Africa/Other"


* Country of birth and language
gen english = language==1
gen spanish = language==12
gen nonfluent = (speakeng==1 | speakeng==6)
drop language speakeng
label var english "English Primary Language"
label var spanish "Spanish Primary Language"
label var nonfluent "Poor English"




* Other Labels
label var age "Current Age"
*label var nsibs "Number of Siblings"


******************************
*** CLEAN/CREATE OUTCOMES
******************************

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

*** HS degree or more
gen hs = yrsed>=12
replace hs=0 if educd==61
replace hs=. if yrsed==.
label var hs "HS Degree"

*** Some college and college
gen scol = yrsed>12
gen col = yrsed>=16
for any scol col: replace X=. if yrsed==.
label var scol "Some College"
label var col "College"

// drop no longer needed ed vars
gen edu_att = 4 if educd>=101
replace edu_att = 3 if educd<101
replace edu_att = 2 if educd<65
replace edu_att = 1 if educd<62

gen edu_attS = "College Diploma" if educd>=101
replace edu_attS = "HS Diploma and some college" if educd<101
replace edu_attS = "HS Diploma" if educd<65
replace edu_attS = "No HS Diploma" if educd<62


drop educd grad*


******************************
*** ELIGIBILITY & POST VARS
******************************

*** Foreign born
gen ageimmig = yrimmig-birthyr
tab ageimmig, m
replace ageimmig=-1 if ageimmig<0
tab ageimmig, m
label var ageimmig "Age at Immigration"
label var yrimmig "Year of Immigration"

*** Citizen/non citizen
gen noncit=citizen==3
replace noncit=. if citizen==.

*** Eligible: noncitizen, immigrated by 16 and 2007, less than 31 in June 2012
// Note: for most of our analysis, we de-fact compare citizens to noncizens
gen elig = (noncit==1 & ageimmig<=16 & yrimmig<=2007 & (2012.5-(birthyr+(birthqtr*.25)))<31) // i.e birthyr + birthqtr>1981.5
replace elig=0 if ageimmig==.
tab elig year, m
gen nonelig = 1-elig
label define noncitizlabel 0 "Citizen" 1 "Non-Citizen"
label values noncit noncitizlabel 
la var elig "Eligible"
la var nonelig "Ineligible"

* How many eligibles by year?
tab birthyr, sum(elig)

* How many eligibles that we think are legal?
tab hhlegal elig, m

*** Post variables
gen post = year>=2012
gen elig_post = elig*post
la var elig_post "Eligible*Post"

gen elig_post_male = elig_post*male
la var elig_post_male "Eligible*Post*Male"


******************************
*** SAMPLE INDICATORS
******************************

*** High takeup (30% or higher) according to MIP: El Salvador, Mexico, Uruguay, Honduras, Bolivia, Brazil, Peru, Ecuador, Jamaica, Guatemala, Venezuela, Dominican Republic, Colombia
tab bpld elig if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025

gen htus = 1 if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025
replace htus=. if yrimmig==0 
tab ageimm htus, m  

replace degfield=9999 if degfield==0
*** Age groups for analysis



