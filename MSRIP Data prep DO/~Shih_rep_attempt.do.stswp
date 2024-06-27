*** SET DIRECTORIES
global dofiles "C:\Users\XCITE-admin\Documents\GitHub\Stata_Work\MSRIP Data prep"

/*global figures /disk/homedirs/nber/ekuka/DACA/Replication/figures
global tables /disk/homedirs/nber/ekuka/DACA/Replication/tables
*/
global rawdata "C:\Users\XCITE-admin\Documents\Local_XCITE_MSRIP"
*global prepdata /homes/nber/ekuka/DACA/Replication/prepdata


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
use "usa_00005.dta", clear
*cd $dofiles/
describe


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
keep if age>=10 & age<=30
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

gen bpl_sum = bpl_mex+ bpl_oth+ bpl_eur + bpl_as + bpl_othsp
sum bpl_sum, d
tab bpld if bpl_sum==2
tab bpld if bpl_sum==0
drop bpl_sum

label var usaborn "Born in US Territory"
label var bpl_mex "Born in Mexico"
label var bpl_othspan "Born in Central/South America"
label var bpl_euraus "Born in Europe/Australia"
label var bpl_asia "Born in Asia"
label var bpl_oth "Born in Africa/Other"