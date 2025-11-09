*** SET DIRECTORIES 
global drive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu" //update this line with your folder 
global data "$drive/Shared drives/Undocu Research/Data"		
global dofiles "$drive/Shared drives/Undocu Research/Code"			

********************************************************************************
********** Mismatch indicators and median mismatched wages *********************
********************************************************************************
cd "$data"
import delimited "ACS_SIPP_gbm.csv", clear 

gen undocu_logit=0 if undocu_logistic=="X0"
replace undocu_logit=1 if undocu_logistic=="X1"

gen undocu_knn=0 if knn_undocu=="X0"
replace undocu_knn=1 if knn_undocu=="X1"

gen undocu_rf=0 if rf_undocu=="X0"
replace undocu_rf=1 if rf_undocu=="X1"

keep caret_undocu_p-undocu_rf undocu year serial pernum



merge 1:1 year serial pernum using "EO_C.dta"

replace undocu_logit=0 if undocu_logit==.
replace undocu_knn=0 if undocu_knn==.
replace undocu_rf=0 if undocu_rf==.
replace gbm_high_prob=0 if gbm_high_prob==.
replace gbm_low_prob=0 if gbm_low_prob==.
replace gbm_high_recall=0 if gbm_high_recall==.



********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed, and not self-employed
4.) People with a degfield listed (COLLEGE GRADUATES)


*/


egen undocu_rf_occ_count=count(occ) if undocu_rf==1, by(occ)
egen undocu_rf_deg_count=count(degfield) if undocu_rf==1, by(degfield)


********************************************************************************
***************** Pre Regression recoding and preparation **********************
********************************************************************************
***elig_year variable creation***
gen eventyear = year
label define eventyr 2009 "2009" 2010 "2010" 2011 "2011" 2012 "2012" 2013 "2013" ///
	 2014 "2014" 2015 "2015" 2016 "2016" 2017 "2017" 2018 "2018" 2019 "2019"
label values eventyear eventyr

forvalues y=2013(1)2019 {
	gen elig_year`y' = elig*(eventyear==`y')
}
drop elig_year2016

forvalues y=2013(1)2019 {
	gen undocu_year`y' = undocu_logit*(eventyear==`y')
}
drop undocu_year2016

***Mismatch and other regression covariate modifications/labeling***
gen hmatch = 1 if hundermatched==1
replace hmatch=2 if hundermatched==0 & hovermatched==0
replace hmatch=3 if  hovermatched==1

gen elig_stem=elig*stem_deg
gen post_stem=post*stem_deg
gen elig_post_stem=elig*post*stem_deg


label define hmatch_label 1 "Hundermatched" 2 "Hmatched" 3 "Hovermatched" 
label values hmatch hmatch_label 

replace post=0 if year==2012
replace immig_by_ten=1 if bpl_foreign==0


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

gen undocu_everify=undocu*everify_inclusive
gen undocu_knn_everify=undocu_knn*everify_inclusive
gen undocu_rf_everify=undocu_rf*everify_inclusive


gen license_inclusive=(professional_licensure==1)
gen undocu_license=undocu*license_inclusive
gen undocu_knn_license=undocu_knn*license_inclusive
gen undocu_rf_license=undocu_rf*license_inclusive


gen undocu_inclusive=undocu*inclusive
gen undocu_drive=undocu*drivers_license

gen gbm_high_prob_inclusive=gbm_high_prob*inclusive
gen gbm_high_recall_inclusive=gbm_high_recall*inclusive
gen gbm_low_prob_inclusive=gbm_low_prob*inclusive


gen gbm_high_prob_everify=gbm_high_prob*everify_inclusive
gen gbm_high_prob_license=gbm_high_prob*license
gen gbm_high_prob_drive=gbm_high_prob*drivers_license

gen gbm_high_recall_everify=gbm_high_recall*everify_inclusive
gen gbm_high_recall_license=gbm_high_recall*license
gen gbm_high_recall_drive=gbm_high_recall*drivers_license

gen gbm_low_prob_everify=gbm_low_prob*everify_inclusive
gen gbm_low_prob_license=gbm_low_prob*license
gen gbm_low_prob_drive=gbm_low_prob*drivers_license




gen elig_knn = (elig==1 & undocu_knn==1)
gen elig_rf = (elig==1 & undocu_rf==1)

label var undocu "Undocumented"
label var undocu_knn "Undocumented (KNN)"
label var undocu_rf "Undocumented (RF)"

label var elig "DACA-eligible"
label var elig_knn "DACA-eligible (KNN)"
label var elig_rf "DACA-eligible (RF)"



*--- Create manual interactions for degree fields (reference: Other)
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


save "EO_Final", replace
