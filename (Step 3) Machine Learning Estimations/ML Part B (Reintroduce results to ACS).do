*** SET DIRECTORIES 
*global drive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu" //update this line with your folder 
global data "G:/Shared drives/Undocu Research/Data"		
global dofiles "G:/Shared drives/Undocu Research/Code"			

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


gen everify_inclusive=(e_verify==2)
gen undocu_everify=undocu*everify_inclusive
gen undocu_knn_everify=undocu_knn*everify_inclusive
gen undocu_rf_everify=undocu_rf*everify_inclusive
gen license_inclusive=(professional_licensure==2)
gen undocu_license=undocu*license_inclusive
gen undocu_knn_license=undocu_knn*license_inclusive
gen undocu_rf_license=undocu_rf*license_inclusive


gen elig_knn = (elig==1 & undocu_knn==1)
gen elig_rf = (elig==1 & undocu_rf==1)

label var undocu "Undocumented"
label var undocu_knn "Undocumented (KNN)"
label var undocu_rf "Undocumented (RF)"

label var elig "DACA-eligible"
label var elig_knn "DACA-eligible (KNN)"
label var elig_rf "DACA-eligible (RF)"

save "EO_Final", replace
