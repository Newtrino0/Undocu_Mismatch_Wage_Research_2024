ssc install outreg2
ssc install tabout
ssc install estout
ssc install groups
global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"
global figures "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Figures"
cd $rawdata

use eo_tables_merged_na, clear


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


*Inflation adjusted incwage*
gen cpi = 211.933 if year==2009
replace cpi = 217.488 if year==2010
replace cpi = 221.187	if year==2011
replace cpi = 227.842	if year==2012
replace cpi = 231.679	if year==2013
replace cpi = 235.288	if year==2014
replace cpi = 234.747	if year==2015
replace cpi = 237.652	if year==2016
replace cpi = 243.618	if year==2017
replace cpi = 248.859	if year==2018
replace cpi = 252.561	if year==2019
replace cpi = 258.906	if year==2020
replace cpi = 262.518	if year==2021
replace cpi = 282.39	if year==2022
replace cpi = 300.356	if year==2023
replace cpi = 309.685	if year==2024
gen adj_incwage = incwage * 309.685 / cpi
format adj_incwage %7.0f


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

sort occ incwage
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
by occ: egen med_wage_hmatched_by_occ = median(incwage) if hmatched==1
*Next line of code extends the med_wage to other observations with the same occ
egen hmatched_med_wage_by_occ = mean(med_wage_hmatched_by_occ), by (occ)
drop med_wage_hmatched

**Same hmatched median wage but by degfield
sort degfield
by degfield: egen med_wage_hmatched_by_degfield = median(incwage) if hmatched==1
*Next line of code extends the med_wage to other observations with the same occ
egen hmatched_med_wage_by_degfield = mean(med_wage_hmatched_by_degfield), by (degfield)
drop med_wage_hmatched_by_degfield

**For vmatched by degfield
by degfield: egen med_wage_vmatched_by_degfield = median(incwage) if vmatched_att==1
egen vmatched_med_wage_by_degfield = mean(med_wage_vmatched_by_degfield), by (degfield)
drop med_wage_vmatched_by_degfield

*Create med_wage for vmatched people within occupation (by attaintment)
sort occ
by occ: egen med_wage_vmatched_by_occ = median(incwage) if vmatched_att==1

egen vmatched_med_wage_by_occ = mean(med_wage_vmatched_by_occ), by (occ)
drop med_wage_vmatched_by_occ


***Horizontal undermatch and overmatched binary variable creation***
gen hundermatched=1 if hmatched==0 & col==1 & med_wage_by_occ<hmatched_med_wage_by_degfield
replace hundermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_wage_by_occ>hmatched_med_wage_by_degfield)

gen hovermatched=1 if (hmatched==0)&(col==1)&(med_wage_by_occ>hmatched_med_wage_by_degfield)
replace hovermatched=0 if (hmatched==1) | (hmatched==0 & col==1 & med_wage_by_occ<hmatched_med_wage_by_degfield)


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
label var incwage "Wage and Salary income"

/*
tab elig stem_deg,row
tab elig hmatched,row
tab elig vmatched_att,row
tab elig degfield, row
tab noncit stem_deg,row

table noncit_elig, stat(mean hmatched vmatched_att stem_deg) stat(median incwage)
table noncit_deg, stat(mean hmatched vmatched_att stem_deg) stat(median incwage)
sum year age elig age_inelig arrival_inelig foreign_deg_likely stem_deg bpl_usa bpl_mex bpl_othspan bpl_asia for_cit noncit nonfluent incwage hmatched vmatched_att


tabout noncit elig using table_output.htm, replace c(freq col cum) ///
 f(0c 1) style(htm) font(bold)
 
tabout noncit hmatched elig using "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data\exceltable.xlsx", ///
replace c(freq col) f(0c 1) font(bold) style(xlsx)

table (var) (noncit_elig result), statistic(mean year age foreign_deg_likely stem_deg for_cit noncit hmatched vmatched_att incwage ln_wage n_noncit_elig) nformat(%10.2f)

table (var) (noncit_deg result), statistic(mean year age elig age_inelig arrival_inelig stem_deg for_cit noncit hmatched vmatched_att incwage ln_wage n_noncit_deg) nformat(%10.2f)  
*/

dtable year age fem arrival_inelig_16_20 foreign_deg_likely stem_deg for_cit noncit nonfluent incwage ln_wage hmismatched hundermatched hovermatched vmismatched, by(noncit_elig) export(noncit_elig_table.xlsx, replace)

dtable year age fem elig age_inelig arrival_inelig arrival_inelig_16_20 for_cit noncit stem_deg nonfluent incwage ln_wage hmismatched hundermatched hovermatched vmismatched, by(noncit_deg) export(noncit_elig_deg.xlsx, replace)

dtable year age fem elig age_inelig arrival_inelig arrival_inelig_16_20 for_cit noncit stem_deg nonfluent incwage ln_wage hmismatched hundermatched hovermatched vmismatched, by(cit_general) export(cit_general.xlsx, replace)

gen hmproportion=1-hproportion


use mismatch_sample_na.dta, clear
sort occ
save mismatch_sample_na.dta, replace

keep if elig==1


*Fix to make table for top # for DACA eligible
collapse (median)hmismatch_rate_occ=hmproportion (median)hunderproportion (median)hoverproportion (median)vproportion_yrs (mean)occ_count (count)count_occ=occ, by(occ)
sort count_occ


gsort -hmismatch_rate_occ

keep if hmismatch_rate_occ > .8813559

eststo clear
eststo occ: estpost summarize hmismatch_rate_occ
esttab using occ_mismatch_table.tex, replace

gen occS = string(occ)
replace occS ="Lifeguards and other recreational, and all other protective service workers" if occS== "3955"
replace occS ="Lifeguards and other protective service workers" if occS== "3950"
replace occS ="Postsecondary Teachers" if occS== "2205"
replace occS ="Textile winding, twisting, and drawing out machine setters, operators, and tenders" if occS== "8420"
replace occS ="Textile Machine Setters, Operators, and Tenders" if occS== "8365"
replace occS ="Postsecondary teachers" if occS== "2200"
replace occS ="Massage Therapists" if occS== "3630"
replace occS ="Other Personal Appearance Workers" if occS== "4525"
replace occS ="Adhesive Bonding Machine Operators and Tenders" if occS== "8850"
replace occS ="Explosives workers, ordnance handling experts, and blasters" if occS== "6830"

save occ_mismatch_table.dta, replace

use mismatch_sample_na.dta, clear

collapse (median)hmismatch_rate_deg=hmproportion (median)hunderproportion (median)hoverproportion (median)vproportion_yrs , by(degfield)
gsort -hmismatch_rate_deg

keep if hmismatch_rate_deg > .6896701

gen degfieldS = string(degfield)
replace degfieldS = "Area, Ethnic, and Civilization Studies" if degfieldS ==	"15"
replace degfieldS = "Cosmetology Services and Culinary Arts" if degfieldS ==	"22"
replace degfieldS = "Law" if degfieldS ==	"32"
replace degfieldS = "English Language, Literature, and Composition" if degfieldS ==	"33"
replace degfieldS = "Library Science" if degfieldS ==	"35"
replace degfieldS = "Military Technologies" if degfieldS ==	"38"
replace degfieldS = "Philosophy and Religious Studies" if degfieldS ==	"48"
replace degfieldS = "Theology and Religious Vocations" if degfieldS ==	"49"
replace degfieldS = "Public Affairs, Policy, and Social Work" if degfieldS ==	"54"
replace degfieldS = "Construction Services" if degfieldS ==	"56"
replace degfieldS = "Electrical and Mechanic Repairs and Technologies" if degfieldS ==	"57"

save deg_mismatch_table.dta, replace


use mismatch_sample_na.dta, clear


********************************************************************************************************
*******************************************Regression Analysis******************************************
********************************************************************************************************
eststo clear

eststo: estpost tabstat vars if treat==1 & estimation_sample==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat vars if treat==0 & estimation_sample==1, statistics(mean sd) columns(statistics) 
eststo: estpost tabstat vars if treat==1 & lap>=15 & estimation_sample==1 , statistics(mean sd) columns(statistics) 
eststo: estpost tabstat $vars if treat==0 & lap>=15 & estimation_sample==1, statistics(mean sd) columns(statistics) esttab est* using sum_stats_boot_peru.rtf, replace label main(mean) aux(sd) title("Participant by Treatment Summary Statistics \label{tab:sum}") unstack mlabels("Total" "Treat" "Control" "Treat (Tray 15 & up)" "Control (Tray 15 & up)") note("Note: Means by person-lap reported; standard deviations in parentheses. ") clear matrix









eststo clear


************Vertical and Horizontal Mismatch models*****************************
eststo, title("Ver. Mismatch Model (by Status)"): quietly regress vmismatched i.year b1.race hisp age age_squared fem yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b1.metro for_cit immig_by_ten
outreg2 using ver_mismatch_reg.xls, replace ctitle(Ver. Mismatch Model (by Status))

eststo, title("Ver. Mismatch Model (by Status and Place Degree)"): quietly regress vmismatched i.year b1.race hisp age age_squared fem yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b1.metro foreign_deg_likely for_cit immig_by_ten
outreg2 using ver_mismatch_reg.xls, append ctitle(Ver. Mismatch Model (by Status and Place Degree))

eststo, title("Ver. Mismatch Model (by Status, Place of Degree, and STEM)"): quietly regress vmismatched i.year b1.race hisp age age_squared fem stem_deg  yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b1.metro foreign_deg_likely for_cit immig_by_ten
outreg2 using ver_mismatch_reg.xls, append ctitle(Ver. Mismatch Model (by Status, Place of Degree, and STEM))

eststo, title("Logit Ver. Mismatch Model"): quietly logit vmismatched i.year b1.race hisp age age_squared fem stem_deg  yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b1.metro foreign_deg_likely for_cit immig_by_ten
outreg2 using ver_mismatch_reg.xls, append ctitle(Logit Ver. Mismatch Model)

***Vertical Mismatch Table***
esttab using Ver_Mismatch_Reg_Table.csv, label plain /// 
title(Vertical mismatch Models) cells("b(star label(Coef.)) se(label(Std. err.))") ///
stats(r2_a r2_p N, labels("Adjusted R-squared" "Pseudo R-squared" "N. of cases")) ///
nonumbers mtitles("Ver. Mismatch Model (by Status)" "Ver. Mismatch Model (by Status and Place Degree)" "Ver. Mismatch Model (by Status, Place of Degree, and STEM)" "Logit Ver. Mismatch Model") /// 
addnote("Source:eo_tables_merged.dta") keep(hisp nonfluent 1.cit_general 2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg) compress replace

/*
eststo, title("Hor. Matched Model"): quietly regress hmatched i.noncit_elig i.year hisp age stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia, robust
outreg2 using myresults.xls, replace ctitle(Hor. Matched Model)

eststo, title("Hor. Mismatched Model"): quietly regress hmismatched i.noncit_elig i.year hisp age stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia, robust
outreg2 using myresults.xls, replace ctitle(Hor. Mismatched Model)
*/
eststo clear
eststo, title("Hor. Undermatch Model (by Status)"): quietly regress hundermatched i.year hisp b1.race age age_squared fem yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b22.classwkrd b1.metro for_cit immig_by_ten
outreg2 using myresults.xls, replace ctitle (Hor. Undermatch Model (by Status))

eststo, title("Hor. Undermatch Model (by Status and Place Degree)"): quietly regress hundermatched i.year hisp b1.race age age_squared fem  foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b22.classwkrd b1.metro for_cit immig_by_ten
outreg2 using myresults.xls, append ctitle (Hor. Undermatch Model (by Status and Place Degree))

eststo, title("Hor. Undermatch Model (by Status, Place of Degree, and STEM)"): quietly regress hundermatched i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b22.classwkrd b1.metro for_cit immig_by_ten
outreg2 using myresults.xls, append ctitle (Hor. Undermatch Model (by Status, Place of Degree, and STEM))


eststo, title("Hor. Overmatch Model (by Status)"): quietly regress hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten
outreg2 using myresults.xls, append ctitle (Hor. Overmatch Model (by Status))

eststo, title("Hor. Overmatch Model (by Status and Place Degree)"): quietly regress hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten
outreg2 using myresults.xls, append ctitle (Hor. Overmatch Model (by Status and Place Degree))

eststo, title("Hor. Overmatch Model (by Status, Place of Degree, and STEM)"): quietly regress hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten
outreg2 using myresults.xls, append ctitle (Hor. Overmatch Model (by Status, Place of Degree, and STEM))

xtset occ
eststo, title("FE Hor. Overmatch Model (by Status, Place of Degree, and STEM)"): xtreg hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten,fe
outreg2 using myresults.xls, append ctitle (FE Hor. Overmatch Model (by Status, Place of Degree, and STEM))
xtset,clear


***Horizontal Mismatch Table***
esttab using Hor_Mismatch_Reg_Table.csv, label plain /// 
title(Horizontal mismatch models)  cells("b(star label(Coef.)) se(label(Std. err.))") stats(r2 N, labels(R-squared "N. of cases")) ///
nonumbers mtitles("Hor. Undermatch Model (by Status)" "Hor. Undermatch Model (by Status and Place Degree)" "Hor. Undermatch Model (by Status, Place of Degree, and STEM)" "Hor. Overmatch Model (by Status)" "Hor. Overmatch Model (by Status and Place Degree)" "Hor. Overmatch Model (by Status, Place of Degree, and STEM)" "FE Hor. Overmatch Model (by Status, Place of Degree, and STEM)") /// 
addnote("Source:eo_tables_merged.dta") keep(hisp nonfluent 1.cit_general 2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg) compress replace

*******************************Wage Regression models *******************************
eststo clear

eststo, title("Mismatch Wage Model"): quietly regress ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 i.metro age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched vmismatched for_cit
outreg2 using myresults.xls, replace ctitle (Mismatch Wage Model)

eststo, title("Mismatch x for_deg Wage Model"): quietly regress ln_wage b1.cit_general b1.metro immig_by_ten stem_deg hisp b1.race married i.year b22.classwkrd i.pwstate2 i.metro age age_squared yrsed nonfluent uhrswork fem hundermatched#foreign_deg_likely hovermatched#foreign_deg_likely vmismatched#foreign_deg_likely for_cit
outreg2 using myresults.xls, append ctitle (Mismatch x for_deg Wage Model)

xtset occ
eststo, title("FE Wage Model"):  xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem for_cit, fe
outreg2 using myresults.xls, append ctitle (FE Wage Model) 


eststo, title("FE Hor. Mismatch Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched vmismatched for_cit, fe
outreg2 using myresults.xls, append ctitle (FE Hor. Mismatch Wage Model) 


xtset degfield
eststo, title("FE Deg Mismatch Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched vmismatched for_cit, fe
outreg2 using myresults.xls, append ctitle (FE Deg Mismatch Wage Model) 

esttab, label /// 
title(Log Wage Models) ///
nonumbers mtitles("Mismatch Wage Model" "Mismatch x for_deg Wage Model" "FE Wage Model" "FE Hor. Mismatch Wage Model" "FE Deg Mismatch Wage Model") /// 
addnote("Source: eo_tables_merged.dta")

***Wage Table***
esttab using Wage_Reg_Tables.csv, cells("b(star label(Coef.)) se(label(Std. err.))")  /// 
stats(r2 N, labels(R-squared "N. of cases")) /// 
nonumbers mtitles("Mismatch Wage Model" "FE Wage Model" "FE Hor. Mismatch Wage Model" "FE Deg Mismatch Wage Model") /// 
label legend varlabels(_cons Constant) keep(hisp nonfluent 1.cit_general 2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg) compress replace




*****(Li, Table 4)****
/*
eststo clear

xtset occ
eststo, title("FE Base Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro foreign_deg_likely immig_by_ten stem_deg hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem for_cit, fe

eststo, title("FE H. Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched##foreign_deg_likely hovermatched##foreign_deg_likely for_cit, fe

eststo, title("FE Mismatch Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched##foreign_deg_likely hovermatched##foreign_deg_likely vmismatched##foreign_deg_likely for_cit, fe


esttab using Li_Table_4.csv, label plain /// 
title(Log Wage Models) ///
nonumbers mtitles("FE Base Wage Model" "FE V. Wage Model" "FE H. Wage Model" "FE Mismatch Wage Model") /// 
addnote("Source: eo_tables_merged.dta") keep(hisp nonfluent 1.cit_general 2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg) compress replace

esttab, cells("b(star label(Coef.)) se(label(Std. err.))")  /// 
stats(r2 N, labels(R-squared "N. of cases")) /// 
label legend varlabels(_cons Constant)
*/









****************************Final Regression Table***********************************
eststo clear

*** (FINAL) Vertical Mismatch Models***
eststo, title("Logistic V. Mismatch Model"): quietly logit vmismatched i.year b1.race hisp age age_squared fem stem_deg  yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b1.metro foreign_deg_likely for_cit immig_by_ten
outreg2 using Final_Regression_Table.xls, append ctitle(Logistic V. Mismatch Model)

*** (FINAL) Horizontal Mismatch Models***
eststo, title("Logistic H. Undermatch Model"): quietly logit hundermatched i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia b1.cit_general b22.classwkrd b1.metro for_cit immig_by_ten
outreg2 using Final_Regression_Table.xls, append ctitle (Logistic H. Undermatch Model)

eststo, title("Logistic H. Overmatch Model"): quietly logit hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten
outreg2 using Final_Regression_Table.xls, append ctitle (Logistic H. Overmatch Model)

xtset degfield
eststo, title("FE by degfield H. Undermatch Model"): xtreg hundermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten,fe
outreg2 using Final_Regression_Table.xls, append ctitle (FE by degfield H. Undermatch Model)
xtset,clear

xtset degfield
eststo, title("FE by degfield H. Overmatch Model"): xtreg hovermatched b1.cit_general b22.classwkrd b1.metro i.year hisp b1.race age age_squared fem stem_deg foreign_deg_likely yrsed nonfluent bpl_mex bpl_othspan bpl_asia for_cit immig_by_ten,fe
outreg2 using Final_Regression_Table.xls, append ctitle (FE by degfield H. Overmatch Model)
xtset,clear

esttab using Final_Mismatch_Table.tex, cells("b(star label(Coef.)) se(label(Std. err.))")  /// 
stats(r2_p r2_a N, labels("Pseudo R-squared" "Adjusted R-squared" "N. of cases")) title(Regression statistics for Vertical Mismatch and Horizontal Undermatch and Overmatch models) /// 
nonumbers mtitles("Logistic V. Mismatch Model" "Logistic H. Undermatch Model" "Logistic H. Overmatch Model" "FE by degfield H. Undermatch Model" "FE by degfield H. Overmatch Model") /// 
label legend varlabels(_cons Constant) keep(2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg hisp nonfluent) addnotes("Note: DACA eligible/ineligible groups are created with Kuka et al. (2020) methods. Foreign Degree (likely) consists of individuals that were outside the U.S. during typical college age.FE by deg. models have 38 unique degree fields. Other covariates not displayed include: year, race, age, age squared, gender, years of education, three binary variables for birthplace (Mexico, other Spanish-speaking countries, and Asia), class of worker, and metropolitan residence.") replace compress

eststo clear

*** (FINAL) Wage Regression models ***
eststo, title("Base Wage Model"): quietly regress ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 i.metro age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched vmismatched for_cit
outreg2 using Final_Regression_Table.xls, append ctitle (Base Wage Model)

xtset occ
eststo, title("FE by occ Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched for_cit, fe
outreg2 using Final_Regression_Table.xls, append ctitle (FE by occ Wage Model) 
xtset,clear

xtset degfield
eststo, title("FE by degfield Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg foreign_deg_likely hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched hovermatched vmismatched for_cit, fe
outreg2 using Final_Regression_Table.xls, append ctitle (FE by degfield Wage Model) 
xtset,clear

xtset degfield
eststo, title("FE by degfield (Mismatch x for_deg) Wage Model"): quietly xtreg ln_wage b1.cit_general b1.metro immig_by_ten stem_deg hisp b1.race married i.year b22.classwkrd i.pwstate2 age age_squared yrsed nonfluent uhrswork fem hundermatched##foreign_deg_likely hovermatched##foreign_deg_likely vmismatched for_cit, fe
outreg2 using Final_Regression_Table.xls, append ctitle (FE by degfield Mismatch x for_deg Wage Model) 
xtset,clear

***Wage Table***
esttab using Final_Wage_Table.tex, cells("b(star label(Coef.)) se(label(Std. err.))")  /// 
stats(r2_a N, labels("Adjusted R-squared" "N. of cases")) title(Regression statistics for Log-transformed Wage models) /// 
nonumbers mtitles("Base Wage Model" "FE by occ. Wage Model" "FE by deg. Wage Model" "FE by deg. (Mismatch x for_deg) Wage Model") /// 
label legend varlabels(_cons Constant)  keep(vmismatched hundermatched hovermatched 2.cit_general 3.cit_general for_cit immig_by_ten foreign_deg_likely stem_deg hisp nonfluent) addnotes("Note: DACA eligible/ineligible groups are created with Kuka et al. (2020) methods. Foreign Degree (likely) consists of individuals that were outside the U.S. during typical college age. FE by deg. models have 38 unique degree fields. Other covariates not displayed include: year, race, age, age squared, gender, years of education, three binary variables for birthplace (Mexico, other Spanish-speaking countries, and Asia), class of worker, and metropolitan residence, US state, usual hours worked per week, marital status, horizontal undermatch, horizontal overmatch, and vertical mismatch.") nobaselevels interaction(" $\times$ ")style(tex) replace compress



*******************Descriptive tables****************************
dtable hmismatched hundermatched hovermatched vmismatched stem_deg nonfluent incwage ln_wage year age fem, by(usborn_elig) export(dtable_paper.xlsx, replace)

dtable hmismatched hundermatched hovermatched vmismatched stem_deg nonfluent incwage ln_wage year age fem, by(usborn_elig) export(dtable_paper.tex, replace)

*********************Figures***********************************************
graph hbar (sum) vmismatched hundermatched hovermatched matched, blabel(bar, size(vsmall) color(gs8) format(%7.0f)) ytitle(`"# of mismatched graduates"') ytitle(, size(medium) color(white)) ylabel(, labcolor(white) format(%9.0f) tlcolor(white)) by(, title(`"Frequency of vertical and horizonal under/overmatch by legal status"', size(medlarge) color(white) alignment(middle)) note(`"Definitions for DACA eligible groups derived from Kuka et al (2020)."', size(vsmall) color(white) position(5))) by(, legend(on position(6) span)) legend(order(1 "Vertical mismatch" 2 "Horizontal undermatch" 3 "Horizontal overmatch" 4 "Matched (vertically & horizontally)") size(vsmall) fcolor(%0)) scheme(meta) name(Mismatch_Status, replace) xsize(20) ysize(10) scale(1) by(, graphregion(fcolor(dknavy) lwidth(none))) by(cit_general, total style(rescale) iscale(*1)) subtitle(, size(medium) color(white) nobox) graphregion(fcolor(dknavy) lcolor(%0) lwidth(none))



graph bar (median) adj_incwage, over(cit_general, label(labcolor("white") labsize(tiny))) bar(1, fcolor(gold)) blabel(bar, size(tiny) format(%7.0f)) ytitle(`"Dollars ($)"') ytitle(, color(white)) ylabel(, labcolor(white) tlcolor(white)) by(, title(`"Median wage of working college graduates grouped by legal status and mismatch"', size(medium) color(white) alignment(middle)) note(`"Definitions for DACA eligible groups derived from Kuka et al (2020). Wage is adjusted for inflation using the CPI of January of every year"', size(tiny) color(white) position(5))) by(, legend(on position(6))) legend(order(1 "Median Wage (50th Percentile)") size(medsmall) fcolor(%0)) scheme(meta) name(Med_Wage_Status, replace) xsize(20) ysize(14) scale(1) by(, graphregion(fcolor(dknavy) lwidth(none))) by(vmismatched hmismatched) subtitle(, size(small) color(white) nobox)
