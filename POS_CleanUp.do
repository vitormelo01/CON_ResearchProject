*-------------------------------------------------------------------------------
* Cleaning and Appending Access Data
* ------------------------------------------------------------------------------


clear
cd "D:\Research\CONandHealthSpending\Data\POSdata"

*-------------------------------------------------------------------------------
* Total Hospitals per State 
* ------------------------------------------------------------------------------

forvalues i = 1991/2020 {

use pos`i'.dta
gen Q_Hospitals = 1
destring prvdr_ctgry_cd, replace
destring ssa_state_cd, replace
keep if prvdr_ctgry_cd == 1
collapse (sum) Q_Hospitals, by(ssa_state_cd)
gen year= `i'

save POS_Hospitals_`i', replace
}

clear
forvalues i = 1984/1990 {

use pos`i'.dta
gen Q_Hospitals = 1
rename state ssa_state_cd
rename category prvdr_ctgry_cd
destring prvdr_ctgry_cd, replace
destring ssa_state_cd, replace

keep if prvdr_ctgry_cd == 1
collapse (sum) Q_Hospitals, by(ssa_state_cd)
gen year= `i'

save POS_Hospitals_`i', replace
}

clear
use POS_Hospitals_1984.dta
forvalues i = 1985/2020 {
	append using POS_Hospitals_`i'.dta
}

save HospitalQuantity_Complete, replace 

*-------------------------------------------------------------------------------
* Total Hospitals In Rural Arteas per State 
* ------------------------------------------------------------------------------

forvalues i = 1991/2020 {

use pos`i'.dta
gen Q_Hospitals = 1
destring prvdr_ctgry_cd, replace
destring ssa_state_cd, replace
keep if prvdr_ctgry_cd == 1
collapse (sum) Q_Hospitals, by(ssa_state_cd)
gen year= `i'

save POS_Hospitals_`i', replace
}

clear
forvalues i = 1984/1990 {

use pos`i'.dta
gen Q_Hospitals = 1
rename state ssa_state_cd
rename category prvdr_ctgry_cd
destring prvdr_ctgry_cd, replace
destring ssa_state_cd, replace

keep if prvdr_ctgry_cd == 1
collapse (sum) Q_Hospitals, by(ssa_state_cd)
gen year= `i'

save POS_Hospitals_`i', replace
}

clear
use POS_Hospitals_1984.dta
forvalues i = 1985/2020 {
	append using POS_Hospitals_`i'.dta
}

save HospitalQuantity_Complete, replace 
