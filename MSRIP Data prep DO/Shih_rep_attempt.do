*** SET DIRECTORIES
global dofiles "C:\Users\mario\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

/*global figures /disk/homedirs/nber/ekuka/DACA/Replication/figures
global tables /disk/homedirs/nber/ekuka/DACA/Replication/tables
*/
global rawdata "C:\Users\mario\Documents\Local_mario_MSRIP\MSRIP_Data"

*global prepdata "C:\Users\mario\Documents\Local_Mario_MSRIP\data\Replication\prepdata"

*** SET CODE
cap log close
set more off, perm

/*log using $dofiles/clean_data.log, replace
cd $dofiles/ */


					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

******************************
*** READ DATA
******************************
cd $rawdata
use "usa_00011.dta", clear
*cd $dofiles/
describe

********* Clean data ***********
replace occ=. if occ==0
drop if missing(occ)

replace degfield =0 if degfield==.

drop if incwage == 999999
drop if empstat !=1


drop degfieldd degfield2 degfield2d citizen_mom citizen_pop citizen_mom2 citizen_pop2 occscore
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People who are employed

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

*** Aggregate them to household level
bysort serial sample year: egen hhvet = max(vet)
bysort serial sample year: egen hhwelf = max(anywelfare)
bysort serial sample year: egen hhss = max(anyss)
bysort serial sample year: egen hhssi = max(anyssi)
drop vetstat incwelfr incss incsupp vet anywelfare anyss anyssi

*** Legal if any of the above hold
egen hhlegal = rowtotal(hhvet hhwelf hhss hhssi)
tab hhlegal, m
replace hhlegal=1 if hhlegal>1 
drop hhvet hhwelf hhss hhssi 

*** Keep only our sample of 10-30 olds
sum age
keep if age>=20 & age<=44
sum age

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

/*gen bpl_sum = bpl_mex+ bpl_oth+ bpl_eur + bpl_as + bpl_othsp
sum bpl_sum, d
tab bpld if bpl_sum==2
tab bpld if bpl_sum==0
drop bpl_sum
*/

label var usaborn "Born in US Territory"
label var bpl_mex "Born in Mexico"
label var bpl_othspan "Born in Central/South America"
label var bpl_euraus "Born in Europe/Australia"
label var bpl_asia "Born in Asia"
label var bpl_oth "Born in Africa/Other"
	
* Metro area
gen inmetro = metro==2 | metro==3 | metro==4
replace inmetro=. if metro==0
drop metro
rename inmetro metro
label var metro "Live in Metro Area"




* Country of birth and language
gen english = language==1
gen spanish = language==12
gen nonfluent = (speakeng==1 | speakeng==6)
drop language speakeng
label var english "English Primary Language"
label var spanish "Spanish Primary Language"
label var nonfluent "Poor English"


*Insurance and poverty
gen healthins = (hcovany==2)
replace foodstmp = foodstmp-1
label var foodstmp "Food Stamp Recipient in HH"
label var healthins "Health Insurance"


* Other Labels
label var age "Current Age"
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
gen edu_attS = "College Diploma" if educd>=101
replace edu_attS = "HS Diploma and some college" if educd<101
replace edu_attS = "HS Diploma" if educd<65
replace edu_attS = "No HS Diploma" if educd<62


drop educd grad*


******************************
*** ELIGIBILITY & POST VARS
******************************

*** Foreign born
gen ageimmig = yrimmig-birthyr
tab ageimmig, m
replace ageimmig=-1 if ageimmig<0
tab ageimmig, m
label var ageimmig "Age at Immigration"
label var yrimmig "Year of Immigration"

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

* How many eligibles by year?
tab birthyr, sum(elig)

* How many eligibles that we think are legal?
tab hhlegal elig, m

*** Post variables
gen post = year>=2012
gen elig_post = elig*post
la var elig_post "Eligible*Post"

gen elig_post_male = elig_post*male
la var elig_post_male "Eligible*Post*Male"


******************************
*** SAMPLE INDICATORS
******************************

*** High takeup (30% or higher) according to MIP: El Salvador, Mexico, Uruguay, Honduras, Bolivia, Brazil, Peru, Ecuador, Jamaica, Guatemala, Venezuela, Dominican Republic, Colombia
tab bpld elig if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025

gen htus = 1 if bpld==21030 | bpld==20000 | bpld==30060 | bpld==21050 | bpld==30010 | bpld==30015 | ///
	bpld==30050 | bpld==30030 | bpld==26030 | bpld==21040 | bpld==30065 | bpld==26010 | bpld==30025
replace htus=. if yrimmig==0 
tab ageimm htus, m  

replace degfield=9999 if degfield==0
*** Age groups for analysis
gen degfieldS = string(degfield)
gen occS = string(occ)

replace occS ="Chief Executives" if occS== "10"
replace occS ="General and Operations Managers" if occS== "20"
replace occS ="Legislators" if occS== "30"
replace occS ="Advertising and Promotions Managers" if occS== "40"
replace occS ="Marketing Managers" if occS== "51"
replace occS ="Sales Managers" if occS== "52"
replace occS ="Public Relations and Fundraising Managers" if occS== "60"
replace occS ="Administrative Services Managers" if occS== "101"
replace occS ="Facilities Managers" if occS== "102"
replace occS ="Computer and Information Systems Managers" if occS== "110"
replace occS ="Financial Managers" if occS== "120"
replace occS ="Compensation and Benefits Managers" if occS== "135"
replace occS ="Human Resources Managers" if occS== "136"
replace occS ="Training and Development Managers" if occS== "137"
replace occS ="Industrial Production Managers" if occS== "140"
replace occS ="Purchasing Managers" if occS== "150"
replace occS ="Transportation, Storage, and Distribution Managers" if occS== "160"
replace occS ="Farmers, Ranchers, and Other Agricultural Managers" if occS== "205"
replace occS ="Construction Managers" if occS== "220"
replace occS ="Education and Childcare Administrators " if occS== "230"
replace occS ="Architectural and Engineering Managers" if occS== "300"
replace occS ="Food Service Managers" if occS== "310"
replace occS ="Funeral Home Managers" if occS== "325"
replace occS ="Entertainment and Recreation Managers" if occS== "335"
replace occS ="Lodging Managers" if occS== "340"
replace occS ="Medical and Health Services Managers" if occS== "350"
replace occS ="Natural Sciences Managers" if occS== "360"
replace occS ="Postmasters and Mail Superintendents" if occS== "400"
replace occS ="Property, Real Estate, and Community Association Managers" if occS== "410"
replace occS ="Social and Community Service Managers" if occS== "420"
replace occS ="Emergency Management Directors" if occS== "425"
replace occS ="Personal Service Managers, All Other" if occS== "426"
replace occS ="Managers, All Other" if occS== "440"
replace occS ="Agents and Business Managers of Artists, Performers, and Athletes" if occS== "500"
replace occS ="Buyers and Purchasing Agents, Farm Products" if occS== "510"
replace occS ="Wholesale and Retail Buyers, Except Farm Products" if occS== "520"
replace occS ="Purchasing Agents, Except Wholesale, Retail, and Farm Products" if occS== "530"
replace occS ="Claims Adjusters, Appraisers, Examiners, and Investigators" if occS== "540"
replace occS ="Compliance Officers" if occS== "565"
replace occS ="Cost Estimators" if occS== "600"
replace occS ="Human Resources Workers" if occS== "630"
replace occS ="Compensation, Benefits, and Job Analysis Specialists" if occS== "640"
replace occS ="Training and Development Specialists" if occS== "650"
replace occS ="Logisticians" if occS== "700"
replace occS ="Project Management Specialists" if occS== "705"
replace occS ="Management Analysts" if occS== "710"
replace occS ="Meeting, Convention, and Event Planners" if occS== "725"
replace occS ="Fundraisers" if occS== "726"
replace occS ="Market Research Analysts and Marketing Specialists" if occS== "735"
replace occS ="Business Operations Specialists, All Other" if occS== "750"
replace occS ="Accountants and Auditors" if occS== "800"
replace occS ="Property Appraisers and Assessors" if occS== "810"
replace occS ="Budget Analysts" if occS== "820"
replace occS ="Credit Analysts" if occS== "830"
replace occS ="Financial and Investment Analysts" if occS== "845"
replace occS ="Personal Financial Advisors" if occS== "850"
replace occS ="Insurance Underwriters" if occS== "860"
replace occS ="Financial Examiners" if occS== "900"
replace occS ="Credit Counselors and Loan Officers" if occS== "910"
replace occS ="Tax Examiners and Collectors, and Revenue Agents" if occS== "930"
replace occS ="Tax Preparers" if occS== "940"
replace occS ="Other Financial Specialists" if occS== "960"
replace occS ="Computer and Information Research Scientists" if occS== "1005"
replace occS ="Computer Systems Analysts" if occS== "1006"
replace occS ="Information Security Analysts" if occS== "1007"
replace occS ="Computer Programmers" if occS== "1010"
replace occS ="Software Developers" if occS== "1021"
replace occS ="Software Quality Assurance Analysts and Testers" if occS== "1022"
replace occS ="Computer Support Specialists" if occS== "1050"
replace occS ="Database Administrators and Architects" if occS== "1065"
replace occS ="Web Developers" if occS== "1031"
replace occS ="Web and Digital Interface Designers" if occS== "1032"
replace occS ="Network and Computer Systems Administrators" if occS== "1105"
replace occS ="Computer Network Architects" if occS== "1106"
replace occS ="Computer Occupations, All Other" if occS== "1108"
replace occS ="Actuaries" if occS== "1200"
replace occS ="Mathematicians" if occS== "1210"
replace occS ="Operations Research Analysts" if occS== "1220"
replace occS ="Statisticians" if occS== "1230"
replace occS ="Other Mathematical Science Occupations" if occS== "1240"
replace occS ="Architects, Except Landscape and Naval" if occS== "1305"
replace occS ="Landscape Architects" if occS== "1306"
replace occS ="Surveyors, Cartographers, and Photogrammetrists" if occS== "1310"
replace occS ="Aerospace Engineers" if occS== "1320"
replace occS ="Agricultural Engineers" if occS== "1330"
replace occS ="Bioengineers and biomedical engineers" if occS== "1340"
replace occS ="Chemical Engineers" if occS== "1350"
replace occS ="Civil Engineers" if occS== "1360"
replace occS ="Computer Hardware Engineers" if occS== "1400"
replace occS ="Electrical and Electronics Engineers" if occS== "1410"
replace occS ="Environmental Engineers" if occS== "1420"
replace occS ="Industrial Engineers, including Health and Safety " if occS== "1430"
replace occS ="Marine Engineers and Naval Architects" if occS== "1440"
replace occS ="Materials Engineers" if occS== "1450"
replace occS ="Mechanical Engineers" if occS== "1460"
replace occS ="Mining and Geological Engineers, Including Mining Safety Engineers" if occS== "1500"
replace occS ="Nuclear Engineers" if occS== "1510"
replace occS ="Petroleum Engineers" if occS== "1520"
replace occS ="Engineers, All Other" if occS== "1530"
replace occS ="Architectural and Civil Drafters" if occS== "1541"
replace occS ="Other Drafters" if occS== "1545"
replace occS ="Electrical and Electronic Engineering Technologists and Technicians" if occS== "1551"
replace occS ="Other Engineering Technologists and Technicians, Except Drafters" if occS== "1555"
replace occS ="Surveying and Mapping Technicians" if occS== "1560"
replace occS ="Agricultural and Food Scientists" if occS== "1600"
replace occS ="Biological Scientists" if occS== "1610"
replace occS ="Conservation Scientists and Foresters" if occS== "1640"
replace occS ="Medical Scientists" if occS== "1650"
replace occS ="Life Scientists, All Other" if occS== "1660"
replace occS ="Astronomers and Physicists" if occS== "1700"
replace occS ="Atmospheric and Space Scientists" if occS== "1710"
replace occS ="Chemists and Materials Scientists" if occS== "1720"
replace occS ="Environmental Scientists and Specialists, Including Health" if occS== "1745"
replace occS ="Geoscientists and Hydrologists, Except Geographers" if occS== "1750"
replace occS ="Physical Scientists, All Other" if occS== "1760"
replace occS ="Economists" if occS== "1800"
replace occS ="Survey Researchers" if occS== "1815"
replace occS ="Clinical and Counseling Psychologists" if occS== "1821"
replace occS ="School Psychologists" if occS== "1822"
replace occS ="Other Psychologists" if occS== "1825"
replace occS ="Sociologists" if occS== "1830"
replace occS ="Urban and Regional Planners" if occS== "1840"
replace occS ="Miscellaneous Social Scientists and Related Workers" if occS== "1860"
replace occS ="Agricultural and Food Science Technicians" if occS== "1900"
replace occS ="Biological Technicians" if occS== "1910"
replace occS ="Chemical Technicians" if occS== "1920"
replace occS ="Environmental Science and Geoscience Technicians" if occS== "1935"
replace occS ="Nuclear Technicians" if occS== "1940"
replace occS ="Social Science Research Assistants" if occS== "1950"
replace occS ="Other Life, Physical, and Social Science Technicians" if occS== "1970"
replace occS ="Occupational Health and Safety Specialists and Technicians" if occS== "1980"
replace occS ="Substance Abuse and Behavioral Disorder Counselors" if occS== "2001"
replace occS ="Educational, Guidance, and Career Counselors and Advisors" if occS== "2002"
replace occS ="Marriage and Family Therapists" if occS== "2003"
replace occS ="Mental Health Counselors" if occS== "2004"
replace occS ="Rehabilitation Counselors" if occS== "2005"
replace occS ="Counselors, All Other" if occS== "2006"
replace occS ="Child, Family, and School Social Workers" if occS== "2011"
replace occS ="Healthcare Social Workers" if occS== "2012"
replace occS ="Mental Health and Substance Abuse Social Workers" if occS== "2013"
replace occS ="Social Workers, All Other" if occS== "2014"
replace occS ="Probation Officers and Correctional Treatment Specialists" if occS== "2015"
replace occS ="Social and Human Service Assistants" if occS== "2016"
replace occS ="Other Community and Social Service Specialists" if occS== "2025"
replace occS ="Clergy" if occS== "2040"
replace occS ="Directors, Religious Activities and Education" if occS== "2050"
replace occS ="Religious Workers, All Other" if occS== "2060"
replace occS ="Lawyers" if occS== "2100"
replace occS ="Judicial Law Clerks" if occS== "2105"
replace occS ="Judges, Magistrates, and Other Judicial Workers" if occS== "2110"
replace occS ="Paralegals and Legal Assistants" if occS== "2145"
replace occS ="Title Examiners, Abstractors, and Searchers" if occS== "2170"
replace occS ="Legal Support Workers, All Other" if occS== "2180"
replace occS ="Postsecondary Teachers" if occS== "2205"
replace occS ="Preschool and Kindergarten Teachers" if occS== "2300"
replace occS ="Elementary and Middle School Teachers" if occS== "2310"
replace occS ="Secondary School Teachers" if occS== "2320"
replace occS ="Special Education Teachers" if occS== "2330"
replace occS ="Tutors" if occS== "2350"
replace occS ="Other Teachers and Instructors" if occS== "2360"
replace occS ="Archivists, Curators, and Museum Technicians" if occS== "2400"
replace occS ="Librarians and Media Collections Specialists" if occS== "2435"
replace occS ="Library Technicians" if occS== "2440"
replace occS ="Teaching Assistants" if occS== "2545"
replace occS ="Other Educational Instruction and Library Workers" if occS== "2555"
replace occS ="Artists and Related Workers" if occS== "2600"
replace occS ="Commercial and Industrial Designers" if occS== "2631"
replace occS ="Fashion Designers" if occS== "2632"
replace occS ="Floral Designers" if occS== "2633"
replace occS ="Graphic Designers" if occS== "2634"
replace occS ="Interior Designers" if occS== "2635"
replace occS ="Merchandise Displayers and Window Trimmers" if occS== "2636"
replace occS ="Other Designers" if occS== "2640"
replace occS ="Actors" if occS== "2700"
replace occS ="Producers and Directors" if occS== "2710"
replace occS ="Athletes and Sports Competitors" if occS== "2721"
replace occS ="Coaches and Scouts" if occS== "2722"
replace occS ="Umpires, Referees, and Other Sports Officials" if occS== "2723"
replace occS ="Dancers and Choreographers" if occS== "2740"
replace occS ="Music Directors and Composers" if occS== "2751"
replace occS ="Musicians and Singers" if occS== "2752"
replace occS ="Disc jockeys, except radio " if occS== "2755"
replace occS ="Entertainers and Performers, Sports and Related Workers, All Other" if occS== "2770"
replace occS ="Broadcast Announcers and Radio Disc Jockeys" if occS== "2805"
replace occS ="News Analysts, Reporters, and Journalists" if occS== "2810"
replace occS ="Public Relations Specialists" if occS== "2825"
replace occS ="Editors" if occS== "2830"
replace occS ="Technical Writers" if occS== "2840"
replace occS ="Writers and Authors" if occS== "2850"
replace occS ="Interpreters and Translators" if occS== "2861"
replace occS ="Court Reporters and Simultaneous Captioners" if occS== "2862"
replace occS ="Media and Communication Workers, All Other" if occS== "2865"
replace occS ="Broadcast, Sound, and Lighting Technicians" if occS== "2905"
replace occS ="Photographers" if occS== "2910"
replace occS ="Television, Video, and Film Camera Operators and Editors" if occS== "2920"
replace occS ="Media and Communication Equipment Workers, All Other" if occS== "2970"
replace occS ="Chiropractors" if occS== "3000"
replace occS ="Dentists" if occS== "3010"
replace occS ="Dietitians and Nutritionists" if occS== "3030"
replace occS ="Optometrists" if occS== "3040"
replace occS ="Pharmacists" if occS== "3050"
replace occS ="Emergency Medicine Physicians" if occS== "3065"
replace occS ="Radiologists" if occS== "3070"
replace occS ="Other Physicians" if occS== "3090"
replace occS ="Surgeons" if occS== "3100"
replace occS ="Physician Assistants" if occS== "3110"
replace occS ="Podiatrists" if occS== "3120"
replace occS ="Audiologists" if occS== "3140"
replace occS ="Occupational Therapists" if occS== "3150"
replace occS ="Physical Therapists" if occS== "3160"
replace occS ="Radiation Therapists" if occS== "3200"
replace occS ="Recreational Therapists" if occS== "3210"
replace occS ="Respiratory Therapists" if occS== "3220"
replace occS ="Speech-Language Pathologists" if occS== "3230"
replace occS ="Exercise Physiologists" if occS== "3235"
replace occS ="Therapists, All Other" if occS== "3245"
replace occS ="Veterinarians" if occS== "3250"
replace occS ="Registered Nurses" if occS== "3255"
replace occS ="Nurse Anesthetists" if occS== "3256"
replace occS ="Nurse Midwives" if occS== "3257"
replace occS ="Nurse Practitioners" if occS== "3258"
replace occS ="Acupuncturists" if occS== "3261"
replace occS ="Healthcare Diagnosing or Treating Practitioners, All Other" if occS== "3270"
replace occS ="Clinical Laboratory Technologists and Technicians" if occS== "3300"
replace occS ="Dental Hygienists" if occS== "3310"
replace occS ="Cardiovascular Technologists and Technicians" if occS== "3321"
replace occS ="Diagnostic Medical Sonographers" if occS== "3322"
replace occS ="Radiologic Technologists and Technicians" if occS== "3323"
replace occS ="Magnetic Resonance Imaging Technologists" if occS== "3324"
replace occS ="Nuclear Medicine Technologists and Medical Dosimetrists" if occS== "3330"
replace occS ="Emergency Medical Technicians" if occS== "3401"
replace occS ="Paramedics" if occS== "3402"
replace occS ="Pharmacy Technicians" if occS== "3421"
replace occS ="Psychiatric Technicians" if occS== "3422"
replace occS ="Surgical Technologists" if occS== "3423"
replace occS ="Veterinary Technologists and Technicians" if occS== "3424"
replace occS ="Dietetic Technicians and Ophthalmic Medical Technicians" if occS== "3430"
replace occS ="Licensed Practical and Licensed Vocational Nurses" if occS== "3500"
replace occS ="Medical Records Specialists" if occS== "3515"
replace occS ="Opticians, Dispensing" if occS== "3520"
replace occS ="Miscellaneous Health Technologists and Technicians" if occS== "3545"
replace occS ="Other Healthcare Practitioners and Technical Occupations" if occS== "3550"
replace occS ="Home Health Aides" if occS== "3601"
replace occS ="Personal Care Aides" if occS== "3602"
replace occS ="Nursing Assistants" if occS== "3603"
replace occS ="Orderlies and Psychiatric Aides" if occS== "3605"
replace occS ="Occupational Therapy Assistants and Aides" if occS== "3610"
replace occS ="Physical Therapist Assistants and Aides" if occS== "3620"
replace occS ="Massage Therapists" if occS== "3630"
replace occS ="Dental Assistants" if occS== "3640"
replace occS ="Medical Assistants" if occS== "3645"
replace occS ="Medical Transcriptionists" if occS== "3646"
replace occS ="Pharmacy Aides" if occS== "3647"
replace occS ="Veterinary Assistants and Laboratory Animal Caretakers" if occS== "3648"
replace occS ="Phlebotomists" if occS== "3649"
replace occS ="Other Healthcare Support Workers" if occS== "3655"
replace occS ="First-Line Supervisors of Correctional Officers" if occS== "3700"
replace occS ="First-Line Supervisors of Police and Detectives" if occS== "3710"
replace occS ="First-Line Supervisors of Firefighting and Prevention Workers" if occS== "3720"
replace occS ="First-Line Supervisors of Security Workers" if occS== "3725"
replace occS ="First-Line Supervisors of Protective Service Workers, All Other" if occS== "3735"
replace occS ="Firefighters" if occS== "3740"
replace occS ="Fire Inspectors " if occS== "3750"
replace occS ="Bailiffs" if occS== "3801"
replace occS ="Correctional Officers and Jailers" if occS== "3802"
replace occS ="Detectives and Criminal Investigators" if occS== "3820"
replace occS ="Fish and Game Wardens" if occS== "3830"
replace occS ="Parking Enforcement Workers" if occS== "3840"
replace occS ="Police Officers" if occS== "3870"
replace occS ="Animal Control Workers" if occS== "3900"
replace occS ="Private Detectives and Investigators" if occS== "3910"
replace occS ="Security Guards and Gambling Surveillance Officers" if occS== "3930"
replace occS ="Crossing Guards and Flaggers" if occS== "3940"
replace occS ="Transportation Security Screeners" if occS== "3945"
replace occS ="School Bus Monitors" if occS== "3946"
replace occS ="Other Protective Service Workers" if occS== "3960"
replace occS ="Chefs and Head Cooks" if occS== "4000"
replace occS ="First-Line Supervisors of Food Preparation and Serving Workers" if occS== "4010"
replace occS ="Cooks" if occS== "4020"
replace occS ="Food Preparation Workers" if occS== "4030"
replace occS ="Bartenders" if occS== "4040"
replace occS ="Fast Food and Counter Workers" if occS== "4055"
replace occS ="Waiters and Waitresses" if occS== "4110"
replace occS ="Food Servers, Nonrestaurant" if occS== "4120"
replace occS ="Dining Room and Cafeteria Attendants and Bartender Helpers" if occS== "4130"
replace occS ="Dishwashers" if occS== "4140"
replace occS ="Hosts and Hostesses, Restaurant, Lounge, and Coffee Shop" if occS== "4150"
replace occS ="Food Preparation and Serving Related Workers, All Other" if occS== "4160"
replace occS ="First-Line Supervisors of Housekeeping and Janitorial Workers" if occS== "4200"
replace occS ="First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers" if occS== "4210"
replace occS ="Janitors and Building Cleaners" if occS== "4220"
replace occS ="Maids and Housekeeping Cleaners" if occS== "4230"
replace occS ="Pest Control Workers" if occS== "4240"
replace occS ="Landscaping and Groundskeeping Workers" if occS== "4251"
replace occS ="Tree Trimmers and Pruners" if occS== "4252"
replace occS ="Other Grounds Maintenance Workers" if occS== "4255"
replace occS ="Supervisors of Personal Care and Service Workers" if occS== "4330"
replace occS ="Animal Trainers" if occS== "4340"
replace occS ="Animal Caretakers" if occS== "4350"
replace occS ="Gambling Services Workers" if occS== "4400"
replace occS ="Ushers, Lobby Attendants, and Ticket Takers" if occS== "4420"
replace occS ="Other Entertainment Attendants and Related Workers" if occS== "4435"
replace occS ="Embalmers, Crematory Operators and Funeral Attendants" if occS== "4461"
replace occS ="Morticians, Undertakers, and Funeral Arrangers" if occS== "4465"
replace occS ="Barbers" if occS== "4500"
replace occS ="Hairdressers, Hairstylists, and Cosmetologists" if occS== "4510"
replace occS ="Manicurists and Pedicurists" if occS== "4521"
replace occS ="Skincare Specialists" if occS== "4522"
replace occS ="Other Personal Appearance Workers" if occS== "4525"
replace occS ="Baggage Porters, Bellhops, and Concierges" if occS== "4530"
replace occS ="Tour and Travel Guides" if occS== "4540"
replace occS ="Childcare Workers" if occS== "4600"
replace occS ="Exercise Trainers and Group Fitness Instructors" if occS== "4621"
replace occS ="Recreation Workers" if occS== "4622"
replace occS ="Residential Advisors" if occS== "4640"
replace occS ="Personal Care and Service Workers, All Other" if occS== "4655"
replace occS ="First-Line Supervisors of Retail Sales Workers" if occS== "4700"
replace occS ="First-Line Supervisors of Non-Retail Sales Workers" if occS== "4710"
replace occS ="Cashiers" if occS== "4720"
replace occS ="Counter and Rental Clerks" if occS== "4740"
replace occS ="Parts Salespersons" if occS== "4750"
replace occS ="Retail Salespersons" if occS== "4760"
replace occS ="Advertising Sales Agents" if occS== "4800"
replace occS ="Insurance Sales Agents" if occS== "4810"
replace occS ="Securities, Commodities, and Financial Services Sales Agents" if occS== "4820"
replace occS ="Travel Agents" if occS== "4830"
replace occS ="Sales representatives of services, except advertising, insurance, financial services, and travel" if occS== "4840"
replace occS ="Sales Representatives, Wholesale and Manufacturing" if occS== "4850"
replace occS ="Models, Demonstrators, and Product Promoters" if occS== "4900"
replace occS ="Real Estate Brokers and Sales Agents" if occS== "4920"
replace occS ="Sales Engineers" if occS== "4930"
replace occS ="Telemarketers" if occS== "4940"
replace occS ="Door-to-Door Sales Workers, News and Street Vendors, and Related Workers" if occS== "4950"
replace occS ="Sales and Related Workers, All Other" if occS== "4965"
replace occS ="First-Line Supervisors of Office and Administrative Support Workers" if occS== "5000"
replace occS ="Switchboard Operators, Including Answering Service" if occS== "5010"
replace occS ="Telephone Operators" if occS== "5020"
replace occS ="Communications Equipment Operators, All Other" if occS== "5040"
replace occS ="Bill and Account Collectors" if occS== "5100"
replace occS ="Billing and Posting Clerks" if occS== "5110"
replace occS ="Bookkeeping, Accounting, and Auditing Clerks" if occS== "5120"
replace occS ="Gambling Cage Workers" if occS== "5130"
replace occS ="Payroll and Timekeeping Clerks" if occS== "5140"
replace occS ="Procurement Clerks" if occS== "5150"
replace occS ="Tellers" if occS== "5160"
replace occS ="Financial Clerks, All Other" if occS== "5165"
replace occS ="Brokerage Clerks" if occS== "5200"
replace occS ="Correspondence Clerks" if occS== "5210"
replace occS ="Court, Municipal, and License Clerks" if occS== "5220"
replace occS ="Credit Authorizers, Checkers, and Clerks" if occS== "5230"
replace occS ="Customer Service Representatives" if occS== "5240"
replace occS ="Eligibility Interviewers, Government Programs" if occS== "5250"
replace occS ="File Clerks" if occS== "5260"
replace occS ="Hotel, Motel, and Resort Desk Clerks" if occS== "5300"
replace occS ="Interviewers, Except Eligibility and Loan" if occS== "5310"
replace occS ="Library Assistants, Clerical" if occS== "5320"
replace occS ="Loan Interviewers and Clerks" if occS== "5330"
replace occS ="New Accounts Clerks" if occS== "5340"
replace occS ="Order Clerks" if occS== "5350"
replace occS ="Human Resources Assistants, Except Payroll and Timekeeping" if occS== "5360"
replace occS ="Receptionists and Information Clerks" if occS== "5400"
replace occS ="Reservation and Transportation Ticket Agents and Travel Clerks" if occS== "5410"
replace occS ="Information and Record Clerks, All Other" if occS== "5420"
replace occS ="Cargo and Freight Agents" if occS== "5500"
replace occS ="Couriers and Messengers" if occS== "5510"
replace occS ="Public Safety Telecommunicators" if occS== "5521"
replace occS ="Dispatchers, Except Police, Fire, and Ambulance" if occS== "5522"
replace occS ="Meter Readers, Utilities" if occS== "5530"
replace occS ="Postal Service Clerks" if occS== "5540"
replace occS ="Postal Service Mail Carriers" if occS== "5550"
replace occS ="Postal Service Mail Sorters, Processors, and Processing Machine Operators" if occS== "5560"
replace occS ="Production, Planning, and Expediting Clerks" if occS== "5600"
replace occS ="Shipping, Receiving, and Inventory Clerks" if occS== "5610"
replace occS ="Weighers, Measurers, Checkers, and Samplers, Recordkeeping" if occS== "5630"
replace occS ="Executive Secretaries and Executive Administrative Assistants" if occS== "5710"
replace occS ="Legal Secretaries and Administrative Assistants" if occS== "5720"
replace occS ="Medical Secretaries and Administrative Assistants" if occS== "5730"
replace occS ="Secretaries and Administrative Assistants, Except Legal, Medical, and Executive" if occS== "5740"
replace occS ="Data Entry Keyers" if occS== "5810"
replace occS ="Word Processors and Typists" if occS== "5820"
replace occS ="Desktop Publishers" if occS== "5830"
replace occS ="Insurance Claims and Policy Processing Clerks" if occS== "5840"
replace occS ="Mail Clerks and Mail Machine Operators, Except Postal Service" if occS== "5850"
replace occS ="Office Clerks, General" if occS== "5860"
replace occS ="Office Machine Operators, Except Computer" if occS== "5900"
replace occS ="Proofreaders and Copy Markers" if occS== "5910"
replace occS ="Statistical Assistants" if occS== "5920"
replace occS ="Office and Administrative Support Workers, All Other" if occS== "5940"
replace occS ="First-Line Supervisors of Farming, Fishing, and Forestry Workers" if occS== "6005"
replace occS ="Agricultural Inspectors" if occS== "6010"
replace occS ="Animal Breeders" if occS== "6020"
replace occS ="Graders and Sorters, Agricultural Products" if occS== "6040"
replace occS ="Miscellaneous Agricultural Workers" if occS== "6050"
replace occS ="Fishing and Hunting Workers" if occS== "6115"
replace occS ="Forest and Conservation Workers" if occS== "6120"
replace occS ="Logging Workers" if occS== "6130"
replace occS ="First-Line Supervisors of Construction Trades and Extraction Workers" if occS== "6200"
replace occS ="Boilermakers" if occS== "6210"
replace occS ="Brickmasons, Blockmasons, and Stonemasons" if occS== "6220"
replace occS ="Carpenters" if occS== "6230"
replace occS ="Carpet, Floor, and Tile Installers and Finishers" if occS== "6240"
replace occS ="Cement Masons, Concrete Finishers, and Terrazzo Workers" if occS== "6250"
replace occS ="Construction Laborers" if occS== "6260"
replace occS ="Construction Equipment Operators" if occS== "6305"
replace occS ="Drywall Installers, Ceiling Tile Installers, and Tapers" if occS== "6330"
replace occS ="Electricians" if occS== "6355"
replace occS ="Glaziers" if occS== "6360"
replace occS ="Insulation Workers" if occS== "6400"
replace occS ="Painters and Paperhangers" if occS== "6410"
replace occS ="Pipelayers" if occS== "6441"
replace occS ="Plumbers, Pipefitters, and Steamfitters" if occS== "6442"
replace occS ="Plasterers and Stucco Masons" if occS== "6460"
replace occS ="Reinforcing Iron and Rebar Workers" if occS== "6500"
replace occS ="Roofers" if occS== "6515"
replace occS ="Sheet Metal Workers" if occS== "6520"
replace occS ="Structural Iron and Steel Workers" if occS== "6530"
replace occS ="Solar Photovoltaic Installers" if occS== "6540"
replace occS ="Helpers, Construction Trades" if occS== "6600"
replace occS ="Construction and Building Inspectors" if occS== "6660"
replace occS ="Elevator and Escalator Installers and Repairers" if occS== "6700"
replace occS ="Fence Erectors" if occS== "6710"
replace occS ="Hazardous Materials Removal Workers" if occS== "6720"
replace occS ="Highway Maintenance Workers" if occS== "6730"
replace occS ="Rail-Track Laying and Maintenance Equipment Operators" if occS== "6740"
replace occS ="Septic Tank Servicers and Sewer Pipe Cleaners" if occS== "6750"
replace occS ="Miscellaneous Construction and Related Workers" if occS== "6765"
replace occS ="Derrick, Rotary Drill, and Service Unit Operators, Oil and Gas  " if occS== "6800"
replace occS ="Excavating and Loading Machine and Dragline Operators, Surface Mining" if occS== "6821"
replace occS ="Earth Drillers, Except Oil and Gas" if occS== "6825"
replace occS ="Explosives Workers, Ordnance Handling Experts, and Blasters" if occS== "6835"
replace occS ="Underground Mining Machine Operators" if occS== "6850"
replace occS ="Roustabouts, Oil and Gas" if occS== "6920"
replace occS ="Other Extraction Workers" if occS== "6950"
replace occS ="First-Line Supervisors of Mechanics, Installers, and Repairers" if occS== "7000"
replace occS ="Computer, Automated Teller, and Office Machine Repairers" if occS== "7010"
replace occS ="Radio and Telecommunications Equipment Installers and Repairers" if occS== "7020"
replace occS ="Avionics Technicians" if occS== "7030"
replace occS ="Electric Motor, Power Tool, and Related Repairers" if occS== "7040"
replace occS ="Electrical and Electronics Installers and Repairers, Transportation Equipment" if occS== "7050"
replace occS ="Electrical and Electronics Repairers, Industrial and Utility " if occS== "7100"
replace occS ="Electronic Equipment Installers and Repairers, Motor Vehicles" if occS== "7110"
replace occS ="Audiovisual Equipment Installers and Repairers" if occS== "7120"
replace occS ="Security and Fire Alarm Systems Installers" if occS== "7130"
replace occS ="Aircraft Mechanics and Service Technicians" if occS== "7140"
replace occS ="Automotive Body and Related Repairers" if occS== "7150"
replace occS ="Automotive Glass Installers and Repairers" if occS== "7160"
replace occS ="Automotive Service Technicians and Mechanics" if occS== "7200"
replace occS ="Bus and Truck Mechanics and Diesel Engine Specialists" if occS== "7210"
replace occS ="Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics" if occS== "7220"
replace occS ="Small Engine Mechanics" if occS== "7240"
replace occS ="Miscellaneous Vehicle and Mobile Equipment Mechanics, Installers, and Repairers" if occS== "7260"
replace occS ="Control and Valve Installers and Repairers" if occS== "7300"
replace occS ="Heating, Air Conditioning, and Refrigeration Mechanics and Installers" if occS== "7315"
replace occS ="Home Appliance Repairers" if occS== "7320"
replace occS ="Industrial and Refractory Machinery Mechanics" if occS== "7330"
replace occS ="Maintenance and Repair Workers, General" if occS== "7340"
replace occS ="Maintenance Workers, Machinery" if occS== "7350"
replace occS ="Millwrights" if occS== "7360"
replace occS ="Electrical Power-Line Installers and Repairers" if occS== "7410"
replace occS ="Telecommunications Line Installers and Repairers" if occS== "7420"
replace occS ="Precision Instrument and Equipment Repairers" if occS== "7430"
replace occS ="Wind Turbine Service Technicians" if occS== "7440"
replace occS ="Coin, Vending, and Amusement Machine Servicers and Repairers" if occS== "7510"
replace occS ="Commercial Divers" if occS== "7520"
replace occS ="Locksmiths and Safe Repairers" if occS== "7540"
replace occS ="Manufactured Building and Mobile Home Installers" if occS== "7550"
replace occS ="Riggers" if occS== "7560"
replace occS ="Helpers--Installation, Maintenance, and Repair Workers" if occS== "7610"
replace occS ="Other Installation, Maintenance, and Repair Workers" if occS== "7640"
replace occS ="First-Line Supervisors of Production and Operating Workers" if occS== "7700"
replace occS ="Aircraft Structure, Surfaces, Rigging, and Systems Assemblers" if occS== "7710"
replace occS ="Electrical, Electronics, and Electromechanical Assemblers" if occS== "7720"
replace occS ="Engine and Other Machine Assemblers" if occS== "7730"
replace occS ="Structural Metal Fabricators and Fitters" if occS== "7740"
replace occS ="Other Assemblers and Fabricators" if occS== "7750"
replace occS ="Bakers" if occS== "7800"
replace occS ="Butchers and Other Meat, Poultry, and Fish Processing Workers" if occS== "7810"
replace occS ="Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders" if occS== "7830"
replace occS ="Food Batchmakers" if occS== "7840"
replace occS ="Food Cooking Machine Operators and Tenders" if occS== "7850"
replace occS ="Food Processing Workers, All Other" if occS== "7855"
replace occS ="Computer numerically controlled tool operators and programmers" if occS== "7905"
replace occS ="Forming Machine Setters, Operators, and Tenders, Metal and Plastic" if occS== "7925"
replace occS ="Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic" if occS== "7950"
replace occS ="Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic" if occS== "8000"
replace occS ="Other Machine Tool Setters, Operators, and Tenders, Metal and Plastic" if occS== "8025"
replace occS ="Machinists" if occS== "8030"
replace occS ="Metal Furnace Operators, Tenders, Pourers, and Casters" if occS== "8040"
replace occS ="Model Makers and Patternmakers, Metal and Plastic" if occS== "8060"
replace occS ="Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic" if occS== "8100"
replace occS ="Tool and Die Makers" if occS== "8130"
replace occS ="Welding, Soldering, and Brazing Workers" if occS== "8140"
replace occS ="Other Metal Workers and Plastic Workers" if occS== "8225"
replace occS ="Prepress Technicians and Workers" if occS== "8250"
replace occS ="Printing Press Operators" if occS== "8255"
replace occS ="Print Binding and Finishing Workers" if occS== "8256"
replace occS ="Laundry and Dry-Cleaning Workers" if occS== "8300"
replace occS ="Pressers, Textile, Garment, and Related Materials" if occS== "8310"
replace occS ="Sewing Machine Operators" if occS== "8320"
replace occS ="Shoe and Leather Workers" if occS== "8335"
replace occS ="Tailors, Dressmakers, and Sewers" if occS== "8350"
replace occS ="Textile Machine Setters, Operators, and Tenders" if occS== "8365"
replace occS ="Upholsterers" if occS== "8450"
replace occS ="Other Textile, Apparel, and Furnishings Workers" if occS== "8465"
replace occS ="Cabinetmakers and Bench Carpenters" if occS== "8500"
replace occS ="Furniture Finishers" if occS== "8510"
replace occS ="Sawing Machine Setters, Operators, and Tenders, Wood" if occS== "8530"
replace occS ="Woodworking Machine Setters, Operators, and Tenders, Except Sawing" if occS== "8540"
replace occS ="Other Woodworkers" if occS== "8555"
replace occS ="Power Plant Operators, Distributors, and Dispatchers" if occS== "8600"
replace occS ="Stationary Engineers and Boiler Operators" if occS== "8610"
replace occS ="Water and Wastewater Treatment Plant and System Operators" if occS== "8620"
replace occS ="Miscellaneous Plant and System Operators" if occS== "8630"
replace occS ="Chemical Processing Machine Setters, Operators, and Tenders" if occS== "8640"
replace occS ="Crushing, Grinding, Polishing, Mixing, and Blending Workers" if occS== "8650"
replace occS ="Cutting Workers" if occS== "8710"
replace occS ="Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders" if occS== "8720"
replace occS ="Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders" if occS== "8730"
replace occS ="Inspectors, Testers, Sorters, Samplers, and Weighers" if occS== "8740"
replace occS ="Jewelers and Precious Stone and Metal Workers" if occS== "8750"
replace occS ="Dental and Ophthalmic Laboratory Technicians and Medical Appliance Technicians" if occS== "8760"
replace occS ="Packaging and Filling Machine Operators and Tenders" if occS== "8800"
replace occS ="Painting Workers" if occS== "8810"
replace occS ="Photographic Process Workers and Processing Machine Operators" if occS== "8830"
replace occS ="Adhesive Bonding Machine Operators and Tenders" if occS== "8850"
replace occS ="Etchers and Engravers" if occS== "8910"
replace occS ="Molders, Shapers, and Casters, Except Metal and Plastic" if occS== "8920"
replace occS ="Paper Goods Machine Setters, Operators, and Tenders" if occS== "8930"
replace occS ="Tire Builders" if occS== "8940"
replace occS ="Helpers--Production Workers" if occS== "8950"
replace occS ="Other Production Equipment Operators and Tenders" if occS== "8865"
replace occS ="Other Production Workers" if occS== "8990"
replace occS ="Supervisors of Transportation and Material Moving Workers" if occS== "9005"
replace occS ="Aircraft Pilots and Flight Engineers" if occS== "9030"
replace occS ="Air Traffic Controllers and Airfield Operations Specialists" if occS== "9040"
replace occS ="Flight Attendants" if occS== "9050"
replace occS ="Ambulance Drivers and Attendants, Except Emergency Medical Technicians" if occS== "9110"
replace occS ="Bus Drivers, School" if occS== "9121"
replace occS ="Bus Drivers, Transit and Intercity" if occS== "9122"
replace occS ="Driver/Sales Workers and Truck Drivers" if occS== "9130"
replace occS ="Shuttle Drivers and Chauffeurs" if occS== "9141"
replace occS ="Taxi Drivers" if occS== "9142"
replace occS ="Motor Vehicle Operators, All Other" if occS== "9150"
replace occS ="Locomotive Engineers and Operators" if occS== "9210"
replace occS ="Railroad Conductors and Yardmasters" if occS== "9240"
replace occS ="Other Rail Transportation Workers" if occS== "9265"
replace occS ="Sailors and Marine Oilers" if occS== "9300"
replace occS ="Ship Engineers " if occS== "9330"
replace occS ="Ship and Boat Captains and Operators" if occS== "9310"
replace occS ="Parking Attendants" if occS== "9350"
replace occS ="Transportation Service Attendants" if occS== "9365"
replace occS ="Transportation Inspectors" if occS== "9410"
replace occS ="Passenger Attendants" if occS== "9415"
replace occS ="Other Transportation Workers" if occS== "9430"
replace occS ="Crane and Tower Operators" if occS== "9510"
replace occS ="Conveyor, Dredge, and Hoist and Winch Operators" if occS== "9570"
replace occS ="Industrial Truck and Tractor Operators" if occS== "9600"
replace occS ="Cleaners of Vehicles and Equipment" if occS== "9610"
replace occS ="Laborers and Freight, Stock, and Material Movers, Hand" if occS== "9620"
replace occS ="Machine Feeders and Offbearers" if occS== "9630"
replace occS ="Packers and Packagers, Hand" if occS== "9640"
replace occS ="Stockers and Order Fillers" if occS== "9645"
replace occS ="Pumping Station Operators" if occS== "9650"
replace occS ="Refuse and Recyclable Material Collectors" if occS== "9720"
replace occS ="Other Material Moving Workers" if occS== "9760"
replace occS ="Military Officer Special and Tactical Operations Leaders" if occS== "9800"
replace occS ="First-Line Enlisted Military Supervisors" if occS== "9810"
replace occS ="Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members" if occS== "9825"
replace occS ="Military, Rank Not Specified" if occS== "9830"
replace occS ="Unemployed, with no work experience in the last 5 years or earlier or never worked" if occS== "9920"
replace occS ="Marketing and sales managers" if occS== "50"
replace occS ="Administrative services managers" if occS== "100"
replace occS ="Gaming managers" if occS== "330"
replace occS ="Managers, all other" if occS== "430"
replace occS ="Business operations specialists, all other" if occS== "740"
replace occS ="Financial analysts" if occS== "840"
replace occS ="Financial specialists, all other" if occS== "950"
replace occS ="Software developers, applications and systems software" if occS== "1020"
replace occS ="Web developers" if occS== "1030"
replace occS ="Database administrators" if occS== "1060"
replace occS ="Computer occupations, all other" if occS== "1107"
replace occS ="Architects, except naval" if occS== "1300"
replace occS ="Drafters" if occS== "1540"
replace occS ="Engineering technicians, except drafters" if occS== "1550"
replace occS ="Environmental scientists and geoscientists" if occS== "1740"
replace occS ="Psychologists" if occS== "1820"
replace occS ="Geological and petroleum technicians" if occS== "1930"
replace occS ="Miscellaneous life, physical, and social science technicians" if occS== "1965"
replace occS ="Counselors" if occS== "2000"
replace occS ="Social workers" if occS== "2010"
replace occS ="Miscellaneous legal support workers" if occS== "2160"
replace occS ="Postsecondary teachers" if occS== "2200"
replace occS ="Other teachers and instructors" if occS== "2340"
replace occS ="Librarians" if occS== "2430"
replace occS ="Teacher assistants" if occS== "2540"
replace occS ="Other education, training, and library workers" if occS== "2550"
replace occS ="Designers" if occS== "2630"
replace occS ="Athletes, coaches, umpires, and related workers" if occS== "2720"
replace occS ="Musicians, singers, and related workers" if occS== "2750"
replace occS ="Entertainers and performers, sports and related workers, all other" if occS== "2760"
replace occS ="Announcers" if occS== "2800"
replace occS ="Miscellaneous media and communication workers" if occS== "2860"
replace occS ="Broadcast and sound engineering technicians and radio operators" if occS== "2900"
replace occS ="Media and communication equipment workers, all other" if occS== "2960"
replace occS ="Physicians and surgeons" if occS== "3060"
replace occS ="Health diagnosing and treating practitioners, all other" if occS== "3260"
replace occS ="Diagnostic related technologists and technicians" if occS== "3320"
replace occS ="Emergency medical technicians and paramedics" if occS== "3400"
replace occS ="Health practitioner support technologists and technicians" if occS== "3420"
replace occS ="Medical records and health information technicians" if occS== "3510"
replace occS ="Miscellaneous health technologists and technicians" if occS== "3535"
replace occS ="Other healthcare practitioners and technical occupations" if occS== "3540"
replace occS ="Nursing, psychiatric, and home health aides" if occS== "3600"
replace occS ="First-line supervisors of protective service workers, all other" if occS== "3730"
replace occS ="Bailiffs, correctional officers, and jailers" if occS== "3800"
replace occS ="Police and sheriff's patrol officers" if occS== "3850"
replace occS ="Transit and railroad police" if occS== "3860"
replace occS ="Lifeguards and other recreational, and all other protective service workers" if occS== "3955"
replace occS ="Combined food preparation and serving workers, including fast food" if occS== "4050"
replace occS ="Counter attendants, cafeteria, food concession, and coffee shop" if occS== "4060"
replace occS ="Grounds maintenance workers" if occS== "4250"
replace occS ="First-line supervisors of gaming workers" if occS== "4300"
replace occS ="First-line supervisors of personal service workers" if occS== "4320"
replace occS ="Motion picture projectionists" if occS== "4410"
replace occS ="Miscellaneous entertainment attendants and related workers" if occS== "4430"
replace occS ="Embalmers and funeral attendants" if occS== "4460"
replace occS ="Miscellaneous personal appearance workers" if occS== "4520"
replace occS ="Personal care aides" if occS== "4610"
replace occS ="Recreation and fitness workers" if occS== "4620"
replace occS ="Personal care and service workers, all other " if occS== "4650"
replace occS ="Communications equipment operators, all other" if occS== "5030"
replace occS ="Dispatchers" if occS== "5520"
replace occS ="Stock clerks and order fillers" if occS== "5620"
replace occS ="Secretaries and administrative assistants" if occS== "5700"
replace occS ="Computer operators" if occS== "5800"
replace occS ="Fishers and related fishing workers" if occS== "6100"
replace occS ="Hunters and trappers" if occS== "6110"
replace occS ="Paving, surfacing, and tamping equipment operators" if occS== "6300"
replace occS ="Pile-driver operators" if occS== "6310"
replace occS ="Operating engineers and other construction equipment operators" if occS== "6320"
replace occS ="Painters, construction and maintenance" if occS== "6420"
replace occS ="Paperhangers" if occS== "6430"
replace occS ="Pipelayers, plumbers, pipefitters, and steamfitters" if occS== "6440"
replace occS ="Earth drillers, except oil and gas" if occS== "6820"
replace occS ="Explosives workers, ordnance handling experts, and blasters" if occS== "6830"
replace occS ="Mining machine operators" if occS== "6840"
replace occS ="Roof bolters, mining" if occS== "6910"
replace occS ="Helpers--extraction workers" if occS== "6930"
replace occS ="Other extraction workers" if occS== "6940"
replace occS ="Signal and track switch repairers" if occS== "7600"
replace occS ="Other installation, maintenance, and repair workers" if occS== "7630"
replace occS ="Computer control programmers and operators" if occS== "7900"
replace occS ="Extruding and drawing machine setters, operators, and tenders, metal and plastic" if occS== "7920"
replace occS ="Forging machine setters, operators, and tenders, metal and plastic" if occS== "7930"
replace occS ="Rolling machine setters, operators, and tenders, metal and plastic" if occS== "7940"
replace occS ="Drilling and boring machine tool setters, operators, and tenders, metal and plastic " if occS== "7960"
replace occS ="Lathe and turning machine tool setters, operators, and tenders, metal and plastic" if occS== "8010"
replace occS ="Milling and planing machine setters, operators, and tenders, metal and plastic" if occS== "8020"
replace occS ="Multiple machine tool setters, operators, and tenders, metal and plastic " if occS== "8120"
replace occS ="Heat treating equipment setters, operators, and tenders, metal and plastic" if occS== "8150"
replace occS ="Layout workers, metal and plastic" if occS== "8160"
replace occS ="Plating and coating machine setters, operators, and tenders, metal and plastic" if occS== "8200"
replace occS ="Tool grinders, filers, and sharpeners" if occS== "8210"
replace occS ="Metal workers and plastic workers, all other" if occS== "8220"
replace occS ="Shoe and leather workers and repairers" if occS== "8330"
replace occS ="Shoe machine operators and tenders" if occS== "8340"
replace occS ="Textile bleaching and dyeing machine operators and tenders" if occS== "8360"
replace occS ="Textile cutting machine setters, operators, and tenders" if occS== "8400"
replace occS ="Textile knitting and weaving machine setters, operators, and tenders" if occS== "8410"
replace occS ="Textile winding, twisting, and drawing out machine setters, operators, and tenders" if occS== "8420"
replace occS ="Extruding and forming machine setters, operators, and tenders, synthetic and glass fibers" if occS== "8430"
replace occS ="Fabric and apparel patternmakers" if occS== "8440"
replace occS ="Textile, apparel, and furnishings workers, all other" if occS== "8460"
replace occS ="Model makers and patternmakers, wood" if occS== "8520"
replace occS ="Woodworkers, all other" if occS== "8550"
replace occS ="Semiconductor processors" if occS== "8840"
replace occS ="Cleaning, washing, and metal pickling equipment operators and tenders" if occS== "8860"
replace occS ="Cooling and freezing equipment operators and tenders" if occS== "8900"
replace occS ="Production workers, all other" if occS== "8965"
replace occS ="Supervisors of transportation and material moving workers" if occS== "9000"
replace occS ="Bus drivers" if occS== "9120"
replace occS ="Taxi drivers and chauffeurs" if occS== "9140"
replace occS ="Locomotive engineers and operators" if occS== "9200"
replace occS ="Railroad brake, signal, and switch operators" if occS== "9230"
replace occS ="Subway, streetcar, and other rail transportation workers" if occS== "9260"
replace occS ="Bridge and lock tenders" if occS== "9340"
replace occS ="Automotive and watercraft service attendants   " if occS== "9360"
replace occS ="Other transportation workers " if occS== "9420"
replace occS ="Conveyor operators and tenders" if occS== "9500"
replace occS ="Dredge, excavating, and loading machine operators" if occS== "9520"
replace occS ="Hoist and winch operators" if occS== "9560"
replace occS ="Mine shuttle car operators" if occS== "9730"
replace occS ="Tank car, truck, and ship loaders" if occS== "9740"
replace occS ="Material moving workers, all other" if occS== "9750"
replace occS ="Military enlisted tactical operations and air/weapons specialists and crew members" if occS== "9820"
replace occS ="Human resources managers" if occS== "130"
replace occS ="Farm, ranch, and other agricultural managers" if occS== "200"
replace occS ="Farmers and ranchers" if occS== "210"
replace occS ="Funeral directors" if occS== "320"
replace occS ="Compliance officers, except agriculture, construction, health and safety, and transportation" if occS== "560"
replace occS ="Human resources, training, and labor relations specialists" if occS== "620"
replace occS ="Meeting and convention planners" if occS== "720"
replace occS ="Other business operations specialists" if occS== "730"
replace occS ="Computer scientists and systems analysts" if occS== "1000"
replace occS ="Computer support specialists" if occS== "1040"
replace occS ="Network and computer systems administrators" if occS== "1100"
replace occS ="Network systems and data communications analysts" if occS== "1110"
replace occS ="Market and survey researchers" if occS== "1810"
replace occS ="Other life, physical, and social science technicians" if occS== "1960"
replace occS ="Miscellaneous community and social service specialists" if occS== "2020"
replace occS ="Paralegals and legal assistants" if occS== "2140"
replace occS ="Miscellaneous legal support workers" if occS== "2150"
replace occS ="Public relations specialists" if occS== "2820"
replace occS ="Registered nurses" if occS== "3130"
replace occS ="Therapists, all other" if occS== "3240"
replace occS ="Health diagnosing and treating practitioner support technicians" if occS== "3410"
replace occS ="Miscellaneous health technologists and technicians" if occS== "3530"
replace occS ="Medical assistants and other healthcare support occupations" if occS== "3650"
replace occS ="Security guards and gaming surveillance officers" if occS== "3920"
replace occS ="Lifeguards and other protective service workers" if occS== "3950"
replace occS ="Transportation attendants" if occS== "4550"
replace occS ="Sales and related workers, all other" if occS== "4960"
replace occS ="Office and administrative support workers, all other" if occS== "5930"
replace occS ="First-line supervisors/managers of farming, fishing, and forestry workers" if occS== "6000"
replace occS ="Electricians" if occS== "6350"
replace occS ="Roofers" if occS== "6510"
replace occS ="Miscellaneous construction and related workers" if occS== "6760"
replace occS ="Heating, air conditioning, and refrigeration mechanics and installers" if occS== "7310"
replace occS ="Other installation, maintenance, and repair workers" if occS== "7620"
replace occS ="Bookbinders and bindery workers" if occS== "8230"
replace occS ="Job printers" if occS== "8240"
replace occS ="Printing machine operators" if occS== "8260"
replace occS ="Production workers, all other" if occS== "8960"

replace degfieldS = "N/A" if degfieldS ==	"9999"
replace degfieldS = "Agriculture" if degfieldS ==	"11"
replace degfieldS = "Environment and Natural Resources" if degfieldS ==	"13"
replace degfieldS = "Architecture" if degfieldS ==	"14"
replace degfieldS = "Area, Ethnic, and Civilization Studies" if degfieldS ==	"15"
replace degfieldS = "Communications" if degfieldS ==	"19"
replace degfieldS = "Communication Technologies" if degfieldS ==	"20"
replace degfieldS = "Computer and Information Sciences" if degfieldS ==	"21"
replace degfieldS = "Cosmetology Services and Culinary Arts" if degfieldS ==	"22"
replace degfieldS = "Education Administration and Teaching" if degfieldS ==	"23"
replace degfieldS = "Engineering" if degfieldS ==	"24"
replace degfieldS = "Engineering Technologies" if degfieldS ==	"25"
replace degfieldS = "Linguistics and Foreign Languages" if degfieldS ==	"26"
replace degfieldS = "Family and Consumer Sciences" if degfieldS ==	"29"
replace degfieldS = "Law" if degfieldS ==	"32"
replace degfieldS = "English Language, Literature, and Composition" if degfieldS ==	"33"
replace degfieldS = "Liberal Arts and Humanities" if degfieldS ==	"34"
replace degfieldS = "Library Science" if degfieldS ==	"35"
replace degfieldS = "Biology and Life Sciences" if degfieldS ==	"36"
replace degfieldS = "Mathematics and Statistics" if degfieldS ==	"37"
replace degfieldS = "Military Technologies" if degfieldS ==	"38"
replace degfieldS = "Interdisciplinary and Multi-Disciplinary Studies (General)" if degfieldS ==	"40"
replace degfieldS = "Physical Fitness, Parks, Recreation, and Leisure" if degfieldS ==	"41"
replace degfieldS = "Philosophy and Religious Studies" if degfieldS ==	"48"
replace degfieldS = "Theology and Religious Vocations" if degfieldS ==	"49"
replace degfieldS = "Physical Sciences" if degfieldS ==	"50"
replace degfieldS = "Nuclear, Industrial Radiology, and Biological Technologies" if degfieldS ==	"51"
replace degfieldS = "Psychology" if degfieldS ==	"52"
replace degfieldS = "Criminal Justice and Fire Protection" if degfieldS ==	"53"
replace degfieldS = "Public Affairs, Policy, and Social Work" if degfieldS ==	"54"
replace degfieldS = "Social Sciences" if degfieldS ==	"55"
replace degfieldS = "Construction Services" if degfieldS ==	"56"
replace degfieldS = "Electrical and Mechanic Repairs and Technologies" if degfieldS ==	"57"
replace degfieldS = "Precision Production and Industrial Arts" if degfieldS ==	"58"
replace degfieldS = "Transportation Sciences and Technologies" if degfieldS ==	"59"
replace degfieldS = "Fine Arts" if degfieldS ==	"60"
replace degfieldS = "Medical and Health Sciences and Services" if degfieldS ==	"61"
replace degfieldS = "Business" if degfieldS ==	"62"
replace degfieldS = "History" if degfieldS ==	"64"

