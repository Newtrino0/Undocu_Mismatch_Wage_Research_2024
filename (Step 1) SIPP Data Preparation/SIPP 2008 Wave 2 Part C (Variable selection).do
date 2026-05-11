*ssc install pq

*** SET DIRECTORIES 
global data "G:/Shared drives/Undocu Research/Data"


					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

********************************
*** Read data from local file***
********************************
*cd $rawdata
cd "$data"
use "(Step 1 output) SIPP 2008 Wave 2.dta", clear
describe


sort epppnum

merge m:1 epppnum eentaid ssuid using "(Step 1 output) TM SIPP 2008 Wave 2.dta"
drop _merge

*save ""
********* Clean data ***********

**This keeps unique person, probably**
keep if srefmon==1
bys epppnum eentaid ssuid:gen count=_N
tab count

keep epppnum ehrefper tpearn ehrsall epayhr1 errp tpmsum1 efspouse shhadid ssuid eentaid eadvncfd ebachfld egedtm eenlevel eeducate evocat rhpov thearn rhcalyr tbyear ebmnth tage tbrstate esex ems epnspous espeak tlang1 ehowwell rcutyp57 rcutyp58 ecrmth rcuown57 ecitizen enatcit timstat eadjust tadyear tmoveus rfnkids rmesr erace eorigin tfipsst ebornus ehhnumpp epayhr1 eslryb1 tpmsum1 tpmsum2 tjbocc1 tjbocc2 eclwrk1 eclwrk2 ejbind1 eunion1 ecntrc1 eocctim1 eenrlm easst06 eafnow eafever rcutyp01 rcutyp03



* Conditions
gen spouse = errp==1 | errp==3
gen cit = ecitizen==1

bysort ssuid (spouse cit): egen cond1 = max(spouse)
bysort ssuid (spouse cit): egen cond2 = max(cit)

* Spouse is citizen (misclassifies citizens as having citizen spouse when not true)
gen cit_spouse = (cond1 & cond2)

* tpmsum1: Earnings from job received in this month What was ...'s gross pay before deductions in this month?
* epayhr1: Does ... have a set annual salary, was ... paid by the hour or was ... paid some other way?
* ehrsall: Usual hours worked at all jobs during the reference period
* tpearn: Total person's earned income for the month
* epppnum: Person number. This field differentiates persons within the sample unit. Person number is unique within the sample unit. 
* ehrefper: number of household reference person
* errp: Household relationship
* efspouse: Person number of spouse of family reference person
* shhadid: Hhld Address ID differentiates hhlds in sample unit
* eenlevel: Education level
* eeducate: Highest Degree received or grade completed. What is the highest level of school ... has completed or the highest degree ... has received?
* evocat:  Attended vocational, technical, trade, or business school. Has ... ever attended a vocational, technical, trade, or business school beyond high school? 
* rhpov: Poverty threshold for this household in this month. Poverty threshold for this household in this month. Official poverty rates (from the CPS) use families not households as the unit of analysis.
* thearn: Total household earned income Reaggregated total household earned income for relevant month of the reference period after topcoding
* tbyear: Year of birth
* rhcalyr: Calendar year for this reference month
* ebmnth:  Month of birth
* tage: Age as of last birthday. Edited and imputed age as of last birthday. Topcoding combines persons into last two single year of age groups. User should combine last two age groups for microdata analysis.
* tbrstate: State or country of birth BRSTATE/BCNTRY Where was ... born?
* esex: Sex of this person
* epayhr1: Paid by the hour. Does ... have a set annual salary, was ...paid by the hour or was ... paid some other way?
* eslryb1: Salary draw from business. Did ... draw a regular salary from this business? (That is, take a regular paycheck, as opposed to just treating the profits as ...'s income.)
* tpmsum1: Earnings from job received in this month. What was ...'s gross pay before deductions in this month?
* tpmsum2: Earnings from job received in this month. What was ...'s gross pay before deductions in this month?
* tjbocc1: Occupation code
* tjbocc2: Occupation code
* eclwrk1: Class of worker
* eclwrk2: Class of worker
* ejbind1: Industry code
* eunion1:  Union/employee-association membership. On this job is ... a member of either a labor union or an employee association like a union?
* ecntrc1: Coverage by union or something like a union contract
* eocctim1: eocctim1Length of time in this occupation. Considering ...'s entire working life, how many years has ... been in this occupation or line of work?
* eenrlm: Enrollment status in this month. Was ... enrolled in school in this month?
* easst06: Grant, Scholarship, or Tuition remission from school. Did ... receive a grant, scholarship, or tuition remission from the school attended?
* ems: Marital status
* epnspous: Person number of spouse
* espeak: Speak language other than English. Does ... speak a language other than English at home?
* tlang1: What language is spoken at home. What is this language? (Speaks language other than English at home)
* ehowwell: Ability to speak English. How well does ... speak English? (Speaks language other than English at home)
* rcutyp57: Medicaid coverage flag
* rcutyp58:  Health ins coverage flag (not Medicare or Medicaid)
* ecrmth: Medicare coverage in this month. Was ... covered by Medicare in this month?
* rcuown57: Person number of the owner of the SS coverage
* US Citizenship Status of Respondent. Is ... a citizen of the United States?
* enatcit: How the respondent became a US citizen. How is ... a U.S. citizen?
* timstat: Immigration status upon entry to the U.S. IMSTAT When ... moved to the U.S. to live, what was ...'s immigration status?
* eadjust: Whether status has changed to permanent resident ADJUST Has ...'s status been changed to permanent resident?
* tadyear: Year status changed to permanent resident ADYEAR What year was ...'s status changed to permanent resident?
* tmoveus: Year moved to the United States MOVEUS When did ... move to the United States?
* rfnkids:  Total number of children under 18 in family. This is family level information placed on the record of each person in the family. 
* rmesr:  Employment status recode for month
* erace: The race(s) the respondent is. What race(s) does ... consider herself/himself to be? 1 White 2 Black or African American 3 American Indian or Alaska Native 4 Asian 5 Native Hawaiian or Other Pacific Islander
* eorigin: Spanish, Hispanic or Latino. Is ... Spanish, Hispanic or Latino? 
* tfipsst: State FIPS code
* ebornus: Respondent was born in the U.S.. Is ... born in the United States?
* ehhnumpp: Total number of persons in this household in this month
* eafnow: Current Armed Forces status. Is ... now on active duty?
* eafever: Lifetime Armed Forces status. Did ... ever serve on active duty in the U.S. Armed Forces?
* rcutyp01: Social Security coverage flag
* rcutyp03: Federal SSI coverage flag
********************************


********************************
**** Cleaning and Preparing ****
********************************

* 1. PRE-CLEANING & NUMERIC CONVERSION
* Fix the baby age string before destringing
capture replace tage = "0" if strpos(tage, "Less than 1") > 0

* Convert listed variables to numeric
local numeric_vars "timstat eadjust eeducate tmoveus rhcalyr ems esex erace eorigin tbrstate ehowwell tlang1 tfipsst ebornus ecitizen cit_spouse rmesr thearn rhpov ehhnumpp rcutyp57 rcutyp58 ecrmth rcutyp01 rcutyp03 eafnow eafever tage tpearn ehrsall"

destring `numeric_vars', replace force

* Create ID
gen id_2 = _n

* 2. THE CLEAN LOGIC BLOCK

* 1. IMMIGRATION & LEGAL STATUS
gen undocu_entry = (timstat == 2)
gen undocu_likely = (timstat == 2 & eadjust == 2)

* 2. EDUCATION 
gen education = "Unknown"
replace education = "No HS diploma" if inrange(eeducate, 31, 38)
replace education = "HS diploma" if inlist(eeducate, 39, 41)
replace education = "Some college" if eeducate == 40
replace education = "Associate's" if inlist(eeducate, 42, 43)
replace education = "Bachelor's" if eeducate == 44
replace education = "Master's" if eeducate == 45
replace education = "PhD/Professional" if inlist(eeducate, 46, 47)

gen yrsed = .
replace yrsed = 0    if eeducate == 31
replace yrsed = 2.5  if eeducate == 32
replace yrsed = 5.5  if eeducate == 33
replace yrsed = 7.5  if eeducate == 34
replace yrsed = 9    if eeducate == 35
replace yrsed = 10   if eeducate == 36
replace yrsed = 11   if eeducate == 37
replace yrsed = 12   if inlist(eeducate, 38, 39, 40, 41)
replace yrsed = 14   if inlist(eeducate, 42, 43)
replace yrsed = 16   if inlist(eeducate, 44, 46)
replace yrsed = 17.5 if eeducate == 45
replace yrsed = 22   if eeducate == 47

gen college = inrange(eeducate, 44, 47)
gen hs_only = inrange(eeducate, 39, 43)

* 3. DEMOGRAPHICS
recode tmoveus (1=1961) (2=1966) (3=1971) (4=1976) (5=1980) ///
               (6=1982) (7=1984) (8=1987) (9=1989) (10=1991) ///
               (11=1993) (12=1995) (13=1998) (14=1999) (15=2000) ///
               (16=2001) (17=2002) (18=2004) (19=2005) (20=2006) ///
               (21=2007) (22=2009) (else=0), gen(immig_yr)

gen years_us = rhcalyr - immig_yr

gen married = inlist(ems, 1, 2)
gen fem = (esex == 2)

gen race = "Unknown"
replace race = "White" if erace == 1
replace race = "Black" if erace == 2
replace race = "Asian" if erace == 3
replace race = "Other" if erace == 4

gen asian = (erace == 3)
gen black = (erace == 2)
gen white = (erace == 1)
gen other_race = (erace == 4)

gen spanish_hispanic_latino = (eorigin == 1)
gen central_latino = (tbrstate == 570 & eorigin == 1)
gen bpl_asia = inrange(tbrstate, 565, 567)

* 4. LANGUAGE 
gen english_difficult = inlist(ehowwell, 3, 4)
gen nonfluent = inlist(ehowwell, 3, 4)
gen english_home = (tlang1 == -1)


* 5. GEOGRAPHY & CITIZENSHIP
gen top_ten_states = inlist(tfipsst, 4, 6, 12, 13, 17, 34, 36, 37, 48, 53)
gen bpl_usa = (ebornus == 1)
gen citizen = (ecitizen == 1)
* Note: cit_spouse is already captured from the raw data

* 6. EMPLOYMENT & INCOME 
gen employed = inlist(rmesr, 1, 2, 3)
* Stata treats missing (.) as infinity, so safely check missing status
gen poverty = (thearn < rhpov) & !missing(thearn) & !missing(rhpov)
gen household_size = ehhnumpp

* INFLATION ADJUSTMENT
gen adj_income = tpearn * (326.588 / 211.080)
gen adj_hourly = .
replace adj_hourly = adj_income / (ehrsall * 4.34524) if adj_income > 0 & ehrsall > 0 & !missing(adj_income) & !missing(ehrsall)
gen ln_adj = ln(adj_hourly)

* 7. BENEFITS
gen medicaid = (rcutyp57 == 1)
gen health_ins = (rcutyp57 == 1 | rcutyp58 == 1)
gen medicare = (ecrmth == 1)
gen social_security = (rcutyp01 == 1 | rcutyp03 == 1)
gen armed_forces = (eafnow == 1 | eafever == 1)

* --- POST-MUTATE LOGICAL CORRECTIONS ---
gen bpl_foreign = (bpl_usa == 0)

* Because undocu_likely is 0/1 numeric in Stata, no string replacements are needed
replace undocu_likely = 0 if immig_yr <= 1961
replace undocu_likely = 0 if armed_forces == 1 | social_security == 1

replace years_us = . if inlist(years_us, 2008, 2009, -1)
gen age = tage

gen undocu_logical = (citizen == 0 & (armed_forces == 0 | medicare == 0 | social_security == 0))
gen id = _n

* Export the master dataset (requires Stata 18+ for parquet, otherwise use export delimited)
*export parquet "G:/Shared drives/Undocu Research/Data/Stata_cleaned_SIPP.parquet", replace

keep if undocu_logical == 1	 
				
				
* Keep with the ID variable included
keep id undocu_likely age fem married cit_spouse medicaid nonfluent ///
     spanish_hispanic_latino central_latino bpl_asia household_size ///
     poverty asian black white other_race employed years_us yrsed ///
	 race college
	 


*pq save "G:/Shared drives/Undocu Research/Data/Stata_cleaned_SIPP.parquet", replace
export delimited using "G:\Shared drives\Undocu Research\Data\(Step 1 output) Core_TM SIPP 2008 Wave 2.csv", replace nolabel

*save "(Step 1 output) Core_TM SIPP 2008 Wave 2.dta", replace