############################ job_simple_ebit_01.R ##############################

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

data_ebit <- readRDS("data/data_ebit.rds")[ticker %in% c("CAT_UN", "HOLMB_SS"), .(ticker, index, value)]
companies <- unique(data_ebit$ticker)

tuning_results <- furrr::future_map(
  unique(data_ebit$ticker),
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    toSlack(paste0(
      "Start Simple RNN EBIT Bayes Optimization for ",
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

fc_ebit_rnn_bayes <- purrr::compact(tuning_results)

saveRDS(fc_ebit_rnn_bayes, file = "03_rnn/simple/fc_ebit_rnn_bayes.rds", compress = "xz")

# Success / Failure message
if (length(fc_ebit_rnn_bayes) > 0)
  toSlack("Simple RNN EBIT Bayes Optimization finished") else
    toSlack("Simple RNN EBIT Bayes Optimization failed")
