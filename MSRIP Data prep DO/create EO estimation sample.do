clear matrix
clear
set more off

global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"
cd $rawdata

use "eo_tables_merged_na", clear


drop if degfield==9999
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed
4.) People with a degfield listed (college graduates)

*/
***********************************************
*******Additional Variable Creation************
***********************************************
gen bpl_usa=bpl<=120
gen bpl_foreign=bpl>120

gen for_cit = noncit==0 & bpl_usa!=1

gen foreign_deg_likely=ageimmig>25 & ageimmig!=.


replace elig=0 if elig==1 & hhlegal==1
replace nonelig=1 if nonelig==0 & hhlegal==1

gen ln_wage=ln(incwage)
gen age_squared=age^2

replace metro=. if metro==0

*Age of arrival before 10*
gen immig_by_ten=ageimmig<10



*****Create similar group variables of ineligility****
gen age_inelig = elig==0 & noncit==1 & yrimmig<=2007 & (ageimmig>16 | (2012.5-(birthyr+(birthqtr*.25)))>=31)
replace age_inelig=. if noncit==0


gen arrival_inelig = elig==0 & noncit==1 & yrimmig>2007 & (ageimmig<=16  & (2012.5-(birthyr+(birthqtr*.25)))<31)
replace arrival_inelig=. if noncit==0
gen arrival_inelig_16_20 =elig==0 & noncit==1 & yrimmig>2007 & (ageimmig<=16  & (2012.5-(birthyr+(birthqtr*.25)))<=20 & (2012.5-(birthyr+(birthqtr*.25)))>=16)
replace arrival_inelig_16_20=. if noncit==0

gen both_inelig = elig==0 & noncit==1 & yrimmig>2007 & (ageimmig>16  | (2012.5-(birthyr+(birthqtr*.25)))>=31)
replace both_inelig=. if noncit==0

gen undocu_likely_noncit= noncit==1 & age_inelig==1 & arrival_inelig==1 & both_inelig==1 & hhlegal==0
**********************************************************

sort occ adj_hourly
**Horizontally matched median wage and identifier (dummy variable)
gen hmatched =1 if (degfield==namode1_deg | degfield==namode2_deg)
replace hmatched =0 if (degfield!=namode1_deg & degfield!=namode2_deg)
**Vertically matched median wage and identifier (dummy variable)
gen vmatched_att = edu_att==mode_att
gen vmatched_yrs =yrsed==med_yrs_by_occ
*Mismatch difference and identifier, + means overmatched, -means undermatched
gen vmismatched_yrs= yrsed-med_yrs_by_occ
gen vmismtached_att = edu_att!=mode_att


*Count of people per occupation
egen occ_count=count(occ), by(occ)

**Create count of people who are horizontally matched and proportion, as well as those with college degree
egen hcount=sum(hmatched), by(occ)
by occ, sort: gen hproportion = hcount/occ_count

**Create count of vertically matched people and proportion
egen vcount=sum(vmatched_att), by(occ)
by occ, sort: gen vproportion = vcount/occ_count
egen vcount_yrs=sum(vmatched_yrs), by(occ)
by occ, sort: gen vproportion_yrs = vcount_yrs/occ_count

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


***Horizontal undermatch and overmatched binary variable creation***
gen hundermatched=1 if hmatched==0 & col==1 & med_hourly_occ<hmatched_med_wage_by_degfield
replace hundermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_hourly_occ>hmatched_med_wage_by_degfield)

gen hovermatched=1 if (hmatched==0)&(col==1)&(med_hourly_occ>hmatched_med_wage_by_degfield)
replace hovermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_hourly_occ<hmatched_med_wage_by_degfield)


egen hundercount=sum(hundermatched), by(occ)
by occ, sort: gen hunderproportion = hundercount/occ_count

egen hovercount=sum(hovermatched), by(occ)
by occ, sort: gen hoverproportion = hovercount/occ_count


************STEM Categorization**************
***For degfield***
gen stem_deg= degfieldd==1100 |	degfieldd==1103 |	degfieldd==1104 |	degfieldd==1105 |	degfieldd==1106 |	degfieldd==1199 |	degfieldd==1300 |	degfieldd==1301 |	degfieldd==1401 |	degfieldd==2001 |	degfieldd==2100 |	degfieldd==2101 |	degfieldd==2102 |	degfieldd==2105 |	degfieldd==2106 |	degfieldd==2107 |	degfieldd==2400 |	degfieldd==2401 |	degfieldd==2402 |	degfieldd==2403 |	degfieldd==2404 |	degfieldd==2405 |	degfieldd==2406 |	degfieldd==2407 |	degfieldd==2408 |	degfieldd==2409 |	degfieldd==2410 |	degfieldd==2411 |	degfieldd==2412 |	degfieldd==2413 |	degfieldd==2414 |	degfieldd==2415 |	degfieldd==2416 |	degfieldd==2417 |	degfieldd==2418 |	degfieldd==2419 |	degfieldd==2499 |	degfieldd==2500 |	degfieldd==2502 |	degfieldd==2503 |	degfieldd==2504 |	degfieldd==2599 |	degfieldd==3600 |	degfieldd==3601 |	degfieldd==3602 |	degfieldd==3603 |	degfieldd==3604 |	degfieldd==3605 |	degfieldd==3606 |	degfieldd==3607 |	degfieldd==3608 |	degfieldd==3609 |	degfieldd==3611 |	degfieldd==3699 |	degfieldd==3700 |	degfieldd==3701 |	degfieldd==3702 |	degfieldd==4002 |	degfieldd==4003 |	degfieldd==4005 |	degfieldd==4006 |	degfieldd==5000 |	degfieldd==5001 |	degfieldd==5002 |	degfieldd==5003 |	degfieldd==5004 |	degfieldd==5005 |	degfieldd==5006 |	degfieldd==5007 |	degfieldd==5008 |	degfieldd==5098 |	degfieldd==5102 |	degfieldd==5202 |	degfieldd==5701 |	degfieldd==5901 |	degfieldd==6100 |	degfieldd==6102 |	degfieldd==6103 |	degfieldd==6104 |	degfieldd==6105 |	degfieldd==6106 |	degfieldd==6107 |	degfieldd==6108 |	degfieldd==6109 |	degfieldd==6110 |	degfieldd==6199


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


gen noncit_deg = 1 if foreign_deg_likely==1 & noncit==1
replace noncit_deg = 2 if foreign_deg_likely==0 & noncit==1
replace noncit_deg = 3 if foreign_deg_likely==1 & noncit==0
replace noncit_deg = 4 if foreign_deg_likely==0 & noncit==0

label define noncit_deg_label 1 "Foreign-likely Educated Noncit." 2 "US-likely Educated Noncit." 3 "Foreign-likely Educated Cit." 4 "US-likely Educated Cit."
label values noncit_deg noncit_deg_label 


gen cit_general = 1 if noncit==0
replace cit_general = 2 if noncit==1 & elig==0
replace cit_general = 3 if noncit==1 & elig==1

label define cit_general_label 1 "U.S. Citizens" 2 "DACA-ineligible Noncitizens" 3 "DACA-eligible Noncitizens"
label values cit_general cit_general_label 

label define stem_deg_label 0 "non-STEM degree graduates" 1 "STEM degree graduates" 
label values stem_deg stem_deg_label 

gen mismatch_cat = 1 if vmismatched==1 & hundermatched!=1 & hovermatched!=1
replace mismatch_cat = 2 if vmismatched!=1 & hundermatched==1 & hovermatched!=1
replace mismatch_cat = 3 if vmismatched!=1 & hundermatched!=1 & hovermatched==1
replace mismatch_cat = 4 if vmismatched==1 & hundermatched!=1 & hovermatched!=1

label define mismatch_cat_label 1 "Foreign-likely Educated Noncit." 2 "US-likely Educated Noncit." 3 "Foreign-likely Educated Cit." 4 "US-likely Educated Cit."
label values mismatch_cat mismatch_cat_label 

label var foreign_deg_likely "Foreign Degree (likely)"
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
gen hmproportion=1-hproportion


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
label var ln_wage "Log-transformed wage"
label var ln_adj "Log-transformed hourly wage"
label var incwage "Wage and Salary income"
label var adj_hourly "Inflation-adjusted Hourly wage"
*save dataset for regression analysis

save final_eo_data, replace
