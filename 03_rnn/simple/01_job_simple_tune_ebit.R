######################## 01_job_simple_tune_ebit.R #############################

################################################################################
### Cross-validated tuning process for simple RNN on time series data        ###
################################################################################

source("settings.R")
source("utils.R")

tuning_bounds <- list(
  lag_1 = c(1L, 4L),
  lag_2 = c(1L, 4L),
  n_units = c(8L, 32L),
  n_epochs = c(20L, 50L),
  optimizer_type = c(1L, 3L), # 1 = "rmsprop", 2 = "adam", 3 = "adagrad"
  dropout = c(0, 0.5),
  recurrent_dropout = c(0, 0.5),
  learning_rate = c(0.001, 0.01)
)

data_ebit_test <- readRDS("data/data_ebit.rds")[ticker == "BA_UN", .(index, value)]

fc_ebit_test_rnn_bayes <- tune_keras_rnn_bayesoptim(
  data = data_ebit_test[1:52],
  col_id = NULL, col_date = "index", col_value = "value",
  model_type = "simple",
  cv_setting = cv_setting_tune,
  tuning_bounds = tuning_bounds
)

save(fc_ebit_test_rnn_bayes, file = "03_rnn/simple/fc_ebit_test_rnn_bayes.rda")

# Success Message
toSlack("Simple RNN EBIT (Test) Bayes Optimization finished")
