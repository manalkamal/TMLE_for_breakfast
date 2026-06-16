## FUNCTION FOR ALL SUB-GROUP ANALYSIS, CONTINOUS DATA: AGE 

get_age_analyses <- function(ModelData, OUTname){
  
  if (FALSE){
    tar_load(ModelData)
  }
  
  #ModelData <- ldd
  
  set.seed(2025)
  tau <- 6
  
  AgeSub <- rtmle_init(intervals = tau,
                       name_id = "id",
                       name_outcome = "Y",
                       name_competing = "Dead",
                       name_censoring = "Censored",
                       censored_label = "censored")
  
  AgeSub <- add_long_data(AgeSub,
                          outcome_data = ModelData$outcome_data,
                          censored_data = ModelData$censored_data,
                          competing_data = ModelData$competing_data,
                          timevar_data = ModelData$timevar_data)
  
  AgeSub <- add_baseline_data(AgeSub, 
                              data = ModelData$baseline_data)
  
  
  ## PREPARE THE DATA 
  AgeSub <- long_to_wide(AgeSub, 
                         intervals = seq(0, 2000, 30.45*6),
                         # fun = list("HBC" = function(x){x}),
                         #          #  "BMI" = function(x){x}),
                         start_followup_date = "start_followup_date")
  
  AgeSub <- prepare_data(AgeSub) 
  
  #AgeSub$prepared_data |> View()
  
  AgeSub <- protocol(AgeSub, 
                     name = "Always_Degludec_Never_Glargine",
                     intervention = data.frame("Degludec" = factor(1,levels = c(0,1)),
                                               "Glargine" = factor(0,levels = c(0,1))))
  AgeSub <- protocol(AgeSub, 
                     name = "Always_Glargine_Never_Degludec",
                     intervention = data.frame("Degludec" = factor(0,levels = c(0,1)),
                                               "Glargine" = factor(1,levels = c(0,1))))
  AgeSub <- target(AgeSub,
                   name = "Outcome_risk",
                   estimator = "tmle",
                   protocols = c("Always_Degludec_Never_Glargine", 
                                 "Always_Glargine_Never_Degludec"))
  
  # CHANGE 06.06.2025
  AgeSub$names$name_constant_variables <- c("Glargine_0",
                                            AgeSub$names$name_constant_variables) 
  # this is new
  AgeSub <- model_formula(AgeSub, exclude_variables = c("Glargine_0",
                                                        "start_followup_date"))
  
  
  # refProtocol1 <- list(Outcome_risk = "Always_Degludec_Never_Glargine")
  
  refProtocol2 <- list(Outcome_risk = "Always_Glargine_Never_Degludec")
  
 
  ## STRATA FOR THE SUBGROUP: AGE
  AGEStrata <- list(list(label = "AGE",
                         append = TRUE,
                         #id = AgeSub$prepared_data[AgeGroupMod %in% c("75+"), id],
                         id = AgeSub$prepared_data[AGE >= 50, id],
                         variable = "Subgroup",
                         level = "Age >= 50"),
                    list(label = "AGE",
                         append = TRUE,
                         # id = AgeSub$prepared_data[AgeGroupMod %in% c("18-44",
                         #                                              "45-64",
                         #                                              "65-74"), id],
                         id = AgeSub$prepared_data[AGE < 50, id],
                         variable = "Subgroup",
                         level = "Age < 50"))
  
  # subset analysis
  AgeSub$estimate$AGE <- NULL
  AgeSub <- run_rtmle(AgeSub,
                      learner = "learn_glmnet", 
                      time_horizon = 1:tau,
                      verbose = FALSE,
                      subsets = AGEStrata,
                      keep_influence = TRUE)
  
  
  
  AgeAnalysis <- summary(AgeSub, analysis = "AGE", reference = refProtocol2)
  
  ## SAVE THE SUMMARY OUTPUT OF THE MODEL FOR EACH OUTCOME. 
  
  saveRDS(object = AgeAnalysis,
          file = here::here(paste0("05-SubgroupAnalyses/", OUTname, "Population_GLM.rds")))
  
  
  return(AgeSub)
  
}