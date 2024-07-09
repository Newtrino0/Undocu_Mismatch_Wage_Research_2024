*** SET DIRECTORIES
**Copy and paste the following User tags
*XCITE-admin
*mario

global dofiles "C:\Users\XCITE-admin\Documents\GitHub\MSRIP_Stata_Work\MSRIP Data prep DO"

global rawdata "C:\Users\XCITE-admin\Documents\Local_XCITE_MSRIP\MSRIP_Data"

*** SET CODE
cap log close
set more off, perm

					 ***********************************************
************************ STEP 1: PREPARE MAIN CENSUS DATA ************************
					 ***********************************************

******************************
*** READ DATA
******************************
*sample: people aged 20-44 who are US born workers
cd $rawdata
use "usa_00011.dta", clear
describe

********* Clean data ***********
replace occ=. if occ==0
drop if missing(occ)

replace degfield =0 if degfield==.

drop if incwage == 999999
drop if bpl >=100
drop if empstat !=1
********************************
/* Filters applied in Clean data section, includes:

1.) People with an occupation listed
2.) People who earned a wage/salary
3.) People born in the US (excluding US territories like Puerto Rico)
4.) People who are employed

*/


					 ***********************************************
************************ STEP 2: Create relevant variables (VERTICAL MISMATCH) ************************
					 ***********************************************
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

*Remove empty fields for occupation denoted by a 0, and empty fields for yrsed denoted by 0 and 999
replace yrsed=. if yrsed==1 | yrsed==999
drop if missing(yrsed)
					 
***********Educational attainment category variable, requirements for an occupation***************
*create a categorical variable of the educational attainment categories


gen edu_cat="HS or less" if yrsed<=12
replace edu_cat="College" if yrsed>12

gen edu_att = 4 if educd>=101
replace edu_att = 3 if educd<101
replace edu_att = 2 if educd<65
replace edu_att = 1 if educd<62


sort occ edu_cat

by occ edu_cat : gen count=_N
by occ : gen total=_N
gen proportion=count/total

by occ: egen mode_cat = mode(edu_cat)
by occ: egen mode_att = mode(edu_att)

keep occ yrsed degfield incwage mode_cat mode_att
***************************************************************************************************

*collapse the data by occ code, keep (or construct when you collapse) the median yrs of education for the occ, the most frequent degfield
table occ, stat(freq) stat(median yrsed)

egen mean_wage=mean(incwage), by(occ)

*college degree requirements for an occupation





*filter for largest two values by occ
* Subset the data for the specific group

					 ***********************************************
************************ STEP 2: Create relevant variables (HORIZONTAL MISMATCH) ************************
					 ***********************************************
*egen method*
sort occ degfield

by occ: egen mode1_deg = mode(degfield) if degfield!=0
by occ: egen mode2_deg = mode(degfield) if degfield!=mode1_deg & degfield!=0

*Count method*
/*
local v = 1
while `v' <= 2 {
    by occ degfield, sort: gen `count' = _N
	egen `max_count' = max(`count')
    local ++v
}
foreach newlist count01-count02 {
	by occ degfield, sort: gen `count' = _N
	egen `max_count' = max(`count')
}

*Correctly counts number of occurences of degfield for each occ
by occ degfield, sort: gen count2=_N
*Creates column with max value of count2
egen max_count2 = max(count2)
*Correctly tabulates frequencies of degfield for occ
list occ degfield count2 max_count2
*/

*collapse so that there is one row per occupational code
collapse (median)med_yrs=yrsed (mean)mode1_deg (mean)mode2_deg (mean)mean_wage=incwage (median)med_wage=incwage (mean)mode_att, by(occ)

gen mode1_degS = string(mode1_deg)
gen mode2_degS = string(mode2_deg)
gen occS = string(occ)
gen mode_attS = string(mode_att)

*****************************************Label after collapsing*********************************************************************
replace mode1_degS = "N/A" if mode1_degS ==	"0"
replace mode1_degS = "Agriculture" if mode1_degS ==	"11"
replace mode1_degS = "Environment and Natural Resources" if mode1_degS ==	"13"
replace mode1_degS = "Architecture" if mode1_degS ==	"14"
replace mode1_degS = "Area, Ethnic, and Civilization Studies" if mode1_degS ==	"15"
replace mode1_degS = "Communications" if mode1_degS ==	"19"
replace mode1_degS = "Communication Technologies" if mode1_degS ==	"20"
replace mode1_degS = "Computer and Information Sciences" if mode1_degS ==	"21"
replace mode1_degS = "Cosmetology Services and Culinary Arts" if mode1_degS ==	"22"
replace mode1_degS = "Education Administration and Teaching" if mode1_degS ==	"23"
replace mode1_degS = "Engineering" if mode1_degS ==	"24"
replace mode1_degS = "Engineering Technologies" if mode1_degS ==	"25"
replace mode1_degS = "Linguistics and Foreign Languages" if mode1_degS ==	"26"
replace mode1_degS = "Family and Consumer Sciences" if mode1_degS ==	"29"
replace mode1_degS = "Law" if mode1_degS ==	"32"
replace mode1_degS = "English Language, Literature, and Composition" if mode1_degS ==	"33"
replace mode1_degS = "Liberal Arts and Humanities" if mode1_degS ==	"34"
replace mode1_degS = "Library Science" if mode1_degS ==	"35"
replace mode1_degS = "Biology and Life Sciences" if mode1_degS ==	"36"
replace mode1_degS = "Mathematics and Statistics" if mode1_degS ==	"37"
replace mode1_degS = "Military Technologies" if mode1_degS ==	"38"
replace mode1_degS = "Interdisciplinary and Multi-Disciplinary Studies (General)" if mode1_degS ==	"40"
replace mode1_degS = "Physical Fitness, Parks, Recreation, and Leisure" if mode1_degS ==	"41"
replace mode1_degS = "Philosophy and Religious Studies" if mode1_degS ==	"48"
replace mode1_degS = "Theology and Religious Vocations" if mode1_degS ==	"49"
replace mode1_degS = "Physical Sciences" if mode1_degS ==	"50"
replace mode1_degS = "Nuclear, Industrial Radiology, and Biological Technologies" if mode1_degS ==	"51"
replace mode1_degS = "Psychology" if mode1_degS ==	"52"
replace mode1_degS = "Criminal Justice and Fire Protection" if mode1_degS ==	"53"
replace mode1_degS = "Public Affairs, Policy, and Social Work" if mode1_degS ==	"54"
replace mode1_degS = "Social Sciences" if mode1_degS ==	"55"
replace mode1_degS = "Construction Services" if mode1_degS ==	"56"
replace mode1_degS = "Electrical and Mechanic Repairs and Technologies" if mode1_degS ==	"57"
replace mode1_degS = "Precision Production and Industrial Arts" if mode1_degS ==	"58"
replace mode1_degS = "Transportation Sciences and Technologies" if mode1_degS ==	"59"
replace mode1_degS = "Fine Arts" if mode1_degS ==	"60"
replace mode1_degS = "Medical and Health Sciences and Services" if mode1_degS ==	"61"
replace mode1_degS = "Business" if mode1_degS ==	"62"
replace mode1_degS = "History" if mode1_degS ==	"64"

replace mode2_degS = "N/A" if mode2_degS ==	"0"
replace mode2_degS = "Agriculture" if mode2_degS ==	"11"
replace mode2_degS = "Environment and Natural Resources" if mode2_degS ==	"13"
replace mode2_degS = "Architecture" if mode2_degS ==	"14"
replace mode2_degS = "Area, Ethnic, and Civilization Studies" if mode2_degS ==	"15"
replace mode2_degS = "Communications" if mode2_degS ==	"19"
replace mode2_degS = "Communication Technologies" if mode2_degS ==	"20"
replace mode2_degS = "Computer and Information Sciences" if mode2_degS ==	"21"
replace mode2_degS = "Cosmetology Services and Culinary Arts" if mode2_degS ==	"22"
replace mode2_degS = "Education Administration and Teaching" if mode2_degS ==	"23"
replace mode2_degS = "Engineering" if mode2_degS ==	"24"
replace mode2_degS = "Engineering Technologies" if mode2_degS ==	"25"
replace mode2_degS = "Linguistics and Foreign Languages" if mode2_degS ==	"26"
replace mode2_degS = "Family and Consumer Sciences" if mode2_degS ==	"29"
replace mode2_degS = "Law" if mode2_degS ==	"32"
replace mode2_degS = "English Language, Literature, and Composition" if mode2_degS ==	"33"
replace mode2_degS = "Liberal Arts and Humanities" if mode2_degS ==	"34"
replace mode2_degS = "Library Science" if mode2_degS ==	"35"
replace mode2_degS = "Biology and Life Sciences" if mode2_degS ==	"36"
replace mode2_degS = "Mathematics and Statistics" if mode2_degS ==	"37"
replace mode2_degS = "Military Technologies" if mode2_degS ==	"38"
replace mode2_degS = "Interdisciplinary and Multi-Disciplinary Studies (General)" if mode2_degS ==	"40"
replace mode2_degS = "Physical Fitness, Parks, Recreation, and Leisure" if mode2_degS ==	"41"
replace mode2_degS = "Philosophy and Religious Studies" if mode2_degS ==	"48"
replace mode2_degS = "Theology and Religious Vocations" if mode2_degS ==	"49"
replace mode2_degS = "Physical Sciences" if mode2_degS ==	"50"
replace mode2_degS = "Nuclear, Industrial Radiology, and Biological Technologies" if mode2_degS ==	"51"
replace mode2_degS = "Psychology" if mode2_degS ==	"52"
replace mode2_degS = "Criminal Justice and Fire Protection" if mode2_degS ==	"53"
replace mode2_degS = "Public Affairs, Policy, and Social Work" if mode2_degS ==	"54"
replace mode2_degS = "Social Sciences" if mode2_degS ==	"55"
replace mode2_degS = "Construction Services" if mode2_degS ==	"56"
replace mode2_degS = "Electrical and Mechanic Repairs and Technologies" if mode2_degS ==	"57"
replace mode2_degS = "Precision Production and Industrial Arts" if mode2_degS ==	"58"
replace mode2_degS = "Transportation Sciences and Technologies" if mode2_degS ==	"59"
replace mode2_degS = "Fine Arts" if mode2_degS ==	"60"
replace mode2_degS = "Medical and Health Sciences and Services" if mode2_degS ==	"61"
replace mode2_degS = "Business" if mode2_degS ==	"62"
replace mode2_degS = "History" if mode2_degS ==	"64"

replace occS ="Chief Executives" if occS == "0010"
replace occS ="General and Operations Managers" if occS =="0020"
replace occS ="Legislators" if occS =="0030"
replace occS ="Advertising and Promotions Managers" if occS =="0040"
replace occS ="Marketing Managers" if occS =="0051"
replace occS ="Sales Managers" if occS =="0052"
replace occS ="Public Relations and Fundraising Managers" if occS =="0060"
replace occS ="Administrative Services Managers" if occS =="0101"
replace occS ="Facilities Managers" if occS =="0102"
replace occS ="Computer and Information Systems Managers" if occS =="0110"
replace occS ="Financial Managers" if occS =="0120"
replace occS ="Compensation and Benefits Managers" if occS =="0135"
replace occS ="Human Resources Managers" if occS =="0136"
replace occS ="Training and Development Managers" if occS =="0137"
replace occS ="Industrial Production Managers" if occS =="0140"
replace occS ="Purchasing Managers" if occS =="0150"
replace occS ="Transportation, Storage, and Distribution Managers" if occS =="0160"
replace occS ="Farmers, Ranchers, and Other Agricultural Managers" if occS =="0205"
replace occS ="Construction Managers" if occS =="0220"
replace occS ="Education and Childcare Administrators " if occS =="0230"
replace occS ="Architectural and Engineering Managers" if occS =="0300"
replace occS ="Food Service Managers" if occS =="0310"
replace occS ="Funeral Home Managers" if occS =="0325"
replace occS ="Entertainment and Recreation Managers" if occS =="0335"
replace occS ="Lodging Managers" if occS =="0340"
replace occS ="Medical and Health Services Managers" if occS =="0350"
replace occS ="Natural Sciences Managers" if occS =="0360"
replace occS ="Postmasters and Mail Superintendents" if occS =="0400"
replace occS ="Property, Real Estate, and Community Association Managers" if occS =="0410"
replace occS ="Social and Community Service Managers" if occS =="0420"
replace occS ="Emergency Management Directors" if occS =="0425"
replace occS ="Personal Service Managers, All Other" if occS =="0426"
replace occS ="Managers, All Other" if occS =="0440"
replace occS ="Agents and Business Managers of Artists, Performers, and Athletes" if occS =="0500"
replace occS ="Buyers and Purchasing Agents, Farm Products" if occS =="0510"
replace occS ="Wholesale and Retail Buyers, Except Farm Products" if occS =="0520"
replace occS ="Purchasing Agents, Except Wholesale, Retail, and Farm Products" if occS =="0530"
replace occS ="Claims Adjusters, Appraisers, Examiners, and Investigators" if occS =="0540"
replace occS ="Compliance Officers" if occS =="0565"
replace occS ="Cost Estimators" if occS =="0600"
replace occS ="Human Resources Workers" if occS =="0630"
replace occS ="Compensation, Benefits, and Job Analysis Specialists" if occS =="0640"
replace occS ="Training and Development Specialists" if occS =="0650"
replace occS ="Logisticians" if occS =="0700"
replace occS ="Project Management Specialists" if occS =="0705"
replace occS ="Management Analysts" if occS =="0710"
replace occS ="Meeting, Convention, and Event Planners" if occS =="0725"
replace occS ="Fundraisers" if occS =="0726"
replace occS ="Training and Development Specialists" if occS =="0650"
replace occS ="Market Research Analysts and Marketing Specialists" if occS =="0735"
replace occS ="Business Operations Specialists, All Other" if occS =="0750"
replace occS ="Accountants and Auditors" if occS =="0800"
replace occS ="Property Appraisers and Assessors" if occS =="0810"
replace occS ="Budget Analysts" if occS =="0820"
replace occS ="Credit Analysts" if occS =="0830"
replace occS ="Financial and Investment Analysts" if occS =="0845"
replace occS ="Personal Financial Advisors" if occS =="0850"
replace occS ="Insurance Underwriters" if occS =="0860"
replace occS ="Financial Examiners" if occS =="0900"
replace occS ="Credit Counselors and Loan Officers" if occS =="0910"
replace occS ="Tax Examiners and Collectors, and Revenue Agents" if occS =="0930"
replace occS ="Tax Preparers" if occS =="0940"
replace occS ="Other Financial Specialists" if occS =="0960"
replace occS ="Computer and Information Research Scientists" if occS =="1005"
replace occS ="Computer Systems Analysts" if occS =="1006"
replace occS ="Information Security Analysts" if occS =="1007"
replace occS ="Computer Programmers" if occS =="1010"
replace occS ="Software Developers" if occS =="1021"
replace occS ="Software Quality Assurance Analysts and Testers" if occS =="1022"
replace occS ="Computer Support Specialists" if occS =="1050"
replace occS ="Database Administrators and Architects" if occS =="1065"
replace occS ="Web Developers" if occS =="1031"
replace occS ="Web and Digital Interface Designers" if occS =="1032"
replace occS ="Network and Computer Systems Administrators" if occS =="1105"
replace occS ="Computer Network Architects" if occS =="1106"
replace occS ="Computer Occupations, All Other" if occS =="1108"
replace occS ="Actuaries" if occS =="1200"
replace occS ="Mathematicians" if occS =="1210"
replace occS ="Operations Research Analysts" if occS =="1220"
replace occS ="Statisticians" if occS =="1230"
replace occS ="Other Mathematical Science Occupations" if occS =="1240"
replace occS ="Architects, Except Landscape and Naval" if occS =="1305"
replace occS ="Landscape Architects" if occS =="1306"
replace occS ="Surveyors, Cartographers, and Photogrammetrists" if occS =="1310"
replace occS ="Aerospace Engineers" if occS =="1320"
replace occS ="Agricultural Engineers" if occS =="1330"
replace occS ="Bioengineers and biomedical engineers" if occS =="1340"
replace occS ="Chemical Engineers" if occS =="1350"
replace occS ="Civil Engineers" if occS =="1360"
replace occS ="Computer Hardware Engineers" if occS =="1400"
replace occS ="Electrical and Electronics Engineers" if occS =="1410"
replace occS ="Environmental Engineers" if occS =="1420"
replace occS ="Industrial Engineers, including Health and Safety " if occS =="1430"
replace occS ="Marine Engineers and Naval Architects" if occS =="1440"
replace occS ="Materials Engineers" if occS =="1450"
replace occS ="Mechanical Engineers" if occS =="1460"
replace occS ="Mining and Geological Engineers, Including Mining Safety Engineers" if occS =="1500"
replace occS ="Nuclear Engineers" if occS =="1510"
replace occS ="Petroleum Engineers" if occS =="1520"
replace occS ="Engineers, All Other" if occS =="1530"
replace occS ="Architectural and Civil Drafters" if occS =="1541"
replace occS ="Other Drafters" if occS =="1545"
replace occS ="Electrical and Electronic Engineering Technologists and Technicians" if occS =="1551"
replace occS ="Other Engineering Technologists and Technicians, Except Drafters" if occS =="1555"
replace occS ="Surveying and Mapping Technicians" if occS =="1560"
replace occS ="Agricultural and Food Scientists" if occS =="1600"
replace occS ="Biological Scientists" if occS =="1610"
replace occS ="Conservation Scientists and Foresters" if occS =="1640"
replace occS ="Medical Scientists" if occS =="1650"
replace occS ="Life Scientists, All Other" if occS =="1660"
replace occS ="Astronomers and Physicists" if occS =="1700"
replace occS ="Atmospheric and Space Scientists" if occS =="1710"
replace occS ="Chemists and Materials Scientists" if occS =="1720"
replace occS ="Environmental Scientists and Specialists, Including Health" if occS =="1745"
replace occS ="Geoscientists and Hydrologists, Except Geographers" if occS =="1750"
replace occS ="Physical Scientists, All Other" if occS =="1760"
replace occS ="Economists" if occS =="1800"
replace occS ="Survey Researchers" if occS =="1815"
replace occS ="Clinical and Counseling Psychologists" if occS =="1821"
replace occS ="School Psychologists" if occS =="1822"
replace occS ="Other Psychologists" if occS =="1825"
replace occS ="Sociologists" if occS =="1830"
replace occS ="Urban and Regional Planners" if occS =="1840"
replace occS ="Miscellaneous Social Scientists and Related Workers" if occS =="1860"
replace occS ="Agricultural and Food Science Technicians" if occS =="1900"
replace occS ="Biological Technicians" if occS =="1910"
replace occS ="Chemical Technicians" if occS =="1920"
replace occS ="Environmental Science and Geoscience Technicians" if occS =="1935"
replace occS ="Nuclear Technicians" if occS =="1940"
replace occS ="Social Science Research Assistants" if occS =="1950"
replace occS ="Other Life, Physical, and Social Science Technicians" if occS =="1970"
replace occS ="Occupational Health and Safety Specialists and Technicians" if occS =="1980"
replace occS ="Substance Abuse and Behavioral Disorder Counselors" if occS =="2001"
replace occS ="Educational, Guidance, and Career Counselors and Advisors" if occS =="2002"
replace occS ="Marriage and Family Therapists" if occS =="2003"
replace occS ="Mental Health Counselors" if occS =="2004"
replace occS ="Rehabilitation Counselors" if occS =="2005"
replace occS ="Counselors, All Other" if occS =="2006"
replace occS ="Child, Family, and School Social Workers" if occS =="2011"
replace occS ="Healthcare Social Workers" if occS =="2012"
replace occS ="Mental Health and Substance Abuse Social Workers" if occS =="2013"
replace occS ="Social Workers, All Other" if occS =="2014"
replace occS ="Probation Officers and Correctional Treatment Specialists" if occS =="2015"
replace occS ="Social and Human Service Assistants" if occS =="2016"
replace occS ="Other Community and Social Service Specialists" if occS =="2025"
replace occS ="Clergy" if occS =="2040"
replace occS ="Directors, Religious Activities and Education" if occS =="2050"
replace occS ="Religious Workers, All Other" if occS =="2060"
replace occS ="Lawyers" if occS =="2100"
replace occS ="Judicial Law Clerks" if occS =="2105"
replace occS ="Judges, Magistrates, and Other Judicial Workers" if occS =="2110"
replace occS ="Paralegals and Legal Assistants" if occS =="2145"
replace occS ="Title Examiners, Abstractors, and Searchers" if occS =="2170"
replace occS ="Legal Support Workers, All Other" if occS =="2180"
replace occS ="Postsecondary Teachers" if occS =="2205"
replace occS ="Preschool and Kindergarten Teachers" if occS =="2300"
replace occS ="Elementary and Middle School Teachers" if occS =="2310"
replace occS ="Secondary School Teachers" if occS =="2320"
replace occS ="Special Education Teachers" if occS =="2330"
replace occS ="Tutors" if occS =="2350"
replace occS ="Other Teachers and Instructors" if occS =="2360"
replace occS ="Archivists, Curators, and Museum Technicians" if occS =="2400"
replace occS ="Librarians and Media Collections Specialists" if occS =="2435"
replace occS ="Library Technicians" if occS =="2440"
replace occS ="Teaching Assistants" if occS =="2545"
replace occS ="Other Educational Instruction and Library Workers" if occS =="2555"
replace occS ="Artists and Related Workers" if occS =="2600"
replace occS ="Commercial and Industrial Designers" if occS =="2631"
replace occS ="Fashion Designers" if occS =="2632"
replace occS ="Floral Designers" if occS =="2633"
replace occS ="Graphic Designers" if occS =="2634"
replace occS ="Interior Designers" if occS =="2635"
replace occS ="Merchandise Displayers and Window Trimmers" if occS =="2636"
replace occS ="Other Designers" if occS =="2640"
replace occS ="Actors" if occS =="2700"
replace occS ="Producers and Directors" if occS =="2710"
replace occS ="Athletes and Sports Competitors" if occS =="2721"
replace occS ="Coaches and Scouts" if occS =="2722"
replace occS ="Umpires, Referees, and Other Sports Officials" if occS =="2723"
replace occS ="Dancers and Choreographers" if occS =="2740"
replace occS ="Music Directors and Composers" if occS =="2751"
replace occS ="Musicians and Singers" if occS =="2752"
replace occS ="Disc jockeys, except radio " if occS =="2755"
replace occS ="Entertainers and Performers, Sports and Related Workers, All Other" if occS =="2770"
replace occS ="Broadcast Announcers and Radio Disc Jockeys" if occS =="2805"
replace occS ="News Analysts, Reporters, and Journalists" if occS =="2810"
replace occS ="Public Relations Specialists" if occS =="2825"
replace occS ="Editors" if occS =="2830"
replace occS ="Technical Writers" if occS =="2840"
replace occS ="Writers and Authors" if occS =="2850"
replace occS ="Interpreters and Translators" if occS =="2861"
replace occS ="Court Reporters and Simultaneous Captioners" if occS =="2862"
replace occS ="Media and Communication Workers, All Other" if occS =="2865"
replace occS ="Broadcast, Sound, and Lighting Technicians" if occS =="2905"
replace occS ="Photographers" if occS =="2910"
replace occS ="Television, Video, and Film Camera Operators and Editors" if occS =="2920"
replace occS ="Media and Communication Equipment Workers, All Other" if occS =="2970"
replace occS ="Chiropractors" if occS =="3000"
replace occS ="Dentists" if occS =="3010"
replace occS ="Dietitians and Nutritionists" if occS =="3030"
replace occS ="Optometrists" if occS =="3040"
replace occS ="Pharmacists" if occS =="3050"
replace occS ="Emergency Medicine Physicians" if occS =="3065"
replace occS ="Radiologists" if occS =="3070"
replace occS ="Other Physicians" if occS =="3090"
replace occS ="Surgeons" if occS =="3100"
replace occS ="Physician Assistants" if occS =="3110"
replace occS ="Podiatrists" if occS =="3120"
replace occS ="Audiologists" if occS =="3140"
replace occS ="Occupational Therapists" if occS =="3150"
replace occS ="Physical Therapists" if occS =="3160"
replace occS ="Radiation Therapists" if occS =="3200"
replace occS ="Recreational Therapists" if occS =="3210"
replace occS ="Respiratory Therapists" if occS =="3220"
replace occS ="Speech-Language Pathologists" if occS =="3230"
replace occS ="Exercise Physiologists" if occS =="3235"
replace occS ="Therapists, All Other" if occS =="3245"
replace occS ="Veterinarians" if occS =="3250"
replace occS ="Registered Nurses" if occS =="3255"
replace occS ="Nurse Anesthetists" if occS =="3256"
replace occS ="Nurse Midwives" if occS =="3257"
replace occS ="Nurse Practitioners" if occS =="3258"
replace occS ="Acupuncturists" if occS =="3261"
replace occS ="Healthcare Diagnosing or Treating Practitioners, All Other" if occS =="3270"
replace occS ="Clinical Laboratory Technologists and Technicians" if occS =="3300"
replace occS ="Dental Hygienists" if occS =="3310"
replace occS ="Cardiovascular Technologists and Technicians" if occS =="3321"
replace occS ="Diagnostic Medical Sonographers" if occS =="3322"
replace occS ="Radiologic Technologists and Technicians" if occS =="3323"
replace occS ="Magnetic Resonance Imaging Technologists" if occS =="3324"
replace occS ="Nuclear Medicine Technologists and Medical Dosimetrists" if occS =="3330"
replace occS ="Emergency Medical Technicians" if occS =="3401"
replace occS ="Paramedics" if occS =="3402"
replace occS ="Pharmacy Technicians" if occS =="3421"
replace occS ="Psychiatric Technicians" if occS =="3422"
replace occS ="Surgical Technologists" if occS =="3423"
replace occS ="Veterinary Technologists and Technicians" if occS =="3424"
replace occS ="Dietetic Technicians and Ophthalmic Medical Technicians" if occS =="3430"
replace occS ="Licensed Practical and Licensed Vocational Nurses" if occS =="3500"
replace occS ="Medical Records Specialists" if occS =="3515"
replace occS ="Opticians, Dispensing" if occS =="3520"
replace occS ="Miscellaneous Health Technologists and Technicians" if occS =="3545"
replace occS ="Other Healthcare Practitioners and Technical Occupations" if occS =="3550"
replace occS ="Home Health Aides" if occS =="3601"
replace occS ="Personal Care Aides" if occS =="3602"
replace occS ="Nursing Assistants" if occS =="3603"
replace occS ="Orderlies and Psychiatric Aides" if occS =="3605"
replace occS ="Occupational Therapy Assistants and Aides" if occS =="3610"
replace occS ="Physical Therapist Assistants and Aides" if occS =="3620"
replace occS ="Massage Therapists" if occS =="3630"
replace occS ="Dental Assistants" if occS =="3640"
replace occS ="Medical Assistants" if occS =="3645"
replace occS ="Medical Transcriptionists" if occS =="3646"
replace occS ="Pharmacy Aides" if occS =="3647"
replace occS ="Veterinary Assistants and Laboratory Animal Caretakers" if occS =="3648"
replace occS ="Phlebotomists" if occS =="3649"
replace occS ="Other Healthcare Support Workers" if occS =="3655"
replace occS ="First-Line Supervisors of Correctional Officers" if occS =="3700"
replace occS ="First-Line Supervisors of Police and Detectives" if occS =="3710"
replace occS ="First-Line Supervisors of Firefighting and Prevention Workers" if occS =="3720"
replace occS ="First-Line Supervisors of Security Workers" if occS =="3725"
replace occS ="First-Line Supervisors of Protective Service Workers, All Other" if occS =="3735"
replace occS ="Firefighters" if occS =="3740"
replace occS ="Fire Inspectors " if occS =="3750"
replace occS ="Bailiffs" if occS =="3801"
replace occS ="Correctional Officers and Jailers" if occS =="3802"
replace occS ="Detectives and Criminal Investigators" if occS =="3820"
replace occS ="Fish and Game Wardens" if occS =="3830"
replace occS ="Parking Enforcement Workers" if occS =="3840"
replace occS ="Police Officers" if occS =="3870"
replace occS ="Animal Control Workers" if occS =="3900"
replace occS ="Private Detectives and Investigators" if occS =="3910"
replace occS ="Security Guards and Gambling Surveillance Officers" if occS =="3930"
replace occS ="Crossing Guards and Flaggers" if occS =="3940"
replace occS ="Transportation Security Screeners" if occS =="3945"
replace occS ="School Bus Monitors" if occS =="3946"
replace occS ="Other Protective Service Workers" if occS =="3960"
replace occS ="Chefs and Head Cooks" if occS =="4000"
replace occS ="First-Line Supervisors of Food Preparation and Serving Workers" if occS =="4010"
replace occS ="Cooks" if occS =="4020"
replace occS ="Food Preparation Workers" if occS =="4030"
replace occS ="Bartenders" if occS =="4040"
replace occS ="Fast Food and Counter Workers" if occS =="4055"
replace occS ="Waiters and Waitresses" if occS =="4110"
replace occS ="Food Servers, Nonrestaurant" if occS =="4120"
replace occS ="Dining Room and Cafeteria Attendants and Bartender Helpers" if occS =="4130"
replace occS ="Dishwashers" if occS =="4140"
replace occS ="Hosts and Hostesses, Restaurant, Lounge, and Coffee Shop" if occS =="4150"
replace occS ="Food Preparation and Serving Related Workers, All Other" if occS =="4160"
replace occS ="First-Line Supervisors of Housekeeping and Janitorial Workers" if occS =="4200"
replace occS ="First-Line Supervisors of Landscaping, Lawn Service, and Groundskeeping Workers" if occS =="4210"
replace occS ="Janitors and Building Cleaners" if occS =="4220"
replace occS ="Maids and Housekeeping Cleaners" if occS =="4230"
replace occS ="Pest Control Workers" if occS =="4240"
replace occS ="Landscaping and Groundskeeping Workers" if occS =="4251"
replace occS ="Tree Trimmers and Pruners" if occS =="4252"
replace occS ="Other Grounds Maintenance Workers" if occS =="4255"
replace occS ="Supervisors of Personal Care and Service Workers" if occS =="4330"
replace occS ="Animal Trainers" if occS =="4340"
replace occS ="Animal Caretakers" if occS =="4350"
replace occS ="Gambling Services Workers" if occS =="4400"
replace occS ="Ushers, Lobby Attendants, and Ticket Takers" if occS =="4420"
replace occS ="Other Entertainment Attendants and Related Workers" if occS =="4435"
replace occS ="Embalmers, Crematory Operators and Funeral Attendants" if occS =="4461"
replace occS ="Morticians, Undertakers, and Funeral Arrangers" if occS =="4465"
replace occS ="Barbers" if occS =="4500"
replace occS ="Hairdressers, Hairstylists, and Cosmetologists" if occS =="4510"
replace occS ="Manicurists and Pedicurists" if occS =="4521"
replace occS ="Skincare Specialists" if occS =="4522"
replace occS ="Other Personal Appearance Workers" if occS =="4525"
replace occS ="Baggage Porters, Bellhops, and Concierges" if occS =="4530"
replace occS ="Tour and Travel Guides" if occS =="4540"
replace occS ="Childcare Workers" if occS =="4600"
replace occS ="Exercise Trainers and Group Fitness Instructors" if occS =="4621"
replace occS ="Recreation Workers" if occS =="4622"
replace occS ="Residential Advisors" if occS =="4640"
replace occS ="Personal Care and Service Workers, All Other" if occS =="4655"
replace occS ="First-Line Supervisors of Retail Sales Workers" if occS =="4700"
replace occS ="First-Line Supervisors of Non-Retail Sales Workers" if occS =="4710"
replace occS ="Cashiers" if occS =="4720"
replace occS ="Counter and Rental Clerks" if occS =="4740"
replace occS ="Parts Salespersons" if occS =="4750"
replace occS ="Retail Salespersons" if occS =="4760"
replace occS ="Advertising Sales Agents" if occS =="4800"
replace occS ="Insurance Sales Agents" if occS =="4810"
replace occS ="Securities, Commodities, and Financial Services Sales Agents" if occS =="4820"
replace occS ="Travel Agents" if occS =="4830"
replace occS ="Sales representatives of services, except advertising, insurance, financial services, and travel" if occS =="4840"
replace occS ="Sales Representatives, Wholesale and Manufacturing" if occS =="4850"
replace occS ="Models, Demonstrators, and Product Promoters" if occS =="4900"
replace occS ="Real Estate Brokers and Sales Agents" if occS =="4920"
replace occS ="Sales Engineers" if occS =="4930"
replace occS ="Telemarketers" if occS =="4940"
replace occS ="Door-to-Door Sales Workers, News and Street Vendors, and Related Workers" if occS =="4950"
replace occS ="Sales and Related Workers, All Other" if occS =="4965"
replace occS ="First-Line Supervisors of Office and Administrative Support Workers" if occS =="5000"
replace occS ="Switchboard Operators, Including Answering Service" if occS =="5010"
replace occS ="Telephone Operators" if occS =="5020"
replace occS ="Communications Equipment Operators, All Other" if occS =="5040"
replace occS ="Bill and Account Collectors" if occS =="5100"
replace occS ="Billing and Posting Clerks" if occS =="5110"
replace occS ="Bookkeeping, Accounting, and Auditing Clerks" if occS =="5120"
replace occS ="Gambling Cage Workers" if occS =="5130"
replace occS ="Payroll and Timekeeping Clerks" if occS =="5140"
replace occS ="Procurement Clerks" if occS =="5150"
replace occS ="Tellers" if occS =="5160"
replace occS ="Financial Clerks, All Other" if occS =="5165"
replace occS ="Brokerage Clerks" if occS =="5200"
replace occS ="Correspondence Clerks" if occS =="5210"
replace occS ="Court, Municipal, and License Clerks" if occS =="5220"
replace occS ="Credit Authorizers, Checkers, and Clerks" if occS =="5230"
replace occS ="Customer Service Representatives" if occS =="5240"
replace occS ="Eligibility Interviewers, Government Programs" if occS =="5250"
replace occS ="File Clerks" if occS =="5260"
replace occS ="Hotel, Motel, and Resort Desk Clerks" if occS =="5300"
replace occS ="Interviewers, Except Eligibility and Loan" if occS =="5310"
replace occS ="Library Assistants, Clerical" if occS =="5320"
replace occS ="Loan Interviewers and Clerks" if occS =="5330"
replace occS ="New Accounts Clerks" if occS =="5340"
replace occS ="Order Clerks" if occS =="5350"
replace occS ="Human Resources Assistants, Except Payroll and Timekeeping" if occS =="5360"
replace occS ="Receptionists and Information Clerks" if occS =="5400"
replace occS ="Reservation and Transportation Ticket Agents and Travel Clerks" if occS =="5410"
replace occS ="Information and Record Clerks, All Other" if occS =="5420"
replace occS ="Cargo and Freight Agents" if occS =="5500"
replace occS ="Couriers and Messengers" if occS =="5510"
replace occS ="Public Safety Telecommunicators" if occS =="5521"
replace occS ="Dispatchers, Except Police, Fire, and Ambulance" if occS =="5522"
replace occS ="Meter Readers, Utilities" if occS =="5530"
replace occS ="Postal Service Clerks" if occS =="5540"
replace occS ="Postal Service Mail Carriers" if occS =="5550"
replace occS ="Postal Service Mail Sorters, Processors, and Processing Machine Operators" if occS =="5560"
replace occS ="Production, Planning, and Expediting Clerks" if occS =="5600"
replace occS ="Shipping, Receiving, and Inventory Clerks" if occS =="5610"
replace occS ="Weighers, Measurers, Checkers, and Samplers, Recordkeeping" if occS =="5630"
replace occS ="Executive Secretaries and Executive Administrative Assistants" if occS =="5710"
replace occS ="Legal Secretaries and Administrative Assistants" if occS =="5720"
replace occS ="Medical Secretaries and Administrative Assistants" if occS =="5730"
replace occS ="Secretaries and Administrative Assistants, Except Legal, Medical, and Executive" if occS =="5740"
replace occS ="Data Entry Keyers" if occS =="5810"
replace occS ="Word Processors and Typists" if occS =="5820"
replace occS ="Desktop Publishers" if occS =="5830"
replace occS ="Insurance Claims and Policy Processing Clerks" if occS =="5840"
replace occS ="Mail Clerks and Mail Machine Operators, Except Postal Service" if occS =="5850"
replace occS ="Office Clerks, General" if occS =="5860"
replace occS ="Office Machine Operators, Except Computer" if occS =="5900"
replace occS ="Proofreaders and Copy Markers" if occS =="5910"
replace occS ="Statistical Assistants" if occS =="5920"
replace occS ="Office and Administrative Support Workers, All Other" if occS =="5940"
replace occS ="First-Line Supervisors of Farming, Fishing, and Forestry Workers" if occS =="6005"
replace occS ="Agricultural Inspectors" if occS =="6010"
replace occS ="Animal Breeders" if occS =="6020"
replace occS ="Graders and Sorters, Agricultural Products" if occS =="6040"
replace occS ="Miscellaneous Agricultural Workers" if occS =="6050"
replace occS ="Fishing and Hunting Workers" if occS =="6115"
replace occS ="Forest and Conservation Workers" if occS =="6120"
replace occS ="Logging Workers" if occS =="6130"
replace occS ="First-Line Supervisors of Construction Trades and Extraction Workers" if occS =="6200"
replace occS ="Boilermakers" if occS =="6210"
replace occS ="Brickmasons, Blockmasons, and Stonemasons" if occS =="6220"
replace occS ="Carpenters" if occS =="6230"
replace occS ="Carpet, Floor, and Tile Installers and Finishers" if occS =="6240"
replace occS ="Cement Masons, Concrete Finishers, and Terrazzo Workers" if occS =="6250"
replace occS ="Construction Laborers" if occS =="6260"
replace occS ="Construction Equipment Operators" if occS =="6305"
replace occS ="Drywall Installers, Ceiling Tile Installers, and Tapers" if occS =="6330"
replace occS ="Electricians" if occS =="6355"
replace occS ="Glaziers" if occS =="6360"
replace occS ="Insulation Workers" if occS =="6400"
replace occS ="Painters and Paperhangers" if occS =="6410"
replace occS ="Pipelayers" if occS =="6441"
replace occS ="Plumbers, Pipefitters, and Steamfitters" if occS =="6442"
replace occS ="Plasterers and Stucco Masons" if occS =="6460"
replace occS ="Reinforcing Iron and Rebar Workers" if occS =="6500"
replace occS ="Roofers" if occS =="6515"
replace occS ="Sheet Metal Workers" if occS =="6520"
replace occS ="Structural Iron and Steel Workers" if occS =="6530"
replace occS ="Solar Photovoltaic Installers" if occS =="6540"
replace occS ="Helpers, Construction Trades" if occS =="6600"
replace occS ="Construction and Building Inspectors" if occS =="6660"
replace occS ="Elevator and Escalator Installers and Repairers" if occS =="6700"
replace occS ="Fence Erectors" if occS =="6710"
replace occS ="Hazardous Materials Removal Workers" if occS =="6720"
replace occS ="Highway Maintenance Workers" if occS =="6730"
replace occS ="Rail-Track Laying and Maintenance Equipment Operators" if occS =="6740"
replace occS ="Septic Tank Servicers and Sewer Pipe Cleaners" if occS =="6750"
replace occS ="Miscellaneous Construction and Related Workers" if occS =="6765"
replace occS ="Derrick, Rotary Drill, and Service Unit Operators, Oil and Gas  " if occS =="6800"
replace occS ="Excavating and Loading Machine and Dragline Operators, Surface Mining" if occS =="6821"
replace occS ="Earth Drillers, Except Oil and Gas" if occS =="6825"
replace occS ="Explosives Workers, Ordnance Handling Experts, and Blasters" if occS =="6835"
replace occS ="Underground Mining Machine Operators" if occS =="6850"
replace occS ="Roustabouts, Oil and Gas" if occS =="6920"
replace occS ="Other Extraction Workers" if occS =="6950"
replace occS ="First-Line Supervisors of Mechanics, Installers, and Repairers" if occS =="7000"
replace occS ="Computer, Automated Teller, and Office Machine Repairers" if occS =="7010"
replace occS ="Radio and Telecommunications Equipment Installers and Repairers" if occS =="7020"
replace occS ="Avionics Technicians" if occS =="7030"
replace occS ="Electric Motor, Power Tool, and Related Repairers" if occS =="7040"
replace occS ="Electrical and Electronics Installers and Repairers, Transportation Equipment" if occS =="7050"
replace occS ="Electrical and Electronics Repairers, Industrial and Utility " if occS =="7100"
replace occS ="Electronic Equipment Installers and Repairers, Motor Vehicles" if occS =="7110"
replace occS ="Audiovisual Equipment Installers and Repairers" if occS =="7120"
replace occS ="Security and Fire Alarm Systems Installers" if occS =="7130"
replace occS ="Aircraft Mechanics and Service Technicians" if occS =="7140"
replace occS ="Automotive Body and Related Repairers" if occS =="7150"
replace occS ="Automotive Glass Installers and Repairers" if occS =="7160"
replace occS ="Automotive Service Technicians and Mechanics" if occS =="7200"
replace occS ="Bus and Truck Mechanics and Diesel Engine Specialists" if occS =="7210"
replace occS ="Heavy Vehicle and Mobile Equipment Service Technicians and Mechanics" if occS =="7220"
replace occS ="Small Engine Mechanics" if occS =="7240"
replace occS ="Miscellaneous Vehicle and Mobile Equipment Mechanics, Installers, and Repairers" if occS =="7260"
replace occS ="Control and Valve Installers and Repairers" if occS =="7300"
replace occS ="Heating, Air Conditioning, and Refrigeration Mechanics and Installers" if occS =="7315"
replace occS ="Home Appliance Repairers" if occS =="7320"
replace occS ="Industrial and Refractory Machinery Mechanics" if occS =="7330"
replace occS ="Maintenance and Repair Workers, General" if occS =="7340"
replace occS ="Maintenance Workers, Machinery" if occS =="7350"
replace occS ="Millwrights" if occS =="7360"
replace occS ="Electrical Power-Line Installers and Repairers" if occS =="7410"
replace occS ="Telecommunications Line Installers and Repairers" if occS =="7420"
replace occS ="Precision Instrument and Equipment Repairers" if occS =="7430"
replace occS ="Wind Turbine Service Technicians" if occS =="7440"
replace occS ="Coin, Vending, and Amusement Machine Servicers and Repairers" if occS =="7510"
replace occS ="Commercial Divers" if occS =="7520"
replace occS ="Locksmiths and Safe Repairers" if occS =="7540"
replace occS ="Manufactured Building and Mobile Home Installers" if occS =="7550"
replace occS ="Riggers" if occS =="7560"
replace occS ="Helpers--Installation, Maintenance, and Repair Workers" if occS =="7610"
replace occS ="Other Installation, Maintenance, and Repair Workers" if occS =="7640"
replace occS ="First-Line Supervisors of Production and Operating Workers" if occS =="7700"
replace occS ="Aircraft Structure, Surfaces, Rigging, and Systems Assemblers" if occS =="7710"
replace occS ="Electrical, Electronics, and Electromechanical Assemblers" if occS =="7720"
replace occS ="Engine and Other Machine Assemblers" if occS =="7730"
replace occS ="Structural Metal Fabricators and Fitters" if occS =="7740"
replace occS ="Other Assemblers and Fabricators" if occS =="7750"
replace occS ="Bakers" if occS =="7800"
replace occS ="Butchers and Other Meat, Poultry, and Fish Processing Workers" if occS =="7810"
replace occS ="Food and Tobacco Roasting, Baking, and Drying Machine Operators and Tenders" if occS =="7830"
replace occS ="Food Batchmakers" if occS =="7840"
replace occS ="Food Cooking Machine Operators and Tenders" if occS =="7850"
replace occS ="Food Processing Workers, All Other" if occS =="7855"
replace occS ="Computer numerically controlled tool operators and programmers" if occS =="7905"
replace occS ="Forming Machine Setters, Operators, and Tenders, Metal and Plastic" if occS =="7925"
replace occS ="Cutting, Punching, and Press Machine Setters, Operators, and Tenders, Metal and Plastic" if occS =="7950"
replace occS ="Grinding, Lapping, Polishing, and Buffing Machine Tool Setters, Operators, and Tenders, Metal and Plastic" if occS =="8000"
replace occS ="Other Machine Tool Setters, Operators, and Tenders, Metal and Plastic" if occS =="8025"
replace occS ="Machinists" if occS =="8030"
replace occS ="Metal Furnace Operators, Tenders, Pourers, and Casters" if occS =="8040"
replace occS ="Model Makers and Patternmakers, Metal and Plastic" if occS =="8060"
replace occS ="Molders and Molding Machine Setters, Operators, and Tenders, Metal and Plastic" if occS =="8100"
replace occS ="Tool and Die Makers" if occS =="8130"
replace occS ="Welding, Soldering, and Brazing Workers" if occS =="8140"
replace occS ="Other Metal Workers and Plastic Workers" if occS =="8225"
replace occS ="Prepress Technicians and Workers" if occS =="8250"
replace occS ="Printing Press Operators" if occS =="8255"
replace occS ="Print Binding and Finishing Workers" if occS =="8256"
replace occS ="Laundry and Dry-Cleaning Workers" if occS =="8300"
replace occS ="Pressers, Textile, Garment, and Related Materials" if occS =="8310"
replace occS ="Sewing Machine Operators" if occS =="8320"
replace occS ="Shoe and Leather Workers" if occS =="8335"
replace occS ="Tailors, Dressmakers, and Sewers" if occS =="8350"
replace occS ="Textile Machine Setters, Operators, and Tenders" if occS =="8365"
replace occS ="Upholsterers" if occS =="8450"
replace occS ="Other Textile, Apparel, and Furnishings Workers" if occS =="8465"
replace occS ="Cabinetmakers and Bench Carpenters" if occS =="8500"
replace occS ="Furniture Finishers" if occS =="8510"
replace occS ="Sawing Machine Setters, Operators, and Tenders, Wood" if occS =="8530"
replace occS ="Woodworking Machine Setters, Operators, and Tenders, Except Sawing" if occS =="8540"
replace occS ="Other Woodworkers" if occS =="8555"
replace occS ="Power Plant Operators, Distributors, and Dispatchers" if occS =="8600"
replace occS ="Stationary Engineers and Boiler Operators" if occS =="8610"
replace occS ="Water and Wastewater Treatment Plant and System Operators" if occS =="8620"
replace occS ="Miscellaneous Plant and System Operators" if occS =="8630"
replace occS ="Chemical Processing Machine Setters, Operators, and Tenders" if occS =="8640"
replace occS ="Crushing, Grinding, Polishing, Mixing, and Blending Workers" if occS =="8650"
replace occS ="Cutting Workers" if occS =="8710"
replace occS ="Extruding, Forming, Pressing, and Compacting Machine Setters, Operators, and Tenders" if occS =="8720"
replace occS ="Furnace, Kiln, Oven, Drier, and Kettle Operators and Tenders" if occS =="8730"
replace occS ="Inspectors, Testers, Sorters, Samplers, and Weighers" if occS =="8740"
replace occS ="Jewelers and Precious Stone and Metal Workers" if occS =="8750"
replace occS ="Dental and Ophthalmic Laboratory Technicians and Medical Appliance Technicians" if occS =="8760"
replace occS ="Packaging and Filling Machine Operators and Tenders" if occS =="8800"
replace occS ="Painting Workers" if occS =="8810"
replace occS ="Photographic Process Workers and Processing Machine Operators" if occS =="8830"
replace occS ="Adhesive Bonding Machine Operators and Tenders" if occS =="8850"
replace occS ="Etchers and Engravers" if occS =="8910"
replace occS ="Molders, Shapers, and Casters, Except Metal and Plastic" if occS =="8920"
replace occS ="Paper Goods Machine Setters, Operators, and Tenders" if occS =="8930"
replace occS ="Tire Builders" if occS =="8940"
replace occS ="Helpers--Production Workers" if occS =="8950"
replace occS ="Other Production Equipment Operators and Tenders" if occS =="8865"
replace occS ="Other Production Workers" if occS =="8990"
replace occS ="Supervisors of Transportation and Material Moving Workers" if occS =="9005"
replace occS ="Aircraft Pilots and Flight Engineers" if occS =="9030"
replace occS ="Air Traffic Controllers and Airfield Operations Specialists" if occS =="9040"
replace occS ="Flight Attendants" if occS =="9050"
replace occS ="Ambulance Drivers and Attendants, Except Emergency Medical Technicians" if occS =="9110"
replace occS ="Bus Drivers, School" if occS =="9121"
replace occS ="Bus Drivers, Transit and Intercity" if occS =="9122"
replace occS ="Driver/Sales Workers and Truck Drivers" if occS =="9130"
replace occS ="Shuttle Drivers and Chauffeurs" if occS =="9141"
replace occS ="Taxi Drivers" if occS =="9142"
replace occS ="Motor Vehicle Operators, All Other" if occS =="9150"
replace occS ="Locomotive Engineers and Operators" if occS =="9210"
replace occS ="Railroad Conductors and Yardmasters" if occS =="9240"
replace occS ="Other Rail Transportation Workers" if occS =="9265"
replace occS ="Sailors and Marine Oilers" if occS =="9300"
replace occS ="Ship Engineers " if occS =="9330"
replace occS ="Ship and Boat Captains and Operators" if occS =="9310"
replace occS ="Parking Attendants" if occS =="9350"
replace occS ="Transportation Service Attendants" if occS =="9365"
replace occS ="Transportation Inspectors" if occS =="9410"
replace occS ="Passenger Attendants" if occS =="9415"
replace occS ="Other Transportation Workers" if occS =="9430"
replace occS ="Crane and Tower Operators" if occS =="9510"
replace occS ="Conveyor, Dredge, and Hoist and Winch Operators" if occS =="9570"
replace occS ="Industrial Truck and Tractor Operators" if occS =="9600"
replace occS ="Cleaners of Vehicles and Equipment" if occS =="9610"
replace occS ="Laborers and Freight, Stock, and Material Movers, Hand" if occS =="9620"
replace occS ="Machine Feeders and Offbearers" if occS =="9630"
replace occS ="Packers and Packagers, Hand" if occS =="9640"
replace occS ="Stockers and Order Fillers" if occS =="9645"
replace occS ="Pumping Station Operators" if occS =="9650"
replace occS ="Refuse and Recyclable Material Collectors" if occS =="9720"
replace occS ="Other Material Moving Workers" if occS =="9760"
replace occS ="Military Officer Special and Tactical Operations Leaders" if occS =="9800"
replace occS ="First-Line Enlisted Military Supervisors" if occS =="9810"
replace occS ="Military Enlisted Tactical Operations and Air/Weapons Specialists and Crew Members" if occS =="9825"
replace occS ="Military, Rank Not Specified" if occS =="9830"
replace occS ="Unemployed, with no work experience in the last 5 years or earlier or never worked" if occS =="9920"

replace mode_attS = "College Diploma" if mode_att == 4
replace mode_attS = "HS Diploma and some college" if mode_att == 3
replace mode_attS = "HS Diploma" if mode_att == 2
replace mode_attS = "No HS Diploma" if mode_att == 1
**********************************************************************************************************************************


drop mode1_deg
drop mode2_deg
drop occ
drop mode_att

list occS med_yrs mode1_degS mode2_degS mean_wage med_wage
*merge this information back to the Shih sample by occ
