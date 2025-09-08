clear matrix
clear
set more off
// Install packages once
/*
ssc install coefplot, replace
ssc estout
*/



// Set paths/directories here
global gdrive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu/Shared drives/Undocu Research"
global data "$gdrive/Data"
global dofiles "$gdrive/Code"
global figures "$gdrive/Output/Figures"
global tables "$gdrive/Output/Tables"



capture restore

cd "$data"

* Sun & Abraham event study — High-precision RF group (undocu_rf==1)
* Requires: ssc install eventstudyinteract, reghdfe
* Sun & Abraham event study — High-precision RF group, e_verify rescaled 0/1/2

 * Sun & Abraham event study — High-precision RF group, e_verify in {-1,0,1}
* REQUIRE = -1, NEUTRAL = 0, PROHIBIT = 1

 use "$data/EO_Final.dta", clear

 * ======= PREP =======
* use "$data/EO_Final.dta", clear

keep if inrange(year,2009,2019)
keep if undocu_knn==1

rename elig daca
gen daca_post=daca*post


global covars  hisp male gov_worker  immig_by_ten nonfluent yrsed metropolitan  

* ==== policy event study (Sun–Abraham), high-precision RF group ====

*policy and treatment definition
local PVAR   drivers_license   // or e_verify, cooperation_federal_immigration, etc.
local PVALUE 1                 // treated value: +1 or -1 (coding is -1/0/1)

* ===== cohort builder =====
local TFLAG     `PVAR'_treat      // 1 when policy is in treated state (value == PVALUE)
local ENTER     `PVAR'_enter      // first entry into treated state (cohort indicator)
local GVAR      g_`PVAR'          // cohort year
local NEVERVAR  never_`PVAR'      // never-treated indicator
local TAUVAR    tau_`PVAR'        // relative time

gen byte `TFLAG' = (`PVAR' == `PVALUE')
bysort statefip (year): gen byte `ENTER' = (`TFLAG'==1 & (_n==1 | `TFLAG'[_n-1]==0))
bysort statefip (year): egen      `GVAR' = min(cond(`ENTER', year, .))

gen byte `NEVERVAR' = missing(`GVAR')
gen       `TAUVAR'  = year - `GVAR'


* Optional caps (upper bounds you allow). Adjust if you want.
local Kcap 5
local Lcap 5

* How many leads (tau < -1) and lags (tau >= 0) are possible in your data?
quietly summarize `TAUVAR' if `TAUVAR' < -1, meanonly
local K_avail = cond(r(N)==0, 0, min(`Kcap', abs(r(min))))   // max feasible leads (excl. -1)

quietly summarize `TAUVAR' if `TAUVAR' >= 0, meanonly
local L_avail = cond(r(N)==0, 0, min(`Lcap', r(max)))        // max feasible lags (0..L)

* Clean any prior dummies
capture drop `PVAR'_m* `PVAR'_p*

* Build only the event-time dummies that have support
local REL
local LEADS
local POST

* Leads: -K_avail..-2 (omit -1)
if `K_avail' >= 2 {
    forvalues k = 2/`K_avail' {
        local v `PVAR'_m`k'
        gen byte `v' = (`TAUVAR' == -`k')
        replace `v' = 0 if missing(`TAUVAR')     // controls & NA tau -> 0
        quietly count if `v'==1
        if r(N)>0 {
            local REL   `REL'   `v'
            local LEADS `LEADS' `v'
        }
        else drop `v'
    }
}

* Lags: 0..L_avail
forvalues h = 0/`L_avail' {
    local v `PVAR'_p`h'
    gen byte `v' = (`TAUVAR' == `h')
    replace `v' = 0 if missing(`TAUVAR')
    quietly count if `v'==1
    if r(N)>0 {
        local REL  `REL'  `v'
        local POST `POST' `v'
    }
    else drop `v'
}

di as txt "Auto window: Leads K = `K_avail' (base -1 omitted), Lags L = `L_avail'"
di as txt "Included leads: `LEADS'"
di as txt "Included lags:  `POST'"



 eststo ES_wage: eventstudyinteract ln_adj `REL' [pweight=perwt], cohort(g_`PVAR') control_cohort(never_`PVAR') ///
     covariates( $covars ) absorb(i.statefip i.year i.degfield_broader i.age) vce(cluster statefip) 
	
