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