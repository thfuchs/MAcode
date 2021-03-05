### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)

### Read predictions -----------------------------------------------------------

# EBIT
fc_ebit_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_ebit.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_ebit_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ebit.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_ebit_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_ebit_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_ebit_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

# Net Income
fc_ni_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_ni.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_ni_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ni.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_ni_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_ni_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_ni_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

# EPS
fc_eps_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_eps.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_eps_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_eps.rds"),
  ~ purrr::map_df(.x, "forecast", .id = "split")
)
fc_eps_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_eps_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
fc_eps_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

### Combine data sets ----------------------------------------------------------
fc_list <- sapply(c("ebit", "ni", "eps"), function(x) {
  data.table::rbindlist(list(
    get(sprintf("fc_%s_baselines", x)), get(sprintf("fc_%s_arima", x)),
    get(sprintf("fc_%s_simple", x)), get(sprintf("fc_%s_lstm", x)),
    get(sprintf("fc_%s_gru", x))
  ))
}, simplify = FALSE)
fc <- data.table::rbindlist(fc_list, idcol = "id")

fc_pred <- fc["predict" == key]
fc_act <- unique(fc["actual" == key], by = c("id", "ticker", "split", "index"))[, c("id", "ticker", "split", "index", "value")]
data.table::setnames(fc_act, "value", "actual")
fc_pred <- fc_act[fc_pred, on = c("id", "ticker", "split", "index")]

fc_pred[, id := factor(id, levels = c("ebit", "ni", "eps"), labels = c("EBIT", "Net Income", "EPS"))]
fc_pred[, type := factor(
  type,
  levels = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "simple", "lstm", "gru"),
  labels = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "Simple", "LSTM", "GRU")
)]

saveRDS(fc_pred, file = "05_results/predictions.rds", compress = "xz")
