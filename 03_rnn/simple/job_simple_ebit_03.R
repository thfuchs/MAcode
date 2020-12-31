############################ job_simple_ebit_03.R ##############################

################################################################################
### Evaluation on cross-validated forecasts                                  ###
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

fc_ebit_rnn_bayes <- readRDS("03_rnn/simple/fc_ebit_rnn_bayes.rds")
fc_ebit_rnn_prediction <- readRDS("03_rnn/simple/fc_ebit_rnn_prediction.rds")

multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### Job ------------------------------------------------------------------------
results <- tune_keras_rnn_eval(
  fc_sample = fc_ebit_rnn_prediction.rds,
  cv_setting = cv_setting_test,
  bayes_best_par = purrr::map(fc_ebit_rnn_bayes, "Best_Par"),
  col_id = NULL, col_date = "index", col_value = "value",
  multiple_h = multiple_h,
  frequency = 4,
  level = 95
)

fc_ebit_rnn_eval <- purrr::compact(results)

# Success / Failure message
if (length(purrr::compact(fc_ebit_rnn_eval)) > 0) {
  saveRDS(fc_ebit_rnn_eval, file = "03_rnn/simple/fc_ebit_rnn_eval.rds", compress = "xz")
  toSlack("Simple RNN EBIT evaluation finished")
} else toSlack("Error: Simple RNN EBIT evaluation failed")
