############################## 00_lstm.R #######################################

################################################################################
### 1. Cross-validated tuning process for LSTM on time series data           ###
### 2. Training, forecasting and evaluation on cross-validation splits with  ###
###    tuned parameters                                                      ###
################################################################################

# EBIT
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ebit_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ebit_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ebit_03.R", workingDir = ".")

# Net Income
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ni_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ni_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_ni_03.R", workingDir = ".")

# EPS
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_eps_01.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_eps_02.R", workingDir = ".")
rstudioapi::jobRunScript("03_rnn/lstm/jobs/job_lstm_eps_03.R", workingDir = ".")
