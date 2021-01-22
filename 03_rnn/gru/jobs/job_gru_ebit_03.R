############################# job_gru_ebit_03.R ################################

################################################################################
### Evaluation on cross-validated forecasts                                  ###
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

fc_ebit_rnn_bayes <- readRDS("03_rnn/gru/results/fc_ebit_rnn_bayes.rds")
fc_ebit_rnn_predict <- readRDS("03_rnn/gru/results/fc_ebit_rnn_predict.rds")

stopifnot(all(names(fc_ebit_rnn_bayes) == names(fc_ebit_rnn_predict)))

companies <- names(fc_ebit_rnn_predict)
overall <- trunc(length(companies) / cores)
fc_horizon <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### Job ------------------------------------------------------------------------
results <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    fc <- fc_ebit_rnn_predict[[x]]
    bayes <- fc_ebit_rnn_bayes[[x]]
    tune_keras_rnn_eval(
      fc_sample = fc,
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      col_id = NULL, col_date = "index", col_value = "value",
      h = fc_horizon,
      frequency = 4,
      level = 95
    )
  }, otherwise = NULL, quiet = FALSE)
)

fc_ebit_rnn_eval <- purrr::compact(purrr::set_names(results, companies))

# Success / Failure message
if (length(purrr::compact(fc_ebit_rnn_eval)) > 0) {
  saveRDS(fc_ebit_rnn_eval, file = "03_rnn/gru/results/fc_ebit_rnn_eval.rds", compress = "xz")
  toSlack("GRU EBIT evaluation finished")
} else toSlack("Error: GRU EBIT evaluation failed")
