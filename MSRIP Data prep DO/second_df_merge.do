use eo_degfield_merged.dta, clear
sort occ
save eo_degfield_merged.dta, replace

use eo_table_by_occ.dta, clear
sort occ

merge 1:m occ using eo_degfield_merged.dta

drop _merge