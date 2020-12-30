############################ tune_simple.R #####################################

################################################################################
### 1. Cross-validated tuning process for simple RNN on time series data     ###
### 2. Training, forecasting and evaluation on cross-validation splits with  ###
###    tuned parameters                                                      ###
################################################################################

# EBIT
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ebit_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ebit_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ebit_03.R", workingDir = ".")

# Net Income
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ni_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ni_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_ni_03.R", workingDir = ".")

# EPS
rstudioapi::jobRunScript("03_rnn/simple/job_simple_eps_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_eps_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/simple/job_simple_eps_03.R", workingDir = ".")
