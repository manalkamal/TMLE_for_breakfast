library("targets")
library("tidyverse")
library("data.table")
library("riskRegression")
# Manal (adapt the path to your computer):
#try(setwd("c:/git/TMLE_for_breakfast/imperial"),silent = TRUE)
rtmle_code <- "D:/gits/rtmle-main/R/"
if (file.exists(rtmle_code)) tar_source(rtmle_code)
# Thomas:
try(setwd("~/research/Methods/TMLE_for_breakfast/imperial"),silent = TRUE)
try(library(rtmle),silent = TRUE)

tar_load(dummy_data)



set.seed(2025)
analysis_horizons <- 6

x <- rtmle_init(
  time_grid = seq(0, 2000, 30.45*6),
  name_id = "id",
  name_outcome = "Y",
  name_competing = "Dead",
  name_censoring = "Censored",
  censored_label = "censored"
)


x <- add_long_data(x,
                   outcome_data = dummy_data$outcome_data,
                   censored_data = dummy_data$censored_data,
                   competing_data = dummy_data$competing_data,
                   timevar_data = dummy_data$timevar_data[c("Degludec", "Glargine")])

x <- add_baseline_data(x, data = dummy_data$baseline_data)


## PREPARE THE DATA 
x <- long_to_wide(x,
                  start_followup_date = "start_followup_date")

## Check id = 4 or id = 6:
longdata <- dummy_data[["timevar_data"]][["Glargine"]]
widedata <- x[["data"]][["timevar_data"]][["Glargine"]]




# x <- protocol(x, 
#               name = "Always_Degludec_Never_Glargine",
#               intervention = data.frame(
#                 node = x$intervention_nodes,
#                 "Degludec" = factor(1,levels = c(0,1)),
#                 "Glargine" = factor(0,levels = c(0,1))))
# 
# x <- protocol(x, 
#               name = "Always_Glargine_Never_Degludec",
#               intervention = data.frame(
#                 node = x$intervention_nodes,
#                 "Degludec" = factor(0,levels = c(0,1)),
#                 "Glargine" = factor(1,levels = c(0,1))))
# 
# x <- prepare_rtmle_data(x) 
# 
# #x$prepared_data |> View()
# 
# x <- target(x,
#             name = "Outcome_risk",
#             estimator = "tmle",
#             protocols = c("Always_Degludec_Never_Glargine", 
#                           "Always_Glargine_Never_Degludec"))
# 
# 
# 
# # CHANGE 06.06.2025
# x$names$name_constant_variables <- c("Glargine_0", 
#                                      x$names$name_constant_variables) 
# 
# # specify nuisance-parameter model formulas
# x <- model_formula(x, 
#                    verbose = FALSE,
#                    exclude_variables = c("Glargine_0", 
#                                          "start_followup_date"))
# 
# 
# # refProtocol1 <- list(Outcome_risk = "Always_Degludec_Never_Glargine")
# 
# refProtocol2 <- list(Outcome_risk = "Always_Glargine_Never_Degludec")
# 
# x <- run_rtmle(x,
#                learner = "learn_glmnet",
#                verbose = FALSE,
#                time_horizon = 1:analysis_horizons)
# 
# 
# Xres <- summary(x, 
#                 targets = "Outcome_risk",
#                 reference = refProtocol2) 
# 
# 
# Xres



