*-------------------------------------------------------------------------------
* Estimating the Impact of Certificate of Need Laws on Expenditure: A Synthetic Control Approach
* ------------------------------------------------------------------------------
clear

* Setting Env Variables
global directory: env Combined_CON_Directory

* Setting Directory
cd "$directory"

forvalues i = 1990/2020 {
	clear
	use `i'.annual.singlefile.dta
	keep if (mod(area_fips,1000) == 0)
	keep if industry_code == 623110
	
	save IndustryData_`i'
	
}

clear
use IndustryData_1990.dta

forvalues i = 1991/2020 {
	append using IndustryData_`i'.dta, force
	
}

save IndustryData, replace

clear
use IndustryData.dta 

keep if own_code==5
keep area_fips year annual_avg_estabs annual_avg_emplvl
rename annual_avg_estabs quantity_nh
rename annual_avg_emplvl employment

save IndustryData, replace

keep if area_fips==42000


