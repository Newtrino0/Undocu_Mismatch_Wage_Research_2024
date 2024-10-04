<h1 align="center">Abstract</h1>
This study aims to estimate the wage penalties associated with education-occupation mis-
match for DACA-eligible college graduates. We use data from The American Community
Survey (ACS) to identify whether a worker is vertically mismatched (employed in an occupa-
tion that doesn’t match their educational attainment) or horizontally mismatched (employed
in an occupation that doesn’t match their field of study). We find higher proportions of hori-
zontal mismatch for the DACA-eligible group of college graduates in the post-DACA period.
Relatedly, we find that earnings were approximately 5 percentage points lower. The results
suggest that DACA generated additional wage penalties for the eligible population of college
graduates.

<h3>Keywords:</h3>
 Undocumented; Education-occupation mismatch; Legal status; Labor; Wage;
DACA; Income inequality


<h3>DACA Eligibility Imputation Strategy:</h3>

A worker is considered DACA-eligible if they are 
- " (i) not a citizen and
- (ii) they meet DACA’s age and year of arrival requirements" (Kuka, Elira, Shenhav, Na’ama, and Shih, Kevin (2020). Do Human Capital Decisions Respond to
the Returns to Education? Evidence from DACA.).

Kuka, Shenhav, and Shih rightfully emphasize that this method cannot distinguish undocumented, DACA recipients from lawful permanent residents and other immigrant/nonimmigrants. Departing from the methods of Kuka et. al., we decide to implement the variables in the replication code to exclude noncitizens with any of the legal status indicators set as true. Legal status indicators are
- receiving social secuirty benefits,
- having veteran status,
- receiving welfare,
- or receiving supplmentary security income

<h3>Mismatch definitions:</h3>

- Vertical mismatch: Workers that hold an educational attainment that is not the most common for their occupation (e.g. college graduate as retail worker)
- Horizontal mismatch: Worker that holds a degree in a field that is not one of two most common degree fields for an occupation (e.g. engineering major working as an accountant)
- Horizontal undermatch: A horizontally mismatched worker, whose median wage for their occupation is less than the median wage for workers, that are horizontally matched, with the same field of study
- Horizontal overmatch: A horizontally mismatched worker, whose median wage for their occupation is more than the median wage for workers, that are horizontally matched, with the same field of study
