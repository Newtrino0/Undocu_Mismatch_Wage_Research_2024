clear
global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"


cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
import delimited "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\ACS_SIPP_rf.csv", clear 

gen undocu_logit=0 if undocu_logistic=="X0"
replace undocu_logit=1 if undocu_logistic=="X1"

gen undocu_knn=0 if knn_undocu=="X0"
replace undocu_knn=1 if knn_undocu=="X1"

gen undocu_rf=0 if rf_undocu=="X0"
replace undocu_rf=1 if rf_undocu=="X1"

keep undocu_logit undocu_knn undocu_rf undocu year serial pernum



merge 1:1 year serial pernum using "(Undocu)EO_Step_2.dta"

replace undocu_logit=0 if undocu_logit==.
replace undocu_knn=0 if undocu_knn==.
replace undocu_rf=0 if undocu_rf==.



drop if degfield==9999
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed, and not self-employed
4.) People with a degfield listed (COLLEGE GRADUATES)


*/
***********************************************
*******Additional Variable Creation************
***********************************************

sort occ adj_hourly
**HORIZONTALLY MATCHED median wage and identifier (dummy variable)
gen hmatched =1 if (degfield==namode1_deg | degfield==namode2_deg)
replace hmatched =0 if (degfield!=namode1_deg & degfield!=namode2_deg)
**VERTICALLY MATCHED median wage and identifier (dummy variable)
gen vmatched_att = edu_att==mode_att
gen vmatched_yrs =yrsed==med_yrs_by_occ
*VERTICAL MISMATCH (YRS) difference and identifier, + means overmatched, -means undermatched
gen vmismatched_yrs= yrsed-med_yrs_by_occ
gen vmismatched_att = edu_att!=mode_att


*COUNTS AND PROPORTIONS of people per occupation and Undocu-likely by occ
egen occ_count=count(occ), by(occ)
egen deg_count=count(degfield), by(degfield)
egen undocu_rf_occ_count=count(occ) if undocu_rf==1, by(occ)
egen undocu_rf_deg_count=count(degfield) if undocu_rf==1, by(degfield)
**Create count of people who are horizontally matched and proportion, as well as those with college degree
egen hcount=sum(hmatched), by(occ)
by occ, sort: gen hproportion = hcount/occ_count
gen hmproportion=1-hproportion

egen hcount_deg=sum(hmatched), by(degfield)
by occ, sort: gen hproportion_deg = hcount_deg/deg_count
gen hmproportion_deg=1-hproportion_deg
**Create count of vertically matched people and proportion
egen vcount=sum(vmismatched_att), by(occ)
by occ, sort: gen vproportion = vcount/occ_count


egen vmean_occ_yrs= mean(vmismatched_yrs), by(occ)
egen vmean_deg_yrs= mean(vmismatched_yrs), by(degfield)
*Generates needed wage but only attaches to hmatched observations
sort occ
by occ: egen med_wage_hmatched_by_occ = median(adj_hourly) if hmatched==1
*Next line of code extends the med_wage to other observations with the same occ
egen hmatched_med_wage_by_occ = mean(med_wage_hmatched_by_occ), by (occ)
drop med_wage_hmatched

**Same hmatched median wage but by degfield
sort degfield
by degfield: egen med_wage_hmatched_by_degfield = median(adj_hourly) if hmatched==1
*Next line of code extends the med_wage to other observations with the same occ
egen hmatched_med_wage_by_degfield = mean(med_wage_hmatched_by_degfield), by (degfield)
drop med_wage_hmatched_by_degfield

**For vmatched by degfield
by degfield: egen med_wage_vmatched_by_degfield = median(adj_hourly) if vmatched_att==1
egen vmatched_med_wage_by_degfield = mean(med_wage_vmatched_by_degfield), by (degfield)
drop med_wage_vmatched_by_degfield

*Create med_wage for vmatched people within occupation (by attaintment)
sort occ
by occ: egen med_wage_vmatched_by_occ = median(adj_hourly) if vmatched_att==1

egen vmatched_med_wage_by_occ = mean(med_wage_vmatched_by_occ), by (occ)
drop med_wage_vmatched_by_occ


***HORIZONTAL UNDERMATCH AND OVERMATCH binary variable creation***
gen hundermatched=1 if hmatched==0 & col==1 & med_hourly_occ<hmatched_med_wage_by_degfield
replace hundermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_hourly_occ>hmatched_med_wage_by_degfield)

gen hovermatched=1 if (hmatched==0)&(col==1)&(med_hourly_occ>hmatched_med_wage_by_degfield)
replace hovermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_hourly_occ<hmatched_med_wage_by_degfield)

**COUNTS of h. undermatch and overmatch by occ**
egen hundercount=sum(hundermatched), by(occ)
by occ, sort: gen hunderproportion = hundercount/occ_count
egen hovercount=sum(hovermatched), by(occ)
by occ, sort: gen hoverproportion = hovercount/occ_count

**COUNTS of h. undermatch and overmatch by degfield**
egen hundercount_deg=sum(hundermatched), by(degfield)
by degfield, sort: gen hunderproportion_deg = hundercount_deg/deg_count
egen hovercount_deg=sum(hovermatched), by(degfield)
by degfield, sort: gen hoverproportion_deg = hovercount_deg/deg_count

************STEM Categorization**************
***For degfield***



egen stem_count=sum(stem_deg), by(occ)
by occ, sort: gen stem_proportion = stem_count/occ_count
by occ, sort: gen stem_primary_deg_by_occ=(stem_proportion>0.5)
***For occ***



************Category Variables for tables**********************

label define stem_deg_label 0 "non-STEM degree graduates" 1 "STEM degree graduates" 
label values stem_deg stem_deg_label 

label var for_cit "Foreign Citizen"
label var immig_by_ten "Immigrated before 10 yrs of age"
label var stem_deg "STEM Degree"





******************Descriptive Statistics***************************
gen vmismatched=vmatched_att!=1
gen hmismatched=hmatched!=1
gen matched = vmismatched!=1 & hmismatched!=1


label define vmismatched_label 0 "Not Vertically Mismatched" 1 "Vertically Mismatched" 
label values vmismatched vmismatched_label 

label define hmismatched_label 0 "Not Horizontally Mismatched" 1 "Horizontally Mismatched" 
label values hmismatched hmismatched_label

label define matched_label 0 "Not Matched" 1 "Mismatched" 
label values matched matched_label

label var vmismatched "Vertically Mismatched"
label var hmismatched "Horizontally Mismatched"
label var hundermatched "Horizontally Undermatched"
label var hovermatched "Horizontally Overmatched"
label var incwage "Wage and Salary income"
label var adj_hourly "Inflation-adjusted Hourly wage"




save "(ML)EO_Final_Sample", replace