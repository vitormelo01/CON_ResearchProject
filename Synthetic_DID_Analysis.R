########################## Pennsylvania Synthetic DID Analysis #############################

##### Load Necessary Packages #####
install.packages("remotes")
remotes::install_github("synth-inference/synthdid")
library(synthdid)
library(ggplot2)
library(haven) # used to import .dta files #

##### Set working directory #####
setwd(Sys.getenv("Combined_CON_Directory"))

##### Import Data #####
CON_Expenditure <- read_dta("CON_Expenditure.dta")
View(CON_Expenditure)

##### Create a 3D array of time-varying covariates for synthetic matching #####

##### Parallel Trends Plots - Expenditure and Access #####
### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "Pennsylvania" & CON_Expenditure$year >= 1996, 1, 0))
CON_Expenditure$treated_aux <- ifelse(CON_Expenditure$name == "Pennsylvania", 1, 0)
total_exp_pa_df <- as.data.frame(subset(CON_Expenditure, code == 10))
total_exp_pa_df <- total_exp_pa_df[order(total_exp_pa_df$year, total_exp_pa_df$treated_aux, total_exp_pa_df$name),]
total_exp_pa_df <- subset(total_exp_pa_df, alwaysconpa == 1 | name == "Pennsylvania", select=c(name, year, total_exp, treated))
setup <- panel.matrices(total_exp_pa_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# Synthetic Diff-in-Diff, Synthetic Control, and Diff-in-Diff Estimates #
total_exp_pa_tau.sdid <- synthdid_estimate(setup$Y, setup$N0, setup$T0)
total_exp_pa_tau.sc <- sc_estimate(setup$Y, setup$N0, setup$T0)
total_exp_pa_tau.did <- did_estimate(setup$Y, setup$N0, setup$T0)
total_exp_pa_estimates = list(total_exp_pa_tau.did, total_exp_pa_tau.sc, total_exp_pa_tau.sdid)
names(total_exp_pa_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
print(unlist(total_exp_pa_estimates))
print(summary(total_exp_pa_tau.sdid))
synthdid_plot(total_exp_pa_estimates)
plot(total_exp_pa_est, overlay = 1)
synthdid_units_plot(tau.hat, se.method='placebo')