*** SET DIRECTORIES 
global drive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu" // update this line with your folder 
global data "$drive/Shared drives/Undocu Research/Data"		
global dofiles "$drive/Shared drives/Undocu Research/Code"			

********************************************************************************
********** Reintegrate GBM predictions and create final ACS analysis file *******
********************************************************************************

cd "$data"

********************************************************************************
*** 1. Import GBM predictions created from the SIPP-to-ACS ML QMD file
********************************************************************************

import delimited "ACS_SIPP_gbm.csv", clear

* Expected variables from the QMD export:
*   gbm_undocu_p
*   gbm_undocu_q
*   gbm_high_prob
*   gbm_low_prob
*   gbm_high_recall
*   year serial pernum

keep gbm* ///
     year serial pernum
	 
	
* Check that prediction file uniquely identifies ACS person-year records
isid year serial pernum

tempfile gbm_predictions
save `gbm_predictions', replace


********************************************************************************
*** 2. Merge predictions back onto the ACS/mismatch file
********************************************************************************

use "EO_C.dta", clear

merge 1:1 year serial pernum using `gbm_predictions'

* _merge interpretation:
*   1 = in EO_C but not in ML prediction target/export
*   3 = matched to GBM prediction
tab _merge

* Observations outside the ML target/export receive zero flags for the ML predictions.
* Leave gbm_undocu_p and gbm_undocu_q missing for observations outside the ML target.

foreach v in gbm_high_prob gbm_low_prob gbm_high_recall ///
              {
    replace `v' = 0 if missing(`v')
}

drop _merge


********************************
/* Filters applied before EO_C include:

1.) People with an occupation listed
2.) People who are employed and not in school
3.) People with valid wage information
4.) People with a degfield listed (college graduates)

*/


********************************************************************************
***************** Pre Regression recoding and preparation **********************
********************************************************************************

*** elig_year variable creation ***
gen eventyear = year
label define eventyr 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" ///
	 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019"
label values eventyear eventyr

forvalues y=2013(1)2019 {
	gen elig_year`y' = elig*(eventyear==`y')
}
drop elig_year2016

* Legacy event-year interactions use the ACS logical-edit proxy undocu.
* The ML classifications are handled separately below.
forvalues y=2013(1)2019 {
	gen undocu_year`y' = undocu*(eventyear==`y')
}
drop undocu_year2016


*** Mismatch and other regression covariate modifications/labeling ***
gen hmatch = 1 if hundermatched==1
replace hmatch=2 if hundermatched==0 & hovermatched==0
replace hmatch=3 if hovermatched==1

gen elig_stem=elig*stem_deg
gen post_stem=post*stem_deg
gen elig_post_stem=elig*post*stem_deg

label define hmatch_label 1 "Hundermatched" 2 "Hmatched" 3 "Hovermatched" 
label values hmatch hmatch_label 

replace post=0 if year==2012
replace immig_by_ten=1 if bpl_foreign==0


*** Immigrant policy climate variables ***
gen annual_total_dummy = 0 if annual_total<0
replace annual_total_dummy = 1 if annual_total==0
replace annual_total_dummy = 2 if annual_total>0

label define annual_total_label 0 "Exclusive" 1 "Neutral" 2 "Inclusive" 
label values annual_total_dummy annual_total_label 

gen exclusive = 1 if annual_total<0
replace exclusive = 0 if annual_total>=0

gen inclusive = 1 if annual_total>0
replace inclusive = 0 if annual_total<=0

gen everify_inclusive=(e_verify==1)

replace drivers_license=0 if drivers_license==-1

gen license_inclusive=(professional_licensure==1)


*** Interactions using ACS logical-edit proxy ***
gen undocu_everify=undocu*everify_inclusive
gen undocu_license=undocu*license_inclusive
gen undocu_inclusive=undocu*inclusive
gen undocu_drive=undocu*drivers_license


*** Interactions using GBM prediction groups ***
gen gbm_high_prob_inclusive=gbm_high_prob*inclusive
gen gbm_high_recall_inclusive=gbm_high_recall*inclusive
gen gbm_low_prob_inclusive=gbm_low_prob*inclusive

gen gbm_high_prob_everify=gbm_high_prob*everify_inclusive
gen gbm_high_prob_license=gbm_high_prob*license_inclusive
gen gbm_high_prob_drive=gbm_high_prob*drivers_license

gen gbm_high_recall_everify=gbm_high_recall*everify_inclusive
gen gbm_high_recall_license=gbm_high_recall*license_inclusive
gen gbm_high_recall_drive=gbm_high_recall*drivers_license

gen gbm_low_prob_everify=gbm_low_prob*everify_inclusive
gen gbm_low_prob_license=gbm_low_prob*license_inclusive
gen gbm_low_prob_drive=gbm_low_prob*drivers_license


*** Labels ***
label var undocu "Undocumented logical-edit proxy"
label var gbm_undocu_p "Predicted undocumented probability (GBM/XGBoost)"
label var gbm_high_prob "High probability undocumented (GBM)"
label var gbm_high_recall "High recall undocumented (GBM)"
label var gbm_low_prob "Low probability / placebo group (GBM)"

label var elig "DACA-eligible"


********************************************************************************
*** Degree-field interactions (reference: Other)
********************************************************************************

foreach d in 1 2 3 4 {
    gen undocu_deg`d'             = (degfield_broader == `d') * undocu
    gen gbm_high_prob_deg`d'      = (degfield_broader == `d') * gbm_high_prob
    gen gbm_high_recall_deg`d'    = (degfield_broader == `d') * gbm_high_recall
    gen gbm_low_prob_deg`d'       = (degfield_broader == `d') * gbm_low_prob
}

label var undocu_deg1          "Undocumented × STEM"
label var undocu_deg2          "Undocumented × STEM Related"
label var undocu_deg3          "Undocumented × Business"
label var undocu_deg4          "Undocumented × Education"

label var gbm_high_prob_deg1   "High Prob × STEM"
label var gbm_high_prob_deg2   "High Prob × STEM Related"
label var gbm_high_prob_deg3   "High Prob × Business"
label var gbm_high_prob_deg4   "High Prob × Education"

label var gbm_high_recall_deg1 "High Recall × STEM"
label var gbm_high_recall_deg2 "High Recall × STEM Related"
label var gbm_high_recall_deg3 "High Recall × Business"
label var gbm_high_recall_deg4 "High Recall × Education"

label var gbm_low_prob_deg1    "Low Prob × STEM"
label var gbm_low_prob_deg2    "Low Prob × STEM Related"
label var gbm_low_prob_deg3    "Low Prob × Business"
label var gbm_low_prob_deg4    "Low Prob × Education"


********************************************************************************
*** Save final file
********************************************************************************

save "EO_Final", replace
