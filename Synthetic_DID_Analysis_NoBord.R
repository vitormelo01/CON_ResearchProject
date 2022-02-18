########################## Synthetic DID Analysis - Not Including Bordering Counties #############################

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
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_pa_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Pennsylvania")
covariates_pa_exp_df <- covariates_pa_exp_df[order(covariates_pa_exp_df$year, covariates_pa_exp_df$treated_pa_aux, covariates_pa_exp_df$name),]
covariates_pa_exp_df <- as.data.frame(subset(covariates_pa_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_pa_exp_df$income_pcp_adj <- covariates_pa_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_exp_df$unemp_rate <- covariates_pa_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_exp_df$top1_adj <- covariates_pa_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_pa <- c(1980:2014)
row.names_exp_pa <- c(covariates_pa_exp_df[1:25,1])
matrix.names_exp_pa <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_pa_array <- array(as.matrix(covariates_pa_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_pa, column.names_exp_pa, matrix.names_exp_pa))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_pa_aux <- ifelse(CON_NursingHome$name == "Pennsylvania", 1, 0)
CON_NursingHome$border_state <- ifelse(CON_NursingHome$name == "New York" | CON_NursingHome$name == "New Jersey" | CON_NursingHome$name == "Delaware" | CON_NursingHome$name == "Maryland" | CON_NursingHome$name == "West Virginia" | CON_NursingHome$name == "Ohio" | CON_NursingHome$name == "Michigan" | CON_NursingHome$name == "Illinois" | CON_NursingHome$name == "Kentucky" | CON_NursingHome$name == "Montana" | CON_NursingHome$name == "South Dakota" | CON_NursingHome$name == "Minnesota", 1, 0)
covariates_pa_acc_df <- subset(CON_NursingHome, (alwaysconpa == 1 & border_state == 0) | name == "Pennsylvania")
covariates_pa_acc_df <- covariates_pa_acc_df[order(covariates_pa_acc_df$year, covariates_pa_acc_df$treated_pa_aux, covariates_pa_acc_df$name),]
covariates_pa_acc_df <- as.data.frame(subset(covariates_pa_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_pa_acc_df$income_pcp_adj <- covariates_pa_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_acc_df$unemp_rate <- covariates_pa_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_pa_acc_df$top1_adj <- covariates_pa_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_pa <- c(1991:2014)
row.names_acc_pa <- c(covariates_pa_acc_df[1:26,1])
matrix.names_acc_pa <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_pa_array <- array(as.matrix(covariates_pa_acc_df[,3:14]), dim = c(26,24,12), dimnames = list(row.names_acc_pa, column.names_acc_pa, matrix.names_acc_pa))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Pennsylvania" & CON_NursingHome$year >= 1996, 1, 0))
q_nursing_homes_pa_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_pa_df$border_state <- ifelse(q_nursing_homes_pa_df$name == "New York" | q_nursing_homes_pa_df$name == "New Jersey" | q_nursing_homes_pa_df$name == "Delaware" | q_nursing_homes_pa_df$name == "Maryland" | q_nursing_homes_pa_df$name == "West Virginia" | q_nursing_homes_pa_df$name == "Ohio" | q_nursing_homes_pa_df$name == "Michigan" | q_nursing_homes_pa_df$name == "Illinois" | q_nursing_homes_pa_df$name == "Kentucky" | q_nursing_homes_pa_df$name == "Montana" | q_nursing_homes_pa_df$name == "South Dakota" | q_nursing_homes_pa_df$name == "Minnesota", 1, 0)
q_nursing_homes_pa_df <- q_nursing_homes_pa_df[order(q_nursing_homes_pa_df$year, q_nursing_homes_pa_df$treated_pa_aux, q_nursing_homes_pa_df$name),]
q_nursing_homes_pa_df <- subset(q_nursing_homes_pa_df, (alwaysconpa == 1 & border_state == 0) | name == "Pennsylvania", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
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
print(q_nursing_homes_pa_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_estimates_PA.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_plots_PA.pdf')
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
q_nursing_home_beds_pa_df$border_state <- ifelse(q_nursing_home_beds_pa_df$name == "New York" | q_nursing_home_beds_pa_df$name == "New Jersey" | q_nursing_home_beds_pa_df$name == "Delaware" | q_nursing_home_beds_pa_df$name == "Maryland" | q_nursing_home_beds_pa_df$name == "West Virginia" | q_nursing_home_beds_pa_df$name == "Ohio" | q_nursing_home_beds_pa_df$name == "Michigan" | q_nursing_home_beds_pa_df$name == "Illinois" | q_nursing_home_beds_pa_df$name == "Kentucky" | q_nursing_home_beds_pa_df$name == "Montana" | q_nursing_home_beds_pa_df$name == "South Dakota" | q_nursing_home_beds_pa_df$name == "Minnesota", 1, 0)
q_nursing_home_beds_pa_df <- subset(q_nursing_home_beds_pa_df, (alwaysconpa == 1 & border_state == 0) | name == "Pennsylvania", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
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
print(q_nursing_home_beds_pa_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_estimates_PA.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_plots_PA.pdf')
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
total_exp_pa_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_pa_df <- total_exp_pa_df[order(total_exp_pa_df$year, total_exp_pa_df$treated_pa_aux, total_exp_pa_df$name),]
total_exp_pa_df$border_state <- ifelse(total_exp_pa_df$name == "New York" | total_exp_pa_df$name == "New Jersey" | total_exp_pa_df$name == "Delaware" | total_exp_pa_df$name == "Maryland" | total_exp_pa_df$name == "West Virginia" | total_exp_pa_df$name == "Ohio" | total_exp_pa_df$name == "Michigan" | total_exp_pa_df$name == "Illinois" | total_exp_pa_df$name == "Kentucky" | total_exp_pa_df$name == "Montana" | total_exp_pa_df$name == "South Dakota" | total_exp_pa_df$name == "Minnesota", 1, 0)
total_exp_pa_df <- subset(total_exp_pa_df, (alwaysconpa == 1 & border_state == 0) | name == "Pennsylvania", select=c(name, year, total_exp, treated))
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
print(total_exp_pa_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_estimates_PA.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_plots_PA.pdf')
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
medicaid_exp_pa_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_pa_df <- medicaid_exp_pa_df[order(medicaid_exp_pa_df$year, medicaid_exp_pa_df$treated_pa_aux, medicaid_exp_pa_df$name),]
medicaid_exp_pa_df$border_state <- ifelse(medicaid_exp_pa_df$name == "New York" | medicaid_exp_pa_df$name == "New Jersey" | medicaid_exp_pa_df$name == "Delaware" | medicaid_exp_pa_df$name == "Maryland" | medicaid_exp_pa_df$name == "West Virginia" | medicaid_exp_pa_df$name == "Ohio" | medicaid_exp_pa_df$name == "Michigan" | medicaid_exp_pa_df$name == "Illinois" | medicaid_exp_pa_df$name == "Kentucky" | medicaid_exp_pa_df$name == "Montana" | medicaid_exp_pa_df$name == "South Dakota" | medicaid_exp_pa_df$name == "Minnesota", 1, 0)
medicaid_exp_pa_df <- subset(medicaid_exp_pa_df, (alwaysconpa == 1 & border_state == 0) | name == "Pennsylvania", select=c(name, year, medicaid_exp, treated))
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
print(medicaid_exp_pa_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_estimates_PA.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_plots_PA.pdf')
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
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_in_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Indiana")
covariates_in_exp_df <- covariates_in_exp_df[order(covariates_in_exp_df$year, covariates_in_exp_df$treated_in_aux, covariates_in_exp_df$name),]
covariates_in_exp_df <- as.data.frame(subset(covariates_in_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_in_exp_df$income_pcp_adj <- covariates_in_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_exp_df$unemp_rate <- covariates_in_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_exp_df$top1_adj <- covariates_in_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_in <- c(1980:2014)
row.names_exp_in <- c(covariates_in_exp_df[1:25,1])
matrix.names_exp_in <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_in_array <- array(as.matrix(covariates_in_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_in, column.names_exp_in, matrix.names_exp_in))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_in_aux <- ifelse(CON_NursingHome$name == "Indiana", 1, 0)
CON_NursingHome$border_state <- ifelse(CON_NursingHome$name == "New York" | CON_NursingHome$name == "New Jersey" | CON_NursingHome$name == "Delaware" | CON_NursingHome$name == "Maryland" | CON_NursingHome$name == "West Virginia" | CON_NursingHome$name == "Ohio" | CON_NursingHome$name == "Michigan" | CON_NursingHome$name == "Illinois" | CON_NursingHome$name == "Kentucky" | CON_NursingHome$name == "Montana" | CON_NursingHome$name == "South Dakota" | CON_NursingHome$name == "Minnesota", 1, 0)
covariates_in_acc_df <- subset(CON_NursingHome, (alwaysconpa == 1 & border_state == 0) | name == "Indiana")
covariates_in_acc_df <- covariates_in_acc_df[order(covariates_in_acc_df$year, covariates_in_acc_df$treated_in_aux, covariates_in_acc_df$name),]
covariates_in_acc_df <- as.data.frame(subset(covariates_in_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_in_acc_df$income_pcp_adj <- covariates_in_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_acc_df$unemp_rate <- covariates_in_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_in_acc_df$top1_adj <- covariates_in_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_in <- c(1991:2014)
row.names_acc_in <- c(covariates_in_acc_df[1:26,1])
matrix.names_acc_in <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_in_array <- array(as.matrix(covariates_in_acc_df[,3:14]), dim = c(26,24,12), dimnames = list(row.names_acc_in, column.names_acc_in, matrix.names_acc_in))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "Indiana" & CON_NursingHome$year >= 1999, 1, 0))
q_nursing_homes_in_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_in_df$border_state <- ifelse(q_nursing_homes_in_df$name == "New York" | q_nursing_homes_in_df$name == "New Jersey" | q_nursing_homes_in_df$name == "Delaware" | q_nursing_homes_in_df$name == "Maryland" | q_nursing_homes_in_df$name == "West Virginia" | q_nursing_homes_in_df$name == "Ohio" | q_nursing_homes_in_df$name == "Michigan" | q_nursing_homes_in_df$name == "Illinois" | q_nursing_homes_in_df$name == "Kentucky" | q_nursing_homes_in_df$name == "Montana" | q_nursing_homes_in_df$name == "South Dakota" | q_nursing_homes_in_df$name == "Minnesota", 1, 0)
q_nursing_homes_in_df <- q_nursing_homes_in_df[order(q_nursing_homes_in_df$year, q_nursing_homes_in_df$treated_in_aux, q_nursing_homes_in_df$name),]
q_nursing_homes_in_df <- subset(q_nursing_homes_in_df, (alwaysconpa == 1 & border_state == 0) | name == "Indiana", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
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
print(q_nursing_homes_in_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_plots_IN.pdf')
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
q_nursing_home_beds_in_df$border_state <- ifelse(q_nursing_home_beds_in_df$name == "New York" | q_nursing_home_beds_in_df$name == "New Jersey" | q_nursing_home_beds_in_df$name == "Delaware" | q_nursing_home_beds_in_df$name == "Maryland" | q_nursing_home_beds_in_df$name == "West Virginia" | q_nursing_home_beds_in_df$name == "Ohio" | q_nursing_home_beds_in_df$name == "Michigan" | q_nursing_home_beds_in_df$name == "Illinois" | q_nursing_home_beds_in_df$name == "Kentucky" | q_nursing_home_beds_in_df$name == "Montana" | q_nursing_home_beds_in_df$name == "South Dakota" | q_nursing_home_beds_in_df$name == "Minnesota", 1, 0)
q_nursing_home_beds_in_df <- subset(q_nursing_home_beds_in_df, (alwaysconpa == 1 & border_state == 0) | name == "Indiana", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
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
print(q_nursing_home_beds_in_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_plots_IN.pdf')
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
total_exp_in_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_in_df <- total_exp_in_df[order(total_exp_in_df$year, total_exp_in_df$treated_in_aux, total_exp_in_df$name),]
total_exp_in_df$border_state <- ifelse(total_exp_in_df$name == "New York" | total_exp_in_df$name == "New Jersey" | total_exp_in_df$name == "Delaware" | total_exp_in_df$name == "Maryland" | total_exp_in_df$name == "West Virginia" | total_exp_in_df$name == "Ohio" | total_exp_in_df$name == "Michigan" | total_exp_in_df$name == "Illinois" | total_exp_in_df$name == "Kentucky" | total_exp_in_df$name == "Montana" | total_exp_in_df$name == "South Dakota" | total_exp_in_df$name == "Minnesota", 1, 0)
total_exp_in_df <- subset(total_exp_in_df, (alwaysconpa == 1 & border_state == 0) | name == "Indiana", select=c(name, year, total_exp, treated))
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
print(total_exp_in_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_plots_IN.pdf')
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
medicaid_exp_in_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_in_df <- medicaid_exp_in_df[order(medicaid_exp_in_df$year, medicaid_exp_in_df$treated_in_aux, medicaid_exp_in_df$name),]
medicaid_exp_in_df$border_state <- ifelse(medicaid_exp_in_df$name == "New York" | medicaid_exp_in_df$name == "New Jersey" | medicaid_exp_in_df$name == "Delaware" | medicaid_exp_in_df$name == "Maryland" | medicaid_exp_in_df$name == "West Virginia" | medicaid_exp_in_df$name == "Ohio" | medicaid_exp_in_df$name == "Michigan" | medicaid_exp_in_df$name == "Illinois" | medicaid_exp_in_df$name == "Kentucky" | medicaid_exp_in_df$name == "Montana" | medicaid_exp_in_df$name == "South Dakota" | medicaid_exp_in_df$name == "Minnesota", 1, 0)
medicaid_exp_in_df <- subset(medicaid_exp_in_df, (alwaysconpa == 1 & border_state == 0) | name == "Indiana", select=c(name, year, medicaid_exp, treated))
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
print(medicaid_exp_in_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_estimates_IN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_plots_IN.pdf')
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
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_nd_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "North Dakota")
covariates_nd_exp_df <- covariates_nd_exp_df[order(covariates_nd_exp_df$year, covariates_nd_exp_df$treated_nd_aux, covariates_nd_exp_df$name),]
covariates_nd_exp_df <- as.data.frame(subset(covariates_nd_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_nd_exp_df$income_pcp_adj <- covariates_nd_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_exp_df$unemp_rate <- covariates_nd_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_exp_df$top1_adj <- covariates_nd_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_nd <- c(1980:2014)
row.names_exp_nd <- c(covariates_nd_exp_df[1:25,1])
matrix.names_exp_nd <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_nd_array <- array(as.matrix(covariates_nd_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_nd, column.names_exp_nd, matrix.names_exp_nd))

##### Create 3D array of time-varying covariates for synthetic matching - CON_NursingHome #####
CON_NursingHome$treated_nd_aux <- ifelse(CON_NursingHome$name == "North Dakota", 1, 0)
CON_NursingHome$border_state <- ifelse(CON_NursingHome$name == "New York" | CON_NursingHome$name == "New Jersey" | CON_NursingHome$name == "Delaware" | CON_NursingHome$name == "Maryland" | CON_NursingHome$name == "West Virginia" | CON_NursingHome$name == "Ohio" | CON_NursingHome$name == "Michigan" | CON_NursingHome$name == "Illinois" | CON_NursingHome$name == "Kentucky" | CON_NursingHome$name == "Montana" | CON_NursingHome$name == "South Dakota" | CON_NursingHome$name == "Minnesota", 1, 0)
covariates_nd_acc_df <- subset(CON_NursingHome, (alwaysconpa == 1 & border_state == 0) | name == "North Dakota")
covariates_nd_acc_df <- covariates_nd_acc_df[order(covariates_nd_acc_df$year, covariates_nd_acc_df$treated_nd_aux, covariates_nd_acc_df$name),]
covariates_nd_acc_df <- as.data.frame(subset(covariates_nd_acc_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_nd_acc_df$income_pcp_adj <- covariates_nd_acc_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_acc_df$unemp_rate <- covariates_nd_acc_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nd_acc_df$top1_adj <- covariates_nd_acc_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_acc_nd <- c(1991:2014)
row.names_acc_nd <- c(covariates_nd_acc_df[1:26,1])
matrix.names_acc_nd <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_acc_nd_array <- array(as.matrix(covariates_nd_acc_df[,3:14]), dim = c(26,24,12), dimnames = list(row.names_acc_nd, column.names_acc_nd, matrix.names_acc_nd))


##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Quantity of Nursing Homes ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
CON_NursingHome$treated <- as.integer(ifelse(CON_NursingHome$name == "North Dakota" & CON_NursingHome$year >= 1995, 1, 0))
q_nursing_homes_nd_df <- as.data.frame(subset(CON_NursingHome, code == 10))
q_nursing_homes_nd_df$border_state <- ifelse(q_nursing_homes_nd_df$name == "New York" | q_nursing_homes_nd_df$name == "New Jersey" | q_nursing_homes_nd_df$name == "Delaware" | q_nursing_homes_nd_df$name == "Maryland" | q_nursing_homes_nd_df$name == "West Virginia" | q_nursing_homes_nd_df$name == "Ohio" | q_nursing_homes_nd_df$name == "Michigan" | q_nursing_homes_nd_df$name == "Illinois" | q_nursing_homes_nd_df$name == "Kentucky" | q_nursing_homes_nd_df$name == "Montana" | q_nursing_homes_nd_df$name == "South Dakota" | q_nursing_homes_nd_df$name == "Minnesota", 1, 0)
q_nursing_homes_nd_df <- q_nursing_homes_nd_df[order(q_nursing_homes_nd_df$year, q_nursing_homes_nd_df$treated_nd_aux, q_nursing_homes_nd_df$name),]
q_nursing_homes_nd_df <- subset(q_nursing_homes_nd_df, (alwaysconpa == 1 & border_state == 0) | name == "North Dakota", select=c(name, year, Q_SkilledNursingHomes_pcp, treated))
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
print(q_nursing_homes_nd_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_homes_plots_ND.pdf')
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
q_nursing_home_beds_nd_df$border_state <- ifelse(q_nursing_home_beds_nd_df$name == "New York" | q_nursing_home_beds_nd_df$name == "New Jersey" | q_nursing_home_beds_nd_df$name == "Delaware" | q_nursing_home_beds_nd_df$name == "Maryland" | q_nursing_home_beds_nd_df$name == "West Virginia" | q_nursing_home_beds_nd_df$name == "Ohio" | q_nursing_home_beds_nd_df$name == "Michigan" | q_nursing_home_beds_nd_df$name == "Illinois" | q_nursing_home_beds_nd_df$name == "Kentucky" | q_nursing_home_beds_nd_df$name == "Montana" | q_nursing_home_beds_nd_df$name == "South Dakota" | q_nursing_home_beds_nd_df$name == "Minnesota", 1, 0)
q_nursing_home_beds_nd_df <- subset(q_nursing_home_beds_nd_df, (alwaysconpa == 1 & border_state == 0) | name == "North Dakota", select=c(name, year, Q_SkilledNursingHomeBeds_pcp, treated))
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
print(q_nursing_home_beds_nd_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/q_nursing_home_beds_plots_ND.pdf')
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
total_exp_nd_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_nd_df <- total_exp_nd_df[order(total_exp_nd_df$year, total_exp_nd_df$treated_nd_aux, total_exp_nd_df$name),]
total_exp_nd_df$border_state <- ifelse(total_exp_nd_df$name == "New York" | total_exp_nd_df$name == "New Jersey" | total_exp_nd_df$name == "Delaware" | total_exp_nd_df$name == "Maryland" | total_exp_nd_df$name == "West Virginia" | total_exp_nd_df$name == "Ohio" | total_exp_nd_df$name == "Michigan" | total_exp_nd_df$name == "Illinois" | total_exp_nd_df$name == "Kentucky" | total_exp_nd_df$name == "Montana" | total_exp_nd_df$name == "South Dakota" | total_exp_nd_df$name == "Minnesota", 1, 0)
total_exp_nd_df <- subset(total_exp_nd_df, (alwaysconpa == 1 & border_state == 0) | name == "North Dakota", select=c(name, year, total_exp, treated))
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
print(total_exp_nd_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/total_expenditure_plots_ND.pdf')
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
medicaid_exp_nd_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_nd_df <- medicaid_exp_nd_df[order(medicaid_exp_nd_df$year, medicaid_exp_nd_df$treated_nd_aux, medicaid_exp_nd_df$name),]
medicaid_exp_nd_df$border_state <- ifelse(medicaid_exp_nd_df$name == "New York" | medicaid_exp_nd_df$name == "New Jersey" | medicaid_exp_nd_df$name == "Delaware" | medicaid_exp_nd_df$name == "Maryland" | medicaid_exp_nd_df$name == "West Virginia" | medicaid_exp_nd_df$name == "Ohio" | medicaid_exp_nd_df$name == "Michigan" | medicaid_exp_nd_df$name == "Illinois" | medicaid_exp_nd_df$name == "Kentucky" | medicaid_exp_nd_df$name == "Montana" | medicaid_exp_nd_df$name == "South Dakota" | medicaid_exp_nd_df$name == "Minnesota", 1, 0)
medicaid_exp_nd_df <- subset(medicaid_exp_nd_df, (alwaysconpa == 1 & border_state == 0) | name == "North Dakota", select=c(name, year, medicaid_exp, treated))
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
print(medicaid_exp_nd_estimates.latextable, type='latex', file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_estimates_ND.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_NoBord_Figs_and_Tables/medicaid_expenditure_plots_ND.pdf')
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




