############################# job_simple_ni_01.R ###############################

################################################################################
### Cross-validated tuning process for simple RNN on time series data        ###
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

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

data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]
companies <- unique(data_ni$ticker)

tuning_results <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    toSlack(paste0(
      "Start Simple RNN Net Income Bayes Optimization for ",
      x, " (", which(companies == x), "/", length(companies), ")"))
    tune_keras_rnn_bayesoptim(
      data = d,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      model_type = "simple",
      cv_setting = cv_setting_tune,
      tuning_bounds = tuning_bounds
    )
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123)
)

fc_ni_rnn_bayes <- purrr::compact(purrr::set_names(tuning_results, companies))

# Save and send Success / Failure message
if (length(fc_ni_rnn_bayes) > 0) {
  saveRDS(fc_ni_rnn_bayes, file = "03_rnn/simple/results/fc_ni_rnn_bayes.rds", compress = "xz")
  toSlack("Simple RNN Net Income Bayes Optimization finished")
} else toSlack("Simple RNN Net Income Bayes Optimization failed")
