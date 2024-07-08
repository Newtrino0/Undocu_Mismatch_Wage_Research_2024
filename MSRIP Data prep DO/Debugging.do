***Find descriptive statistics of occupation***
*** SET DIRECTORIES
global dofiles "C:\Users\mario\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

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
use "usa_00006.dta", clear
*cd $dofiles/
describe


tab yrimmig, m
tab birthyr, m