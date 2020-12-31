############################ job_simple_ebit_02.R ##############################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

data_ebit <- readRDS("data/data_ebit.rds")[ticker %in% c("CAT_UN", "HOLMB_SS"), .(ticker, index, value)]
companies <- unique(data_ebit$ticker)
fc_ebit_rnn_bayes <- readRDS("03_rnn/simple/fc_ebit_rnn_bayes.rds")

### Job ------------------------------------------------------------------------
forecast <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    bayes <- fc_ebit_rnn_bayes[[x]]
    toSlack(paste0(
      "Start Simple RNN EBIT Prediction for ",
      x, " (", which(companies == x), "/", length(companies), ")"))
    tune_keras_rnn_predict(
      data = d,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      model_type = "simple",
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      iter_dropout = 500,
      save_model = NULL
      # save_model_id = "ebit"
    )
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123)
)

fc_ebit_rnn_prediction <- purrr::compact(purrr::set_names(forecast, companies))

# Save and send Success / Failure message
if (length(fc_ebit_rnn_prediction) > 0) {
  saveRDS(fc_ebit_rnn_prediction, file = "03_rnn/simple/fc_ebit_rnn_prediction.rds", compress = "xz")
  toSlack("Simple RNN EBIT prediction finished")
} else toSlack("Error: Simple RNN EBIT prediction failed")
