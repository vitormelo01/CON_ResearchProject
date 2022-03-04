########################## Synthetic DID Analysis - Bordering States (Not Including Other Bordering States as Controls) #############################

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




########## New York ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_ny_aux <- ifelse(CON_Expenditure$name == "New York", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_ny_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "New York")
covariates_ny_exp_df <- covariates_ny_exp_df[order(covariates_ny_exp_df$year, covariates_ny_exp_df$treated_ny_aux, covariates_ny_exp_df$name),]
covariates_ny_exp_df <- as.data.frame(subset(covariates_ny_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_ny_exp_df$income_pcp_adj <- covariates_ny_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_ny_exp_df$unemp_rate <- covariates_ny_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_ny_exp_df$top1_adj <- covariates_ny_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_ny <- c(1980:2014)
row.names_exp_ny <- c(covariates_ny_exp_df[1:25,1])
matrix.names_exp_ny <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_ny_array <- array(as.matrix(covariates_ny_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_ny, column.names_exp_ny, matrix.names_exp_ny))

##### DID, SC, and SDID Estimates, SEs, and 95% CIs; Parallel Trends Plots; Control Unit Contribution Plots #####
### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_ny_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_ny_df $treated <- as.integer(ifelse(total_exp_ny_df $name == "New York" & total_exp_ny_df $year >= 1996, 1, 0))
total_exp_ny_df <- total_exp_ny_df[order(total_exp_ny_df$year, total_exp_ny_df$treated_ny_aux, total_exp_ny_df$name),]
total_exp_ny_df$border_state <- ifelse(total_exp_ny_df$name == "New Jersey" | total_exp_ny_df$name == "Delaware" | total_exp_ny_df$name == "Maryland" | total_exp_ny_df$name == "West Virginia" | total_exp_ny_df$name == "Ohio" | total_exp_ny_df$name == "Michigan" | total_exp_ny_df$name == "Illinois" | total_exp_ny_df$name == "Kentucky" | total_exp_ny_df$name == "Montana" | total_exp_ny_df$name == "South Dakota" | total_exp_ny_df$name == "Minnesota", 1, 0)
total_exp_ny_df <- subset(total_exp_ny_df, (alwaysconpa == 1 & border_state == 0) | name == "New York", select=c(name, year, total_exp, treated))
setup_total_exp_ny <- panel.matrices(total_exp_ny_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_ny_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_ny$Y, setup_total_exp_ny$N0, setup_total_exp_ny$T0, X = covariates_exp_ny_array)
})
names(total_exp_ny_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_ny_estimates_rounded <- rbind(unlist(total_exp_ny_estimates))
total_exp_ny_estimates_rounded <- lapply(total_exp_ny_estimates,round,2)
total_exp_ny_se <- lapply(total_exp_ny_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_ny_se_rounded <- lapply(total_exp_ny_se,round,2)
total_exp_ny_ci <- foreach(i = total_exp_ny_estimates, j = total_exp_ny_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_ny_estimates.table <- rbind(unlist(total_exp_ny_estimates_rounded), unlist(total_exp_ny_se_rounded), unlist(total_exp_ny_ci))
rownames(total_exp_ny_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_ny_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_ny_estimates.table
total_exp_ny_estimates.latextable <- xtable(total_exp_ny_estimates.table, align = "lccc", caption = 'Total Expenditure - NY')
print(total_exp_ny_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_NY.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_NY.pdf')
total_expenditure_plots_NY <- synthdid_plot(total_exp_ny_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='New York',
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
total_expenditure_control_plots_NY <- synthdid_units_plot(total_exp_ny_estimates, se.method='none') + 
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
total_expenditure_plots_NY + total_expenditure_control_plots_NY + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_ny_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_ny_df$treated <- as.integer(ifelse(medicaid_exp_ny_df$name == "New York" & medicaid_exp_ny_df$year >= 1996, 1, 0))
medicaid_exp_ny_df <- medicaid_exp_ny_df[order(medicaid_exp_ny_df$year, medicaid_exp_ny_df$treated_ny_aux, medicaid_exp_ny_df$name),]
medicaid_exp_ny_df$border_state <- ifelse(medicaid_exp_ny_df$name == "New Jersey" | medicaid_exp_ny_df$name == "Delaware" | medicaid_exp_ny_df$name == "Maryland" | medicaid_exp_ny_df$name == "West Virginia" | medicaid_exp_ny_df$name == "Ohio" | medicaid_exp_ny_df$name == "Michigan" | medicaid_exp_ny_df$name == "Illinois" | medicaid_exp_ny_df$name == "Kentucky" | medicaid_exp_ny_df$name == "Montana" | medicaid_exp_ny_df$name == "South Dakota" | medicaid_exp_ny_df$name == "Minnesota", 1, 0)
medicaid_exp_ny_df <- subset(medicaid_exp_ny_df, (alwaysconpa == 1 & border_state == 0) | name == "New York", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_ny <- panel.matrices(medicaid_exp_ny_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_ny_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_ny$Y, setup_medicaid_exp_ny$N0, setup_medicaid_exp_ny$T0, X = covariates_exp_ny_array)
})
names(medicaid_exp_ny_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_ny_estimates_rounded <- rbind(unlist(medicaid_exp_ny_estimates))
medicaid_exp_ny_estimates_rounded <- lapply(medicaid_exp_ny_estimates,round,2)
medicaid_exp_ny_se <- lapply(medicaid_exp_ny_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_ny_se_rounded <- lapply(medicaid_exp_ny_se,round,2)
medicaid_exp_ny_ci <- foreach(i = medicaid_exp_ny_estimates, j = medicaid_exp_ny_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_ny_estimates.table <- rbind(unlist(medicaid_exp_ny_estimates_rounded), unlist(medicaid_exp_ny_se_rounded), unlist(medicaid_exp_ny_ci))
rownames(medicaid_exp_ny_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_ny_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_ny_estimates.table
medicaid_exp_ny_estimates.latextable <- xtable(medicaid_exp_ny_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - NY')
print(medicaid_exp_ny_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_NY.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_NY.pdf')
medicaid_expenditure_plots_NY <- synthdid_plot(medicaid_exp_ny_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='New York',
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
medicaid_expenditure_control_plots_NY <- synthdid_units_plot(medicaid_exp_ny_estimates, se.method='none') + 
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
medicaid_expenditure_plots_NY + medicaid_expenditure_control_plots_NY + plot_layout(ncol=1)
dev.off()




########## New Jersey ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_nj_aux <- ifelse(CON_Expenditure$name == "New Jersey", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_nj_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "New Jersey")
covariates_nj_exp_df <- covariates_nj_exp_df[order(covariates_nj_exp_df$year, covariates_nj_exp_df$treated_nj_aux, covariates_nj_exp_df$name),]
covariates_nj_exp_df <- as.data.frame(subset(covariates_nj_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_nj_exp_df$income_pcp_adj <- covariates_nj_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nj_exp_df$unemp_rate <- covariates_nj_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_nj_exp_df$top1_adj <- covariates_nj_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_nj <- c(1980:2014)
row.names_exp_nj <- c(covariates_nj_exp_df[1:25,1])
matrix.names_exp_nj <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_nj_array <- array(as.matrix(covariates_nj_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_nj, column.names_exp_nj, matrix.names_exp_nj))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_nj_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_nj_df$treated <- as.integer(ifelse(total_exp_nj_df$name == "New Jersey" & total_exp_nj_df$year >= 1996, 1, 0))
total_exp_nj_df <- total_exp_nj_df[order(total_exp_nj_df$year, total_exp_nj_df$treated_nj_aux, total_exp_nj_df$name),]
total_exp_nj_df$border_state <- ifelse(total_exp_nj_df$name == "New York" | total_exp_nj_df$name == "Delaware" | total_exp_nj_df$name == "Maryland" | total_exp_nj_df$name == "West Virginia" | total_exp_nj_df$name == "Ohio" | total_exp_nj_df$name == "Michigan" | total_exp_nj_df$name == "Illinois" | total_exp_nj_df$name == "Kentucky" | total_exp_nj_df$name == "Montana" | total_exp_nj_df$name == "South Dakota" | total_exp_nj_df$name == "Minnesota", 1, 0)
total_exp_nj_df <- subset(total_exp_nj_df, (alwaysconpa == 1 & border_state == 0) | name == "New Jersey", select=c(name, year, total_exp, treated))
setup_total_exp_nj <- panel.matrices(total_exp_nj_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_nj_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_nj$Y, setup_total_exp_nj$N0, setup_total_exp_nj$T0, X = covariates_exp_nj_array)
})
names(total_exp_nj_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_nj_estimates_rounded <- rbind(unlist(total_exp_nj_estimates))
total_exp_nj_estimates_rounded <- lapply(total_exp_nj_estimates,round,2)
total_exp_nj_se <- lapply(total_exp_nj_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_nj_se_rounded <- lapply(total_exp_nj_se,round,2)
total_exp_nj_ci <- foreach(i = total_exp_nj_estimates, j = total_exp_nj_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_nj_estimates.table <- rbind(unlist(total_exp_nj_estimates_rounded), unlist(total_exp_nj_se_rounded), unlist(total_exp_nj_ci))
rownames(total_exp_nj_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_nj_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_nj_estimates.table
total_exp_nj_estimates.latextable <- xtable(total_exp_nj_estimates.table, align = "lccc", caption = 'Total Expenditure -NJ')
print(total_exp_nj_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_NJ.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_NJ.pdf')
total_expenditure_plots_NJ <- synthdid_plot(total_exp_nj_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='New Jersey',
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
total_expenditure_control_plots_NJ <- synthdid_units_plot(total_exp_nj_estimates, se.method='none') + 
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
total_expenditure_plots_NJ + total_expenditure_control_plots_NJ + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_nj_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_nj_df$treated <- as.integer(ifelse(medicaid_exp_nj_df$name == "New Jersey" & medicaid_exp_nj_df$year >= 1996, 1, 0))
medicaid_exp_nj_df <- medicaid_exp_nj_df[order(medicaid_exp_nj_df$year, medicaid_exp_nj_df$treated_nj_aux, medicaid_exp_nj_df$name),]
medicaid_exp_nj_df$border_state <- ifelse(medicaid_exp_nj_df$name == "New York" | medicaid_exp_nj_df$name == "Delaware" | medicaid_exp_nj_df$name == "Maryland" | medicaid_exp_nj_df$name == "West Virginia" | medicaid_exp_nj_df$name == "Ohio" | medicaid_exp_nj_df$name == "Michigan" | medicaid_exp_nj_df$name == "Illinois" | medicaid_exp_nj_df$name == "Kentucky" | medicaid_exp_nj_df$name == "Montana" | medicaid_exp_nj_df$name == "South Dakota" | medicaid_exp_nj_df$name == "Minnesota", 1, 0)
medicaid_exp_nj_df <- subset(medicaid_exp_nj_df, (alwaysconpa == 1 & border_state == 0) | name == "New Jersey", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_nj <- panel.matrices(medicaid_exp_nj_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_nj_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_nj$Y, setup_medicaid_exp_nj$N0, setup_medicaid_exp_nj$T0, X = covariates_exp_nj_array)
})
names(medicaid_exp_nj_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_nj_estimates_rounded <- rbind(unlist(medicaid_exp_nj_estimates))
medicaid_exp_nj_estimates_rounded <- lapply(medicaid_exp_nj_estimates,round,2)
medicaid_exp_nj_se <- lapply(medicaid_exp_nj_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_nj_se_rounded <- lapply(medicaid_exp_nj_se,round,2)
medicaid_exp_nj_ci <- foreach(i = medicaid_exp_nj_estimates, j = medicaid_exp_nj_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_nj_estimates.table <- rbind(unlist(medicaid_exp_nj_estimates_rounded), unlist(medicaid_exp_nj_se_rounded), unlist(medicaid_exp_nj_ci))
rownames(medicaid_exp_nj_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_nj_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_nj_estimates.table
medicaid_exp_nj_estimates.latextable <- xtable(medicaid_exp_nj_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - NJ')
print(medicaid_exp_nj_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_NJ.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_NJ.pdf')
medicaid_expenditure_plots_NJ <- synthdid_plot(medicaid_exp_nj_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='New Jersey',
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
medicaid_expenditure_control_plots_NJ <- synthdid_units_plot(medicaid_exp_nj_estimates, se.method='none') + 
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
medicaid_expenditure_plots_NJ + medicaid_expenditure_control_plots_NJ + plot_layout(ncol=1)
dev.off()




########## Delaware ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_de_aux <- ifelse(CON_Expenditure$name == "Delaware", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_de_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Delaware")
covariates_de_exp_df <- covariates_de_exp_df[order(covariates_de_exp_df$year, covariates_de_exp_df$treated_de_aux, covariates_de_exp_df$name),]
covariates_de_exp_df <- as.data.frame(subset(covariates_de_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_de_exp_df$income_pcp_adj <- covariates_de_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_de_exp_df$unemp_rate <- covariates_de_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_de_exp_df$top1_adj <- covariates_de_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_de <- c(1980:2014)
row.names_exp_de <- c(covariates_de_exp_df[1:25,1])
matrix.names_exp_de <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_de_array <- array(as.matrix(covariates_de_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_de, column.names_exp_de, matrix.names_exp_de))


### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_de_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_de_df$treated <- as.integer(ifelse(total_exp_de_df$name == "Delaware" & total_exp_de_df$year >= 1996, 1, 0))
total_exp_de_df <- total_exp_de_df[order(total_exp_de_df$year, total_exp_de_df$treated_de_aux, total_exp_de_df$name),]
total_exp_de_df$border_state <- ifelse(total_exp_de_df$name == "New York" | total_exp_de_df$name == "New Jersey" | total_exp_de_df$name == "Maryland" | total_exp_de_df$name == "West Virginia" | total_exp_de_df$name == "Ohio" | total_exp_de_df$name == "Michigan" | total_exp_de_df$name == "Illinois" | total_exp_de_df$name == "Kentucky" | total_exp_de_df$name == "Montana" | total_exp_de_df$name == "South Dakota" | total_exp_de_df$name == "Minnesota", 1, 0)
total_exp_de_df <- subset(total_exp_de_df, (alwaysconpa == 1 & border_state == 0) | name == "Delaware", select=c(name, year, total_exp, treated))
setup_total_exp_de <- panel.matrices(total_exp_de_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_de_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_de$Y, setup_total_exp_de$N0, setup_total_exp_de$T0, X = covariates_exp_de_array)
})
names(total_exp_de_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_de_estimates_rounded <- rbind(unlist(total_exp_de_estimates))
total_exp_de_estimates_rounded <- lapply(total_exp_de_estimates,round,2)
total_exp_de_se <- lapply(total_exp_de_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_de_se_rounded <- lapply(total_exp_de_se,round,2)
total_exp_de_ci <- foreach(i = total_exp_de_estimates, j = total_exp_de_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_de_estimates.table <- rbind(unlist(total_exp_de_estimates_rounded), unlist(total_exp_de_se_rounded), unlist(total_exp_de_ci))
rownames(total_exp_de_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_de_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_de_estimates.table
total_exp_de_estimates.latextable <- xtable(total_exp_de_estimates.table, align = "lccc", caption = 'Total Expenditure - DE')
print(total_exp_de_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_DE.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_DE.pdf')
total_expenditure_plots_DE <- synthdid_plot(total_exp_de_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Delaware',
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
total_expenditure_control_plots_DE <- synthdid_units_plot(total_exp_de_estimates, se.method='none') + 
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
total_expenditure_plots_DE + total_expenditure_control_plots_DE + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_de_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_de_df$treated <- as.integer(ifelse(medicaid_exp_de_df$name == "Delaware" & medicaid_exp_de_df$year >= 1996, 1, 0))
medicaid_exp_de_df <- medicaid_exp_de_df[order(medicaid_exp_de_df$year, medicaid_exp_de_df$treated_de_aux, medicaid_exp_de_df$name),]
medicaid_exp_de_df$border_state <- ifelse(medicaid_exp_de_df$name == "New York" | medicaid_exp_de_df$name == "New Jersey" | medicaid_exp_de_df$name == "Maryland" | medicaid_exp_de_df$name == "West Virginia" | medicaid_exp_de_df$name == "Ohio" | medicaid_exp_de_df$name == "Michigan" | medicaid_exp_de_df$name == "Illinois" | medicaid_exp_de_df$name == "Kentucky" | medicaid_exp_de_df$name == "Montana" | medicaid_exp_de_df$name == "South Dakota" | medicaid_exp_de_df$name == "Minnesota", 1, 0)
medicaid_exp_de_df <- subset(medicaid_exp_de_df, (alwaysconpa == 1 & border_state == 0) | name == "Delaware", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_de <- panel.matrices(medicaid_exp_de_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_de_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_de$Y, setup_medicaid_exp_de$N0, setup_medicaid_exp_de$T0, X = covariates_exp_de_array)
})
names(medicaid_exp_de_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_de_estimates_rounded <- rbind(unlist(medicaid_exp_de_estimates))
medicaid_exp_de_estimates_rounded <- lapply(medicaid_exp_de_estimates,round,2)
medicaid_exp_de_se <- lapply(medicaid_exp_de_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_de_se_rounded <- lapply(medicaid_exp_de_se,round,2)
medicaid_exp_de_ci <- foreach(i = medicaid_exp_de_estimates, j = medicaid_exp_de_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_de_estimates.table <- rbind(unlist(medicaid_exp_de_estimates_rounded), unlist(medicaid_exp_de_se_rounded), unlist(medicaid_exp_de_ci))
rownames(medicaid_exp_de_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_de_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_de_estimates.table
medicaid_exp_de_estimates.latextable <- xtable(medicaid_exp_de_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - DE')
print(medicaid_exp_de_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_DE.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_DE.pdf')
medicaid_expenditure_plots_DE <- synthdid_plot(medicaid_exp_de_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Delaware',
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
medicaid_expenditure_control_plots_DE <- synthdid_units_plot(medicaid_exp_de_estimates, se.method='none') + 
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
medicaid_expenditure_plots_DE + medicaid_expenditure_control_plots_DE + plot_layout(ncol=1)
dev.off()




########## Maryland ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_md_aux <- ifelse(CON_Expenditure$name == "Maryland", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_md_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Maryland")
covariates_md_exp_df <- covariates_md_exp_df[order(covariates_md_exp_df$year, covariates_md_exp_df$treated_md_aux, covariates_md_exp_df$name),]
covariates_md_exp_df <- as.data.frame(subset(covariates_md_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_md_exp_df$income_pcp_adj <- covariates_md_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_md_exp_df$unemp_rate <- covariates_md_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_md_exp_df$top1_adj <- covariates_md_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_md <- c(1980:2014)
row.names_exp_md <- c(covariates_md_exp_df[1:25,1])
matrix.names_exp_md <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_md_array <- array(as.matrix(covariates_md_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_md, column.names_exp_md, matrix.names_exp_md))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_md_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_md_df$treated <- as.integer(ifelse(total_exp_md_df$name == "Maryland" & total_exp_md_df$year >= 1996, 1, 0))
total_exp_md_df <- total_exp_md_df[order(total_exp_md_df$year, total_exp_md_df$treated_md_aux, total_exp_md_df$name),]
total_exp_md_df$border_state <- ifelse(total_exp_md_df$name == "New York" | total_exp_md_df$name == "New Jersey" | total_exp_md_df$name == "Delaware" | total_exp_md_df$name == "West Virginia" | total_exp_md_df$name == "Ohio" | total_exp_md_df$name == "Michigan" | total_exp_md_df$name == "Illinois" | total_exp_md_df$name == "Kentucky" | total_exp_md_df$name == "Montana" | total_exp_md_df$name == "South Dakota" | total_exp_md_df$name == "Minnesota", 1, 0)
total_exp_md_df <- subset(total_exp_md_df, (alwaysconpa == 1 & border_state == 0) | name == "Maryland", select=c(name, year, total_exp, treated))
setup_total_exp_md <- panel.matrices(total_exp_md_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_md_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_md$Y, setup_total_exp_md$N0, setup_total_exp_md$T0, X = covariates_exp_md_array)
})
names(total_exp_md_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_md_estimates_rounded <- rbind(unlist(total_exp_md_estimates))
total_exp_md_estimates_rounded <- lapply(total_exp_md_estimates,round,2)
total_exp_md_se <- lapply(total_exp_md_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_md_se_rounded <- lapply(total_exp_md_se,round,2)
total_exp_md_ci <- foreach(i = total_exp_md_estimates, j = total_exp_md_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_md_estimates.table <- rbind(unlist(total_exp_md_estimates_rounded), unlist(total_exp_md_se_rounded), unlist(total_exp_md_ci))
rownames(total_exp_md_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_md_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_md_estimates.table
total_exp_md_estimates.latextable <- xtable(total_exp_md_estimates.table, align = "lccc", caption = 'Total Expenditure - MD')
print(total_exp_md_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_MD.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_MD.pdf')
total_expenditure_plots_MD <- synthdid_plot(total_exp_md_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Maryland',
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
total_expenditure_control_plots_MD <- synthdid_units_plot(total_exp_md_estimates, se.method='none') + 
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
total_expenditure_plots_MD + total_expenditure_control_plots_MD + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_md_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_md_df$treated <- as.integer(ifelse(medicaid_exp_md_df$name == "Maryland" & medicaid_exp_md_df$year >= 1996, 1, 0))
medicaid_exp_md_df <- medicaid_exp_md_df[order(medicaid_exp_md_df$year, medicaid_exp_md_df$treated_md_aux, medicaid_exp_md_df$name),]
medicaid_exp_md_df$border_state <- ifelse(medicaid_exp_md_df$name == "New York" | medicaid_exp_md_df$name == "New Jersey" | medicaid_exp_md_df$name == "Delaware" | medicaid_exp_md_df$name == "West Virginia" | medicaid_exp_md_df$name == "Ohio" | medicaid_exp_md_df$name == "Michigan" | medicaid_exp_md_df$name == "Illinois" | medicaid_exp_md_df$name == "Kentucky" | medicaid_exp_md_df$name == "Montana" | medicaid_exp_md_df$name == "South Dakota" | medicaid_exp_md_df$name == "Minnesota", 1, 0)
medicaid_exp_md_df <- subset(medicaid_exp_md_df, (alwaysconpa == 1 & border_state == 0) | name == "Maryland", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_md <- panel.matrices(medicaid_exp_md_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_md_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_md$Y, setup_medicaid_exp_md$N0, setup_medicaid_exp_md$T0, X = covariates_exp_md_array)
})
names(medicaid_exp_md_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_md_estimates_rounded <- rbind(unlist(medicaid_exp_md_estimates))
medicaid_exp_md_estimates_rounded <- lapply(medicaid_exp_md_estimates,round,2)
medicaid_exp_md_se <- lapply(medicaid_exp_md_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_md_se_rounded <- lapply(medicaid_exp_md_se,round,2)
medicaid_exp_md_ci <- foreach(i = medicaid_exp_md_estimates, j = medicaid_exp_md_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_md_estimates.table <- rbind(unlist(medicaid_exp_md_estimates_rounded), unlist(medicaid_exp_md_se_rounded), unlist(medicaid_exp_md_ci))
rownames(medicaid_exp_md_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_md_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_md_estimates.table
medicaid_exp_md_estimates.latextable <- xtable(medicaid_exp_md_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - MD')
print(medicaid_exp_md_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_MD.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_MD.pdf')
medicaid_expenditure_plots_MD <- synthdid_plot(medicaid_exp_md_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Maryland',
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
medicaid_expenditure_control_plots_MD <- synthdid_units_plot(medicaid_exp_md_estimates, se.method='none') + 
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
medicaid_expenditure_plots_MD + medicaid_expenditure_control_plots_MD + plot_layout(ncol=1)
dev.off()




########## West Virginia ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_wv_aux <- ifelse(CON_Expenditure$name == "West Virginia", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_wv_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "West Virginia")
covariates_wv_exp_df <- covariates_wv_exp_df[order(covariates_wv_exp_df$year, covariates_wv_exp_df$treated_wv_aux, covariates_wv_exp_df$name),]
covariates_wv_exp_df <- as.data.frame(subset(covariates_wv_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_wv_exp_df$income_pcp_adj <- covariates_wv_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_wv_exp_df$unemp_rate <- covariates_wv_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_wv_exp_df$top1_adj <- covariates_wv_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_wv <- c(1980:2014)
row.names_exp_wv <- c(covariates_wv_exp_df[1:25,1])
matrix.names_exp_wv <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_wv_array <- array(as.matrix(covariates_wv_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_wv, column.names_exp_wv, matrix.names_exp_wv))


### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_wv_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_wv_df$treated <- as.integer(ifelse(total_exp_wv_df$name == "West Virginia" & total_exp_wv_df$year >= 1996, 1, 0))
total_exp_wv_df <- total_exp_wv_df[order(total_exp_wv_df$year, total_exp_wv_df$treated_wv_aux, total_exp_wv_df$name),]
total_exp_wv_df$border_state <- ifelse(total_exp_wv_df$name == "New York" | total_exp_wv_df$name == "New Jersey" | total_exp_wv_df$name == "Delaware" | total_exp_wv_df$name == "Maryland" | total_exp_wv_df$name == "Ohio" | total_exp_wv_df$name == "Michigan" | total_exp_wv_df$name == "Illinois" | total_exp_wv_df$name == "Kentucky" | total_exp_wv_df$name == "Montana" | total_exp_wv_df$name == "South Dakota" | total_exp_wv_df$name == "Minnesota", 1, 0)
total_exp_wv_df <- subset(total_exp_wv_df, (alwaysconpa == 1 & border_state == 0) | name == "West Virginia", select=c(name, year, total_exp, treated))
setup_total_exp_wv <- panel.matrices(total_exp_wv_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_wv_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_wv$Y, setup_total_exp_wv$N0, setup_total_exp_wv$T0, X = covariates_exp_wv_array)
})
names(total_exp_wv_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_wv_estimates_rounded <- rbind(unlist(total_exp_wv_estimates))
total_exp_wv_estimates_rounded <- lapply(total_exp_wv_estimates,round,2)
total_exp_wv_se <- lapply(total_exp_wv_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_wv_se_rounded <- lapply(total_exp_wv_se,round,2)
total_exp_wv_ci <- foreach(i = total_exp_wv_estimates, j = total_exp_wv_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_wv_estimates.table <- rbind(unlist(total_exp_wv_estimates_rounded), unlist(total_exp_wv_se_rounded), unlist(total_exp_wv_ci))
rownames(total_exp_wv_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_wv_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_wv_estimates.table
total_exp_wv_estimates.latextable <- xtable(total_exp_wv_estimates.table, align = "lccc", caption = 'Total Expenditure - WV')
print(total_exp_wv_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_WV.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_WV.pdf')
total_expenditure_plots_WV <- synthdid_plot(total_exp_wv_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='West Virginia',
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
total_expenditure_control_plots_WV <- synthdid_units_plot(total_exp_wv_estimates, se.method='none') + 
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
total_expenditure_plots_WV + total_expenditure_control_plots_WV + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_wv_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_wv_df$treated <- as.integer(ifelse(medicaid_exp_wv_df$name == "West Virginia" & medicaid_exp_wv_df$year >= 1996, 1, 0))
medicaid_exp_wv_df <- medicaid_exp_wv_df[order(medicaid_exp_wv_df$year, medicaid_exp_wv_df$treated_wv_aux, medicaid_exp_wv_df$name),]
medicaid_exp_wv_df$border_state <- ifelse(medicaid_exp_wv_df$name == "New York" | medicaid_exp_wv_df$name == "New Jersey" | medicaid_exp_wv_df$name == "Delaware" | medicaid_exp_wv_df$name == "Maryland" | medicaid_exp_wv_df$name == "Ohio" | medicaid_exp_wv_df$name == "Michigan" | medicaid_exp_wv_df$name == "Illinois" | medicaid_exp_wv_df$name == "Kentucky" | medicaid_exp_wv_df$name == "Montana" | medicaid_exp_wv_df$name == "South Dakota" | medicaid_exp_wv_df$name == "Minnesota", 1, 0)
medicaid_exp_wv_df <- subset(medicaid_exp_wv_df, (alwaysconpa == 1 & border_state == 0) | name == "West Virginia", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_wv <- panel.matrices(medicaid_exp_wv_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_wv_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_wv$Y, setup_medicaid_exp_wv$N0, setup_medicaid_exp_wv$T0, X = covariates_exp_wv_array)
})
names(medicaid_exp_wv_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_wv_estimates_rounded <- rbind(unlist(medicaid_exp_wv_estimates))
medicaid_exp_wv_estimates_rounded <- lapply(medicaid_exp_wv_estimates,round,2)
medicaid_exp_wv_se <- lapply(medicaid_exp_wv_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_wv_se_rounded <- lapply(medicaid_exp_wv_se,round,2)
medicaid_exp_wv_ci <- foreach(i = medicaid_exp_wv_estimates, j = medicaid_exp_wv_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_wv_estimates.table <- rbind(unlist(medicaid_exp_wv_estimates_rounded), unlist(medicaid_exp_wv_se_rounded), unlist(medicaid_exp_wv_ci))
rownames(medicaid_exp_wv_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_wv_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_wv_estimates.table
medicaid_exp_wv_estimates.latextable <- xtable(medicaid_exp_wv_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - WV')
print(medicaid_exp_wv_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_WV.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_WV.pdf')
medicaid_expenditure_plots_WV <- synthdid_plot(medicaid_exp_wv_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='West Virginia',
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
medicaid_expenditure_control_plots_WV <- synthdid_units_plot(medicaid_exp_wv_estimates, se.method='none') + 
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
medicaid_expenditure_plots_WV + medicaid_expenditure_control_plots_WV + plot_layout(ncol=1)
dev.off()




########## Ohio ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_oh_aux <- ifelse(CON_Expenditure$name == "Ohio", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_oh_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Ohio")
covariates_oh_exp_df <- covariates_oh_exp_df[order(covariates_oh_exp_df$year, covariates_oh_exp_df$treated_oh_aux, covariates_oh_exp_df$name),]
covariates_oh_exp_df <- as.data.frame(subset(covariates_oh_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_oh_exp_df$income_pcp_adj <- covariates_oh_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_oh_exp_df$unemp_rate <- covariates_oh_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_oh_exp_df$top1_adj <- covariates_oh_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_oh <- c(1980:2014)
row.names_exp_oh <- c(covariates_oh_exp_df[1:25,1])
matrix.names_exp_oh <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_oh_array <- array(as.matrix(covariates_oh_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_oh, column.names_exp_oh, matrix.names_exp_oh))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_oh_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_oh_df$treated <- as.integer(ifelse(total_exp_oh_df$name == "Ohio" & total_exp_oh_df$year >= 1996, 1, 0))
total_exp_oh_df <- total_exp_oh_df[order(total_exp_oh_df$year, total_exp_oh_df$treated_oh_aux, total_exp_oh_df$name),]
total_exp_oh_df$border_state <- ifelse(total_exp_oh_df$name == "New York" | total_exp_oh_df$name == "New Jersey" | total_exp_oh_df$name == "Delaware" | total_exp_oh_df$name == "Maryland" | total_exp_oh_df$name == "West Virginia" | total_exp_oh_df$name == "Michigan" | total_exp_oh_df$name == "Illinois" | total_exp_oh_df$name == "Kentucky" | total_exp_oh_df$name == "Montana" | total_exp_oh_df$name == "South Dakota" | total_exp_oh_df$name == "Minnesota", 1, 0)
total_exp_oh_df <- subset(total_exp_oh_df, (alwaysconpa == 1 & border_state == 0) | name == "Ohio", select=c(name, year, total_exp, treated))
setup_total_exp_oh <- panel.matrices(total_exp_oh_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_oh_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_oh$Y, setup_total_exp_oh$N0, setup_total_exp_oh$T0, X = covariates_exp_oh_array)
})
names(total_exp_oh_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_oh_estimates_rounded <- rbind(unlist(total_exp_oh_estimates))
total_exp_oh_estimates_rounded <- lapply(total_exp_oh_estimates,round,2)
total_exp_oh_se <- lapply(total_exp_oh_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_oh_se_rounded <- lapply(total_exp_oh_se,round,2)
total_exp_oh_ci <- foreach(i = total_exp_oh_estimates, j = total_exp_oh_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_oh_estimates.table <- rbind(unlist(total_exp_oh_estimates_rounded), unlist(total_exp_oh_se_rounded), unlist(total_exp_oh_ci))
rownames(total_exp_oh_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_oh_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_oh_estimates.table
total_exp_oh_estimates.latextable <- xtable(total_exp_oh_estimates.table, align = "lccc", caption = 'Total Expenditure - OH')
print(total_exp_oh_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_OH.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_OH.pdf')
total_expenditure_plots_OH <- synthdid_plot(total_exp_oh_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Ohio',
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
total_expenditure_control_plots_OH <- synthdid_units_plot(total_exp_oh_estimates, se.method='none') + 
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
total_expenditure_plots_OH + total_expenditure_control_plots_OH + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_oh_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_oh_df$treated <- as.integer(ifelse(medicaid_exp_oh_df$name == "Ohio" & medicaid_exp_oh_df$year >= 1996, 1, 0))
medicaid_exp_oh_df <- medicaid_exp_oh_df[order(medicaid_exp_oh_df$year, medicaid_exp_oh_df$treated_oh_aux, medicaid_exp_oh_df$name),]
medicaid_exp_oh_df$border_state <- ifelse(medicaid_exp_oh_df$name == "New York" | medicaid_exp_oh_df$name == "New Jersey" | medicaid_exp_oh_df$name == "Delaware" | medicaid_exp_oh_df$name == "Maryland" | medicaid_exp_oh_df$name == "West Virginia" | medicaid_exp_oh_df$name == "Michigan" | medicaid_exp_oh_df$name == "Illinois" | medicaid_exp_oh_df$name == "Kentucky" | medicaid_exp_oh_df$name == "Montana" | medicaid_exp_oh_df$name == "South Dakota" | medicaid_exp_oh_df$name == "Minnesota", 1, 0)
medicaid_exp_oh_df <- subset(medicaid_exp_oh_df, (alwaysconpa == 1 & border_state == 0) | name == "Ohio", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_oh <- panel.matrices(medicaid_exp_oh_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_oh_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_oh$Y, setup_medicaid_exp_oh$N0, setup_medicaid_exp_oh$T0, X = covariates_exp_oh_array)
})
names(medicaid_exp_oh_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_oh_estimates_rounded <- rbind(unlist(medicaid_exp_oh_estimates))
medicaid_exp_oh_estimates_rounded <- lapply(medicaid_exp_oh_estimates,round,2)
medicaid_exp_oh_se <- lapply(medicaid_exp_oh_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_oh_se_rounded <- lapply(medicaid_exp_oh_se,round,2)
medicaid_exp_oh_ci <- foreach(i = medicaid_exp_oh_estimates, j = medicaid_exp_oh_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_oh_estimates.table <- rbind(unlist(medicaid_exp_oh_estimates_rounded), unlist(medicaid_exp_oh_se_rounded), unlist(medicaid_exp_oh_ci))
rownames(medicaid_exp_oh_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_oh_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_oh_estimates.table
medicaid_exp_oh_estimates.latextable <- xtable(medicaid_exp_oh_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - OH')
print(medicaid_exp_oh_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_OH.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_OH.pdf')
medicaid_expenditure_plots_OH <- synthdid_plot(medicaid_exp_oh_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Ohio',
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
medicaid_expenditure_control_plots_OH <- synthdid_units_plot(medicaid_exp_oh_estimates, se.method='none') + 
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
medicaid_expenditure_plots_OH + medicaid_expenditure_control_plots_OH + plot_layout(ncol=1)
dev.off()




########## Michigan ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_mi_aux <- ifelse(CON_Expenditure$name == "Michigan", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_mi_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Michigan")
covariates_mi_exp_df <- covariates_mi_exp_df[order(covariates_mi_exp_df$year, covariates_mi_exp_df$treated_mi_aux, covariates_mi_exp_df$name),]
covariates_mi_exp_df <- as.data.frame(subset(covariates_mi_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_mi_exp_df$income_pcp_adj <- covariates_mi_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mi_exp_df$unemp_rate <- covariates_mi_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mi_exp_df$top1_adj <- covariates_mi_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_mi <- c(1980:2014)
row.names_exp_mi <- c(covariates_mi_exp_df[1:25,1])
matrix.names_exp_mi <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_mi_array <- array(as.matrix(covariates_mi_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_mi, column.names_exp_mi, matrix.names_exp_mi))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_mi_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_mi_df$treated <- as.integer(ifelse(total_exp_mi_df$name == "Michigan" & total_exp_mi_df$year >= 1999, 1, 0))
total_exp_mi_df <- total_exp_mi_df[order(total_exp_mi_df$year, total_exp_mi_df$treated_mi_aux, total_exp_mi_df$name),]
total_exp_mi_df$border_state <- ifelse(total_exp_mi_df$name == "New York" | total_exp_mi_df$name == "New Jersey" | total_exp_mi_df$name == "Delaware" | total_exp_mi_df$name == "Maryland" | total_exp_mi_df$name == "West Virginia" | total_exp_mi_df$name == "Ohio" | total_exp_mi_df$name == "Illinois" | total_exp_mi_df$name == "Kentucky" | total_exp_mi_df$name == "Montana" | total_exp_mi_df$name == "South Dakota" | total_exp_mi_df$name == "Minnesota", 1, 0)
total_exp_mi_df <- subset(total_exp_mi_df, (alwaysconpa == 1 & border_state == 0) | name == "Michigan", select=c(name, year, total_exp, treated))
setup_total_exp_mi <- panel.matrices(total_exp_mi_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_mi_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_mi$Y, setup_total_exp_mi$N0, setup_total_exp_mi$T0, X = covariates_exp_mi_array)
})
names(total_exp_mi_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_mi_estimates_rounded <- rbind(unlist(total_exp_mi_estimates))
total_exp_mi_estimates_rounded <- lapply(total_exp_mi_estimates,round,2)
total_exp_mi_se <- lapply(total_exp_mi_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_mi_se_rounded <- lapply(total_exp_mi_se,round,2)
total_exp_mi_ci <- foreach(i = total_exp_mi_estimates, j = total_exp_mi_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_mi_estimates.table <- rbind(unlist(total_exp_mi_estimates_rounded), unlist(total_exp_mi_se_rounded), unlist(total_exp_mi_ci))
rownames(total_exp_mi_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_mi_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_mi_estimates.table
total_exp_mi_estimates.latextable <- xtable(total_exp_mi_estimates.table, align = "lccc", caption = 'Total Expenditure - MI')
print(total_exp_mi_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_MI.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_MI.pdf')
total_expenditure_plots_MI <- synthdid_plot(total_exp_mi_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Michigan',
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
total_expenditure_control_plots_MI <- synthdid_units_plot(total_exp_mi_estimates, se.method='none') + 
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
total_expenditure_plots_MI + total_expenditure_control_plots_MI + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_mi_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_mi_df$treated <- as.integer(ifelse(medicaid_exp_mi_df$name == "Michigan" & medicaid_exp_mi_df$year >= 1999, 1, 0))
medicaid_exp_mi_df <- medicaid_exp_mi_df[order(medicaid_exp_mi_df$year, medicaid_exp_mi_df$treated_mi_aux, medicaid_exp_mi_df$name),]
medicaid_exp_mi_df$border_state <- ifelse(medicaid_exp_mi_df$name == "New York" | medicaid_exp_mi_df$name == "New Jersey" | medicaid_exp_mi_df$name == "Delaware" | medicaid_exp_mi_df$name == "Maryland" | medicaid_exp_mi_df$name == "West Virginia" | medicaid_exp_mi_df$name == "Ohio" | medicaid_exp_mi_df$name == "Illinois" | medicaid_exp_mi_df$name == "Kentucky" | medicaid_exp_mi_df$name == "Montana" | medicaid_exp_mi_df$name == "South Dakota" | medicaid_exp_mi_df$name == "Minnesota", 1, 0)
medicaid_exp_mi_df <- subset(medicaid_exp_mi_df, (alwaysconpa == 1 & border_state == 0) | name == "Michigan", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_mi <- panel.matrices(medicaid_exp_mi_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_mi_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_mi$Y, setup_medicaid_exp_mi$N0, setup_medicaid_exp_mi$T0, X = covariates_exp_mi_array)
})
names(medicaid_exp_mi_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_mi_estimates_rounded <- rbind(unlist(medicaid_exp_mi_estimates))
medicaid_exp_mi_estimates_rounded <- lapply(medicaid_exp_mi_estimates,round,2)
medicaid_exp_mi_se <- lapply(medicaid_exp_mi_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_mi_se_rounded <- lapply(medicaid_exp_mi_se,round,2)
medicaid_exp_mi_ci <- foreach(i = medicaid_exp_mi_estimates, j = medicaid_exp_mi_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_mi_estimates.table <- rbind(unlist(medicaid_exp_mi_estimates_rounded), unlist(medicaid_exp_mi_se_rounded), unlist(medicaid_exp_mi_ci))
rownames(medicaid_exp_mi_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_mi_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_mi_estimates.table
medicaid_exp_mi_estimates.latextable <- xtable(medicaid_exp_mi_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - MI')
print(medicaid_exp_mi_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_MI.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_MI.pdf')
medicaid_expenditure_plots_MI <- synthdid_plot(medicaid_exp_mi_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Michigan',
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
medicaid_expenditure_control_plots_MI <- synthdid_units_plot(medicaid_exp_mi_estimates, se.method='none') + 
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
medicaid_expenditure_plots_MI + medicaid_expenditure_control_plots_MI + plot_layout(ncol=1)
dev.off()




########## Illinois ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_il_aux <- ifelse(CON_Expenditure$name == "Illinois", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_il_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Illinois")
covariates_il_exp_df <- covariates_il_exp_df[order(covariates_il_exp_df$year, covariates_il_exp_df$treated_il_aux, covariates_il_exp_df$name),]
covariates_il_exp_df <- as.data.frame(subset(covariates_il_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_il_exp_df$income_pcp_adj <- covariates_il_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_il_exp_df$unemp_rate <- covariates_il_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_il_exp_df$top1_adj <- covariates_il_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_il <- c(1980:2014)
row.names_exp_il <- c(covariates_il_exp_df[1:25,1])
matrix.names_exp_il <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_il_array <- array(as.matrix(covariates_il_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_il, column.names_exp_il, matrix.names_exp_il))


### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_il_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_il_df$treated <- as.integer(ifelse(total_exp_il_df$name == "Illinois" & total_exp_il_df$year >= 1999, 1, 0))
total_exp_il_df <- total_exp_il_df[order(total_exp_il_df$year, total_exp_il_df$treated_il_aux, total_exp_il_df$name),]
total_exp_il_df$border_state <- ifelse(total_exp_il_df$name == "New York" | total_exp_il_df$name == "New Jersey" | total_exp_il_df$name == "Delaware" | total_exp_il_df$name == "Maryland" | total_exp_il_df$name == "West Virginia" | total_exp_il_df$name == "Ohio" | total_exp_il_df$name == "Michigan" | total_exp_il_df$name == "Kentucky" | total_exp_il_df$name == "Montana" | total_exp_il_df$name == "South Dakota" | total_exp_il_df$name == "Minnesota", 1, 0)
total_exp_il_df <- subset(total_exp_il_df, (alwaysconpa == 1 & border_state == 0) | name == "Illinois", select=c(name, year, total_exp, treated))
setup_total_exp_il <- panel.matrices(total_exp_il_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_il_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_il$Y, setup_total_exp_il$N0, setup_total_exp_il$T0, X = covariates_exp_il_array)
})
names(total_exp_il_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_il_estimates_rounded <- rbind(unlist(total_exp_il_estimates))
total_exp_il_estimates_rounded <- lapply(total_exp_il_estimates,round,2)
total_exp_il_se <- lapply(total_exp_il_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_il_se_rounded <- lapply(total_exp_il_se,round,2)
total_exp_il_ci <- foreach(i = total_exp_il_estimates, j = total_exp_il_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_il_estimates.table <- rbind(unlist(total_exp_il_estimates_rounded), unlist(total_exp_il_se_rounded), unlist(total_exp_il_ci))
rownames(total_exp_il_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_il_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_il_estimates.table
total_exp_il_estimates.latextable <- xtable(total_exp_il_estimates.table, align = "lccc", caption = 'Total Expenditure - IL')
print(total_exp_il_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_IL.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_IL.pdf')
total_expenditure_plots_IL <- synthdid_plot(total_exp_il_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Illinois',
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
total_expenditure_control_plots_IL <- synthdid_units_plot(total_exp_il_estimates, se.method='none') + 
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
total_expenditure_plots_IL + total_expenditure_control_plots_IL + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_il_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_il_df$treated <- as.integer(ifelse(medicaid_exp_il_df$name == "Illinois" & medicaid_exp_il_df$year >= 1999, 1, 0))
medicaid_exp_il_df <- medicaid_exp_il_df[order(medicaid_exp_il_df$year, medicaid_exp_il_df$treated_il_aux, medicaid_exp_il_df$name),]
medicaid_exp_il_df$border_state <- ifelse(medicaid_exp_il_df$name == "New York" | medicaid_exp_il_df$name == "New Jersey" | medicaid_exp_il_df$name == "Delaware" | medicaid_exp_il_df$name == "Maryland" | medicaid_exp_il_df$name == "West Virginia" | medicaid_exp_il_df$name == "Ohio" | medicaid_exp_il_df$name == "Michigan" | medicaid_exp_il_df$name == "Kentucky" | medicaid_exp_il_df$name == "Montana" | medicaid_exp_il_df$name == "South Dakota" | medicaid_exp_il_df$name == "Minnesota", 1, 0)
medicaid_exp_il_df <- subset(medicaid_exp_il_df, (alwaysconpa == 1 & border_state == 0) | name == "Illinois", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_il <- panel.matrices(medicaid_exp_il_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_il_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_il$Y, setup_medicaid_exp_il$N0, setup_medicaid_exp_il$T0, X = covariates_exp_il_array)
})
names(medicaid_exp_il_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_il_estimates_rounded <- rbind(unlist(medicaid_exp_il_estimates))
medicaid_exp_il_estimates_rounded <- lapply(medicaid_exp_il_estimates,round,2)
medicaid_exp_il_se <- lapply(medicaid_exp_il_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_il_se_rounded <- lapply(medicaid_exp_il_se,round,2)
medicaid_exp_il_ci <- foreach(i = medicaid_exp_il_estimates, j = medicaid_exp_il_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_il_estimates.table <- rbind(unlist(medicaid_exp_il_estimates_rounded), unlist(medicaid_exp_il_se_rounded), unlist(medicaid_exp_il_ci))
rownames(medicaid_exp_il_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_il_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_il_estimates.table
medicaid_exp_il_estimates.latextable <- xtable(medicaid_exp_il_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - IL')
print(medicaid_exp_il_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_IL.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_IL.pdf')
medicaid_expenditure_plots_IL <- synthdid_plot(medicaid_exp_il_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Illinois',
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
medicaid_expenditure_control_plots_IL <- synthdid_units_plot(medicaid_exp_il_estimates, se.method='none') + 
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
medicaid_expenditure_plots_IL + medicaid_expenditure_control_plots_IL + plot_layout(ncol=1)
dev.off()




########## Kentucky ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_ky_aux <- ifelse(CON_Expenditure$name == "Kentucky", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_ky_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Kentucky")
covariates_ky_exp_df <- covariates_ky_exp_df[order(covariates_ky_exp_df$year, covariates_ky_exp_df$treated_ky_aux, covariates_ky_exp_df$name),]
covariates_ky_exp_df <- as.data.frame(subset(covariates_ky_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_ky_exp_df$income_pcp_adj <- covariates_ky_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_ky_exp_df$unemp_rate <- covariates_ky_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_ky_exp_df$top1_adj <- covariates_ky_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_ky <- c(1980:2014)
row.names_exp_ky <- c(covariates_ky_exp_df[1:25,1])
matrix.names_exp_ky <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_ky_array <- array(as.matrix(covariates_ky_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_ky, column.names_exp_ky, matrix.names_exp_ky))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_ky_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_ky_df$treated <- as.integer(ifelse(total_exp_ky_df$name == "Kentucky" & total_exp_ky_df$year >= 1999, 1, 0))
total_exp_ky_df <- total_exp_ky_df[order(total_exp_ky_df$year, total_exp_ky_df$treated_ky_aux, total_exp_ky_df$name),]
total_exp_ky_df$border_state <- ifelse(total_exp_ky_df$name == "New York" | total_exp_ky_df$name == "New Jersey" | total_exp_ky_df$name == "Delaware" | total_exp_ky_df$name == "Maryland" | total_exp_ky_df$name == "West Virginia" | total_exp_ky_df$name == "Ohio" | total_exp_ky_df$name == "Michigan" | total_exp_ky_df$name == "Illinois" | total_exp_ky_df$name == "Montana" | total_exp_ky_df$name == "South Dakota" | total_exp_ky_df$name == "Minnesota", 1, 0)
total_exp_ky_df <- subset(total_exp_ky_df, (alwaysconpa == 1 & border_state == 0) | name == "Kentucky", select=c(name, year, total_exp, treated))
setup_total_exp_ky <- panel.matrices(total_exp_ky_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_ky_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_ky$Y, setup_total_exp_ky$N0, setup_total_exp_ky$T0, X = covariates_exp_ky_array)
})
names(total_exp_ky_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_ky_estimates_rounded <- rbind(unlist(total_exp_ky_estimates))
total_exp_ky_estimates_rounded <- lapply(total_exp_ky_estimates,round,2)
total_exp_ky_se <- lapply(total_exp_ky_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_ky_se_rounded <- lapply(total_exp_ky_se,round,2)
total_exp_ky_ci <- foreach(i = total_exp_ky_estimates, j = total_exp_ky_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_ky_estimates.table <- rbind(unlist(total_exp_ky_estimates_rounded), unlist(total_exp_ky_se_rounded), unlist(total_exp_ky_ci))
rownames(total_exp_ky_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_ky_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_ky_estimates.table
total_exp_ky_estimates.latextable <- xtable(total_exp_ky_estimates.table, align = "lccc", caption = 'Total Expenditure - KY')
print(total_exp_ky_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_KY.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_KY.pdf')
total_expenditure_plots_KY <- synthdid_plot(total_exp_ky_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Kentucky',
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
total_expenditure_control_plots_KY <- synthdid_units_plot(total_exp_ky_estimates, se.method='none') + 
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
total_expenditure_plots_KY + total_expenditure_control_plots_KY + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_ky_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_ky_df$treated <- as.integer(ifelse(medicaid_exp_ky_df$name == "Kentucky" & medicaid_exp_ky_df$year >= 1999, 1, 0))
medicaid_exp_ky_df <- medicaid_exp_ky_df[order(medicaid_exp_ky_df$year, medicaid_exp_ky_df$treated_ky_aux, medicaid_exp_ky_df$name),]
medicaid_exp_ky_df$border_state <- ifelse(medicaid_exp_ky_df$name == "New York" | medicaid_exp_ky_df$name == "New Jersey" | medicaid_exp_ky_df$name == "Delaware" | medicaid_exp_ky_df$name == "Maryland" | medicaid_exp_ky_df$name == "West Virginia" | medicaid_exp_ky_df$name == "Ohio" | medicaid_exp_ky_df$name == "Michigan" | medicaid_exp_ky_df$name == "Illinois" | medicaid_exp_ky_df$name == "Montana" | medicaid_exp_ky_df$name == "South Dakota" | medicaid_exp_ky_df$name == "Minnesota", 1, 0)
medicaid_exp_ky_df <- subset(medicaid_exp_ky_df, (alwaysconpa == 1 & border_state == 0) | name == "Kentucky", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_ky <- panel.matrices(medicaid_exp_ky_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_ky_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_ky$Y, setup_medicaid_exp_ky$N0, setup_medicaid_exp_ky$T0, X = covariates_exp_ky_array)
})
names(medicaid_exp_ky_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_ky_estimates_rounded <- rbind(unlist(medicaid_exp_ky_estimates))
medicaid_exp_ky_estimates_rounded <- lapply(medicaid_exp_ky_estimates,round,2)
medicaid_exp_ky_se <- lapply(medicaid_exp_ky_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_ky_se_rounded <- lapply(medicaid_exp_ky_se,round,2)
medicaid_exp_ky_ci <- foreach(i = medicaid_exp_ky_estimates, j = medicaid_exp_ky_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_ky_estimates.table <- rbind(unlist(medicaid_exp_ky_estimates_rounded), unlist(medicaid_exp_ky_se_rounded), unlist(medicaid_exp_ky_ci))
rownames(medicaid_exp_ky_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_ky_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_ky_estimates.table
medicaid_exp_ky_estimates.latextable <- xtable(medicaid_exp_ky_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - KY')
print(medicaid_exp_ky_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_KY.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_KY.pdf')
medicaid_expenditure_plots_KY <- synthdid_plot(medicaid_exp_ky_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Kentucky',
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
medicaid_expenditure_control_plots_KY <- synthdid_units_plot(medicaid_exp_ky_estimates, se.method='none') + 
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
medicaid_expenditure_plots_KY + medicaid_expenditure_control_plots_KY + plot_layout(ncol=1)
dev.off()




########## Montana ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_mt_aux <- ifelse(CON_Expenditure$name == "Montana", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "South Dakota" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_mt_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Montana")
covariates_mt_exp_df <- covariates_mt_exp_df[order(covariates_mt_exp_df$year, covariates_mt_exp_df$treated_mt_aux, covariates_mt_exp_df$name),]
covariates_mt_exp_df <- as.data.frame(subset(covariates_mt_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_mt_exp_df$income_pcp_adj <- covariates_mt_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mt_exp_df$unemp_rate <- covariates_mt_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mt_exp_df$top1_adj <- covariates_mt_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_mt <- c(1980:2014)
row.names_exp_mt <- c(covariates_mt_exp_df[1:25,1])
matrix.names_exp_mt <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_mt_array <- array(as.matrix(covariates_mt_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_mt, column.names_exp_mt, matrix.names_exp_mt))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_mt_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_mt_df$treated <- as.integer(ifelse(total_exp_mt_df$name == "Montana" & total_exp_mt_df$year >= 1995, 1, 0))
total_exp_mt_df <- total_exp_mt_df[order(total_exp_mt_df$year, total_exp_mt_df$treated_mt_aux, total_exp_mt_df$name),]
total_exp_mt_df$border_state <- ifelse(total_exp_mt_df$name == "New York" | total_exp_mt_df$name == "New Jersey" | total_exp_mt_df$name == "Delaware" | total_exp_mt_df$name == "Maryland" | total_exp_mt_df$name == "West Virginia" | total_exp_mt_df$name == "Ohio" | total_exp_mt_df$name == "Michigan" | total_exp_mt_df$name == "Illinois" | total_exp_mt_df$name == "Kentucky" | total_exp_mt_df$name == "South Dakota" | total_exp_mt_df$name == "Minnesota", 1, 0)
total_exp_mt_df <- subset(total_exp_mt_df, (alwaysconpa == 1 & border_state == 0) | name == "Montana", select=c(name, year, total_exp, treated))
setup_total_exp_mt <- panel.matrices(total_exp_mt_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_mt_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_mt$Y, setup_total_exp_mt$N0, setup_total_exp_mt$T0, X = covariates_exp_mt_array)
})
names(total_exp_mt_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_mt_estimates_rounded <- rbind(unlist(total_exp_mt_estimates))
total_exp_mt_estimates_rounded <- lapply(total_exp_mt_estimates,round,2)
total_exp_mt_se <- lapply(total_exp_mt_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_mt_se_rounded <- lapply(total_exp_mt_se,round,2)
total_exp_mt_ci <- foreach(i = total_exp_mt_estimates, j = total_exp_mt_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_mt_estimates.table <- rbind(unlist(total_exp_mt_estimates_rounded), unlist(total_exp_mt_se_rounded), unlist(total_exp_mt_ci))
rownames(total_exp_mt_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_mt_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_mt_estimates.table
total_exp_mt_estimates.latextable <- xtable(total_exp_mt_estimates.table, align = "lccc", caption = 'Total Expenditure - MT')
print(total_exp_mt_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_MT.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_MT.pdf')
total_expenditure_plots_MT <- synthdid_plot(total_exp_mt_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Montana',
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
total_expenditure_control_plots_MT <- synthdid_units_plot(total_exp_mt_estimates, se.method='none') + 
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
total_expenditure_plots_MT + total_expenditure_control_plots_MT + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_mt_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_mt_df$treated <- as.integer(ifelse(medicaid_exp_mt_df$name == "Montana" & medicaid_exp_mt_df$year >= 1995, 1, 0))
medicaid_exp_mt_df <- medicaid_exp_mt_df[order(medicaid_exp_mt_df$year, medicaid_exp_mt_df$treated_mt_aux, medicaid_exp_mt_df$name),]
medicaid_exp_mt_df$border_state <- ifelse(medicaid_exp_mt_df$name == "New York" | medicaid_exp_mt_df$name == "New Jersey" | medicaid_exp_mt_df$name == "Delaware" | medicaid_exp_mt_df$name == "Maryland" | medicaid_exp_mt_df$name == "West Virginia" | medicaid_exp_mt_df$name == "Ohio" | medicaid_exp_mt_df$name == "Michigan" | medicaid_exp_mt_df$name == "Illinois" | medicaid_exp_mt_df$name == "Kentucky" | medicaid_exp_mt_df$name == "South Dakota" | medicaid_exp_mt_df$name == "Minnesota", 1, 0)
medicaid_exp_mt_df <- subset(medicaid_exp_mt_df, (alwaysconpa == 1 & border_state == 0) | name == "Montana", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_mt <- panel.matrices(medicaid_exp_mt_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_mt_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_mt$Y, setup_medicaid_exp_mt$N0, setup_medicaid_exp_mt$T0, X = covariates_exp_mt_array)
})
names(medicaid_exp_mt_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_mt_estimates_rounded <- rbind(unlist(medicaid_exp_mt_estimates))
medicaid_exp_mt_estimates_rounded <- lapply(medicaid_exp_mt_estimates,round,2)
medicaid_exp_mt_se <- lapply(medicaid_exp_mt_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_mt_se_rounded <- lapply(medicaid_exp_mt_se,round,2)
medicaid_exp_mt_ci <- foreach(i = medicaid_exp_mt_estimates, j = medicaid_exp_mt_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_mt_estimates.table <- rbind(unlist(medicaid_exp_mt_estimates_rounded), unlist(medicaid_exp_mt_se_rounded), unlist(medicaid_exp_mt_ci))
rownames(medicaid_exp_mt_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_mt_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_mt_estimates.table
medicaid_exp_mt_estimates.latextable <- xtable(medicaid_exp_mt_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - MT')
print(medicaid_exp_mt_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_MT.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_MT.pdf')
medicaid_expenditure_plots_MT <- synthdid_plot(medicaid_exp_mt_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Montana',
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
medicaid_expenditure_control_plots_MT <- synthdid_units_plot(medicaid_exp_mt_estimates, se.method='none') + 
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
medicaid_expenditure_plots_MT + medicaid_expenditure_control_plots_MT + plot_layout(ncol=1)
dev.off()




########## South Dakota ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_sd_aux <- ifelse(CON_Expenditure$name == "South Dakota", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "Minnesota", 1, 0)
covariates_sd_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "South Dakota")
covariates_sd_exp_df <- covariates_sd_exp_df[order(covariates_sd_exp_df$year, covariates_sd_exp_df$treated_sd_aux, covariates_sd_exp_df$name),]
covariates_sd_exp_df <- as.data.frame(subset(covariates_sd_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_sd_exp_df$income_pcp_adj <- covariates_sd_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_sd_exp_df$unemp_rate <- covariates_sd_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_sd_exp_df$top1_adj <- covariates_sd_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_sd <- c(1980:2014)
row.names_exp_sd <- c(covariates_sd_exp_df[1:25,1])
matrix.names_exp_sd <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_sd_array <- array(as.matrix(covariates_sd_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_sd, column.names_exp_sd, matrix.names_exp_sd))


### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_sd_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_sd_df$treated <- as.integer(ifelse(total_exp_sd_df$name == "South Dakota" & total_exp_sd_df$year >= 1995, 1, 0))
total_exp_sd_df <- total_exp_sd_df[order(total_exp_sd_df$year, total_exp_sd_df$treated_sd_aux, total_exp_sd_df$name),]
total_exp_sd_df$border_state <- ifelse(total_exp_sd_df$name == "New York" | total_exp_sd_df$name == "New Jersey" | total_exp_sd_df$name == "Delaware" | total_exp_sd_df$name == "Maryland" | total_exp_sd_df$name == "West Virginia" | total_exp_sd_df$name == "Ohio" | total_exp_sd_df$name == "Michigan" | total_exp_sd_df$name == "Illinois" | total_exp_sd_df$name == "Kentucky" | total_exp_sd_df$name == "Montana" | total_exp_sd_df$name == "Minnesota", 1, 0)
total_exp_sd_df <- subset(total_exp_sd_df, (alwaysconpa == 1 & border_state == 0) | name == "South Dakota", select=c(name, year, total_exp, treated))
setup_total_exp_sd <- panel.matrices(total_exp_sd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_sd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_sd$Y, setup_total_exp_sd$N0, setup_total_exp_sd$T0, X = covariates_exp_sd_array)
})
names(total_exp_sd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_sd_estimates_rounded <- rbind(unlist(total_exp_sd_estimates))
total_exp_sd_estimates_rounded <- lapply(total_exp_sd_estimates,round,2)
total_exp_sd_se <- lapply(total_exp_sd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_sd_se_rounded <- lapply(total_exp_sd_se,round,2)
total_exp_sd_ci <- foreach(i = total_exp_sd_estimates, j = total_exp_sd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_sd_estimates.table <- rbind(unlist(total_exp_sd_estimates_rounded), unlist(total_exp_sd_se_rounded), unlist(total_exp_sd_ci))
rownames(total_exp_sd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_sd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_sd_estimates.table
total_exp_sd_estimates.latextable <- xtable(total_exp_sd_estimates.table, align = "lccc", caption = 'Total Expenditure - SD')
print(total_exp_sd_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_SD.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_SD.pdf')
total_expenditure_plots_SD <- synthdid_plot(total_exp_sd_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='South Dakota',
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
total_expenditure_control_plots_SD <- synthdid_units_plot(total_exp_sd_estimates, se.method='none') + 
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
total_expenditure_plots_SD + total_expenditure_control_plots_SD + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_sd_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_sd_df$treated <- as.integer(ifelse(medicaid_exp_sd_df$name == "South Dakota" & medicaid_exp_sd_df$year >= 1995, 1, 0))
medicaid_exp_sd_df <- medicaid_exp_sd_df[order(medicaid_exp_sd_df$year, medicaid_exp_sd_df$treated_sd_aux, medicaid_exp_sd_df$name),]
medicaid_exp_sd_df$border_state <- ifelse(medicaid_exp_sd_df$name == "New York" | medicaid_exp_sd_df$name == "New Jersey" | medicaid_exp_sd_df$name == "Delaware" | medicaid_exp_sd_df$name == "Maryland" | medicaid_exp_sd_df$name == "West Virginia" | medicaid_exp_sd_df$name == "Ohio" | medicaid_exp_sd_df$name == "Michigan" | medicaid_exp_sd_df$name == "Illinois" | medicaid_exp_sd_df$name == "Kentucky" | medicaid_exp_sd_df$name == "Montana" | medicaid_exp_sd_df$name == "Minnesota", 1, 0)
medicaid_exp_sd_df <- subset(medicaid_exp_sd_df, (alwaysconpa == 1 & border_state == 0) | name == "South Dakota", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_sd <- panel.matrices(medicaid_exp_sd_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_sd_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_sd$Y, setup_medicaid_exp_sd$N0, setup_medicaid_exp_sd$T0, X = covariates_exp_sd_array)
})
names(medicaid_exp_sd_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_sd_estimates_rounded <- rbind(unlist(medicaid_exp_sd_estimates))
medicaid_exp_sd_estimates_rounded <- lapply(medicaid_exp_sd_estimates,round,2)
medicaid_exp_sd_se <- lapply(medicaid_exp_sd_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_sd_se_rounded <- lapply(medicaid_exp_sd_se,round,2)
medicaid_exp_sd_ci <- foreach(i = medicaid_exp_sd_estimates, j = medicaid_exp_sd_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_sd_estimates.table <- rbind(unlist(medicaid_exp_sd_estimates_rounded), unlist(medicaid_exp_sd_se_rounded), unlist(medicaid_exp_sd_ci))
rownames(medicaid_exp_sd_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_sd_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_sd_estimates.table
medicaid_exp_sd_estimates.latextable <- xtable(medicaid_exp_sd_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - SD')
print(medicaid_exp_sd_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_SD.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_SD.pdf')
medicaid_expenditure_plots_SD <- synthdid_plot(medicaid_exp_sd_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='South Dakota',
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
medicaid_expenditure_control_plots_SD <- synthdid_units_plot(medicaid_exp_sd_estimates, se.method='none') + 
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
medicaid_expenditure_plots_SD + medicaid_expenditure_control_plots_SD + plot_layout(ncol=1)
dev.off()




########## Minnesota ###########

##### Create 3D array of time-varying covariates for synthetic matching - CON_Expenditure #####
CON_Expenditure$treated_mn_aux <- ifelse(CON_Expenditure$name == "Minnesota", 1, 0)
CON_Expenditure$border_state <- ifelse(CON_Expenditure$name == "New York" | CON_Expenditure$name == "New Jersey" | CON_Expenditure$name == "Delaware" | CON_Expenditure$name == "Maryland" | CON_Expenditure$name == "West Virginia" | CON_Expenditure$name == "Ohio" | CON_Expenditure$name == "Michigan" | CON_Expenditure$name == "Illinois" | CON_Expenditure$name == "Kentucky" | CON_Expenditure$name == "Montana" | CON_Expenditure$name == "South Dakota", 1, 0)
covariates_mn_exp_df <- subset(CON_Expenditure, (alwaysconpa == 1 & border_state == 0 & id != 11) | name == "Minnesota")
covariates_mn_exp_df <- covariates_mn_exp_df[order(covariates_mn_exp_df$year, covariates_mn_exp_df$treated_mn_aux, covariates_mn_exp_df$name),]
covariates_mn_exp_df <- as.data.frame(subset(covariates_mn_exp_df, code == 10, select=c(name, year, income_pcp_adj, pop_density, unemp_rate, top1_adj, gini, prop_age_25to45_bsy, prop_age_45to65_bsy, prop_age_over65_bsy, prop_bach_degree_bsy, prop_male_bsy, prop_married_bsy, prop_white_bsy)))
covariates_mn_exp_df$income_pcp_adj <- covariates_mn_exp_df$income_pcp_adj/100000    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mn_exp_df$unemp_rate <- covariates_mn_exp_df$unemp_rate/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
covariates_mn_exp_df$top1_adj <- covariates_mn_exp_df$top1_adj/100    # there seems to be a problem with the scalability of covariates - see Github issues page #
column.names_exp_mn <- c(1980:2014)
row.names_exp_mn <- c(covariates_mn_exp_df[1:25,1])
matrix.names_exp_mn <- c("income_pcp_adj", "pop_density", "unemp_rate", "top1_adj", "gini", "prop_age_25to45_bsy", "prop_age_45to65_bsy", "prop_age_over65_bsy", "prop_bach_degree_bsy", "prop_male_bsy", "prop_married_bsy", "prop_white_bsy")
covariates_exp_mn_array <- array(as.matrix(covariates_mn_exp_df[,3:14]), dim = c(25,35,12), dimnames = list(row.names_exp_mn, column.names_exp_mn, matrix.names_exp_mn))

### Total Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
total_exp_mn_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
total_exp_mn_df$treated <- as.integer(ifelse(total_exp_mn_df$name == "Minnesota" & total_exp_mn_df$year >= 1995, 1, 0))
total_exp_mn_df <- total_exp_mn_df[order(total_exp_mn_df$year, total_exp_mn_df$treated_mn_aux, total_exp_mn_df$name),]
total_exp_mn_df$border_state <- ifelse(total_exp_mn_df$name == "New York" | total_exp_mn_df$name == "New Jersey" | total_exp_mn_df$name == "Delaware" | total_exp_mn_df$name == "Maryland" | total_exp_mn_df$name == "West Virginia" | total_exp_mn_df$name == "Ohio" | total_exp_mn_df$name == "Michigan" | total_exp_mn_df$name == "Illinois" | total_exp_mn_df$name == "Kentucky" | total_exp_mn_df$name == "Montana" | total_exp_mn_df$name == "South Dakota", 1, 0)
total_exp_mn_df <- subset(total_exp_mn_df, (alwaysconpa == 1 & border_state == 0) | name == "Minnesota", select=c(name, year, total_exp, treated))
setup_total_exp_mn <- panel.matrices(total_exp_mn_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
total_exp_mn_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_total_exp_mn$Y, setup_total_exp_mn$N0, setup_total_exp_mn$T0, X = covariates_exp_mn_array)
})
names(total_exp_mn_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
total_exp_mn_estimates_rounded <- rbind(unlist(total_exp_mn_estimates))
total_exp_mn_estimates_rounded <- lapply(total_exp_mn_estimates,round,2)
total_exp_mn_se <- lapply(total_exp_mn_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
total_exp_mn_se_rounded <- lapply(total_exp_mn_se,round,2)
total_exp_mn_ci <- foreach(i = total_exp_mn_estimates, j = total_exp_mn_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
total_exp_mn_estimates.table <- rbind(unlist(total_exp_mn_estimates_rounded), unlist(total_exp_mn_se_rounded), unlist(total_exp_mn_ci))
rownames(total_exp_mn_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(total_exp_mn_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
total_exp_mn_estimates.table
total_exp_mn_estimates.latextable <- xtable(total_exp_mn_estimates.table, align = "lccc", caption = 'Total Expenditure - MN')
print(total_exp_mn_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/total_expenditure_estimates_MN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/total_expenditure_plots_MN.pdf')
total_expenditure_plots_MN <- synthdid_plot(total_exp_mn_estimates, 
                                            facet.vertical=FALSE,
                                            control.name='Control', treated.name='Minnesota',
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
total_expenditure_control_plots_MN <- synthdid_units_plot(total_exp_mn_estimates, se.method='none') + 
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
total_expenditure_plots_MN + total_expenditure_control_plots_MN + plot_layout(ncol=1)
dev.off()

### Medicaid Expenditure ###
# Restrict to treated state and control states by expenditure type (code = 10 for nursing home care), and get in panel form for synthdid #
medicaid_exp_mn_df <- as.data.frame(subset(CON_Expenditure, code == 10 & id != 11))
medicaid_exp_mn_df$treated <- as.integer(ifelse(medicaid_exp_mn_df$name == "Minnesota" & medicaid_exp_mn_df$year >= 1995, 1, 0))
medicaid_exp_mn_df <- medicaid_exp_mn_df[order(medicaid_exp_mn_df$year, medicaid_exp_mn_df$treated_mn_aux, medicaid_exp_mn_df$name),]
medicaid_exp_mn_df$border_state <- ifelse(medicaid_exp_mn_df$name == "New York" | medicaid_exp_mn_df$name == "New Jersey" | medicaid_exp_mn_df$name == "Delaware" | medicaid_exp_mn_df$name == "Maryland" | medicaid_exp_mn_df$name == "West Virginia" | medicaid_exp_mn_df$name == "Ohio" | medicaid_exp_mn_df$name == "Michigan" | medicaid_exp_mn_df$name == "Illinois" | medicaid_exp_mn_df$name == "Kentucky" | medicaid_exp_mn_df$name == "Montana" | medicaid_exp_mn_df$name == "South Dakota", 1, 0)
medicaid_exp_mn_df <- subset(medicaid_exp_mn_df, (alwaysconpa == 1 & border_state == 0) | name == "Minnesota", select=c(name, year, medicaid_exp, treated))
setup_medicaid_exp_mn <- panel.matrices(medicaid_exp_mn_df, unit = 1, time = 2, outcome = 3, treatment = 4)
# DID, SC, and SDID Estimates, SEs, and 95% CIs #
estimators = list(did=did_estimate,
                  sc=sc_estimate,
                  sdid=synthdid_estimate)
medicaid_exp_mn_estimates <- lapply(estimators, function(estimator) {
  estimator(setup_medicaid_exp_mn$Y, setup_medicaid_exp_mn$N0, setup_medicaid_exp_mn$T0, X = covariates_exp_mn_array)
})
names(medicaid_exp_mn_estimates) = c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff')
medicaid_exp_mn_estimates_rounded <- rbind(unlist(medicaid_exp_mn_estimates))
medicaid_exp_mn_estimates_rounded <- lapply(medicaid_exp_mn_estimates,round,2)
medicaid_exp_mn_se <- lapply(medicaid_exp_mn_estimates, function(estimate) {
  set.seed(12345)
  sqrt(vcov(estimate, method='placebo'))
})
medicaid_exp_mn_se_rounded <- lapply(medicaid_exp_mn_se,round,2)
medicaid_exp_mn_ci <- foreach(i = medicaid_exp_mn_estimates, j = medicaid_exp_mn_se) %do% sprintf('(%1.2f, %1.2f)', i - 1.96*j, i + 1.96*j)
medicaid_exp_mn_estimates.table <- rbind(unlist(medicaid_exp_mn_estimates_rounded), unlist(medicaid_exp_mn_se_rounded), unlist(medicaid_exp_mn_ci))
rownames(medicaid_exp_mn_estimates.table) <- (c('estimate', 'standard error', '95% Confidence Interval'))
colnames(medicaid_exp_mn_estimates.table) <- (c('Diff-in-Diff', 'Synthetic Control', 'Synthetic Diff-in-Diff'))
medicaid_exp_mn_estimates.table
medicaid_exp_mn_estimates.latextable <- xtable(medicaid_exp_mn_estimates.table, align = "lccc", caption = 'Medicaid Expenditure - MN')
print(medicaid_exp_mn_estimates.latextable, type='latex', file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_estimates_MN.tex')
# Parallel Trends and Control Contribution Plots #
pdf(file='SynthDID_Bord_Figs_and_Tables/medicaid_expenditure_plots_MN.pdf')
medicaid_expenditure_plots_MN <- synthdid_plot(medicaid_exp_mn_estimates, 
                                               facet.vertical=FALSE,
                                               control.name='Control', treated.name='Minnesota',
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
medicaid_expenditure_control_plots_MN <- synthdid_units_plot(medicaid_exp_mn_estimates, se.method='none') + 
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
medicaid_expenditure_plots_MN + medicaid_expenditure_control_plots_MN + plot_layout(ncol=1)
dev.off()



