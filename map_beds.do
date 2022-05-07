cd "C:\Users\vitor\OneDrive\Combined_CON_Research\Data"
clear


*** Indiana ***

forvalues i = 1991(1)2018 {
	
	clear
	use "pos_cleaned_`i'.dta"
	* Collapsing the data into total beds per county for year `i'
	keep if prvdr_ctgry_cd == 4
	keep if fips_state_cd == 18 
	collapse (sum) bed_cnt crtfd_bed_cnt, by(fips_cnty_cd)
	* Replacing blanks for 0s
	
	rename bed_cnt bed_cnt`i'
	rename crtfd_bed_cnt crtfd_bed_cnt`i'

	gen fips = fips_cnty_cd + 18000
	gen year = `i'
	
	merge m:m fips year using CountyPop1990_2019.dta
	keep if _merge==3
	drop _merge
	
	*Generating beds per 100,000 people.
	gen bed_per_capita`i' = bed_cnt/tot_pop*100000
	gen crtfd_bed_per_capita`i' = crtfd_bed_cnt/tot_pop*100000
	
	save IN_POS_MapofBeds`i', replace
	
}


clear
use IN_POS_MapofBeds1995.dta

* Merging data for year 2018 and 1995
merge m:m fips using IN_POS_MapofBeds2018
drop _merge 
drop fips_cnty_cd
drop tot_pop
sort fips

replace crtfd_bed_cnt1995 = 0 if crtfd_bed_cnt1995 == .
replace bed_cnt1995 = 0 if bed_cnt1995 == .
replace crtfd_bed_per_capita1995 = 0 if crtfd_bed_per_capita1995 == .
replace bed_per_capita1995 = 0 if bed_per_capita1995 == .
	
gen bed_change_pcap = bed_per_capita2018 - bed_per_capita1995

gen crtfd_bed_change_pcap = crtfd_bed_per_capita2018 - crtfd_bed_per_capita1995
duplicates drop


replace crtfd_bed_cnt1995 = 0 if crtfd_bed_cnt1995 == .
* Calculating total difference in certified beds for each county
gen diff_beds = crtfd_bed_cnt2018 - crtfd_bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen percentage_bedchange = (crtfd_bed_cnt2018 - crtfd_bed_cnt1995)/crtfd_bed_cnt1995*100

replace bed_cnt1995 = 0 if bed_cnt1995 == .
* Calculating total difference in beds for each county
gen total_diff_beds = bed_cnt2018 - bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen total_percentage_bedchange = (bed_cnt2018 - bed_cnt1995)/bed_cnt1995*100

gen state_fips = 18
save IN_BedChange_Map, replace 


* Getting data ready for map
clear
use IN_BedChange_Map.dta


rename diff_beds certified_beds_changed
keep fips total_diff_beds certified_beds_changed

save map_IN_final, replace
outsheet using "map_IN_final.csv", comma


******************************************************************************************

*** Pennsylvania ***
clear
use "pos_cleaned_1995.dta"

* Collapsing the data into total beds per county for year 1995
keep if prvdr_ctgry_cd == 4
keep if fips_state_cd == 42 
collapse (sum) bed_cnt crtfd_bed_cnt, by(fips_cnty_cd)
rename bed_cnt bed_cnt1995
rename crtfd_bed_cnt crtfd_bed_cnt1995

save PA_POS_MapofBeds1995, replace

* Collapsing the data into total beds per county for year 2018
clear 
use "pos_cleaned_2018.dta"
keep if prvdr_ctgry_cd == 4
keep if fips_state_cd == 42 
collapse (sum) bed_cnt crtfd_bed_cnt, by(fips_cnty_cd)
rename bed_cnt bed_cnt2018
rename crtfd_bed_cnt crtfd_bed_cnt2018

save PA_POS_MapofBeds2018, replace

* Merging data for year 2018 and 1995
merge m:m fips_cnty_cd using PA_POS_MapofBeds1995

replace crtfd_bed_cnt1995 = 0 if crtfd_bed_cnt1995 == .
* Calculating total difference in certified beds for each county
gen diff_beds = crtfd_bed_cnt2018 - crtfd_bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen percentage_bedchange = (crtfd_bed_cnt2018 - crtfd_bed_cnt1995)/crtfd_bed_cnt1995*100

replace bed_cnt1995 = 0 if bed_cnt1995 == .
* Calculating total difference in beds for each county
gen total_diff_beds = bed_cnt2018 - bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen total_percentage_bedchange = (bed_cnt2018 - bed_cnt1995)/bed_cnt1995*100

gen state_fips = 42
save PA_BedChange_Map, replace 

* Getting data ready for map
clear
use PA_BedChange_Map.dta

rename diff_beds certified_beds_changed
gen fips = state_fips*1000 + fips_cnty_cd
keep fips total_diff_beds certified_beds_changed


save map_PA_final, replace
outsheet using "map_PA_final.csv", comma




*****************************************************************************************
/*
*** North Dakota ***
clear
use "pos_cleaned_1995.dta"

* Collapsing the data into total beds per county for year 1995
keep if prvdr_ctgry_cd == 4
keep if fips_state_cd == 38 
collapse (sum) bed_cnt crtfd_bed_cnt, by(fips_cnty_cd)
rename bed_cnt bed_cnt1995
rename crtfd_bed_cnt crtfd_bed_cnt1995

save ND_POS_MapofBeds1995, replace

clear 
use "pos_cleaned_2018.dta"

* Collapsing the data into total beds per county for year 2018
keep if prvdr_ctgry_cd == 4
keep if fips_state_cd == 38 
collapse (sum) bed_cnt crtfd_bed_cnt, by(fips_cnty_cd)
rename bed_cnt bed_cnt2018
rename crtfd_bed_cnt crtfd_bed_cnt2018

save ND_POS_MapofBeds2018, replace

* Merging data for year 2018 and 1995
merge m:m fips_cnty_cd using ND_POS_MapofBeds1995


replace crtfd_bed_cnt1995 = 0 if crtfd_bed_cnt1995 == .
* Calculating total difference in certified beds for each county
gen diff_beds = crtfd_bed_cnt2018 - crtfd_bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen percentage_bedchange = (crtfd_bed_cnt2018 - crtfd_bed_cnt1995)/crtfd_bed_cnt1995*100

replace bed_cnt1995 = 0 if bed_cnt1995 == .
* Calculating total difference in beds for each county
gen total_diff_beds = bed_cnt2018 - bed_cnt1995
* Calculating percentage change in certified beds for each county. Note that some number cannot be calculate dbecause the initial number of beds is 0 
gen total_percentage_bedchange = (bed_cnt2018 - bed_cnt1995)/bed_cnt1995*100

gen state_fips = 38
save ND_BedChange_Map, replace 

clear 
use ND_BedChange_Map.dta

*/




















