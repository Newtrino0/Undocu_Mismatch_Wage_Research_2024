*******************************************************
* 3×3 Event studies (ln_adj, vmismatched, hundermatched)
* Samples: undocu, undocu_knn, undocu_rf
* Combine with grc1leg using row/column headers
*******************************************************
clear all
set more off

*— If needed once:
* ssc install grc1leg, replace
* ssc install eventstudyinteract, replace
* ssc install event_plot, replace
* ssc install estout, replace

* Paths
global gdrive "/Users/verosovero/Library/CloudStorage/GoogleDrive-vsovero@ucr.edu/Shared drives/Undocu Research"
global data   "$gdrive/Data"
global figures "$gdrive/Output/Figures"

* Numeric covariates only
global covars  hisp asian male gov_worker immig_by_ten nonfluent yrsed metropolitan

use "$data/EO_Final.dta", clear
keep if inrange(year,2009,2019)

set scheme s2color

local samples  undocu undocu_knn undocu_rf
local outcomes ln_adj vmismatched hundermatched

* Window caps (actual support auto-detected each loop)
scalar Kcap = 5
scalar Lcap = 5

* Build the 9 panels (no per-panel titles; legend only on the first panel)
foreach s of local samples {
    foreach y of local outcomes {

        preserve
            keep if `s'==1

            * ========== EDIT HERE to change policy/value ==========
            * e-Verify REQUIRE (= -1) as treated state (coding -1/0/1)
            capture drop evt_treat evt_enter g_evt never_evt tau_evt evt_m* evt_p*
            gen byte evt_treat = (e_verify == -1)
            * ======================================================

            * Cohorts & relative time
            bysort statefip (year): gen byte evt_enter = (evt_treat==1 & (_n==1 | evt_treat[_n-1]==0))
            bysort statefip (year): egen      g_evt    = min(cond(evt_enter==1, year, .))
            gen byte never_evt = missing(g_evt)
            gen       tau_evt  = year - g_evt

            * Auto window
            quietly summarize tau_evt if tau_evt < -1, meanonly
            scalar K_avail = cond(r(N)==0, 0, min(Kcap, abs(r(min))))
            quietly summarize tau_evt if tau_evt >= 0, meanonly
            scalar L_avail = cond(r(N)==0, 0, min(Lcap, r(max)))

            * Dummies
            capture drop evt_m* evt_p*
            local K = scalar(K_avail)
            if `K' >= 2 {
                forvalues k = 2/`K' {
                    gen byte evt_m`k' = (tau_evt == -`k')
                    replace evt_m`k'  = 0 if missing(tau_evt)
                    quietly count if evt_m`k'==1
                    if r(N)==0 drop evt_m`k'
                }
            }
            local L = scalar(L_avail)
            forvalues h = 0/`L' {
                gen byte evt_p`h' = (tau_evt == `h')
                replace evt_p`h'  = 0 if missing(tau_evt)
                quietly count if evt_p`h'==1
                if r(N)==0 drop evt_p`h'
            }

            * IW event–study
            quietly eststo drop *
            eststo ES_`s'_`y': ///
            eventstudyinteract `y' evt_m* evt_p* [pweight=perwt], ///
                cohort(g_evt) control_cohort(never_evt) ///
                absorb(statefip year degfield_broader age) ///
                covariates($covars) vce(cluster statefip)

            * Legend only on the first panel (undocu × ln_adj)
            local LEGOPTs "legend(off)"
            if "`s'"=="undocu" & "`y'"=="ln_adj" local LEGOPTs "legend(on)"

            * Draw panel (no per-panel title)
            event_plot e(b_iw)#e(V_iw), ///
                stub_lead(evt_m#) stub_lag(evt_p#) ///
                trimlead(`=scalar(K_avail)') trimlag(`=scalar(L_avail)') ///
                ciplottype(rcap) ///
                lead_ci_opt(lcolor(maroon)) lag_ci_opt(lcolor(navy)) ///
                lead_opt(msize(medium) mcolor(maroon)) ///
                lag_opt(msize(medium)  mcolor(navy))  ///
                graph_opt( ///
                    `LEGOPTs' ///
                    xtitle("Event time (τ)") ytitle("Effect vs. τ = -1") ///
                    yline(0, lcolor(gs7) lp(dash)) xline(0, lcolor(gs7) lp(dash)) ///
                    graphregion(color(white)) bgcolor(white))

            * Keep graph in memory with a clean name and save to disk
            graph rename G_`s'_`y', replace
            graph save "$figures/G_`s'_`y'.gph", replace
        restore
    }
}

* ---------- Build header graphs (blank panels with only titles) ----------
* Corner (blank)
twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) ///
    plotregion(margin(zero) style(none)) graphregion(color(white)) ///
    legend(off) title("")
graph rename H_corner, replace
graph save "$figures/H_corner.gph", replace

* Column headers (top row): nicer labels if desired
twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("Wages (ln_adj)", size(medsmall))
graph rename H_col_ln_adj, replace
graph save "$figures/H_col_ln_adj.gph", replace

twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("Vertical mismatch", size(medsmall))
graph rename H_col_vm, replace
graph save "$figures/H_col_vm.gph", replace

twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("Horizontal undermatch", size(medsmall))
graph rename H_col_hu, replace
graph save "$figures/H_col_hu.gph", replace

* Row headers (first column)
twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("Undocumented", size(medsmall))
graph rename H_row_undocu, replace
graph save "$figures/H_row_undocu.gph", replace

twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("KNN high-precision", size(medsmall))
graph rename H_row_knn, replace
graph save "$figures/H_row_knn.gph", replace

twoway scatter 0 0, yscale(off) xscale(off) ///
    ylabel(none) xlabel(none) plotregion(margin(zero) style(none)) ///
    graphregion(color(white)) legend(off) ///
    title("RF high-precision", size(medsmall))
graph rename H_row_rf, replace
graph save "$figures/H_row_rf.gph", replace

* ---------- Load all panels from disk (ensures names in memory) ----------
foreach g in H_corner H_col_ln_adj H_col_vm H_col_hu H_row_undocu H_row_knn H_row_rf ///
             G_undocu_ln_adj G_undocu_vmismatched G_undocu_hundermatched ///
             G_undocu_knn_ln_adj G_undocu_knn_vmismatched G_undocu_knn_hundermatched ///
             G_undocu_rf_ln_adj G_undocu_rf_vmismatched G_undocu_rf_hundermatched {
    graph use "$figures/`g'.gph", name(`g', replace)
}

* ---------- Combine with grc1leg (4×4 grid; legend from first panel) ----------
grc1leg ///
    H_corner H_col_ln_adj H_col_vm H_col_hu ///
    H_row_undocu    G_undocu_ln_adj    G_undocu_vmismatched    G_undocu_hundermatched ///
    H_row_knn       G_undocu_knn_ln_adj G_undocu_knn_vmismatched G_undocu_knn_hundermatched ///
    H_row_rf        G_undocu_rf_ln_adj  G_undocu_rf_vmismatched  G_undocu_rf_hundermatched, ///
    rows(4) cols(4) imargin(tiny) ///
    legendfrom(G_undocu_ln_adj) position(6) ///
    name(ES_3x3, replace)

graph export "$figures/ES_3x3_everify_require_grc1leg.png", width(2400) replace
