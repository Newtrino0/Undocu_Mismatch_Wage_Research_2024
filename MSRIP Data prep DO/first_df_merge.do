use shih_prepped.dta, clear
sort degfield
save shih_prepped.dta, replace

use eo_table_by_degfield.dta, clear
sort degfield

merge 1:m degfield using shih_prepped.dta

drop _merge