############################# job_simple_ni_02.R ###############################

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
fc_ni_rnn_bayes <- readRDS("03_rnn/simple/results/fc_ni_rnn_bayes.rds")

stopifnot(all(companies == names(fc_ni_rnn_bayes)))

### Job ------------------------------------------------------------------------
forecast_results <- furrr::future_map(
  companies,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    bayes <- fc_ni_rnn_bayes[[x]]
    current <- which(companies == x)
    tmp <- tempdir()
    result <- tune_keras_rnn_predict(
      data = d,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      model_type = "simple",
      cv_setting = cv_setting_test,
      bayes_best_par = purrr::map(bayes, "Best_Par"),
      iter = 10,
      iter_dropout = 500,
      save_model = tmp,
      save_model_id = "ni"
    )
    if (!is.null(result)) {
      RDStoS3(
        data = result,
        filename = paste0("fc_ni_rnn_predict_", x, ".rds"),
        s3_prefix = "simple/predict/ni/"
      )
      tmp_files <- list.files(
        tmp,
        pattern = sprintf("\\w+_ni_simple_%s_\\w+\\.hdf5$", x),
        full.names = TRUE
      )
      hdf5toS3(files = tmp_files, s3_prefix = "simple/models/ni/")
      file.remove(tmp_files)
    }
    if (current <= overall) toSlack(paste0(
      "Simple RNN Net Income: Predicted ", x, "\n",
      round(current/overall * 100, 2), "% (", current, "/", overall, ")"
    ))
    keras::k_clear_session()
    # output
    return(result)
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = NULL)
)

fc_ni_rnn_predict <- purrr::compact(purrr::set_names(forecast_results, companies))

# Save and send Success / Failure message
if (length(fc_ni_rnn_predict) > 0) {
  saveRDS(fc_ni_rnn_predict, file = "03_rnn/simple/results/fc_ni_rnn_predict.rds", compress = "xz")
  RDStoS3(data = fc_ni_rnn_predict, filename = "fc_ni_rnn_predict.rds", s3_prefix = "simple/")
  toSlack("Simple RNN Net Income prediction finished")
} else toSlack("Error: Simple RNN Net Income prediction failed")
