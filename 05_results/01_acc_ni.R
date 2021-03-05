### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)

acc_rank_str <- c("smape", "mase", "smis")

# Functions
source("05_results/00_fun_results.R")

### Read and compare accuracies ------------------------------------------------

acc_ni_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_ni.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "ticker"
)
acc_ni_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ni.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "ticker"
)
acc_ni_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ni_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_ni_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ni_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_ni_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ni_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_ni_arnn <- readRDS("04_hybrids/acc_ni_arnn_mean.rds")

### Accuracy -------------------------------------------------------------------

# All Models
acc_mean_rank_save(
  acc_ni_baselines, acc_ni_arima, acc_ni_simple, acc_ni_gru, acc_ni_lstm, acc_ni_arnn,
  rank_str = acc_rank_str,
  type_old = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "simple", "gru", "lstm", "arnn_mean"),
  type_new = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "Simple", "GRU", "LSTM", "ARNN"),
  file_path = "05_results/acc_ni.rds"
)
