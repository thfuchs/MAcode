############################### 00_gru.R #######################################

################################################################################
### 1. Cross-validated tuning process for GRU on time series data            ###
### 2. Training, forecasting and evaluation on cross-validation splits with  ###
###    tuned parameters                                                      ###
################################################################################

# EBIT
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ebit_01.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ebit_02.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ebit_03.R", workingDir = ".", exportEnv = "R_GlobalEnv")

# Net Income
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ni_01.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ni_02.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_ni_03.R", workingDir = ".", exportEnv = "R_GlobalEnv")

# EPS
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_eps_01.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_eps_02.R", workingDir = ".", exportEnv = "R_GlobalEnv")
rstudioapi::jobRunScript("03_rnn/gru/jobs/job_gru_eps_03.R", workingDir = ".", exportEnv = "R_GlobalEnv")
