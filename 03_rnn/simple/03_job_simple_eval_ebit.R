########################## 03_job_simple_eval_ebit.R ###########################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

source("settings.R")
source("utils.R")

load("03_rnn/simple/fc_ebit_test_rnn_prediction.rda")
multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)
frequency <- 4

tune_keras_rnn_eval(
  fc_sample = fc_ebit_test_rnn_prediction,
  cv_setting = cv_setting_test,
  bayes_best_par = purrr::map(fc_ebit_test_rnn_bayes, "Best_Par"),
  col_id = NULL, col_date = "index", col_value = "value",
  multiple_h = multiple_h,
  frequency = frequency,
  level = 95
)
