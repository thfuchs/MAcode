############################## job_gru_eps_02.R ################################

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
fc_eps_rnn_bayes <- readRDS("03_rnn/gru/results/fc_eps_rnn_bayes.rds")

stopifnot(all(companies == names(fc_eps_rnn_bayes)))

### Job ------------------------------------------------------------------------
forecast_results <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    bayes <- fc_eps_rnn_bayes[[x]]
    current <- which(companies == x)
    tmp <- tempdir()
    result <- tune_keras_rnn_predict(
      data = d,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      model_type = "gru",
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      iter = 10,
      iter_dropout = 500,
      save_model = tmp,
      save_model_id = "eps"
    )
    if (!is.null(result)) {
      RDStoS3(
        data = result,
        filename = paste0("fc_eps_rnn_predict_", x, ".rds"),
        s3_prefix = "gru/predict/eps/"
      )
      tmp_files <- list.files(
        tmp,
        pattern = sprintf("\\w+_eps_gru_%s_\\w+\\.hdf5$", x),
        full.names = TRUE
      )
      hdf5toS3(files = tmp_files, s3_prefix = "gru/models/eps/")
      file.remove(tmp_files)
    }
    if (current <= overall) toSlack(paste0(
      "GRU EPS: Predicted ", x, "\n",
      round(current/overall * 100, 2), "% (", current, "/", overall, ")"
    ))
    keras::k_clear_session()
    # output
    return(result)
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = NULL)
)

fc_eps_rnn_predict <- purrr::compact(purrr::set_names(forecast_results, companies))

# Save and send Success / Failure message
if (length(fc_eps_rnn_predict) > 0) {
  saveRDS(fc_eps_rnn_predict, file = "03_rnn/gru/results/fc_eps_rnn_predict.rds", compress = "xz")
  RDStoS3(data = fc_eps_rnn_predict, filename = "fc_eps_rnn_predict.rds", s3_prefix = "gru/")
  toSlack("GRU EPS prediction finished")
} else toSlack("Error: GRU EPS prediction failed")
