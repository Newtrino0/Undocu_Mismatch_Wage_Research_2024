

use shih_prepped.dta, clear
sort degfieldS
save shih_prepped.dta, replace

use eo_table_by_degfield, clear
sort degfieldS

merge 1:m degfieldS using shih_prepped.dta


