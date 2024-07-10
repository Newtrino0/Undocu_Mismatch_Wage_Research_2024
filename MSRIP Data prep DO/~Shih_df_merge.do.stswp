

use Stage_1_df.dta, clear
sort occS
save Stage_1_df.dta, replace

use temp_shih_data.dta, clear
sort occS

merge 1:1 occS using Stage_1_df.dta