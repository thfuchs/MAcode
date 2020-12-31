############################# job_simple_ni_03.R ###############################

################################################################################
### Evaluation on cross-validated forecasts                                  ###
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

fc_ni_rnn_bayes <- readRDS("03_rnn/simple/results/fc_ni_rnn_bayes.rds")
fc_ni_rnn_prediction <- readRDS("03_rnn/simple/results/fc_ni_rnn_prediction.rds")

stopifnot(all(names(fc_ni_rnn_bayes) == names(fc_ni_rnn_prediction)))

companies <- names(fc_ni_rnn_prediction)
multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### Job ------------------------------------------------------------------------
results <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    fc <- fc_ni_rnn_prediction[[x]]
    bayes <- fc_ni_rnn_bayes[[x]]
    tune_keras_rnn_eval(
      fc_sample = fc,
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      col_id = NULL, col_date = "index", col_value = "value",
      multiple_h = multiple_h,
      frequency = 4,
      level = 95
    )
  }, otherwise = NULL, quiet = FALSE)
)

fc_ni_rnn_eval <- purrr::compact(purrr::set_names(results, companies))

# Success / Failure message
if (length(purrr::compact(fc_ni_rnn_eval)) > 0) {
  saveRDS(fc_ni_rnn_eval, file = "03_rnn/simple/results/fc_ni_rnn_eval.rds", compress = "xz")
  toSlack("Simple RNN Net Income evaluation finished")
} else toSlack("Error: Simple RNN Net Income evaluation failed")
