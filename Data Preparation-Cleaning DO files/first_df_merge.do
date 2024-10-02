*** Degree field tables/dateframes merged with sample***
**1st merge: by degfield merge**
use shih_prepped.dta, clear
sort degfield
save shih_prepped.dta, replace

use eo_table_by_degfield.dta, clear
sort degfield

merge 1:m degfield using shih_prepped.dta
drop _merge

**2nd merge: by degfieldd**
save eo_tables_merged, replace

use eo_table_by_degfieldd,clear
sort degfieldd

merge 1:m degfieldd using eo_tables_merged
drop _merge


***Occupation tables/dataframes merged with sample***
**3rd merge: by occ merge**
save eo_tables_merged, replace

use eo_table_by_occ_na, clear
sort occ

merge 1:m occ using eo_tables_merged
drop _merge


save eo_tables_merged_na, replace