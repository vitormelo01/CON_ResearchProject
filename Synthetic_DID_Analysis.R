########################## Synthetic DID Analysis #############################

##### Load Necessary Packages #####
#install.packages("remotes")
#remotes::install_github("synth-inference/synthdid")
#install.packages("foreach")
#install.packages("xtable")
library(synthdid)
library(ggplot2)
library(haven) # used to import .dta files #
library(foreach) # for parallel execution #
library(xtable) # to export latex tables #


##### Set working directory #####
setwd(Sys.getenv("Combined_CON_Directory"))


##### Import Data #####
CON_Expenditure <- read_dta("CON_Expenditure.dta")
View(CON_Expenditure)
CON_NursingHome <- read_dta("CON_NursingHome.dta")
View(CON_NursingHome)


########## Pennsylvania ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_pa_aux <- ifelse(CON_Expenditure$name == "Pennsylvania", 1, 0)
covariates_pa_exp_df <- subset(CON_Expenditure, alwaysconpa == 1 | name == "Pennsylvania")
covariates_pa_exp_df <- covariates_pa_exp_df[order(covariates_pa_exp_df$year, covariates_pa_exp_df$treated_pa_aux, covariates_pa_exp_df$name),]
covariates_pa_exp_df <- as.data.frame(subset(covariates_pa_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_pa_exp_df$income_pcp_adj <- covariates_pa_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_exp_df$unemp_rate <- covariates_pa_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_exp_df$top1_adj <- covariates_pa_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_pa <- c(1980:2014)
row.names_exp_pa <- c(covariates_pa_exp_df[1:36,1])
matrix.names_exp_pa <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_pa_array <- array(as.matrix(covariates_pa_exp_df[,3:14]), dim = c(36,35,12), dimnames = list(row.names_exp_pa, column.names_exp_pa, matrix.names_exp_pa))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_pa_aux <- ifelse(CON_NursingHome$name == "Pennsylvania", 1, 0)
covariates_pa_acc_df <- subset(CON_NursingHome, alwaysconpa == 1 | name == "Pennsylvania")
covariates_pa_acc_df <- covariates_pa_acc_df[order(covariates_pa_acc_df$year, covariates_pa_acc_df$treated_pa_aux, covariates_pa_acc_df$name),]
covariates_pa_acc_df <- as.data.frame(subset(covariates_pa_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_pa_acc_df$income_pcp_adj <- covariates_pa_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_acc_df$unemp_rate <- covariates_pa_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_acc_df$top1_adj <- covariates_pa_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_pa <- c(1991:2014)
row.names_acc_pa <- c(covariates_pa_acc_df[1:36,1])
matrix.names_acc_pa <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_pa_array <- array(as.matrix(covariates_pa_acc_df[,3:14]), dim = c(36,24,12), dimnames = list(row.names_acc_pa, column.names_acc_pa, matrix.names_acc_pa))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Pennsylvania" & CON_NursingHome$year >= 1996, 1, 0))
q_nursing_homes_pa_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_pa_df <- q_nursing_homes_pa_df[order(q_nursing_homes_pa_df$year, q_nursing_homes_pa_df$treated_pa_aux, q_nursing_homes_pa_df$name),]
q_nursing_homes_pa_df <- subset(q_nursing_homes_pa_df, alwaysconpa == 1 | name == "Pennsylvania", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
setup_q_nursing_homes_pa <- panel.matrices(q_nursing_homes_pa_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_homes_pa_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_homes_pa$Y, setup_q_nursing_homes_pa$N0, setup_q_nursing_homes_pa$T0, X = covariates_acc_pa_array)
})
names(q_nursing_homes_pa_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_homes_pa_estimates_rounded <- rbind(unlist(q_nursing_homes_pa_estimates))
q_nursing_homes_pa_estimates_rounded <- lapply(q_nursing_homes_pa_estimates,round,2)
q_nursing_homes_pa_se <- lapply(q_nursing_homes_pa_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_homes_pa_se_rounded <- lapply(q_nursing_homes_pa_se,round,2)
q_nursing_homes_pa_ci <- foreach(i = q_nursing_homes_pa_estimates, j = q_nursing_homes_pa_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_homes_pa_estimates.table <- rbind(unlist(q_nursing_homes_pa_estimates_rounded), unlist(q_nursing_homes_pa_se_rounded), unlist(q_nursing_homes_pa_ci))
rownames(q_nursing_homes_pa_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_homes_pa_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_homes_pa_estimates.table
q_nursing_homes_pa_estimates.latextable <- xtable(q_nursing_homes_pa_estimates.table, align = "lccc", caption = 'Quantity of Nursing Homes Per 100,000 - PA')
print(q_nursing_homes_pa_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_homes_estimates_PA.tex')
# Parallel Trends Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_homes_plots_PA.pdf')
synthdid_plot(q_nursing_homes_pa_estimates)
dev.off()
# Control Unit Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_homes_control_plots_PA.pdf')
synthdid_units_plot(q_nursing_homes_pa_estimates, se.method='none') + theme(axis.text.x = element_text(size = 5, hjust=1, vjust=0.3))
dev.off()

### Quantity of Nursing Home Beds ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Pennsylvania" & CON_NursingHome$year >= 1996, 1, 0))
q_nursing_home_beds_pa_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_home_beds_pa_df <- q_nursing_home_beds_pa_df[order(q_nursing_home_beds_pa_df$year, q_nursing_home_beds_pa_df$treated_pa_aux, q_nursing_home_beds_pa_df$name),]
q_nursing_home_beds_pa_df <- subset(q_nursing_home_beds_pa_df, alwaysconpa == 1 | name == "Pennsylvania", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
setup_q_nursing_home_beds_pa <- panel.matrices(q_nursing_home_beds_pa_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_home_beds_pa_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_home_beds_pa$Y, setup_q_nursing_home_beds_pa$N0, setup_q_nursing_home_beds_pa$T0, X = covariates_acc_pa_array)
})
names(q_nursing_home_beds_pa_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_home_beds_pa_estimates_rounded <- rbind(unlist(q_nursing_home_beds_pa_estimates))
q_nursing_home_beds_pa_estimates_rounded <- lapply(q_nursing_home_beds_pa_estimates,round,2)
q_nursing_home_beds_pa_se <- lapply(q_nursing_home_beds_pa_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_home_beds_pa_se_rounded <- lapply(q_nursing_home_beds_pa_se,round,2)
q_nursing_home_beds_pa_ci <- foreach(i = q_nursing_home_beds_pa_estimates, j = q_nursing_home_beds_pa_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_home_beds_pa_estimates.table <- rbind(unlist(q_nursing_home_beds_pa_estimates_rounded), unlist(q_nursing_home_beds_pa_se_rounded), unlist(q_nursing_home_beds_pa_ci))
rownames(q_nursing_home_beds_pa_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_home_beds_pa_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_home_beds_pa_estimates.table
q_nursing_home_beds_pa_estimates.latextable <- xtable(q_nursing_home_beds_pa_estimates.table, align = "lccc", caption = 'Quantity of Nursing Home Beds Per 100,000 - PA')
print(q_nursing_home_beds_pa_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_home_beds_estimates_PA.tex')
# Parallel Trends Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_home_beds_plots_PA.pdf')
synthdid_plot(q_nursing_home_beds_pa_estimates)
dev.off()
# Control Unit Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_home_beds_control_plots_PA.pdf')
synthdid_units_plot(q_nursing_home_beds_pa_estimates, se.method='none') + theme(axis.text.x = element_text(size = 5, hjust=1, vjust=0.3))
dev.off()

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
  estimator(setup_total_exp_pa$Y, setup_total_exp_pa$N0, setup_total_exp_pa$T0, X = covariates_exp_pa_array)
  })
names(total_exp_pa_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_pa_estimates_rounded <- rbind(unlist(total_exp_pa_estimates))
total_exp_pa_estimates_rounded <- lapply(total_exp_pa_estimates,round,2)
total_exp_pa_se <- lapply(total_exp_pa_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
  })
total_exp_pa_se_rounded <- lapply(total_exp_pa_se,round,2)
total_exp_pa_ci <- foreach(i = total_exp_pa_estimates, j = total_exp_pa_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_pa_estimates.table <- rbind(unlist(total_exp_pa_estimates_rounded), unlist(total_exp_pa_se_rounded), unlist(total_exp_pa_ci))
rownames(total_exp_pa_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_pa_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_pa_estimates.table
total_exp_pa_estimates.latextable <- xtable(total_exp_pa_estimates.table, align = "lccc", caption = 'Total Expenditure - PA')
print(total_exp_pa_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/total_expenditure_estimates_PA.tex')
# Parallel Trends Plots #
pdf(file='SynthDID_Figs_and_Tables/total_expenditure_plots_PA.pdf')
synthdid_plot(total_exp_pa_estimates)
dev.off()
# Control Unit Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/total_expenditure_control_plots_PA.pdf')
synthdid_units_plot(total_exp_pa_estimates, se.method='none') + theme(axis.text.x = element_text(size = 5, hjust=1, vjust=0.3))
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "Pennsylvania" & CON_Expenditure$year >= 1996, 1, 0))
medicaid_exp_pa_df <- as.data.frame(subset(CON_Expenditure, code == 10))
medicaid_exp_pa_df <- medicaid_exp_pa_df[order(medicaid_exp_pa_df$year, medicaid_exp_pa_df$treated_pa_aux, medicaid_exp_pa_df$name),]
medicaid_exp_pa_df <- subset(medicaid_exp_pa_df, alwaysconpa == 1 | name == "Pennsylvania", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_pa <- panel.matrices(medicaid_exp_pa_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_pa_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_pa$Y, setup_medicaid_exp_pa$N0, setup_medicaid_exp_pa$T0, X = covariates_exp_pa_array)
})
names(medicaid_exp_pa_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_pa_estimates_rounded <- rbind(unlist(medicaid_exp_pa_estimates))
medicaid_exp_pa_estimates_rounded <- lapply(medicaid_exp_pa_estimates,round,2)
medicaid_exp_pa_se <- lapply(medicaid_exp_pa_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_pa_se_rounded <- lapply(medicaid_exp_pa_se,round,2)
medicaid_exp_pa_ci <- foreach(i = medicaid_exp_pa_estimates, j = medicaid_exp_pa_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_pa_estimates.table <- rbind(unlist(medicaid_exp_pa_estimates_rounded), unlist(medicaid_exp_pa_se_rounded), unlist(medicaid_exp_pa_ci))
rownames(medicaid_exp_pa_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_pa_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_pa_estimates.table
medicaid_exp_pa_estimates.latextable <- xtable(medicaid_exp_pa_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - PA')
print(medicaid_exp_pa_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/medicaid_expenditure_estimates_PA.tex')
# Parallel Trends Plots #
pdf(file='SynthDID_Figs_and_Tables/medicaid_expenditure_plots_PA.pdf')
synthdid_plot(medicaid_exp_pa_estimates)
dev.off()
# Control Unit Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/medicaid_expenditure_control_plots_PA.pdf')
synthdid_units_plot(medicaid_exp_pa_estimates, se.method='none') + theme(axis.text.x = element_text(size = 5, hjust=1, vjust=0.3))
dev.off()
