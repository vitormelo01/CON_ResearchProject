########################## Pennsylvania Synthetic DID Analysis #############################

##### Load Necessary Packages #####
#devtools::install_github("synth-inference/synthdid")
library(synthdid)
library(ggplot2)
library(haven) # used to import .dta files #

##### Set working directory #####
setwd(Sys.getenv("Combined_CON_Directory"))

##### Import Data #####
CON_Expenditure <- read_dta("CON_Expenditure.dta")
View(CON_Expenditure)

##### Parallel Trends Plots - Expenditure and Access #####
### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care) #


setup = panel.matrices(CON_Expenditure, unit = name, time = year, outcome = tot_exp, )
