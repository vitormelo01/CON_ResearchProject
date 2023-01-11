*-------------------------------------------------------------------------------
* Creating Quality Variables
* ------------------------------------------------------------------------------
clear

* Setting Env Variables
*global directory: env Combined_CON_Directory

* Setting Directory
cd "C:\Users\vmelo\OneDrive\Combined_CON_Research\Data"

* Data dictionary: 
/* 

prvdr_ctgry_cd == Provider category
crtfd_bed_cnt == certified bed count
bed_cnt == total bed count
mdcd_snf_bed_cnt == Medicaid Skilled Nursing Facility beds
mdcr_snf_bed_cnt == Medicare Skilled Nursing Facility beds
dlys_bed_cnt == dialysis dedicated beds
hntgtn_dease_bed_cnt == Huntington's disease beds 
vntltr_bed_cnt == ventilator and/or respiratory care
alzhmr_bed_cnt ==  Alzheimers beds
aids_bed_cnt == Aids beds
dsbl_chldrn_bed_cnt == Disabled children beds 
head_trma_bed_cnt == Head Trauma beds

Nurses data: 
nrs_prctnr_cnt == number of full time nurse practicioners
rn_cnt  == numbers of registered nurses 
emplee_cnt == total number of employees 

*/

************ Generating number of assisted living certfied beds per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 10
collapse (sum) crtfd_bed_cnt , by(fips)
gen year = `i'

save POS_AssistedLivingdBeds`i', replace
}

* Appending all years
clear
use POS_AssistedLivingdBeds1991.dta
forvalues i = 1992/2020 {
	append using POS_AssistedLivingdBeds`i'.dta
	
}
save AssistedLivingdBeds_POS_allyears.dta, replace



************ Generating number of hospital certfied beds per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 1
collapse (sum) crtfd_bed_cnt , by(fips)
gen year = `i'

save POS_HospitalBeds`i', replace
}

* Appending all years
clear
use POS_HospitalBeds1991.dta
forvalues i = 1992/2020 {
	append using POS_HospitalBeds`i'.dta
	
}
save HospitalBeds_POS_allyears.dta, replace



************ Generating number of home care agencies per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 5
gen homecare_agencies = 1
collapse (sum) homecare_agencies, by(fips)
gen year = `i'

save POS_Homecare`i', replace
}

* Appending all years
clear
use POS_Homecare1991.dta
forvalues i = 1992/2020 {
	append using POS_Homecare`i'.dta
	
}
save Homecare_POS_allyears.dta, replace


************ Generating number of assisted living facilities per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 10
gen facilities = 1
collapse (sum) facilities, by(fips)
gen year = `i'

save POS_AssistedLivingdFacilities`i', replace
}

* Appending all years
clear
use POS_AssistedLivingdFacilities1991.dta
forvalues i = 1992/2020 {
	append using POS_AssistedLivingdFacilities`i'.dta
	
}
save AssistedLivingdFacilities_POS_allyears.dta, replace



************ Generating number of hospital facilities per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 1
gen facilities = 1
collapse (sum) facilities , by(fips)
gen year = `i'

save POS_HospitalFacilities`i', replace
}

* Appending all years
clear
use POS_HospitalFacilities1991.dta
forvalues i = 1992/2020 {
	append using POS_HospitalFacilities`i'.dta
	
}
save HospitalFacilities_POS_allyears.dta, replace
