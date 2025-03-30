*** SET DIRECTORIES 
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\Data Preparation-Cleaning DO files"
global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"

*global prepdata "C:\Users\mario\Documents\Local_Mario_MSRIP\data\Replication\prepdata"

*** SET CODE
cap log close
set more off, perm

					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

********************************
*** Read data from local file***
********************************
*cd $rawdata
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "Core_TM SIPP 2008 Wave 2.dta", clear
describe




********* Clean data ***********



replace occ=. if occ==0
drop if missing(occ)

replace degfield =9999 if degfield==. | degfield==0
replace degfieldd =9999 if degfieldd==. | degfieldd==0

drop if incwage == 999999 | incwage==0
drop if empstat !=1
keep if school==1

drop if classwkr==1

drop if year==2005 | year==2006 | year==2007 | year==2008 | year==2009 | year==2010 | year==2011 | year==2012 | year==2020 | year==2021 | year==2022


drop cbserial momloc poploc
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed, and not self-employed
4.) People who are not currently attending school
5.) People who are 18 at the time they resided in the U.S.
*/


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
gen medicare = hinscare==2


gen healthins = (hcovany==2)
replace foodstmp = foodstmp-1
label var foodstmp "Food Stamp Recipient in HH"
label var healthins "Health Insurance"

*** Aggregate them to household level
bysort serial sample year: egen hhvet = max(vet)
bysort serial sample year: egen hhwelf = max(anywelfare)
bysort serial sample year: egen hhss = max(anyss)
bysort serial sample year: egen hhssi = max(anyssi)
bysort serial sample year: egen hhmedicare = max(medicare)
drop vetstat incwelfr incss incsupp vet anywelfare anyss anyssi

*** Legal if any of the above hold
egen hhlegal = rowtotal(hhvet hhwelf hhss hhssi hhmedicare)
tab hhlegal, m
replace hhlegal=1 if hhlegal>1 
drop hhvet hhwelf hhss hhssi hhmedicare

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

label var usaborn "Born in US Territory"
label var bpl_mex "Born in Mexico"
label var bpl_othspan "Born in Central/South America"
label var bpl_euraus "Born in Europe/Australia"
label var bpl_asia "Born in Asia"
label var bpl_oth "Born in Africa/Other"


* Country of birth and language
gen english = language==1
gen spanish = language==12
gen nonfluent = (speakeng==1 | speakeng==6)
drop language speakeng
label var english "English Primary Language"
label var spanish "Spanish Primary Language"
label var nonfluent "Poor English"




* Other Labels
label var age "Surveyed Age"
*label var nsibs "Number of Siblings"


******************************
*** CLEAN/CREATE OUTCOMES
******************************

*** Years of Education
gen yrsed = 0 if educd==2 | educd==11 | educd==12 			// 0 ed
replace yrsed = 2 if educd==10 									// nursery to grade 4
replace yrsed = 2.5 if educd==13 								// 1-4
replace yrsed = 1 if educd==14 									// 1
replace yrsed = 2 if educd==15 									// 2
replace yrsed = 3 if educd==16 									// 3
replace yrsed = 4 if educd==17 									// 4
replace yrsed = 6.5 if educd==20 								// 5-8
replace yrsed = 5.5 if educd==21 								// 5-6
replace yrsed = 5 if educd==22 									// 5
replace yrsed = 6 if educd==23 									// 6
replace yrsed = 7.5 if educd==24 								// 7-8
replace yrsed = 7 if educd==25 									// 7
replace yrsed = 8 if educd==26 									// 8
replace yrsed = 9 if educd==30 									// 9
replace yrsed = 10 if educd==40 									// 10
replace yrsed = 11 if educd==50 									// 11
replace yrsed = 12 if educd==60 | educd==61 | educd==62 | educd==63 | educd==64
replace yrsed = 12.5 if educd==65 								// less than a year of college
replace yrsed = 13 if educd==70 | educd==71 					// 13
replace yrsed = 14 if educd==80 | educd==81 | educd==82 | educd==83 // 14
replace yrsed = 15 if educd==90 									// 15
replace yrsed = 16 if educd==100 | educd==101 				// 16
replace yrsed = 17 if educd==110 								// 17
replace yrsed = 18 if educd==111 | educd==114 				// 18
replace yrsed = 19 if educd==112 | educd==115 				// 19
replace yrsed = 21 if educd==116 								// 21
label var yrsed "Years of Education"

*** HS degree or more
gen hs = yrsed>=12
replace hs=0 if educd==61
replace hs=. if yrsed==.
label var hs "HS Degree"

*** Some college and college
gen scol = yrsed>12
gen col = yrsed>=16
for any scol col: replace X=. if yrsed==.
label var scol "Some College"
label var col "College"

// drop no longer needed ed vars
gen edu_att = 4 if educd>=101
replace edu_att = 3 if educd<101
replace edu_att = 2 if educd<65
replace edu_att = 1 if educd<62

gen edu_attS = "College Diploma" if educd>=101
replace edu_attS = "HS Diploma and some college" if educd<101
replace edu_attS = "HS Diploma" if educd<65
replace edu_attS = "No HS Diploma" if educd<62

******************************
*** ELIGIBILITY & POST VARS
******************************

*** Foreign born
gen ageimmig = yrimmig-birthyr
tab ageimmig, m
replace ageimmig=. if ageimmig<0
tab ageimmig, m
label var ageimmig "Age at Immigration"
label var yrimmig "Year of Immigration"

gen eighteen_by_arrival = (ageimmig<=18 | ageimmig==.)
*** Citizen/non citizen
gen noncit=citizen==3
replace noncit=. if citizen==.

*** Eligible: noncitizen, immigrated by 16 and 2007, less than 31 in June 2012
// Note: for most of our analysis, we de-fact compare citizens to noncizens
gen elig = (noncit==1 & ageimmig<=16 & yrimmig<=2007 & (2012.5-(birthyr+(birthqtr*.25)))<31) // i.e birthyr + birthqtr>1981.5
replace elig=0 if ageimmig==.
tab elig year, m
gen nonelig = 1-elig
label define noncitizlabel 0 "Citizen" 1 "Non-Citizen"
label values noncit noncitizlabel 
la var elig "Eligible"
la var nonelig "Ineligible"

****** POST 2012 variables*******
gen post = year>=2012
gen elig_post = elig*post
la var elig_post "Eligible*Post"

gen elig_post_male = elig_post*male
la var elig_post_male "Eligible*Post*Male"

* How many eligibles by year?
tab birthyr, sum(elig)

* How many eligibles that we think are legal?
tab hhlegal elig, m

******************************
*** Undocu/DACA/Immigrant Variables
******************************

*** High takeup (30% or higher) according to MIP: El Salvador, Mexico, Uruguay, Honduras, Bolivia, Brazil, Peru, Ecuador, Jamaica, Guatemala, Venezuela, Dominican Republic, Colombia
tab bpld elig if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025

gen htus = 1 if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025
replace htus=. if yrimmig==0 
tab ageimm htus, m  

***********************************************END OF KUKA et. al. EXACT REPLICATION CODE**************************

****************************************************************************
************ BORJAS H-1B NONIMMIGRANT FILTER MODIFICATION*******************
****************************************************************************
gen reside_immig = year-yrimmig if yrimmig!=0
gen H1B_likely = (reside_immig<=6) & ( occ==101  | 	 occ==110  | 	 occ==230  | 	 occ==300  | 	 occ==800  | 	 occ==1005  | 	 occ==1006  | 	 occ==1010  | 	 occ==1021  | 	 occ==1022  | 	 occ==1050  | 	 occ==1065  | 	 occ==1105  | 	 occ==1106  | 	 occ==1108  | 	 occ==1305  | 	 occ==1306  | 	 occ==1310  | 	 occ==1320  | 	 occ==1330  | 	 occ==1340  | 	 occ==1350  | 	 occ==1360  | 	 occ==1400  | 	 occ==1410  | 	 occ==1420  | 	 occ==1430  | 	 occ==1440  | 	 occ==1450  | 	 occ==1460  | 	 occ==1500  | 	 occ==1510  | 	 occ==1520  | 	 occ==1530  | 	 occ==1541  | 	 occ==1551  | 	 occ==1555  | 	 occ==1560  | 	 occ==2205  | 	 occ==4930  | 	 occ==5000  | 	 occ==5100  | 	 occ==5120  | 	 occ==5340  | 	 occ==5710  | 	 occ==5720  | 	 occ==5730  | 	 occ==5740  | 	 occ==5900  | 	 occ==5940  | 	 occ==7010  | 	 occ==7905  | 	 occ==8610  | 	 occ==9030  | 	 occ==9210  | 	 occ==9330  | 	 occ==100  | 	 occ==1020  | 	 occ==1060  | 	 occ==1107  | 	 occ==1300  | 	 occ==1550  | 	 occ==2200  | 	 occ==2900  | 	 occ==5700  | 	 occ==5800  | 	 occ==6320  | 	 occ==7900  | 	 occ==9200  | 	 occ==1000  | 	 occ==1040  | 	 occ==1100  | 	 occ==5930) & (col==1)

replace elig=0 if H1B_likely==1
*****************************************************************************

**Applying Kuka/Warren/Passel legal status filter**
replace elig=0 if elig==1 & hhlegal==1
**Important modification for regression analysis**
replace metro=. if metro==0
**Educational attainment categorical variable**
gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12

**Inflation adjustment of wage since 2009, using CPI of January of each year**
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

**Midpoint method for wkswork2 (intervalled weeks worked last year)**
gen wkswork_midpoint = 6 if wkswork2==1 & wkswork1==.
replace wkswork_midpoint = 20 if wkswork2==2 & wkswork1==.
replace wkswork_midpoint = 33 if wkswork2==3 & wkswork1==.
replace wkswork_midpoint = 43.5 if wkswork2==4 & wkswork1==.
replace wkswork_midpoint = 48.5 if wkswork2==5 & wkswork1==.
replace wkswork_midpoint = 51 if wkswork2==6 & wkswork1==.
replace wkswork_midpoint = wkswork1 if wkswork1!=.

**Inflation-adjusted hourly wage of worker**
gen adj_hourly = adj_incwage / (uhrswork * wkswork_midpoint)
**Exluding outliers as per CPI sources on extremely low and high wages**
drop if adj_hourly<0.84 | adj_hourly>216.0

***************************************************************************
************ IMPORTANT VARIABLES FOR REGRESSION ANALYSIS*******************
***************************************************************************
**Indicator for immigrating before the age of 10**
gen immig_by_ten=ageimmig<10
**Age squared**
gen age_squared=age^2
**Indicator for those born in the U.S.**
gen bpl_usa=bpl<=120
**Indicator for those born outside the U.S.**
gen bpl_foreign=bpl>120
**Log transformation of hourly wage of worker, following previous literature**
gen ln_adj = ln(adj_hourly)
**Binary indicator for residing in metropolitan area**
gen metropolitan = metro == 2 | metro == 3 | metro == 4
**Binary indicator for whether a worker is in a government position**
gen gov_worker = classwkrd == 24 | classwkrd == 25 | classwkrd == 26 | classwkrd == 27 | classwkrd == 28



*****Additional categorical variables for detail and descriptive statistics if needed****
**Age-ineligible noncitizens meeting all other criteria**
gen age_inelig = elig==0 & noncit==1 & yrimmig<=2007 & (ageimmig>16 | (2012.5-(birthyr+(birthqtr*.25)))>=31)
replace age_inelig=. if noncit==0
**Arrival-ineligible noncitizens meeting all other criteria**
gen arrival_inelig = elig==0 & noncit==1 & yrimmig>2007 & (ageimmig<=16  & (2012.5-(birthyr+(birthqtr*.25)))<31)
replace arrival_inelig=. if noncit==0
**Young, arrival-ineligible noncitizens meeting all other criteria**
gen arrival_inelig_16_20 =elig==0 & noncit==1 & yrimmig>2007 & (ageimmig<=16  & (2012.5-(birthyr+(birthqtr*.25)))<=20 & (2012.5-(birthyr+(birthqtr*.25)))>=16)
replace arrival_inelig_16_20=. if noncit==0
**Both age-ineligible and arrival-ineligible noncitizens meeting all other criteria**
gen both_inelig = elig==0 & noncit==1 & yrimmig>2007 & (ageimmig>16  | (2012.5-(birthyr+(birthqtr*.25)))>=31)
replace both_inelig=. if noncit==0

gen undocu = noncit==1 & H1B_likely==0 & hhlegal==0
**********************************************************


**Foreign Citizens, born abroad and then naturalized**
gen for_cit = noncit==0 & bpl_usa!=1
***** Occ variable labels and categorization (Beyond 5 categories)*****


save "(Undocu)EO_Step_1.dta", replace