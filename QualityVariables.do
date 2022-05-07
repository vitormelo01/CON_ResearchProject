*-------------------------------------------------------------------------------
* Creating Quality Variables
* ------------------------------------------------------------------------------
clear

* Setting Env Variables
global directory: env Combined_CON_Directory

* Setting Directory
cd "$directory"

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

************ Generating number of medicaid beds per state ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 4
collapse (sum) crtfd_bed_cnt , by(fips)
gen year = `i'

save POS_MedicaidBeds`i', replace
}

* Appending all years
clear
use POS_MedicaidBeds1991.dta
forvalues i = 1992/2020 {
	append using POS_MedicaidBeds`i'.dta
	
}
save CertifiedBeds_POS_allyears.dta, replace


clear
use CertifiedBeds_POS_allyears.dta

*keep if fips == 42000


sum vntltr_bed_cnt if prvdr_ctgry_cd == 1

************ Generating Share of specialized beds ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd
keep if prvdr_ctgry_cd == 4
collapse (sum) crtfd_bed_cnt bed_cnt dlys_bed_cnt hntgtn_dease_bed_cnt alzhmr_bed_cnt aids_bed_cnt head_trma_bed_cnt, by(fips)
gen specializedbeds_with_htt = dlys_bed_cnt + hntgtn_dease_bed_cnt + alzhmr_bed_cnt + aids_bed_cnt + head_trma_bed_cnt
gen specializedbeds_no_htt = dlys_bed_cnt + alzhmr_bed_cnt + aids_bed_cnt + head_trma_bed_cnt

* generating shares
gen share_alzhmr_bed_cnt = alzhmr_bed_cnt/bed_cnt
gen share_specializedbeds_no_htt = specializedbeds_no_htt/bed_cnt
gen share_specializedbeds_with_htt = specializedbeds_with_htt/bed_cnt

gen year = `i'

save POS_SpecializedBeds`i', replace
}

* Appending all years
clear
use POS_SpecializedBeds1991.dta
forvalues i = 1992/2020 {
	append using POS_SpecializedBeds`i'.dta
	
}

keep fips year crtfd_bed_cnt bed_cnt share_alzhmr_bed_cnt share_specializedbeds_no_htt share_specializedbeds_with_htt
save Shares_SpecializedBeds_POS_allyears.dta, replace

clear
use Shares_SpecializedBeds_POS_allyears.dta







************ Generating Number of specialized beds ************
forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd
keep if prvdr_ctgry_cd == 4
collapse (sum) crtfd_bed_cnt bed_cnt dlys_bed_cnt hntgtn_dease_bed_cnt alzhmr_bed_cnt aids_bed_cnt head_trma_bed_cnt, by(fips)
gen specializedbeds_with_htt = dlys_bed_cnt + hntgtn_dease_bed_cnt + alzhmr_bed_cnt + aids_bed_cnt + head_trma_bed_cnt
gen specializedbeds_no_htt = dlys_bed_cnt + alzhmr_bed_cnt + aids_bed_cnt + head_trma_bed_cnt


gen year = `i'

save POS_SpecializedBeds`i', replace
}

* Appending all years
clear
use POS_SpecializedBeds1991.dta
forvalues i = 1992/2020 {
	append using POS_SpecializedBeds`i'.dta
	
}


save SpecializedBeds_POS_allyears.dta, replace

clear 
use SpecializedBeds_POS_allyears.dta

keep if fips == 38



************ Generating number of nurses/nurse practicioner  ************
/*

Nurses are not being reported by nursing homes:


forvalues i = 1991/2020 {
	clear 
	use pos_cleaned_`i'.dta
destring prvdr_ctgry_cd, replace
gen fips = fips_state_cd*1000
keep if prvdr_ctgry_cd == 4
collapse (sum) bed_cnt nrs_prctnr_cnt rn_cnt emplee_cnt, by(fips)
gen nursepractc_perbed = nrs_prctnr_cnt/bed_cnt
gen registerednurse_perbed = rn_cnt/bed_cnt
gen allnurses_perbed = (rn_cnt + nrs_prctnr_cnt)/bed_cnt

*Generating shares of employment by nurses
gen nursepractc_peremp = nrs_prctnr_cnt/emplee_cnt
gen registerednurse_peremp = rn_cnt/emplee_cnt
gen allnurses_peremp = (rn_cnt + nrs_prctnr_cnt)/emplee_cnt

gen year = `i'

save POS_Nurses`i', replace
}


clear
use POS_Nurses2012.dta
*/

************ Merging population data with certified beds ************
clear
use CertifiedBeds_POS_allyears.dta

replace fips = fips/1000
rename fips id

merge 1:1 year id using PopulationStates.dta
drop if id>58
drop if id==0
drop if id==43
keep if _merge==3
drop _merge
* population is in thousands so I multiply the poulation variable by 1000 to get actual population
replace pop = pop*1000
rename pop population 

gen CertifiedBeds_perhundredk = mdcr_mdcd_snf_bed_cnt/population*100000
save Scaled_CertifiedBeds_POS_allyears.dta, replace

************ Merging population data with specialized beds ************
clear
use SpecializedBeds_POS_allyears.dta

*replace fips = fips/1000
rename fips id

merge 1:1 year id using PopulationStates.dta
drop if id>58
drop if id==0
drop if id==43
keep if _merge==3
drop _merge


* population is in thousands so I multiply the poulation variable by 1000 to get actual population
replace pop = pop*1000
rename pop population 


gen alzhmrbeds_perhundredk = alzhmr_bed_cnt/population*100000
gen specialized_withhtt_perhundredk = specializedbeds_with_htt/population*100000
gen certifiedBeds_perhundredk = crtfd_bed_cnt/population*100000

save Scaled_specializedBeds_POS_allyears.dta, replace

clear 
use Scaled_specializedBeds_POS_allyears.dta



************ Merging everything with controls ************

clear

use CON_NursingHome.dta
*rename id fips
*replace id = fips*1000

merge 1:1 year id using  Scaled_specializedBeds_POS_allyears.dta
keep if _merge == 3
drop _merge 

save Specialization_withControls.dta, replace



/*
merge 1:1 year id using  Scaled_CertifiedBeds_POS_allyears.dta
keep if _merge == 3
drop _merge 

rename id fips
replace fips = fips*1000
merge 1:1 year fips using Shares_SpecializedBeds_POS_allyears.dta
drop _merge

replace fips = fips/1000
drop if year >2014

drop mdcr_mdcd_snf_bed_cnt
drop landarea

save Specialization_CertifiedBeds_Complete.dta, replace

*/

