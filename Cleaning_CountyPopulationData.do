cd "C:\Users\vitor\OneDrive\Combined_CON_Research\Data"
clear

*Saving 1990-1999 population data in dta format
insheet using "POP1990.CSV"
keep fips year tot_pop
save CountyPop_1990, replace

*Saving 2000-2009 data in dta format
clear
insheet using "POP2000.CSV"
keep fips year tot_pop
save CountyPop_2000, replace

*Saving 2010-2019 data in dta format
clear
insheet using "POP2010.CSV"

gen fips = (state*1000) + county
reshape long popestimate, i(fips) j(year)

rename popestimate tot_pop 
keep fips year tot_pop
save CountyPop_2010, replace

* Appending all data years
clear
use CountyPop_1990.dta

append using CountyPop_2000.dta
append using CountyPop_2010.dta

sort fips year

save CountyPop1990_2019.dta