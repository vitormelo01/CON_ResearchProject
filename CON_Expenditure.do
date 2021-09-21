*-------------------------------------------------------------------------------
* Estimating the Impact of Certificate of Need Laws on Expenditure: A Synthetic Control Approach
* ------------------------------------------------------------------------------
clear

* Setting Env Variables
global directory: env Combined_CON_Directory

* Setting Directory
cd "$directory"


* Setting Globals
global controls "income_pcp_adj pop_density unemp_rate top1_adj gini prop_age_25to45_bsy prop_age_45to65_bsy prop_age_over65_bsy prop_bach_degree_bsy prop_male_bsy prop_married_bsy prop_white_bsy"

*-------------------------------------------------------------------------------
* Total Health Expenditure - Clean up
* ------------------------------------------------------------------------------

insheet using "PROV_US_AGGREGATE14.csv"

* Creating fips state id
{ 
	rename state_name state
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

* Reshape data
drop if id==.
reshape long y, i(id code) j(year)

* Drop and rename variables
rename y total_spending 
drop average_annual_percent_growth
drop item
drop state

* Saving total health expenditure data
save TotalHealthSpending, replace


*-------------------------------------------------------------------------------
* Medicare - Clean up
* ------------------------------------------------------------------------------
clear
insheet using "PROV_MEDICARE_AGGREGATE14.csv"

* Creating fips state id
{ 
	rename state_name state
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

* Reshape data
drop if id==.
reshape long y, i(id code) j(year)

* Drop and rename variables
rename y medicare_spending 
drop average_annual_percent_growth
drop item
drop state

* Saving total health expenditure data
save MedicareSpending, replace


*-------------------------------------------------------------------------------
* Medicaid Expenditure - Clean up
* ------------------------------------------------------------------------------
clear
insheet using "PROV_MEDICAID_AGGREGATE14.csv"

* Creating fips state id
{ 
	rename state_name state
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

* Reshape data
drop if id==.
reshape long y, i(id code) j(year)

* Drop and rename variables
rename y medicaid_spending 
drop average_annual_percent_growth
drop item
drop state

* Saving total health expenditure data
save MedicaidSpending, replace

*-------------------------------------------------------------------------------
* Merging Data on Total, Medicare, and Medicaid Spending
* ------------------------------------------------------------------------------

clear
use "TotalHealthSpending.dta"

* Merging datasets
merge 1:1 id year code using MedicareSpending.dta
drop _merge
merge 1:1 id year code using MedicaidSpending.dta
drop _merge

* Saving final data
save Health_Spending_Data, replace


*-------------------------------------------------------------------------------
* Loading population data and merging it with health exp data
* ------------------------------------------------------------------------------

clear 
insheet using "PopulationStates.csv"
reshape long pop, i(year) j(id)

* Saving Population data
save PopulationStates, replace

merge m:m id year using Health_Spending_Data.dta
drop if region_number==.
drop region_number
drop _merge 

* Creating spending per capita data
gen total_spending_pcp = total_spending/pop
gen medicare_spending_pcp = medicare_spending/pop
gen medicaid_spending_pcp = medicaid_spending/pop

drop group
drop region_name
save CON_Expenditure.dta, replace

*-------------------------------------------------------------------------------
* Loading CPI and adjusting health spendging levels for inflation (2015 prices)
* ------------------------------------------------------------------------------

clear 
insheet using "CPI_2015Prices.csv"

* Merging data with Exp. per capita data
merge m:m year using CON_Expenditure.dta
drop if _merge==1
       // only year 1960-1979 and 2015-2019 did not match

* Creating  expenditure per capita adjusted for inflation (2015 prices)

gen total_spending_pcp_adj = total_spending_pcp/cpi*100
gen medicare_spending_pcp_adj = medicare_spending_pcp/cpi*100
gen medicaid_spending_pcp_adj = medicaid_spending_pcp/cpi*100

* Dropping old expenditure variables
drop total_spending
drop total_spending_pcp
drop medicare_spending
drop medicare_spending_pcp
drop medicaid_spending
drop medicaid_spending_pcp

* Renaming expenditure variables
rename total_spending_pcp_adj total_exp
rename medicare_spending_pcp_adj medicare_exp
rename medicaid_spending_pcp_adj medicaid_exp

* Saving
drop _merge 
sort year id
save CON_Expenditure.dta, replace

*-------------------------------------------------------------------------------
* Merging Con data with cleaned Expenditure
* ------------------------------------------------------------------------------

clear 
insheet using "CON_Data.csv"
rename yearofrepeal repeal_y
reshape long con, i(id) j(year)
save CON_Data, replace

merge 1:m year id using CON_Expenditure.dta

* Droping Louisiana because it did not have CON laws until 1991 and then implemented it, so it does not work with our model
drop _merge 
save CON_Expenditure.dta, replace

*-------------------------------------------------------------------------------
* Merging with Income per Capita Data
* ------------------------------------------------------------------------------

clear 
insheet using "income_pcp.csv"

*clean up
keep if linecode==3
gen id=geofips/1000
drop geofips
drop geoname
drop linecode
drop description 

*Reshaping and saving income per capita data
reshape long i, i(id) j(year)
rename i income_pcp
save income_pct, replace

* Loading CPI and adjusting income per capita for inflation (2015 prices)
clear 
insheet using "CPI_2015Prices.csv"

* Merging data with Exp. per capita data
merge 1:m year using income_pct.dta
drop if _merge==2
       
* Creating  income per capita adjusted for inflation (2015 prices)
gen income_pcp_adj = .
replace income_pcp_adj = income_pcp/cpi*100

* Clean Up
drop income_pcp
drop _merge 
sort year id

merge 1:m year id using CON_Expenditure.dta
drop if _merge==1
drop _merge
save CON_Expenditure.dta, replace

* ------------------------------------------------------------------------------
* Merging with Gini Coefficients Data
* ------------------------------------------------------------------------------
clear 
insheet using "Gini.csv"

* Creating Fips id
{
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

* Clean Up 
drop if id==.
rename Year year
keep year id gini

* Merging with current data
merge 1:m year id using CON_Expenditure.dta
drop if _merge==1
drop _merge

save CON_Expenditure.dta, replace

* ------------------------------------------------------------------------------
* Merging with Income Shares Data
* ------------------------------------------------------------------------------

clear 
insheet using "IncomeShares.csv"

* Creating Fips id
{
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

* Clean Up 
drop if id==.
rename Year year
drop number state

* Merging with current data
merge 1:m year id using CON_Expenditure.dta
drop if _merge==1
drop _merge

save CON_Expenditure.dta, replace

* ------------------------------------------------------------------------------
* Merging with Unemployment Rate data
* ------------------------------------------------------------------------------

clear 
insheet using "Unemployment_states.csv"

* Clean up and Reshape
replace id = id/1000
drop area
reshape long u, i(id) j(year)
rename u unemp_rate
drop if id==0

* Merging with current data
merge 1:m year id using CON_Expenditure.dta
drop if _merge==1
drop _merge

save CON_Expenditure.dta, replace

* ------------------------------------------------------------------------------
* Merging with Population Density
* ------------------------------------------------------------------------------

clear 
insheet using "Area_States.csv"

* Creating Fips id

{
	rename State state
	gen id = .
replace id = 1 if state=="Alabama"
replace id = 2 if state=="Alaska"
replace id = 4 if state=="Arizona"
replace id = 5 if state=="Arkansas"
replace id = 6 if state=="California"
replace id = 8 if state=="Colorado"
replace id = 9 if state=="Connecticut"
replace id = 10 if state=="Delaware"
replace id = 11 if state=="District of Columbia"
replace id = 12 if state=="Florida"
replace id = 13 if state=="Georgia"
replace id = 15 if state=="Hawaii"
replace id = 16 if state=="Idaho"
replace id = 17 if state=="Illinois"
replace id = 18 if state=="Indiana"
replace id = 19 if state=="Iowa"
replace id = 20 if state=="Kansas"
replace id = 21 if state=="Kentucky"
replace id = 22 if state=="Louisiana"
replace id = 23 if state=="Maine"
replace id = 24 if state=="Maryland"
replace id = 25 if state=="Massachusetts"
replace id = 26 if state=="Michigan"
replace id = 27 if state=="Minnesota"
replace id = 28 if state=="Mississippi"
replace id = 29 if state=="Missouri"
replace id = 30 if state=="Montana"
replace id = 31 if state=="Nebraska"
replace id = 32 if state=="Nevada"
replace id = 33 if state=="New Hampshire"
replace id = 34 if state=="New Jersey"
replace id = 35 if state=="New Mexico"
replace id = 36 if state=="New York"
replace id = 37 if state=="North Carolina"
replace id = 38 if state=="North Dakota"
replace id = 39 if state=="Ohio"
replace id = 40 if state=="Oklahoma"
replace id = 41 if state=="Oregon"
replace id = 42 if state=="Pennsylvania"
replace id = 44 if state=="Rhode Island"
replace id = 45 if state=="South Carolina"
replace id = 46 if state=="South Dakota"
replace id = 47 if state=="Tennessee"
replace id = 48 if state=="Texas"
replace id = 49 if state=="Utah"
replace id = 50 if state=="Vermont"
replace id = 51 if state=="Virginia"
replace id = 53 if state=="Washington"
replace id = 54 if state=="West Virginia"
replace id = 55 if state=="Wisconsin"
replace id = 56 if state=="Wyoming"
}

keep id landarea
merge 1:m id using CON_Expenditure.dta
drop _merge

gen pop_density = pop/landarea

* ------------------------------------------------------------------------------
* Merging with Demographic Controls - ASEC
* ------------------------------------------------------------------------------

rename id state
merge m:1 state year using ASEC_1980-2014_State.dta

rename state id
save CON_Expenditure.dta, replace


* ------------------------------------------------------------------------------
* Synthetic Control Estimates
* ------------------------------------------------------------------------------

* Installing Synth Command
*ssc install synth, replace all

/* Variable Code can be changed for different break downs of expenditure data:
1 = Total Personal Health Care
2 = Hopital Care
3 = Physician & Clinical Services
6 = Home Health Care
9 = Durable Medical Products
10 = Nursing Home Care 
*/


* ------------------------------------------------------------------------------
* Preparing Data for Graphs from Synthetic control analysis
* ------------------------------------------------------------------------------

clear 
use CON_Expenditure.dta

replace total_exp = total_exp*1000
replace medicare_exp = medicare_exp*1000
replace medicaid_exp = medicaid_exp*1000

save CON_Expenditure.dta, replace


* ------------------------------------------------------------------------------
* Pennsylvania Synthetic Control Analysis
* ------------------------------------------------------------------------------

*   ---Trend Graphs - Expenditure and Access---
clear

*Total Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 1/1 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1987) `outcome'(1986) `outcome'(1985) `outcome'(1984) 
		`outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(42) trperiod(1996) nested
		keep(CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1995, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Pennsylvania") lab(2 "Synthetic Pennsylvania") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(200[100]900, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_PA\Figures\\`output'_Trends_PA.pdf, replace
}
*Medicaid Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 2/2 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1987) `outcome'(1986) `outcome'(1985) `outcome'(1984) 
		`outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(42) trperiod(1996) nested
		keep(CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1995, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Pennsylvania") lab(2 "Synthetic Pennsylvania") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(50[50]400, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_PA\Figures\\`output'_Trends_PA.pdf, replace
}
*Quantity of Nursing Homes
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 3/3 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1993) `outcome'(1992) `outcome'(1991), 
		trunit(42) trperiod(1996) nested
		keep(CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1995, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Pennsylvania") lab(2 "Synthetic Pennsylvania") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[.2]1.6, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_PA\Figures\\`output'_Trends_PA.pdf, replace
}
*Quantity of Nursing Home Beds
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 4/4 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1993) `outcome'(1992) `outcome'(1991), 
		trunit(42) trperiod(1996) nested
		keep(CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_PA\Synth_Output\synth_`output'_PA.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1995, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Pennsylvania") lab(2 "Synthetic Pennsylvania") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[10]80, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_PA\Figures\\`output'_Trends_PA.pdf, replace
}



*   ---Placebo Graph and Exact P-value - Total Nursing Home Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to PA and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "Pennsylvania"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth total_exp $controls 
		total_exp(1987) total_exp(1986) total_exp(1985) total_exp(1984) 
		total_exp(1983) total_exp(1982) total_exp(1981) total_exp(1980), 
		trunit(`i') trperiod(1996) nested
		keep(CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, replace
*create figures
use CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 42
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 42, lwidth(thick) lcolor(black) 
		xline(1995, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Pennsylvania") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Total Nursing Home Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_PA\Figures\nursing_home_tot_exp_Gaps_with_Placebos_`i'_PA.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1995
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 42
list pvalue if state == 42 /* P value = .056 */
*Average post-intervention effect 
use CON_Expenditure_PA\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1995
list ave_effect if state == 42 /* Ave. effect = 123.57 */


*   ---Placebo Graph and Exact P-value - Nursing Home Medicaid Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to PA and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "Pennsylvania"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth medicaid_exp $controls 
		medicaid_exp(1987) medicaid_exp(1986) medicaid_exp(1985) medicaid_exp(1984) 
		medicaid_exp(1983) medicaid_exp(1982) medicaid_exp(1981) medicaid_exp(1980), 
		trunit(`i') trperiod(1996) nested
		keep(CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, replace
*create figure
use CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 42
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 42, lwidth(thick) lcolor(black) 
		xline(1995, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Pennsylvania") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Nursing Home Medicaid Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_PA\Figures\nursing_home_medicaid_exp_Gaps_with_Placebos_`i'_PA.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1995
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 42
list pvalue if state == 42 /* P value = .083 */
*Average post-intervention effect 
use CON_Expenditure_PA\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1995
list ave_effect if state == 42 /* Ave. effect = 104.17 */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Homes---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomes_pcp $controls 
		Q_SkilledNursingHomes_pcp(1993) Q_SkilledNursingHomes_pcp(1992) Q_SkilledNursingHomes_pcp(1991), 
		trunit(`i') trperiod(1996) nested
		keep(CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, nogenerate    
}
save CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, replace
*create figure
use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 42
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 42, lwidth(thick) lcolor(black) 
		xline(1995, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Pennsylvania") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Homes Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_PA\Figures\q_nursing_homes_Gaps_with_Placebos_`i'_PA.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1995
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 42
list pvalue if state == 42 /* P value = .083 */
*Average post-intervention effect 
use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1995
list ave_effect if state == 42 /* Ave. effect = 0.369 */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Home Beds---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Pennsylvania"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomeBeds_pcp $controls 
		Q_SkilledNursingHomeBeds_pcp(1993) Q_SkilledNursingHomeBeds_pcp(1992) Q_SkilledNursingHomeBeds_pcp(1991), 
		trunit(`i') trperiod(1996) nested
		keep(CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, nogenerate    
}
save CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, replace
*create figure
use CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
use CON_Expenditure_PA\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 42
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 42, lwidth(thick) lcolor(black) 
		xline(1995, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Pennsylvania") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Home Beds Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_PA\Figures\q_nursing_home_beds_Gaps_with_Placebos_`i'_PA.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1995
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1995
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 42 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 42
list pvalue if state == 42 /* P value = .5278 */
*Average post-intervention effect 
use CON_Expenditure_PA\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1995
list ave_effect if state == 42 /* Ave. effect = 12.12 */





* ------------------------------------------------------------------------------
* North Dakota Synthetic Control Analysis
* ------------------------------------------------------------------------------

*   ---Trend Graphs - Expenditure and Access---
clear

*Total Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 1/1 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1987) `outcome'(1986) `outcome'(1985) `outcome'(1984) 
		`outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(38) trperiod(1995) nested
		keep(CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1994, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "North Dakota") lab(2 "Synthetic North Dakota") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(200[100]900, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_ND\Figures\\`output'_Trends_ND.pdf, replace
}
*Medicaid Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 2/2 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1987) `outcome'(1986) `outcome'(1985) `outcome'(1984) 
		`outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(38) trperiod(1995) nested
		keep(CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1994, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "North Dakota") lab(2 "Synthetic North Dakota") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(50[50]400, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_ND\Figures\\`output'_Trends_ND.pdf, replace
}
*Quantity of Nursing Homes
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 3/3 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1992) `outcome'(1991), 
		trunit(38) trperiod(1995) nested
		keep(CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1994, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "North Dakota") lab(2 "Synthetic North Dakota") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[.2]1.6, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_ND\Figures\\`output'_Trends_ND.pdf, replace
}
*Quantity of Nursing Home Beds
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 4/4 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1992) `outcome'(1991), 
		trunit(38) trperiod(1995) nested
		keep(CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_ND\Synth_Output\synth_`output'_ND.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1994, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "North Dakota") lab(2 "Synthetic North Dakota") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[10]80, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_ND\Figures\\`output'_Trends_ND.pdf, replace
}


*   ---Placebo Graph and Exact P-value - Total Nursing Home Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to ND and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "North Dakota"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth total_exp $controls 
		total_exp(1987) total_exp(1986) total_exp(1985) total_exp(1984) 
		total_exp(1983) total_exp(1982) total_exp(1981) total_exp(1980), 
		trunit(`i') trperiod(1995) nested
		keep(CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, replace
*create figure
use CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 38
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 38, lwidth(thick) lcolor(black) 
		xline(1994, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "North Dakota") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Total Nursing Home Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_ND\Figures\nursing_home_tot_exp_Gaps_with_Placebos_`i'_ND.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1994
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 38
list pvalue if state == 38 /* P value = . */
*Average post-intervention effect 
use CON_Expenditure_ND\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1994
list ave_effect if state == 38 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Nursing Home Medicaid Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to ND and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "North Dakota"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth medicaid_exp $controls 
		medicaid_exp(1987) medicaid_exp(1986) medicaid_exp(1985) medicaid_exp(1984) 
		medicaid_exp(1983) medicaid_exp(1982) medicaid_exp(1981) medicaid_exp(1980), 
		trunit(`i') trperiod(1995) nested
		keep(CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, replace
*create figure
use CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 38
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 38, lwidth(thick) lcolor(black) 
		xline(1994, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "North Dakota") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Nursing Home Medicaid Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_ND\Figures\nursing_home_medicaid_exp_Gaps_with_Placebos_`i'_ND.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1994
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 38
list pvalue if state == 38 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_ND\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1994
list ave_effect if state == 38 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Homes---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomes_pcp $controls 
		Q_SkilledNursingHomes_pcp(1992) Q_SkilledNursingHomes_pcp(1991), 
		trunit(`i') trperiod(1995) nested
		keep(CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, nogenerate    
}
save CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, replace
*create figure
use CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 38
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 38, lwidth(thick) lcolor(black) 
		xline(1994, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "North Dakota") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Homes Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_ND\Figures\q_nursing_homes_Gaps_with_Placebos_`i'_ND.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1994
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 38
list pvalue if state == 38 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_ND\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1994
list ave_effect if state == 38 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Home Beds---
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "North Dakota"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomeBeds_pcp $controls 
		Q_SkilledNursingHomeBeds_pcp(1992) Q_SkilledNursingHomeBeds_pcp(1991), 
		trunit(`i') trperiod(1995) nested
		keep(CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, nogenerate    
}
save CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, replace
*create figure
use CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 38
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 38, lwidth(thick) lcolor(black) 
		xline(1994, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "North Dakota") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Home Beds Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_ND\Figures\q_nursing_home_beds_Gaps_with_Placebos_`i'_ND.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1994
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1994
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 38 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 38
list pvalue if state == 38 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_ND\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1994
list ave_effect if state == 38 /* Ave. effect =  */





* ------------------------------------------------------------------------------
* Indiana Synthetic Control Analysis
* ------------------------------------------------------------------------------

*   ---Trend Graphs - Expenditure and Access---
clear

*Total Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 1/1 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1989) `outcome'(1988) `outcome'(1987) `outcome'(1986) `outcome'(1985) 
		`outcome'(1984) `outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(18) trperiod(1999) nested
		keep(CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1998, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Indiana") lab(2 "Synthetic Indiana") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(200[100]900, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_IN\Figures\\`output'_Trends_IN.pdf, replace
}
*Medicaid Expenditure
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 2/2 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_Expenditure.dta, clear
	*replace medicare_exp = 0.01 if medicare_exp == 0	/* to avoid the unstable or asymmetric Hessian error */
	
	*Restrict to treated state and Control States by expenditure type
	keep if code == 10
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1989) `outcome'(1988) `outcome'(1987) `outcome'(1986) `outcome'(1985) 
		`outcome'(1984) `outcome'(1983) `outcome'(1982) `outcome'(1981) `outcome'(1980), 
		trunit(18) trperiod(1999) nested
		keep(CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1998, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Indiana") lab(2 "Synthetic Indiana") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(50[50]400, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_IN\Figures\\`output'_Trends_IN.pdf, replace
}
*Quantity of Nursing Homes
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 3/3 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1994) `outcome'(1993) `outcome'(1992) `outcome'(1991), 
		trunit(18) trperiod(1999) nested
		keep(CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1998, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Indiana") lab(2 "Synthetic Indiana") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[.2]1.6, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_IN\Figures\\`output'_Trends_IN.pdf, replace
}
*Quantity of Nursing Home Beds
local Outcome " "total_exp" "medicaid_exp" "Q_SkilledNursingHomes_pcp" "Q_SkilledNursingHomeBeds_pcp" "
local Output " "nursing_home_tot_exp" "nursing_home_medicaid_exp" "q_nursing_homes" "q_nursing_home_beds" "
local Ytitle " "Total Nursing Home Expenditure Per Capita" "Nursing Home Medicaid Expenditure Per Capita" "Quantity of Nursing Homes Per 100,000" "Quantity of Nursing Home Beds Per 100,000" "
forvalues i = 4/4 {
	*setting up local macros to refer to the current element in the parallel lists being looped through
	local outcome : word `i' of `Outcome'
	local output : word `i' of `Output'
	local ytitle : word `i' of `Ytitle'
		
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year
		
	*Create synthetic control
	# delimit
		quietly synth `outcome' $controls 
		`outcome'(1994) `outcome'(1993) `outcome'(1992) `outcome'(1991), 
		trunit(18) trperiod(1999) nested
		keep(CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace);
	# delimit cr
	
	*Process synthetic control output
	use CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, clear
	rename _time year
	gen alpha = _Y_treated - _Y_synthetic
	keep year _Y_* alpha
	drop if missing(year)
	save CON_Expenditure_IN\Synth_Output\synth_`output'_IN.dta, replace
	
	*Trend graphs
	# delimit
	twoway
		(line _Y_treated year, lwidth(medthick) lcolor(black) xline(1998, lwidth(thick) lcolor(gs10)) )
		(line _Y_synthetic year, lwidth(medthick) lpattern(dash) lcolor(black))
		,
		leg(lab(1 "Indiana") lab(2 "Synthetic Indiana") size(medsmall) order(1 2) pos(11) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("`ytitle'") ylab(0[10]80, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export CON_Expenditure_IN\Figures\\`output'_Trends_IN.pdf, replace
}


*   ---Placebo Graph and Exact P-value - Total Nursing Home Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to IN and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "Indiana"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth total_exp $controls 
		total_exp(1989) total_exp(1988) total_exp(1987) total_exp(1986) total_exp(1985)  
		total_exp(1984) total_exp(1983) total_exp(1982) total_exp(1981) total_exp(1980), 
		trunit(`i') trperiod(1999) nested
		keep(CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, replace
*create figure
use CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 18
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 18, lwidth(thick) lcolor(black) 
		xline(1998, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Indiana") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Total Nursing Home Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_IN\Figures\nursing_home_tot_exp_Gaps_with_Placebos_`i'_IN.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1998
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 18
list pvalue if state == 18 /* P value = . */
*Average post-intervention effect 
use CON_Expenditure_IN\Placebos\Nursing_Home_Total_Exp\synth_total_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1998
list ave_effect if state == 18 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Nursing Home Medicaid Expenditure---
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_Expenditure.dta, clear

	*Restrict to IN and Control States
	keep if code == 10
	keep if alwaysconpa==1 | name == "Indiana"

	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth medicaid_exp $controls 
		medicaid_exp(1989) medicaid_exp(1988) medicaid_exp(1987) medicaid_exp(1986) medicaid_exp(1985) 
		medicaid_exp(1984) medicaid_exp(1983) medicaid_exp(1982) medicaid_exp(1981) medicaid_exp(1980), 
		trunit(`i') trperiod(1999) nested
		keep(CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_`i'.dta, nogenerate    
}
save CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, replace
*create figure
use CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 18
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 18, lwidth(thick) lcolor(black) 
		xline(1998, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Indiana") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1980[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Nursing Home Medicaid Expenditure Per Capita") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_IN\Figures\nursing_home_medicaid_exp_Gaps_with_Placebos_`i'_IN.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1998
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 18
list pvalue if state == 18 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_IN\Placebos\Nursing_Home_Medicaid_Exp\synth_medicaid_nursing_home_exp_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1998
list ave_effect if state == 18 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Homes---
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomes_pcp $controls 
		Q_SkilledNursingHomes_pcp(1994) Q_SkilledNursingHomes_pcp(1993) Q_SkilledNursingHomes_pcp(1992) Q_SkilledNursingHomes_pcp(1991), 
		trunit(`i') trperiod(1999) nested
		keep(CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_`i'.dta, nogenerate    
}
save CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, replace
*create figure
use CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 18
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 18, lwidth(thick) lcolor(black) 
		xline(1998, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Indiana") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Homes Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_IN\Figures\q_nursing_homes_Gaps_with_Placebos_`i'_IN.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1998
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 18
list pvalue if state == 18 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_IN\Placebos\Q_Nursing_Homes\synth_q_nursing_homes_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1998
list ave_effect if state == 18 /* Ave. effect =  */


*   ---Placebo Graph and Exact P-value - Quantity of Nursing Home Beds---
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
	*load fresh data
	use CON_NursingHome.dta, clear
	
	*Restrict to treated state and Control States by expenditure type
	keep if alwaysconpa==1 | name == "Indiana"
	
	*declare data as a time series with year as time variable (required for synth command)
	tsset id year

	*Create synthetic control
	# delimit
		quietly synth Q_SkilledNursingHomeBeds_pcp $controls 
		Q_SkilledNursingHomeBeds_pcp(1994) Q_SkilledNursingHomeBeds_pcp(1993) Q_SkilledNursingHomeBeds_pcp(1992) Q_SkilledNursingHomeBeds_pcp(1991), 
		trunit(`i') trperiod(1999) nested
		keep(CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace);
	# delimit cr

	*Process synthetic control output
	use CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, clear
	rename _Y_treated _Y_treated_`i'
	rename _Y_synthetic _Y_synthetic_`i'
	rename _time year
	gen alpha`i' = _Y_treated_`i' - _Y_synthetic_`i'
	keep year _Y_* alpha`i'
	drop if missing(year)
	save CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, replace
}
*merge all synth data sets
use CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_1.dta, clear
local statelist2  "2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist2 {
    merge 1:1 year using CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_`i'.dta, nogenerate    
}
save CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, replace
*create figure
use CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
gen pre_rmspe = sqrt(pre_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
}
local threshold " "1000000" "20" "10" "5" "2" "	/* the 1000000 is meant to ensure that no states are dropped in the graph */
foreach i of local threshold {
	sort state year
	gen threshold_pre_rmspe_`i' = `i'*pre_rmspe if state == 18
	sum threshold_pre_rmspe_`i'
	replace threshold_pre_rmspe_`i' = r(mean)
	# delimit
	twoway
		(line alpha year if state == 1 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 2 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 5 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 10 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 11 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 12 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 13 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 15 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 17 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 19 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 21 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 23 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 24 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 25 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 26 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 28 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 29 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 30 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 31 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 32 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 33 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 34 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 36 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 37 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 39 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 40 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 41 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 44 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 45 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 47 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 50 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 51 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 53 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 54 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 55 & pre_rmspe <= threshold_pre_rmspe_`i', lcolor(gs12))
		(line alpha year if state == 18, lwidth(thick) lcolor(black) 
		xline(1998, lwidth(thick) lcolor(maroon)) yline(0, lwidth(thick) lcolor(maroon)))
		,
		leg(lab(36 "Indiana") lab(1 "Control States") size(medsmall) pos(11) order(36 1) ring(0) cols(1))
		xtitle("Year") xlab(1990[2]2014, grid glcolor(gs15) angle(45))
		ytitle("Gap in Quantity of Nursing Home Beds Per 100,000") ylab(, grid glcolor(gs15))
		graphregion(color(white)) bgcolor(white) plotregion(color(white));
	# delimit cr
	graph export "CON_Expenditure_IN\Figures\q_nursing_home_beds_Gaps_with_Placebos_`i'_IN.pdf", replace
}
*Exact p-value based on post/pre RMSPE & histogram of RMSPEs
use CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
gen alpha_sqrd = alpha*alpha
bysort state: egen pre_mspe = mean(alpha_sqrd) if year <= 1998
bysort state: egen post_mspe = mean(alpha_sqrd) if year > 1998
gen pre_rmspe = sqrt(pre_mspe)
gen post_rmspe = sqrt(post_mspe)
local statelist "1 2 5 10 11 12 13 15 17 18 19 21 23 24 25 26 28 29 30 31 32 33 34 36 37 39 40 41 44 45 47 50 51 53 54 55"
foreach i of local statelist {
    sum pre_rmspe if state == `i'
	replace pre_rmspe = r(mean) if state == `i'
	sum post_rmspe if state == `i'
	replace post_rmspe = r(mean) if state == `i'
}
sort state year
gen post_pre_rmspe_ratio = post_rmspe/pre_rmspe
duplicates drop state, force
gsort -post_pre_rmspe_ratio
gen rank = _n
gen pvalue = rank/_N if state == 18
list pvalue if state == 18 /* P value =  */
*Average post-intervention effect 
use CON_Expenditure_IN\Placebos\Q_Nursing_Home_Beds\synth_q_nursing_home_beds_all.dta, clear
keep alpha* year
reshape long alpha, i(year) j(state)
bysort state: egen ave_effect = mean(alpha) if year > 1998
list ave_effect if state == 18 /* Ave. effect =  */


















clear
use CON_Expenditure.dta

keep if code == 1

tsset id year
keep if alwaysconpa==1 | repeal_y=="1996"

* Counting the number of states in the dataset
drop x
egen x = group(id)
sum x

* Dropping states that border PA
drop if id==11
drop if name==  "West Virginia" 
drop if name== "Delaware" 
drop if name== "Ohio" 
drop if name== "New York" 
drop if name== "New Jersey" 
drop if name== "Maryland" 

*   ---Total Expenditure Analysis---

*synth total_exp $controls total_exp(1995) total_exp(1990) total_exp(1984), trunit(42) trperiod(1996) nested fig
synth total_exp $controls total_exp(1989) total_exp(1988) total_exp(1987) total_exp(1986) total_exp(1985) total_exp(1984) total_exp(1983) total_exp(1982) total_exp(1981) total_exp(1980), trunit(42) trperiod(1996) nested fig

*   ---Medicaid Expenditure Analysis---

synth medicaid_exp $controls medicaid_exp(1995) medicaid_exp(1990) medicaid_exp(1984), trunit(42) trperiod(1996) nested fig
synth medicaid_exp $controls medicaid_exp(1989) medicaid_exp(1988) medicaid_exp(1987) medicaid_exp(1986) medicaid_exp(1985) medicaid_exp(1984) medicaid_exp(1983) medicaid_exp(1982) medicaid_exp(1981) medicaid_exp(1980), trunit(42) trperiod(1995) nested fig

*   ---Medicare Expenditure Analysis---

*synth medicare_exp $controls medicare_exp(1995) medicare_exp(1990) medicare_exp(1984), trunit(42) trperiod(1996) nested fig
synth medicare_exp $controls medicare_exp(1988) medicare_exp(1987) medicare_exp(1986) medicare_exp(1985) medicare_exp(1984) medicare_exp(1983) medicare_exp(1982) medicare_exp(1981) medicare_exp(1980), trunit(42) trperiod(1995) nested fig


















* ------------------------------------------------------------------------------
* North Dakota Synthetic Control Analysis
* ------------------------------------------------------------------------------

clear 
use CON_Expenditure.dta

keep if code == 10

tsset id year
keep if alwaysconpa==1 | id==38

*   ---Total Expenditure Analysis---

*synth total_exp $controls total_exp(1995) total_exp(1990) total_exp(1984), trunit(38) trperiod(1996) nested fig
synth total_exp $controls total_exp(1988) total_exp(1987) total_exp(1986) total_exp(1985) total_exp(1984) total_exp(1983) total_exp(1982) total_exp(1981) total_exp(1980), trunit(38) trperiod(1994) nested fig

*   ---Medicaid Expenditure Analysis---

*synth medicaid_exp $controls medicaid_exp(1995) medicaid_exp(1990) medicaid_exp(1984), trunit(42) trperiod(1996) nested fig
synth medicaid_exp $controls medicaid_exp(1988) medicaid_exp(1987) medicaid_exp(1986) medicaid_exp(1985) medicaid_exp(1984) medicaid_exp(1983) medicaid_exp(1982) medicaid_exp(1981) medicaid_exp(1980), trunit(38) trperiod(1994) nested fig

*   ---Medicare Expenditure Analysis---

*synth medicare_exp $controls medicare_exp(1995) medicare_exp(1990) medicare_exp(1984), trunit(42) trperiod(1996) nested fig
synth medicare_exp $controls medicare_exp(1988) medicare_exp(1987) medicare_exp(1986) medicare_exp(1985) medicare_exp(1984) medicare_exp(1983) medicare_exp(1982) medicare_exp(1981) medicare_exp(1980), trunit(38) trperiod(1994) nested fig





