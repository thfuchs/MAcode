############################# job_simple_eps_02.R ##############################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

data_eps <- readRDS("data/data_eps.rds")[, .(ticker, index, value)]
companies <- unique(data_eps$ticker)
overall <- trunc(length(companies) / cores)
fc_eps_rnn_bayes <- readRDS("03_rnn/simple/results/fc_eps_rnn_bayes.rds")

stopifnot(all(companies == names(fc_eps_rnn_bayes)))

### Job ------------------------------------------------------------------------
forecast <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    current <- which(companies == x)
    if (current <= overall) {
      resp <- toSlack(paste0(
        "Simple RNN EPS Bayes Optimization: Starting ", x, "\n",
        round(current/overall * 100, 2), "% (", current, "/", overall, ")"
      ))
    }
    bayes <- fc_eps_rnn_bayes[[x]]
    toSlack(paste0(
      "Start Simple RNN EPS Prediction for ",
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
      # save_model_id = "eps"
    )
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123)
)

fc_eps_rnn_prediction <- purrr::compact(purrr::set_names(forecast, companies))

# Save and send Success / Failure message
if (length(fc_eps_rnn_prediction) > 0) {
  saveRDS(fc_eps_rnn_prediction, file = "03_rnn/simple/results/fc_eps_rnn_prediction.rds", compress = "xz")
  toSlack("Simple RNN EPS prediction finished")
} else toSlack("Error: Simple RNN EPS prediction failed")
