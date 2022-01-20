########################## Synthetic DID Analysis #############################

##### Load Necessary Packages #####
#install.packages("remotes")
#remotes::install_github("synth-inference/synthdid")
#install.packages("ggplot2")
#install.packages("haven")
#install.packages("foreach")
#install.packages("xtable")
#install.packages("patchwork")
library(synthdid)
library(ggplot2)
library(haven) # used to import .dta files #
library(foreach) # for parallel execution #
library(xtable) # to export latex tables #
library(patchwork) # to combine multiple plots on a single page #


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
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_homes_plots_PA.pdf')
q_nursing_homes_plots_PA <- synthdid_plot(q_nursing_homes_pa_estimates, 
              facet.vertical=FALSE,
              control.name='Control', treated.name='Pennsylvania',
              lambda.comparable=TRUE, se.method = 'none',
              trajectory.linetype = 'solid', line.width=.5, 
              trajectory.alpha = .5, guide.linetype = 'dashed', 
              effect.curvature=.25, effect.alpha=.5, 
              diagram.alpha=1, onset.alpha=.5,
              point.size = 1) +
  labs(y= "Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_homes_control_plots_PA <- synthdid_units_plot(q_nursing_homes_pa_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_homes_plots_PA + q_nursing_homes_control_plots_PA + plot_layout(ncol=1)
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
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_home_beds_plots_PA.pdf')
q_nursing_home_beds_plots_PA <- synthdid_plot(q_nursing_home_beds_pa_estimates, 
                                          facet.vertical=FALSE,
                                          control.name='Control', treated.name='Pennsylvania',
                                          lambda.comparable=TRUE, se.method = 'none',
                                          trajectory.linetype = 'solid', line.width=.5, 
                                          trajectory.alpha = .5, guide.linetype = 'dashed', 
                                          effect.curvature=.25, effect.alpha=.5, 
                                          diagram.alpha=1, onset.alpha=.5,
                                          point.size = 1) +
  labs(y= "Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_home_beds_control_plots_PA <- synthdid_units_plot(q_nursing_home_beds_pa_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_home_beds_plots_PA + q_nursing_home_beds_control_plots_PA + plot_layout(ncol=1)
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
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/total_expenditure_plots_PA.pdf')
total_expenditure_plots_PA <- synthdid_plot(total_exp_pa_estimates, 
                                              facet.vertical=FALSE,
                                              control.name='Control', treated.name='Pennsylvania',
                                              lambda.comparable=TRUE, se.method = 'none',
                                              trajectory.linetype = 'solid', line.width=.5, 
                                              trajectory.alpha = .5, guide.linetype = 'dashed', 
                                              effect.curvature=.25, effect.alpha=.5, 
                                              diagram.alpha=1, onset.alpha=.5,
                                              point.size = 1) +
  labs(y= "Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
total_expenditure_control_plots_PA <- synthdid_units_plot(total_exp_pa_estimates, se.method='none') + 
  labs(y= "Difference in Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
total_expenditure_plots_PA + total_expenditure_control_plots_PA + plot_layout(ncol=1)
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
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/medicaid_expenditure_plots_PA.pdf')
medicaid_expenditure_plots_PA <- synthdid_plot(medicaid_exp_pa_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Pennsylvania',
                                            lambda.comparable=TRUE, se.method = 'none',
                                            trajectory.linetype = 'solid', line.width=.5, 
                                            trajectory.alpha = .5, guide.linetype = 'dashed', 
                                            effect.curvature=.25, effect.alpha=.5, 
                                            diagram.alpha=1, onset.alpha=.5,
                                            point.size = 1) +
  labs(y= "Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
medicaid_expenditure_control_plots_PA <- synthdid_units_plot(medicaid_exp_pa_estimates, se.method='none') + 
  labs(y= "Difference in Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
medicaid_expenditure_plots_PA + medicaid_expenditure_control_plots_PA + plot_layout(ncol=1)
dev.off()



########## Indiana ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_in_aux <- ifelse(CON_Expenditure$name == "Indiana", 1, 0)
covariates_in_exp_df <- subset(CON_Expenditure, alwaysconpa == 1 | name == "Indiana")
covariates_in_exp_df <- covariates_in_exp_df[order(covariates_in_exp_df$year, covariates_in_exp_df$treated_in_aux, covariates_in_exp_df$name),]
covariates_in_exp_df <- as.data.frame(subset(covariates_in_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_in_exp_df$income_pcp_adj <- covariates_in_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_exp_df$unemp_rate <- covariates_in_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_exp_df$top1_adj <- covariates_in_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_in <- c(1980:2014)
row.names_exp_in <- c(covariates_in_exp_df[1:36,1])
matrix.names_exp_in <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_in_array <- array(as.matrix(covariates_in_exp_df[,3:14]), dim = c(36,35,12), dimnames = list(row.names_exp_in, column.names_exp_in, matrix.names_exp_in))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_in_aux <- ifelse(CON_NursingHome$name == "Indiana", 1, 0)
covariates_in_acc_df <- subset(CON_NursingHome, alwaysconpa == 1 | name == "Indiana")
covariates_in_acc_df <- covariates_in_acc_df[order(covariates_in_acc_df$year, covariates_in_acc_df$treated_in_aux, covariates_in_acc_df$name),]
covariates_in_acc_df <- as.data.frame(subset(covariates_in_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_in_acc_df$income_pcp_adj <- covariates_in_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_acc_df$unemp_rate <- covariates_in_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_acc_df$top1_adj <- covariates_in_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_in <- c(1991:2014)
row.names_acc_in <- c(covariates_in_acc_df[1:36,1])
matrix.names_acc_in <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_in_array <- array(as.matrix(covariates_in_acc_df[,3:14]), dim = c(36,24,12), dimnames = list(row.names_acc_in, column.names_acc_in, matrix.names_acc_in))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Indiana" & CON_NursingHome$year >= 1999, 1, 0))
q_nursing_homes_in_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_in_df <- q_nursing_homes_in_df[order(q_nursing_homes_in_df$year, q_nursing_homes_in_df$treated_in_aux, q_nursing_homes_in_df$name),]
q_nursing_homes_in_df <- subset(q_nursing_homes_in_df, alwaysconpa == 1 | name == "Indiana", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
setup_q_nursing_homes_in <- panel.matrices(q_nursing_homes_in_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_homes_in_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_homes_in$Y, setup_q_nursing_homes_in$N0, setup_q_nursing_homes_in$T0, X = covariates_acc_in_array)
})
names(q_nursing_homes_in_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_homes_in_estimates_rounded <- rbind(unlist(q_nursing_homes_in_estimates))
q_nursing_homes_in_estimates_rounded <- lapply(q_nursing_homes_in_estimates,round,2)
q_nursing_homes_in_se <- lapply(q_nursing_homes_in_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_homes_in_se_rounded <- lapply(q_nursing_homes_in_se,round,2)
q_nursing_homes_in_ci <- foreach(i = q_nursing_homes_in_estimates, j = q_nursing_homes_in_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_homes_in_estimates.table <- rbind(unlist(q_nursing_homes_in_estimates_rounded), unlist(q_nursing_homes_in_se_rounded), unlist(q_nursing_homes_in_ci))
rownames(q_nursing_homes_in_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_homes_in_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_homes_in_estimates.table
q_nursing_homes_in_estimates.latextable <- xtable(q_nursing_homes_in_estimates.table, align = "lccc", caption = 'Quantity of Nursing Homes Per 100,000 - IN')
print(q_nursing_homes_in_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_homes_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_homes_plots_IN.pdf')
q_nursing_homes_plots_IN <- synthdid_plot(q_nursing_homes_in_estimates, 
                                          facet.vertical=FALSE,
                                          control.name='Control', treated.name='Indiana',
                                          lambda.comparable=TRUE, se.method = 'none',
                                          trajectory.linetype = 'solid', line.width=.5, 
                                          trajectory.alpha = .5, guide.linetype = 'dashed', 
                                          effect.curvature=.25, effect.alpha=.5, 
                                          diagram.alpha=1, onset.alpha=.5,
                                          point.size = 1) +
  labs(y= "Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_homes_control_plots_IN <- synthdid_units_plot(q_nursing_homes_in_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_homes_plots_IN + q_nursing_homes_control_plots_IN + plot_layout(ncol=1)
dev.off()

### Quantity of Nursing Home Beds ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Indiana" & CON_NursingHome$year >= 1999, 1, 0))
q_nursing_home_beds_in_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_home_beds_in_df <- q_nursing_home_beds_in_df[order(q_nursing_home_beds_in_df$year, q_nursing_home_beds_in_df$treated_in_aux, q_nursing_home_beds_in_df$name),]
q_nursing_home_beds_in_df <- subset(q_nursing_home_beds_in_df, alwaysconpa == 1 | name == "Indiana", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
setup_q_nursing_home_beds_in <- panel.matrices(q_nursing_home_beds_in_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_home_beds_in_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_home_beds_in$Y, setup_q_nursing_home_beds_in$N0, setup_q_nursing_home_beds_in$T0, X = covariates_acc_in_array)
})
names(q_nursing_home_beds_in_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_home_beds_in_estimates_rounded <- rbind(unlist(q_nursing_home_beds_in_estimates))
q_nursing_home_beds_in_estimates_rounded <- lapply(q_nursing_home_beds_in_estimates,round,2)
q_nursing_home_beds_in_se <- lapply(q_nursing_home_beds_in_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_home_beds_in_se_rounded <- lapply(q_nursing_home_beds_in_se,round,2)
q_nursing_home_beds_in_ci <- foreach(i = q_nursing_home_beds_in_estimates, j = q_nursing_home_beds_in_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_home_beds_in_estimates.table <- rbind(unlist(q_nursing_home_beds_in_estimates_rounded), unlist(q_nursing_home_beds_in_se_rounded), unlist(q_nursing_home_beds_in_ci))
rownames(q_nursing_home_beds_in_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_home_beds_in_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_home_beds_in_estimates.table
q_nursing_home_beds_in_estimates.latextable <- xtable(q_nursing_home_beds_in_estimates.table, align = "lccc", caption = 'Quantity of Nursing Home Beds Per 100,000 - IN')
print(q_nursing_home_beds_in_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_home_beds_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_home_beds_plots_IN.pdf')
q_nursing_home_beds_plots_IN <- synthdid_plot(q_nursing_home_beds_in_estimates, 
                                              facet.vertical=FALSE,
                                              control.name='Control', treated.name='Indiana',
                                              lambda.comparable=TRUE, se.method = 'none',
                                              trajectory.linetype = 'solid', line.width=.5, 
                                              trajectory.alpha = .5, guide.linetype = 'dashed', 
                                              effect.curvature=.25, effect.alpha=.5, 
                                              diagram.alpha=1, onset.alpha=.5,
                                              point.size = 1) +
  labs(y= "Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_home_beds_control_plots_IN <- synthdid_units_plot(q_nursing_home_beds_in_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_home_beds_plots_IN + q_nursing_home_beds_control_plots_IN + plot_layout(ncol=1)
dev.off()

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "Indiana" & CON_Expenditure$year >= 1999, 1, 0))
total_exp_in_df <- as.data.frame(subset(CON_Expenditure, code == 10))
total_exp_in_df <- total_exp_in_df[order(total_exp_in_df$year, total_exp_in_df$treated_in_aux, total_exp_in_df$name),]
total_exp_in_df <- subset(total_exp_in_df, alwaysconpa == 1 | name == "Indiana", select=c(name, year, total_exp, treated))
setup_total_exp_in <- panel.matrices(total_exp_in_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_in_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_in$Y, setup_total_exp_in$N0, setup_total_exp_in$T0, X = covariates_exp_in_array)
})
names(total_exp_in_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_in_estimates_rounded <- rbind(unlist(total_exp_in_estimates))
total_exp_in_estimates_rounded <- lapply(total_exp_in_estimates,round,2)
total_exp_in_se <- lapply(total_exp_in_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_in_se_rounded <- lapply(total_exp_in_se,round,2)
total_exp_in_ci <- foreach(i = total_exp_in_estimates, j = total_exp_in_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_in_estimates.table <- rbind(unlist(total_exp_in_estimates_rounded), unlist(total_exp_in_se_rounded), unlist(total_exp_in_ci))
rownames(total_exp_in_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_in_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_in_estimates.table
total_exp_in_estimates.latextable <- xtable(total_exp_in_estimates.table, align = "lccc", caption = 'Total Expenditure - IN')
print(total_exp_in_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/total_expenditure_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/total_expenditure_plots_IN.pdf')
total_expenditure_plots_IN <- synthdid_plot(total_exp_in_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Indiana',
                                            lambda.comparable=TRUE, se.method = 'none',
                                            trajectory.linetype = 'solid', line.width=.5, 
                                            trajectory.alpha = .5, guide.linetype = 'dashed', 
                                            effect.curvature=.25, effect.alpha=.5, 
                                            diagram.alpha=1, onset.alpha=.5,
                                            point.size = 1) +
  labs(y= "Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
total_expenditure_control_plots_IN <- synthdid_units_plot(total_exp_in_estimates, se.method='none') + 
  labs(y= "Difference in Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
total_expenditure_plots_IN + total_expenditure_control_plots_IN + plot_layout(ncol=1)
dev.off()


### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "Indiana" & CON_Expenditure$year >= 1999, 1, 0))
medicaid_exp_in_df <- as.data.frame(subset(CON_Expenditure, code == 10))
medicaid_exp_in_df <- medicaid_exp_in_df[order(medicaid_exp_in_df$year, medicaid_exp_in_df$treated_in_aux, medicaid_exp_in_df$name),]
medicaid_exp_in_df <- subset(medicaid_exp_in_df, alwaysconpa == 1 | name == "Indiana", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_in <- panel.matrices(medicaid_exp_in_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_in_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_in$Y, setup_medicaid_exp_in$N0, setup_medicaid_exp_in$T0, X = covariates_exp_in_array)
})
names(medicaid_exp_in_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_in_estimates_rounded <- rbind(unlist(medicaid_exp_in_estimates))
medicaid_exp_in_estimates_rounded <- lapply(medicaid_exp_in_estimates,round,2)
medicaid_exp_in_se <- lapply(medicaid_exp_in_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_in_se_rounded <- lapply(medicaid_exp_in_se,round,2)
medicaid_exp_in_ci <- foreach(i = medicaid_exp_in_estimates, j = medicaid_exp_in_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_in_estimates.table <- rbind(unlist(medicaid_exp_in_estimates_rounded), unlist(medicaid_exp_in_se_rounded), unlist(medicaid_exp_in_ci))
rownames(medicaid_exp_in_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_in_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_in_estimates.table
medicaid_exp_in_estimates.latextable <- xtable(medicaid_exp_in_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - IN')
print(medicaid_exp_in_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/medicaid_expenditure_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/medicaid_expenditure_plots_IN.pdf')
medicaid_expenditure_plots_IN <- synthdid_plot(medicaid_exp_in_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Indiana',
                                               lambda.comparable=TRUE, se.method = 'none',
                                               trajectory.linetype = 'solid', line.width=.5, 
                                               trajectory.alpha = .5, guide.linetype = 'dashed', 
                                               effect.curvature=.25, effect.alpha=.5, 
                                               diagram.alpha=1, onset.alpha=.5,
                                               point.size = 1) +
  labs(y= "Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
medicaid_expenditure_control_plots_IN <- synthdid_units_plot(medicaid_exp_in_estimates, se.method='none') + 
  labs(y= "Difference in Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
medicaid_expenditure_plots_IN + medicaid_expenditure_control_plots_IN + plot_layout(ncol=1)
dev.off()




########## North Dakota ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_nd_aux <- ifelse(CON_Expenditure$name == "North Dakota", 1, 0)
covariates_nd_exp_df <- subset(CON_Expenditure, alwaysconpa == 1 | name == "North Dakota")
covariates_nd_exp_df <- covariates_nd_exp_df[order(covariates_nd_exp_df$year, covariates_nd_exp_df$treated_nd_aux, covariates_nd_exp_df$name),]
covariates_nd_exp_df <- as.data.frame(subset(covariates_nd_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_nd_exp_df$income_pcp_adj <- covariates_nd_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_exp_df$unemp_rate <- covariates_nd_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_exp_df$top1_adj <- covariates_nd_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_nd <- c(1980:2014)
row.names_exp_nd <- c(covariates_nd_exp_df[1:36,1])
matrix.names_exp_nd <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_nd_array <- array(as.matrix(covariates_nd_exp_df[,3:14]), dim = c(36,35,12), dimnames = list(row.names_exp_nd, column.names_exp_nd, matrix.names_exp_nd))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_nd_aux <- ifelse(CON_NursingHome$name == "North Dakota", 1, 0)
covariates_nd_acc_df <- subset(CON_NursingHome, alwaysconpa == 1 | name == "North Dakota")
covariates_nd_acc_df <- covariates_nd_acc_df[order(covariates_nd_acc_df$year, covariates_nd_acc_df$treated_nd_aux, covariates_nd_acc_df$name),]
covariates_nd_acc_df <- as.data.frame(subset(covariates_nd_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_nd_acc_df$income_pcp_adj <- covariates_nd_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_acc_df$unemp_rate <- covariates_nd_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_acc_df$top1_adj <- covariates_nd_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_nd <- c(1991:2014)
row.names_acc_nd <- c(covariates_nd_acc_df[1:36,1])
matrix.names_acc_nd <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_nd_array <- array(as.matrix(covariates_nd_acc_df[,3:14]), dim = c(36,24,12), dimnames = list(row.names_acc_nd, column.names_acc_nd, matrix.names_acc_nd))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "North Dakota" & CON_NursingHome$year >= 1995, 1, 0))
q_nursing_homes_nd_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_nd_df <- q_nursing_homes_nd_df[order(q_nursing_homes_nd_df$year, q_nursing_homes_nd_df$treated_nd_aux, q_nursing_homes_nd_df$name),]
q_nursing_homes_nd_df <- subset(q_nursing_homes_nd_df, alwaysconpa == 1 | name == "North Dakota", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
setup_q_nursing_homes_nd <- panel.matrices(q_nursing_homes_nd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_homes_nd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_homes_nd$Y, setup_q_nursing_homes_nd$N0, setup_q_nursing_homes_nd$T0, X = covariates_acc_nd_array)
})
names(q_nursing_homes_nd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_homes_nd_estimates_rounded <- rbind(unlist(q_nursing_homes_nd_estimates))
q_nursing_homes_nd_estimates_rounded <- lapply(q_nursing_homes_nd_estimates,round,2)
q_nursing_homes_nd_se <- lapply(q_nursing_homes_nd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_homes_nd_se_rounded <- lapply(q_nursing_homes_nd_se,round,2)
q_nursing_homes_nd_ci <- foreach(i = q_nursing_homes_nd_estimates, j = q_nursing_homes_nd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_homes_nd_estimates.table <- rbind(unlist(q_nursing_homes_nd_estimates_rounded), unlist(q_nursing_homes_nd_se_rounded), unlist(q_nursing_homes_nd_ci))
rownames(q_nursing_homes_nd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_homes_nd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_homes_nd_estimates.table
q_nursing_homes_nd_estimates.latextable <- xtable(q_nursing_homes_nd_estimates.table, align = "lccc", caption = 'Quantity of Nursing Homes Per 100,000 - ND')
print(q_nursing_homes_nd_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_homes_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_homes_plots_ND.pdf')
q_nursing_homes_plots_ND <- synthdid_plot(q_nursing_homes_nd_estimates, 
                                          facet.vertical=FALSE,
                                          control.name='Control', treated.name='North Dakota',
                                          lambda.comparable=TRUE, se.method = 'none',
                                          trajectory.linetype = 'solid', line.width=.5, 
                                          trajectory.alpha = .5, guide.linetype = 'dashed', 
                                          effect.curvature=.25, effect.alpha=.5, 
                                          diagram.alpha=1, onset.alpha=.5,
                                          point.size = 1) +
  labs(y= "Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_homes_control_plots_ND <- synthdid_units_plot(q_nursing_homes_nd_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Homes\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_homes_plots_ND + q_nursing_homes_control_plots_ND + plot_layout(ncol=1)
dev.off()

### Quantity of Nursing Home Beds ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "North Dakota" & CON_NursingHome$year >= 1995, 1, 0))
q_nursing_home_beds_nd_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_home_beds_nd_df <- q_nursing_home_beds_nd_df[order(q_nursing_home_beds_nd_df$year, q_nursing_home_beds_nd_df$treated_nd_aux, q_nursing_home_beds_nd_df$name),]
q_nursing_home_beds_nd_df <- subset(q_nursing_home_beds_nd_df, alwaysconpa == 1 | name == "North Dakota", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
setup_q_nursing_home_beds_nd <- panel.matrices(q_nursing_home_beds_nd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
q_nursing_home_beds_nd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_q_nursing_home_beds_nd$Y, setup_q_nursing_home_beds_nd$N0, setup_q_nursing_home_beds_nd$T0, X = covariates_acc_nd_array)
})
names(q_nursing_home_beds_nd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
q_nursing_home_beds_nd_estimates_rounded <- rbind(unlist(q_nursing_home_beds_nd_estimates))
q_nursing_home_beds_nd_estimates_rounded <- lapply(q_nursing_home_beds_nd_estimates,round,2)
q_nursing_home_beds_nd_se <- lapply(q_nursing_home_beds_nd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
q_nursing_home_beds_nd_se_rounded <- lapply(q_nursing_home_beds_nd_se,round,2)
q_nursing_home_beds_nd_ci <- foreach(i = q_nursing_home_beds_nd_estimates, j = q_nursing_home_beds_nd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
q_nursing_home_beds_nd_estimates.table <- rbind(unlist(q_nursing_home_beds_nd_estimates_rounded), unlist(q_nursing_home_beds_nd_se_rounded), unlist(q_nursing_home_beds_nd_ci))
rownames(q_nursing_home_beds_nd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(q_nursing_home_beds_nd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
q_nursing_home_beds_nd_estimates.table
q_nursing_home_beds_nd_estimates.latextable <- xtable(q_nursing_home_beds_nd_estimates.table, align = "lccc", caption = 'Quantity of Nursing Home Beds Per 100,000 - ND')
print(q_nursing_home_beds_nd_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/q_nursing_home_beds_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/q_nursing_home_beds_plots_ND.pdf')
q_nursing_home_beds_plots_ND <- synthdid_plot(q_nursing_home_beds_nd_estimates, 
                                              facet.vertical=FALSE,
                                              control.name='Control', treated.name='North Dakota',
                                              lambda.comparable=TRUE, se.method = 'none',
                                              trajectory.linetype = 'solid', line.width=.5, 
                                              trajectory.alpha = .5, guide.linetype = 'dashed', 
                                              effect.curvature=.25, effect.alpha=.5, 
                                              diagram.alpha=1, onset.alpha=.5,
                                              point.size = 1) +
  labs(y= "Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
q_nursing_home_beds_control_plots_ND <- synthdid_units_plot(q_nursing_home_beds_nd_estimates, se.method='none') + 
  labs(y= "Difference in Quantity of Nursing Home Beds\n(Per 100,000)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
q_nursing_home_beds_plots_ND + q_nursing_home_beds_control_plots_ND + plot_layout(ncol=1)
dev.off()

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "North Dakota" & CON_Expenditure$year >= 1995, 1, 0))
total_exp_nd_df <- as.data.frame(subset(CON_Expenditure, code == 10))
total_exp_nd_df <- total_exp_nd_df[order(total_exp_nd_df$year, total_exp_nd_df$treated_nd_aux, total_exp_nd_df$name),]
total_exp_nd_df <- subset(total_exp_nd_df, alwaysconpa == 1 | name == "North Dakota", select=c(name, year, total_exp, treated))
setup_total_exp_nd <- panel.matrices(total_exp_nd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_nd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_nd$Y, setup_total_exp_nd$N0, setup_total_exp_nd$T0, X = covariates_exp_nd_array)
})
names(total_exp_nd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_nd_estimates_rounded <- rbind(unlist(total_exp_nd_estimates))
total_exp_nd_estimates_rounded <- lapply(total_exp_nd_estimates,round,2)
total_exp_nd_se <- lapply(total_exp_nd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_nd_se_rounded <- lapply(total_exp_nd_se,round,2)
total_exp_nd_ci <- foreach(i = total_exp_nd_estimates, j = total_exp_nd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_nd_estimates.table <- rbind(unlist(total_exp_nd_estimates_rounded), unlist(total_exp_nd_se_rounded), unlist(total_exp_nd_ci))
rownames(total_exp_nd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_nd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_nd_estimates.table
total_exp_nd_estimates.latextable <- xtable(total_exp_nd_estimates.table, align = "lccc", caption = 'Total Expenditure - ND')
print(total_exp_nd_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/total_expenditure_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/total_expenditure_plots_ND.pdf')
total_expenditure_plots_ND <- synthdid_plot(total_exp_nd_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='North Dakota',
                                            lambda.comparable=TRUE, se.method = 'none',
                                            trajectory.linetype = 'solid', line.width=.5, 
                                            trajectory.alpha = .5, guide.linetype = 'dashed', 
                                            effect.curvature=.25, effect.alpha=.5, 
                                            diagram.alpha=1, onset.alpha=.5,
                                            point.size = 1) +
  labs(y= "Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
total_expenditure_control_plots_ND <- synthdid_units_plot(total_exp_nd_estimates, se.method='none') + 
  labs(y= "Difference in Total Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
total_expenditure_plots_ND + total_expenditure_control_plots_ND + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_Expenditure$treated <- as.integer(ifelse(CON_Expenditure$name == "North Dakota" & CON_Expenditure$year >= 1995, 1, 0))
medicaid_exp_nd_df <- as.data.frame(subset(CON_Expenditure, code == 10))
medicaid_exp_nd_df <- medicaid_exp_nd_df[order(medicaid_exp_nd_df$year, medicaid_exp_nd_df$treated_nd_aux, medicaid_exp_nd_df$name),]
medicaid_exp_nd_df <- subset(medicaid_exp_nd_df, alwaysconpa == 1 | name == "North Dakota", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_nd <- panel.matrices(medicaid_exp_nd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_nd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_nd$Y, setup_medicaid_exp_nd$N0, setup_medicaid_exp_nd$T0, X = covariates_exp_nd_array)
})
names(medicaid_exp_nd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_nd_estimates_rounded <- rbind(unlist(medicaid_exp_nd_estimates))
medicaid_exp_nd_estimates_rounded <- lapply(medicaid_exp_nd_estimates,round,2)
medicaid_exp_nd_se <- lapply(medicaid_exp_nd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_nd_se_rounded <- lapply(medicaid_exp_nd_se,round,2)
medicaid_exp_nd_ci <- foreach(i = medicaid_exp_nd_estimates, j = medicaid_exp_nd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_nd_estimates.table <- rbind(unlist(medicaid_exp_nd_estimates_rounded), unlist(medicaid_exp_nd_se_rounded), unlist(medicaid_exp_nd_ci))
rownames(medicaid_exp_nd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_nd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_nd_estimates.table
medicaid_exp_nd_estimates.latextable <- xtable(medicaid_exp_nd_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - ND')
print(medicaid_exp_nd_estimates.latextable, type='latex', file='SynthDID_Figs_and_Tables/medicaid_expenditure_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Figs_and_Tables/medicaid_expenditure_plots_ND.pdf')
medicaid_expenditure_plots_ND <- synthdid_plot(medicaid_exp_nd_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='North Dakota',
                                               lambda.comparable=TRUE, se.method = 'none',
                                               trajectory.linetype = 'solid', line.width=.5, 
                                               trajectory.alpha = .5, guide.linetype = 'dashed', 
                                               effect.curvature=.25, effect.alpha=.5, 
                                               diagram.alpha=1, onset.alpha=.5,
                                               point.size = 1) +
  labs(y= "Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.text.x = element_text(angle = 45, hjust=1, size = 8),
        axis.title.y = element_text(size=8),
        strip.background = element_rect(fill="grey70", size=1),
        strip.text = element_text(size=8, face="bold"),
        legend.position='top', 
        legend.text = element_text(size=8),
        legend.direction='horizontal')
medicaid_expenditure_control_plots_ND <- synthdid_units_plot(medicaid_exp_nd_estimates, se.method='none') + 
  labs(y= "Difference in Medicaid Nursing Home Expenditure\n(Per Capita)") +
  theme(aspect.ratio=1,
        panel.spacing.x=unit(1, "lines"),
        panel.grid.major.x = element_blank(),
        panel.grid.minor.x = element_blank(), 
        panel.grid.major.y = element_line(size=.25, color='grey90'),
        panel.grid.minor.y = element_blank(),
        axis.title.y = element_text(size=8),
        axis.text.x = element_text(size = 5, hjust=1, vjust=0.3),
        legend.background=element_blank(),
        legend.direction='horizontal', legend.position='bottom',
        strip.background=element_blank(), strip.text.x = element_blank(),
        legend.text = element_text(size=8),
        legend.title = element_text(size=8, face="bold"))
medicaid_expenditure_plots_ND + medicaid_expenditure_control_plots_ND + plot_layout(ncol=1)
dev.off()




############### Spaghetti and Placebo Distribution Plots ###############

##### Create 3D arrays of time-varying covariates for synthetic matching for all potential control states - CON_Expenditure #####
controls.df <- subset(CON_Expenditure, alwaysconpa == 1)
print(unique(controls.df$id))
for(i in unique(controls.df$id)) {
  assign(paste0("covariates_exp_df", i), subset(CON_Expenditure, alwaysconpa == 1))
}
covariates_exp_df1$treated_aux <- ifelse(covariates_exp_df1$id == 1, 1, 0)
covariates_exp_df2$treated_aux <- ifelse(covariates_exp_df5$id == 2, 1, 0)
covariates_exp_df5$treated_aux <- ifelse(covariates_exp_df5$id == 5, 1, 0)
covariates_exp_df10$treated_aux <- ifelse(covariates_exp_df5$id == 10, 1, 0)
covariates_exp_df11$treated_aux <- ifelse(covariates_exp_df5$id == 11, 1, 0)
covariates_exp_df12$treated_aux <- ifelse(covariates_exp_df5$id == 12, 1, 0)
covariates_exp_df13$treated_aux <- ifelse(covariates_exp_df5$id == 13, 1, 0)
covariates_exp_df15$treated_aux <- ifelse(covariates_exp_df5$id == 15, 1, 0)
covariates_exp_df17$treated_aux <- ifelse(covariates_exp_df5$id == 17, 1, 0)
covariates_exp_df19$treated_aux <- ifelse(covariates_exp_df5$id == 19, 1, 0)
covariates_exp_df21$treated_aux <- ifelse(covariates_exp_df5$id == 21, 1, 0)
covariates_exp_df23$treated_aux <- ifelse(covariates_exp_df5$id == 23, 1, 0)
covariates_exp_df24$treated_aux <- ifelse(covariates_exp_df5$id == 24, 1, 0)
covariates_exp_df25$treated_aux <- ifelse(covariates_exp_df5$id == 25, 1, 0)
covariates_exp_df26$treated_aux <- ifelse(covariates_exp_df5$id == 26, 1, 0)
covariates_exp_df28$treated_aux <- ifelse(covariates_exp_df5$id == 28, 1, 0)
covariates_exp_df29$treated_aux <- ifelse(covariates_exp_df5$id == 29, 1, 0)
covariates_exp_df30$treated_aux <- ifelse(covariates_exp_df5$id == 30, 1, 0)
covariates_exp_df31$treated_aux <- ifelse(covariates_exp_df5$id == 31, 1, 0)
covariates_exp_df32$treated_aux <- ifelse(covariates_exp_df5$id == 32, 1, 0)
covariates_exp_df33$treated_aux <- ifelse(covariates_exp_df5$id == 33, 1, 0)
covariates_exp_df34$treated_aux <- ifelse(covariates_exp_df5$id == 34, 1, 0)
covariates_exp_df36$treated_aux <- ifelse(covariates_exp_df5$id == 36, 1, 0)
covariates_exp_df37$treated_aux <- ifelse(covariates_exp_df5$id == 37, 1, 0)
covariates_exp_df39$treated_aux <- ifelse(covariates_exp_df5$id == 39, 1, 0)
covariates_exp_df40$treated_aux <- ifelse(covariates_exp_df5$id == 40, 1, 0)
covariates_exp_df41$treated_aux <- ifelse(covariates_exp_df5$id == 41, 1, 0)
covariates_exp_df44$treated_aux <- ifelse(covariates_exp_df5$id == 44, 1, 0)
covariates_exp_df45$treated_aux <- ifelse(covariates_exp_df5$id == 45, 1, 0)
covariates_exp_df47$treated_aux <- ifelse(covariates_exp_df5$id == 47, 1, 0)
covariates_exp_df50$treated_aux <- ifelse(covariates_exp_df5$id == 50, 1, 0)
covariates_exp_df51$treated_aux <- ifelse(covariates_exp_df5$id == 51, 1, 0)
covariates_exp_df53$treated_aux <- ifelse(covariates_exp_df5$id == 53, 1, 0)
covariates_exp_df54$treated_aux <- ifelse(covariates_exp_df5$id == 54, 1, 0)
covariates_exp_df55$treated_aux <- ifelse(covariates_exp_df5$id == 55, 1, 0)
covariates_exp_df_list <- list(covariates_exp_df1,covariates_exp_df2,covariates_exp_df5,
                               covariates_exp_df10,covariates_exp_df11,covariates_exp_df12,
                               covariates_exp_df13,covariates_exp_df15,covariates_exp_df17,
                               covariates_exp_df19,covariates_exp_df21,covariates_exp_df23,
                               covariates_exp_df24,covariates_exp_df25,covariates_exp_df26,
                               covariates_exp_df28,covariates_exp_df29,covariates_exp_df30,
                               covariates_exp_df31,covariates_exp_df32,covariates_exp_df33,
                               covariates_exp_df34,covariates_exp_df36,covariates_exp_df37,
                               covariates_exp_df39,covariates_exp_df40,covariates_exp_df41,
                               covariates_exp_df44,covariates_exp_df45,covariates_exp_df47,
                               covariates_exp_df50,covariates_exp_df51,covariates_exp_df53,
                               covariates_exp_df54,covariates_exp_df55)
rm(covariates_exp_df1,covariates_exp_df2,covariates_exp_df5,
   covariates_exp_df10,covariates_exp_df11,covariates_exp_df12,
   covariates_exp_df13,covariates_exp_df15,covariates_exp_df17,
   covariates_exp_df19,covariates_exp_df21,covariates_exp_df23,
   covariates_exp_df24,covariates_exp_df25,covariates_exp_df26,
   covariates_exp_df28,covariates_exp_df29,covariates_exp_df30,
   covariates_exp_df31,covariates_exp_df32,covariates_exp_df33,
   covariates_exp_df34,covariates_exp_df36,covariates_exp_df37,
   covariates_exp_df39,covariates_exp_df40,covariates_exp_df41,
   covariates_exp_df44,covariates_exp_df45,covariates_exp_df47,
   covariates_exp_df50,covariates_exp_df51,covariates_exp_df53,
   covariates_exp_df54,covariates_exp_df55)
covariates_exp_df_list <- lapply(covariates_exp_df_list, function(x) {
  x <- x[order(x$year, x$treated_aux, x$name),]
  return(x)
}
)
covariates_exp_df_list <- lapply(covariates_exp_df_list, function(x)
  x <- as.data.frame(subset(x, code == 10, select=c(id,name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
)
covariates_exp_df_list <- lapply(covariates_exp_df_list, function(x) {
  x["income_pcp_adj"] <- x["income_pcp_adj"]/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
  x["unemp_rate"] <- x["unemp_rate"]/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
  x["top1_adj"] <- x["top1_adj"]/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
  return(x)
}
)
column.names_exp <- c(1980:2014)
row.names_exp_1 <- c(covariates_exp_df_list[[1]][1:35,2])
row.names_exp_2 <- c(covariates_exp_df_list[[2]][1:35,2])
row.names_exp_5 <- c(covariates_exp_df_list[[3]][1:35,2])
row.names_exp_10 <- c(covariates_exp_df_list[[4]][1:35,2])
row.names_exp_11 <- c(covariates_exp_df_list[[5]][1:35,2])
row.names_exp_12 <- c(covariates_exp_df_list[[6]][1:35,2])
row.names_exp_13 <- c(covariates_exp_df_list[[7]][1:35,2])
row.names_exp_15 <- c(covariates_exp_df_list[[8]][1:35,2])
row.names_exp_17 <- c(covariates_exp_df_list[[9]][1:35,2])
row.names_exp_19 <- c(covariates_exp_df_list[[10]][1:35,2])
row.names_exp_21 <- c(covariates_exp_df_list[[11]][1:35,2])
row.names_exp_23 <- c(covariates_exp_df_list[[12]][1:35,2])
row.names_exp_24 <- c(covariates_exp_df_list[[13]][1:35,2])
row.names_exp_25 <- c(covariates_exp_df_list[[14]][1:35,2])
row.names_exp_26 <- c(covariates_exp_df_list[[15]][1:35,2])
row.names_exp_28 <- c(covariates_exp_df_list[[16]][1:35,2])
row.names_exp_29 <- c(covariates_exp_df_list[[17]][1:35,2])
row.names_exp_30 <- c(covariates_exp_df_list[[18]][1:35,2])
row.names_exp_31 <- c(covariates_exp_df_list[[19]][1:35,2])
row.names_exp_32 <- c(covariates_exp_df_list[[20]][1:35,2])
row.names_exp_33 <- c(covariates_exp_df_list[[21]][1:35,2])
row.names_exp_34 <- c(covariates_exp_df_list[[22]][1:35,2])
row.names_exp_36 <- c(covariates_exp_df_list[[23]][1:35,2])
row.names_exp_37 <- c(covariates_exp_df_list[[24]][1:35,2])
row.names_exp_39 <- c(covariates_exp_df_list[[25]][1:35,2])
row.names_exp_40 <- c(covariates_exp_df_list[[26]][1:35,2])
row.names_exp_41 <- c(covariates_exp_df_list[[27]][1:35,2])
row.names_exp_44 <- c(covariates_exp_df_list[[28]][1:35,2])
row.names_exp_45 <- c(covariates_exp_df_list[[29]][1:35,2])
row.names_exp_47 <- c(covariates_exp_df_list[[30]][1:35,2])
row.names_exp_50 <- c(covariates_exp_df_list[[31]][1:35,2])
row.names_exp_51 <- c(covariates_exp_df_list[[32]][1:35,2])
row.names_exp_53 <- c(covariates_exp_df_list[[33]][1:35,2])
row.names_exp_54 <- c(covariates_exp_df_list[[34]][1:35,2])
row.names_exp_55 <- c(covariates_exp_df_list[[35]][1:35,2])
row.names_exp_list <- list(row.names_exp_1,row.names_exp_2,row.names_exp_5,
                           row.names_exp_10,row.names_exp_11,row.names_exp_12,
                           row.names_exp_13,row.names_exp_15,row.names_exp_17,
                           row.names_exp_19,row.names_exp_21,row.names_exp_23,
                           row.names_exp_24,row.names_exp_25,row.names_exp_26,
                           row.names_exp_28,row.names_exp_29,row.names_exp_30,
                           row.names_exp_31,row.names_exp_32,row.names_exp_33,
                           row.names_exp_34,row.names_exp_36,row.names_exp_37,
                           row.names_exp_39,row.names_exp_40,row.names_exp_41,
                           row.names_exp_44,row.names_exp_45,row.names_exp_47,
                           row.names_exp_50,row.names_exp_51,row.names_exp_53,
                           row.names_exp_54,row.names_exp_55)
rm(row.names_exp_1,row.names_exp_2,row.names_exp_5,
   row.names_exp_10,row.names_exp_11,row.names_exp_12,
   row.names_exp_13,row.names_exp_15,row.names_exp_17,
   row.names_exp_19,row.names_exp_21,row.names_exp_23,
   row.names_exp_24,row.names_exp_25,row.names_exp_26,
   row.names_exp_28,row.names_exp_29,row.names_exp_30,
   row.names_exp_31,row.names_exp_32,row.names_exp_33,
   row.names_exp_34,row.names_exp_36,row.names_exp_37,
   row.names_exp_39,row.names_exp_40,row.names_exp_41,
   row.names_exp_44,row.names_exp_45,row.names_exp_47,
   row.names_exp_50,row.names_exp_51,row.names_exp_53,
   row.names_exp_54,row.names_exp_55)
matrix.names_exp <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_array_1 <- array(as.matrix(covariates_exp_df_list[[1]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[1]], column.names_exp, matrix.names_exp))
covariates_exp_array_2 <- array(as.matrix(covariates_exp_df_list[[2]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[2]], column.names_exp, matrix.names_exp))
covariates_exp_array_5 <- array(as.matrix(covariates_exp_df_list[[3]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[3]], column.names_exp, matrix.names_exp))
covariates_exp_array_10 <- array(as.matrix(covariates_exp_df_list[[4]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[4]], column.names_exp, matrix.names_exp))
covariates_exp_array_11 <- array(as.matrix(covariates_exp_df_list[[5]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[5]], column.names_exp, matrix.names_exp))
covariates_exp_array_12 <- array(as.matrix(covariates_exp_df_list[[6]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[6]], column.names_exp, matrix.names_exp))
covariates_exp_array_13 <- array(as.matrix(covariates_exp_df_list[[7]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[7]], column.names_exp, matrix.names_exp))
covariates_exp_array_15 <- array(as.matrix(covariates_exp_df_list[[8]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[8]], column.names_exp, matrix.names_exp))
covariates_exp_array_17 <- array(as.matrix(covariates_exp_df_list[[9]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[9]], column.names_exp, matrix.names_exp))
covariates_exp_array_19 <- array(as.matrix(covariates_exp_df_list[[10]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[10]], column.names_exp, matrix.names_exp))
covariates_exp_array_21 <- array(as.matrix(covariates_exp_df_list[[11]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[11]], column.names_exp, matrix.names_exp))
covariates_exp_array_23 <- array(as.matrix(covariates_exp_df_list[[12]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[12]], column.names_exp, matrix.names_exp))
covariates_exp_array_24 <- array(as.matrix(covariates_exp_df_list[[13]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[13]], column.names_exp, matrix.names_exp))
covariates_exp_array_25 <- array(as.matrix(covariates_exp_df_list[[14]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[14]], column.names_exp, matrix.names_exp))
covariates_exp_array_26 <- array(as.matrix(covariates_exp_df_list[[15]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[15]], column.names_exp, matrix.names_exp))
covariates_exp_array_28 <- array(as.matrix(covariates_exp_df_list[[16]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[16]], column.names_exp, matrix.names_exp))
covariates_exp_array_29 <- array(as.matrix(covariates_exp_df_list[[17]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[17]], column.names_exp, matrix.names_exp))
covariates_exp_array_30 <- array(as.matrix(covariates_exp_df_list[[18]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[18]], column.names_exp, matrix.names_exp))
covariates_exp_array_31 <- array(as.matrix(covariates_exp_df_list[[19]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[19]], column.names_exp, matrix.names_exp))
covariates_exp_array_32 <- array(as.matrix(covariates_exp_df_list[[20]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[20]], column.names_exp, matrix.names_exp))
covariates_exp_array_33 <- array(as.matrix(covariates_exp_df_list[[21]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[21]], column.names_exp, matrix.names_exp))
covariates_exp_array_34 <- array(as.matrix(covariates_exp_df_list[[22]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[22]], column.names_exp, matrix.names_exp))
covariates_exp_array_36 <- array(as.matrix(covariates_exp_df_list[[23]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[23]], column.names_exp, matrix.names_exp))
covariates_exp_array_37 <- array(as.matrix(covariates_exp_df_list[[24]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[24]], column.names_exp, matrix.names_exp))
covariates_exp_array_39 <- array(as.matrix(covariates_exp_df_list[[25]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[25]], column.names_exp, matrix.names_exp))
covariates_exp_array_40 <- array(as.matrix(covariates_exp_df_list[[26]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[26]], column.names_exp, matrix.names_exp))
covariates_exp_array_41 <- array(as.matrix(covariates_exp_df_list[[27]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[27]], column.names_exp, matrix.names_exp))
covariates_exp_array_44 <- array(as.matrix(covariates_exp_df_list[[28]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[28]], column.names_exp, matrix.names_exp))
covariates_exp_array_45 <- array(as.matrix(covariates_exp_df_list[[29]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[29]], column.names_exp, matrix.names_exp))
covariates_exp_array_47 <- array(as.matrix(covariates_exp_df_list[[30]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[30]], column.names_exp, matrix.names_exp))
covariates_exp_array_50 <- array(as.matrix(covariates_exp_df_list[[31]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[31]], column.names_exp, matrix.names_exp))
covariates_exp_array_51 <- array(as.matrix(covariates_exp_df_list[[32]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[32]], column.names_exp, matrix.names_exp))
covariates_exp_array_53 <- array(as.matrix(covariates_exp_df_list[[33]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[33]], column.names_exp, matrix.names_exp))
covariates_exp_array_54 <- array(as.matrix(covariates_exp_df_list[[34]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[34]], column.names_exp, matrix.names_exp))
covariates_exp_array_55 <- array(as.matrix(covariates_exp_df_list[[35]][,4:15]), dim = c(35,35,12), dimnames = list(row.names_exp_list[[35]], column.names_exp, matrix.names_exp))

##### Create 3D arrays of time-varying covariates for synthetic matching for all potential control states - CON_NursingHome #####
controls.nh.df <- subset(CON_NursingHome, alwaysconpa == 1)
print(unique(controls.nh.df$id))
for(i in unique(controls.nh.df$id)) {
  assign(paste0("covariates_acc_df", i), subset(CON_NursingHome, alwaysconpa == 1))
}
covariates_acc_df1$treated_aux <- ifelse(covariates_acc_df1$id == 1, 1, 0)
covariates_acc_df2$treated_aux <- ifelse(covariates_acc_df5$id == 2, 1, 0)
covariates_acc_df5$treated_aux <- ifelse(covariates_acc_df5$id == 5, 1, 0)
covariates_acc_df10$treated_aux <- ifelse(covariates_acc_df5$id == 10, 1, 0)
covariates_acc_df11$treated_aux <- ifelse(covariates_acc_df5$id == 11, 1, 0)
covariates_acc_df12$treated_aux <- ifelse(covariates_acc_df5$id == 12, 1, 0)
covariates_acc_df13$treated_aux <- ifelse(covariates_acc_df5$id == 13, 1, 0)
covariates_acc_df15$treated_aux <- ifelse(covariates_acc_df5$id == 15, 1, 0)
covariates_acc_df17$treated_aux <- ifelse(covariates_acc_df5$id == 17, 1, 0)
covariates_acc_df19$treated_aux <- ifelse(covariates_acc_df5$id == 19, 1, 0)
covariates_acc_df21$treated_aux <- ifelse(covariates_acc_df5$id == 21, 1, 0)
covariates_acc_df23$treated_aux <- ifelse(covariates_acc_df5$id == 23, 1, 0)
covariates_acc_df24$treated_aux <- ifelse(covariates_acc_df5$id == 24, 1, 0)
covariates_acc_df25$treated_aux <- ifelse(covariates_acc_df5$id == 25, 1, 0)
covariates_acc_df26$treated_aux <- ifelse(covariates_acc_df5$id == 26, 1, 0)
covariates_acc_df28$treated_aux <- ifelse(covariates_acc_df5$id == 28, 1, 0)
covariates_acc_df29$treated_aux <- ifelse(covariates_acc_df5$id == 29, 1, 0)
covariates_acc_df30$treated_aux <- ifelse(covariates_acc_df5$id == 30, 1, 0)
covariates_acc_df31$treated_aux <- ifelse(covariates_acc_df5$id == 31, 1, 0)
covariates_acc_df32$treated_aux <- ifelse(covariates_acc_df5$id == 32, 1, 0)
covariates_acc_df33$treated_aux <- ifelse(covariates_acc_df5$id == 33, 1, 0)
covariates_acc_df34$treated_aux <- ifelse(covariates_acc_df5$id == 34, 1, 0)
covariates_acc_df36$treated_aux <- ifelse(covariates_acc_df5$id == 36, 1, 0)
covariates_acc_df37$treated_aux <- ifelse(covariates_acc_df5$id == 37, 1, 0)
covariates_acc_df39$treated_aux <- ifelse(covariates_acc_df5$id == 39, 1, 0)
covariates_acc_df40$treated_aux <- ifelse(covariates_acc_df5$id == 40, 1, 0)
covariates_acc_df41$treated_aux <- ifelse(covariates_acc_df5$id == 41, 1, 0)
covariates_acc_df44$treated_aux <- ifelse(covariates_acc_df5$id == 44, 1, 0)
covariates_acc_df45$treated_aux <- ifelse(covariates_acc_df5$id == 45, 1, 0)
covariates_acc_df47$treated_aux <- ifelse(covariates_acc_df5$id == 47, 1, 0)
covariates_acc_df50$treated_aux <- ifelse(covariates_acc_df5$id == 50, 1, 0)
covariates_acc_df51$treated_aux <- ifelse(covariates_acc_df5$id == 51, 1, 0)
covariates_acc_df53$treated_aux <- ifelse(covariates_acc_df5$id == 53, 1, 0)
covariates_acc_df54$treated_aux <- ifelse(covariates_acc_df5$id == 54, 1, 0)
covariates_acc_df55$treated_aux <- ifelse(covariates_acc_df5$id == 55, 1, 0)
covariates_acc_df_list <- list(covariates_acc_df1,covariates_acc_df2,covariates_acc_df5,
                               covariates_acc_df10,covariates_acc_df11,covariates_acc_df12,
                               covariates_acc_df13,covariates_acc_df15,covariates_acc_df17,
                               covariates_acc_df19,covariates_acc_df21,covariates_acc_df23,
                               covariates_acc_df24,covariates_acc_df25,covariates_acc_df26,
                               covariates_acc_df28,covariates_acc_df29,covariates_acc_df30,
                               covariates_acc_df31,covariates_acc_df32,covariates_acc_df33,
                               covariates_acc_df34,covariates_acc_df36,covariates_acc_df37,
                               covariates_acc_df39,covariates_acc_df40,covariates_acc_df41,
                               covariates_acc_df44,covariates_acc_df45,covariates_acc_df47,
                               covariates_acc_df50,covariates_acc_df51,covariates_acc_df53,
                               covariates_acc_df54,covariates_acc_df55)
rm(covariates_acc_df1,covariates_acc_df2,covariates_acc_df5,
   covariates_acc_df10,covariates_acc_df11,covariates_acc_df12,
   covariates_acc_df13,covariates_acc_df15,covariates_acc_df17,
   covariates_acc_df19,covariates_acc_df21,covariates_acc_df23,
   covariates_acc_df24,covariates_acc_df25,covariates_acc_df26,
   covariates_acc_df28,covariates_acc_df29,covariates_acc_df30,
   covariates_acc_df31,covariates_acc_df32,covariates_acc_df33,
   covariates_acc_df34,covariates_acc_df36,covariates_acc_df37,
   covariates_acc_df39,covariates_acc_df40,covariates_acc_df41,
   covariates_acc_df44,covariates_acc_df45,covariates_acc_df47,
   covariates_acc_df50,covariates_acc_df51,covariates_acc_df53,
   covariates_acc_df54,covariates_acc_df55)
covariates_acc_df_list <- lapply(covariates_acc_df_list, function(x) {
  x <- x[order(x$year, x$treated_aux, x$name),]
  return(x)
}
)
covariates_acc_df_list <- lapply(covariates_acc_df_list, function(x)
  x <- as.data.frame(subset(x, code == 10, select=c(id,name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
)
covariates_acc_df_list <- lapply(covariates_acc_df_list, function(x) {
  x["income_pcp_adj"] <- x["income_pcp_adj"]/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
  x["unemp_rate"] <- x["unemp_rate"]/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
  x["top1_adj"] <- x["top1_adj"]/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
  return(x)
}
)
column.names_acc <- c(1991:2014)
row.names_acc_1 <- c(covariates_acc_df_list[[1]][1:35,2])
row.names_acc_2 <- c(covariates_acc_df_list[[2]][1:35,2])
row.names_acc_5 <- c(covariates_acc_df_list[[3]][1:35,2])
row.names_acc_10 <- c(covariates_acc_df_list[[4]][1:35,2])
row.names_acc_11 <- c(covariates_acc_df_list[[5]][1:35,2])
row.names_acc_12 <- c(covariates_acc_df_list[[6]][1:35,2])
row.names_acc_13 <- c(covariates_acc_df_list[[7]][1:35,2])
row.names_acc_15 <- c(covariates_acc_df_list[[8]][1:35,2])
row.names_acc_17 <- c(covariates_acc_df_list[[9]][1:35,2])
row.names_acc_19 <- c(covariates_acc_df_list[[10]][1:35,2])
row.names_acc_21 <- c(covariates_acc_df_list[[11]][1:35,2])
row.names_acc_23 <- c(covariates_acc_df_list[[12]][1:35,2])
row.names_acc_24 <- c(covariates_acc_df_list[[13]][1:35,2])
row.names_acc_25 <- c(covariates_acc_df_list[[14]][1:35,2])
row.names_acc_26 <- c(covariates_acc_df_list[[15]][1:35,2])
row.names_acc_28 <- c(covariates_acc_df_list[[16]][1:35,2])
row.names_acc_29 <- c(covariates_acc_df_list[[17]][1:35,2])
row.names_acc_30 <- c(covariates_acc_df_list[[18]][1:35,2])
row.names_acc_31 <- c(covariates_acc_df_list[[19]][1:35,2])
row.names_acc_32 <- c(covariates_acc_df_list[[20]][1:35,2])
row.names_acc_33 <- c(covariates_acc_df_list[[21]][1:35,2])
row.names_acc_34 <- c(covariates_acc_df_list[[22]][1:35,2])
row.names_acc_36 <- c(covariates_acc_df_list[[23]][1:35,2])
row.names_acc_37 <- c(covariates_acc_df_list[[24]][1:35,2])
row.names_acc_39 <- c(covariates_acc_df_list[[25]][1:35,2])
row.names_acc_40 <- c(covariates_acc_df_list[[26]][1:35,2])
row.names_acc_41 <- c(covariates_acc_df_list[[27]][1:35,2])
row.names_acc_44 <- c(covariates_acc_df_list[[28]][1:35,2])
row.names_acc_45 <- c(covariates_acc_df_list[[29]][1:35,2])
row.names_acc_47 <- c(covariates_acc_df_list[[30]][1:35,2])
row.names_acc_50 <- c(covariates_acc_df_list[[31]][1:35,2])
row.names_acc_51 <- c(covariates_acc_df_list[[32]][1:35,2])
row.names_acc_53 <- c(covariates_acc_df_list[[33]][1:35,2])
row.names_acc_54 <- c(covariates_acc_df_list[[34]][1:35,2])
row.names_acc_55 <- c(covariates_acc_df_list[[35]][1:35,2])
row.names_acc_list <- list(row.names_acc_1,row.names_acc_2,row.names_acc_5,
                           row.names_acc_10,row.names_acc_11,row.names_acc_12,
                           row.names_acc_13,row.names_acc_15,row.names_acc_17,
                           row.names_acc_19,row.names_acc_21,row.names_acc_23,
                           row.names_acc_24,row.names_acc_25,row.names_acc_26,
                           row.names_acc_28,row.names_acc_29,row.names_acc_30,
                           row.names_acc_31,row.names_acc_32,row.names_acc_33,
                           row.names_acc_34,row.names_acc_36,row.names_acc_37,
                           row.names_acc_39,row.names_acc_40,row.names_acc_41,
                           row.names_acc_44,row.names_acc_45,row.names_acc_47,
                           row.names_acc_50,row.names_acc_51,row.names_acc_53,
                           row.names_acc_54,row.names_acc_55)
rm(row.names_acc_1,row.names_acc_2,row.names_acc_5,
   row.names_acc_10,row.names_acc_11,row.names_acc_12,
   row.names_acc_13,row.names_acc_15,row.names_acc_17,
   row.names_acc_19,row.names_acc_21,row.names_acc_23,
   row.names_acc_24,row.names_acc_25,row.names_acc_26,
   row.names_acc_28,row.names_acc_29,row.names_acc_30,
   row.names_acc_31,row.names_acc_32,row.names_acc_33,
   row.names_acc_34,row.names_acc_36,row.names_acc_37,
   row.names_acc_39,row.names_acc_40,row.names_acc_41,
   row.names_acc_44,row.names_acc_45,row.names_acc_47,
   row.names_acc_50,row.names_acc_51,row.names_acc_53,
   row.names_acc_54,row.names_acc_55)
matrix.names_acc <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_array_1 <- array(as.matrix(covariates_acc_df_list[[1]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[1]], column.names_acc, matrix.names_acc))
covariates_acc_array_2 <- array(as.matrix(covariates_acc_df_list[[2]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[2]], column.names_acc, matrix.names_acc))
covariates_acc_array_5 <- array(as.matrix(covariates_acc_df_list[[3]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[3]], column.names_acc, matrix.names_acc))
covariates_acc_array_10 <- array(as.matrix(covariates_acc_df_list[[4]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[4]], column.names_acc, matrix.names_acc))
covariates_acc_array_11 <- array(as.matrix(covariates_acc_df_list[[5]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[5]], column.names_acc, matrix.names_acc))
covariates_acc_array_12 <- array(as.matrix(covariates_acc_df_list[[6]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[6]], column.names_acc, matrix.names_acc))
covariates_acc_array_13 <- array(as.matrix(covariates_acc_df_list[[7]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[7]], column.names_acc, matrix.names_acc))
covariates_acc_array_15 <- array(as.matrix(covariates_acc_df_list[[8]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[8]], column.names_acc, matrix.names_acc))
covariates_acc_array_17 <- array(as.matrix(covariates_acc_df_list[[9]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[9]], column.names_acc, matrix.names_acc))
covariates_acc_array_19 <- array(as.matrix(covariates_acc_df_list[[10]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[10]], column.names_acc, matrix.names_acc))
covariates_acc_array_21 <- array(as.matrix(covariates_acc_df_list[[11]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[11]], column.names_acc, matrix.names_acc))
covariates_acc_array_23 <- array(as.matrix(covariates_acc_df_list[[12]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[12]], column.names_acc, matrix.names_acc))
covariates_acc_array_24 <- array(as.matrix(covariates_acc_df_list[[13]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[13]], column.names_acc, matrix.names_acc))
covariates_acc_array_25 <- array(as.matrix(covariates_acc_df_list[[14]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[14]], column.names_acc, matrix.names_acc))
covariates_acc_array_26 <- array(as.matrix(covariates_acc_df_list[[15]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[15]], column.names_acc, matrix.names_acc))
covariates_acc_array_28 <- array(as.matrix(covariates_acc_df_list[[16]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[16]], column.names_acc, matrix.names_acc))
covariates_acc_array_29 <- array(as.matrix(covariates_acc_df_list[[17]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[17]], column.names_acc, matrix.names_acc))
covariates_acc_array_30 <- array(as.matrix(covariates_acc_df_list[[18]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[18]], column.names_acc, matrix.names_acc))
covariates_acc_array_31 <- array(as.matrix(covariates_acc_df_list[[19]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[19]], column.names_acc, matrix.names_acc))
covariates_acc_array_32 <- array(as.matrix(covariates_acc_df_list[[20]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[20]], column.names_acc, matrix.names_acc))
covariates_acc_array_33 <- array(as.matrix(covariates_acc_df_list[[21]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[21]], column.names_acc, matrix.names_acc))
covariates_acc_array_34 <- array(as.matrix(covariates_acc_df_list[[22]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[22]], column.names_acc, matrix.names_acc))
covariates_acc_array_36 <- array(as.matrix(covariates_acc_df_list[[23]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[23]], column.names_acc, matrix.names_acc))
covariates_acc_array_37 <- array(as.matrix(covariates_acc_df_list[[24]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[24]], column.names_acc, matrix.names_acc))
covariates_acc_array_39 <- array(as.matrix(covariates_acc_df_list[[25]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[25]], column.names_acc, matrix.names_acc))
covariates_acc_array_40 <- array(as.matrix(covariates_acc_df_list[[26]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[26]], column.names_acc, matrix.names_acc))
covariates_acc_array_41 <- array(as.matrix(covariates_acc_df_list[[27]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[27]], column.names_acc, matrix.names_acc))
covariates_acc_array_44 <- array(as.matrix(covariates_acc_df_list[[28]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[28]], column.names_acc, matrix.names_acc))
covariates_acc_array_45 <- array(as.matrix(covariates_acc_df_list[[29]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[29]], column.names_acc, matrix.names_acc))
covariates_acc_array_47 <- array(as.matrix(covariates_acc_df_list[[30]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[30]], column.names_acc, matrix.names_acc))
covariates_acc_array_50 <- array(as.matrix(covariates_acc_df_list[[31]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[31]], column.names_acc, matrix.names_acc))
covariates_acc_array_51 <- array(as.matrix(covariates_acc_df_list[[32]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[32]], column.names_acc, matrix.names_acc))
covariates_acc_array_53 <- array(as.matrix(covariates_acc_df_list[[33]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[33]], column.names_acc, matrix.names_acc))
covariates_acc_array_54 <- array(as.matrix(covariates_acc_df_list[[34]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[34]], column.names_acc, matrix.names_acc))
covariates_acc_array_55 <- array(as.matrix(covariates_acc_df_list[[35]][,4:15]), dim = c(35,24,12), dimnames = list(row.names_acc_list[[35]], column.names_acc, matrix.names_acc))


########## Pennsylvania ##########
