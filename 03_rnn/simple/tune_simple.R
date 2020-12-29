############################ tune_simple.R #####################################

################################################################################
### 1. Cross-validated tuning process for simple RNN on time series data     ###
### 2. Training, forecasting and evaluation on cross-validation splits with  ###
###    tuned parameters                                                      ###
################################################################################

library(rstudioapi)

# EBIT
jobRunScript("03_rnn/simple/01_job_simple_tune_ebit.R", workingDir = ".")
jobRunScript("03_rnn/simple/02_job_simple_predict_ebit.R", workingDir = ".")
jobRunScript("03_rnn/simple/03_job_simple_eval_ebit.R", workingDir = ".", exportEnv = "R_GlobalEnv")
