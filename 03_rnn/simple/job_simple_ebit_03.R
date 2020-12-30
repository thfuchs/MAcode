############################ job_simple_ebit_03.R ##############################

################################################################################
### Evaluation on cross-validated forecasts                                  ###
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

load("03_rnn/simple/fc_ebit_test_rnn_bayes.rda")
load("03_rnn/simple/fc_ebit_test_rnn_prediction.rda")

multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### Job ------------------------------------------------------------------------
fc_ebit_test_rnn_eval <- tune_keras_rnn_eval(
  fc_sample = fc_ebit_test_rnn_prediction,
  cv_setting = cv_setting_test,
  bayes_best_par = purrr::map(fc_ebit_test_rnn_bayes, "Best_Par"),
  col_id = NULL, col_date = "index", col_value = "value",
  multiple_h = multiple_h,
  frequency = 4,
  level = 95
)

save(fc_ebit_test_rnn_eval, file = "03_rnn/simple/fc_ebit_test_rnn_eval.rda")

# Success / Failure message
if (length(purrr::compact(fc_ebit_test_rnn_eval)) > 0)
  toSlack("Simple RNN EBIT (Test) evaluation finished") else
    toSlack("Error: Simple RNN EBIT (Test) evaluation failed")
