ssc install outreg2
ssc install tabout
ssc install estout
ssc install groups
global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"


cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"

use "EO_Second_Step.dta", clear

drop if hs==0
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


*COUNTS AND PROPORTIONS of people per occupation and DACA eligible by occ
egen occ_count=count(occ), by(occ)
egen deg_count=count(degfield), by(degfield)
egen elig_occ_count=count(occ) if elig==1, by(occ)
egen elig_deg_count=count(degfield) if elig==1, by(degfield)
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
gen usborn_elig = 1 if elig==1
replace usborn_elig = 0 if elig==0 & noncit==0 & bpl_usa==1

label define usborn_elig_label 0 "U.S. born citizen" 1 "DACA eligible noncitizen"
label values usborn_elig usborn_elig_label


gen noncit_elig = 1 if elig==1
replace noncit_elig = 2 if age_inelig==1
replace noncit_elig = 3 if arrival_inelig==1
replace noncit_elig = 4 if both_inelig==1
replace noncit_elig = 5 if noncit==0

label define noncit_elig_label 1 "DACA-elig Noncit." 2 "Age_inelig_only Noncit." 3 "Arrival_inelig_only Noncit." 4 "Both age-arrival_inelig Noncit." 5 "U.S. Citizen"
label values noncit_elig noncit_elig_label 



gen cit_general = 1 if noncit==0
replace cit_general = 2 if noncit==1 & elig==0
replace cit_general = 3 if noncit==1 & elig==1

label define cit_general_label 1 "U.S. Citizens" 2 "DACA-ineligible Noncitizens" 3 "DACA-eligible Noncitizens"
label values cit_general cit_general_label 

label define stem_deg_label 0 "non-STEM degree graduates" 1 "STEM degree graduates" 
label values stem_deg stem_deg_label 

label var for_cit "Foreign Citizen"
label var immig_by_ten "Immigrated before 10 yrs of age"
label var stem_deg "STEM Degree"

/* Count for using table command
egen n_noncit_elig= sum(noncit_elig), by(noncit_elig)
label var n_noncit_elig "Number of Observations (by Cit.& Elig.)"

egen n_noncit_deg= sum(noncit_deg), by(noncit_deg)
label var n_noncit_deg "Number of Observations (by Cit.& Deg.)"
*/






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




save "EO_Final_Alternate_Sample", replace