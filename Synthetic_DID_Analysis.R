########################## Pennsylvania Synthetic DID Analysis #############################

##### Load Necessary Packages #####
#install.packages("remotes")
#remotes::install_github("synth-inference/synthdid")
library(synthdid)
library(ggplot2)
library(haven) # used to import .dta files #


##### Set working directory #####
setwd(Sys.getenv("Combined_CON_Directory"))


##### Import Data #####
CON_Expenditure <- read_dta("CON_Expenditure.dta")
View(CON_Expenditure)


##### Create 3D arrays of time-varying covariates for synthetic matching #####
CON_Expenditure$treated_pa_aux <- ifelse(CON_Expenditure$name == "Pennsylvania", 1, 0)
covariates_pa_df <- subset(CON_Expenditure, alwaysconpa == 1 | name == "Pennsylvania")
covariates_pa_df <- covariates_pa_df[order(covariates_pa_df$year, covariates_pa_df$treated_pa_aux, covariates_pa_df$name),]
covariates_pa_df <- as.data.frame(subset(covariates_pa_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_pa_df$income_pcp_adj <- covariates_pa_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_df$unemp_rate <- covariates_pa_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_df$top1_adj <- covariates_pa_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_pa <- c(1980:2014)
row.names_pa <- c(covariates_pa_df[1:36,1])
matrix.names_pa <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_pa_array <- array(as.matrix(covariates_pa_df[,3:14]), dim = c(36,35,12), dimnames = list(row.names_pa, column.names_pa, matrix.names_pa))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "Pennsylvania" & CON_Expenditure$year >= 1996, 1, 0))
total_exp_pa_df <- as.data.frame(subset(CON_Expenditure, code == 10))
total_exp_pa_df <- total_exp_pa_df[order(total_exp_pa_df$year, total_exp_pa_df$treated_pa_aux, total_exp_pa_df$name),]
total_exp_pa_df <- subset(total_exp_pa_df, alwaysconpa == 1 | name == "Pennsylvania", select=c(name, year, total_exp, treated))
setup_total_exp_pa <- panel.matrices(total_exp_pa_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_pa_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_pa$Y, setup_total_exp_pa$N0, setup_total_exp_pa$T0, X = covariates_pa_array)
  })
total_exp_pa_se <- lapply(total_exp_pa_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
  })
total_exp_pa_ci <- foreach(i = total_exp_pa_estimates, j = total_exp_pa_se) {
  sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
}
total_exp_pa_estimates.table <- rbind(unlist(total_exp_pa_estimates), unlist(total_exp_pa_se), unlist(total_exp_pa_ci))
rownames(total_exp_pa_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_pa_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
round(total_exp_pa_estimates.table, digits=2)
# Parallel Trends Plots #
synthdid_plot(total_exp_pa_estimates)
# Control Unit Contribution Plots #
synthdid_units_plot(total_exp_pa_estimates, se.method='placebo')
