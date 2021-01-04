############################## job_lstm_ni_02.R ################################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]
companies <- unique(data_ni$ticker)
overall <- trunc(length(companies) / cores)
fc_ni_rnn_bayes <- readRDS("03_rnn/lstm/results/fc_ni_rnn_bayes.rds")

stopifnot(all(companies == names(fc_ni_rnn_bayes)))

### Job ------------------------------------------------------------------------
forecast <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    current <- which(companies == x)
    if (current <= overall) {
      resp <- toSlack(paste0(
        "LSTM EPS Bayes Optimization: Starting ", x, "\n",
        round(current/overall * 100, 2), "% (", current, "/", overall, ")"
      ))
    }
    bayes <- fc_ni_rnn_bayes[[x]]
    toSlack(paste0(
      "Start LSTM Net Income Prediction for ",
      x, " (", which(companies == x), "/", length(companies), ")"))
    tune_keras_rnn_predict(
      data = d,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      model_type = "lstm",
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      iter_dropout = 500,
      save_model = NULL
      # save_model_id = "ni"
    )
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123)
)

fc_ni_rnn_prediction <- purrr::compact(purrr::set_names(forecast, companies))

# Save and send Success / Failure message
if (length(fc_ni_rnn_prediction) > 0) {
  saveRDS(fc_ni_rnn_prediction, file = "03_rnn/lstm/results/fc_ni_rnn_prediction.rds", compress = "xz")
  toSlack("LSTM Net Income prediction finished")
} else toSlack("Error: LSTM Net Income prediction failed")
