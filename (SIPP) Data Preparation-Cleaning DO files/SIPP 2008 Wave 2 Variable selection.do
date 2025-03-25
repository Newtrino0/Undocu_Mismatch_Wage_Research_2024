*** SET DIRECTORIES 
global dofiles "C:\Users\mario\Documents\GitHub\Undocu_Mismatch_Wage_Research_2024\ML SIPP Data Prep-Clean DO files"
global rawdata "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"


					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

********************************
*** Read data from local file***
********************************
*cd $rawdata
cd "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data"
use "SIPP 2008 Wave 2.dta", clear
describe


sort epppnum

merge m:1 epppnum eentaid ssuid using "TM SIPP 2008 Wave 2.dta"
drop _merge

*save ""
********* Clean data ***********

keep epppnum shhadid ssuid eentaid eadvncfd ebachfld egedtm eenlevel eeducate evocat rhpov thearn rhcalyr tbyear ebmnth tage tbrstate esex ems epnspous espeak tlang1 ehowwell rcutyp57 rcutyp58 ecrmth rcuown57 ecitizen enatcit timstat eadjust tadyear tmoveus rfnkids rmesr erace eorigin tfipsst ebornus ehhnumpp epayhr1 eslryb1 tpmsum1 tpmsum2 tjbocc1 tjbocc2 eclwrk1 eclwrk2 ejbind1 eunion1 ecntrc1 eocctim1 eenrlm easst06 eafnow eafever rcutyp01 rcutyp03

* epppnum: Person number. This field differentiates persons within the sample unit. Person number is unique within the sample unit. 
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

save "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\Core_TM SIPP 2008 Wave 2.dta", replace
export delimited using "C:\Users\mario\Documents\Undocu_Mismatch_Wage_Research_2024 Data\Core_TM SIPP 2008 Wave 2.csv", replace