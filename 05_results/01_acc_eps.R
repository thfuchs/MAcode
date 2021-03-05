### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)

acc_rank_str <- c("smape", "mase", "smis")

# Functions
source("05_results/00_fun_results.R")

### Read and compare accuracies ------------------------------------------------

acc_eps_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_eps.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "ticker"
)
acc_eps_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_eps.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "ticker"
)
acc_eps_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_eps_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_eps_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_eps_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_eps_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_eps_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "ticker"
)
acc_eps_arnn <- readRDS("04_hybrids/acc_eps_arnn_mean.rds")

### Accuracy -------------------------------------------------------------------

# All Models
acc_mean_rank_save(
  acc_eps_baselines, acc_eps_arima, acc_eps_simple, acc_eps_gru, acc_eps_lstm, acc_eps_arnn,
  rank_str = acc_rank_str,
  type_old = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "simple", "gru", "lstm", "arnn_mean"),
  type_new = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "Simple", "GRU", "LSTM", "ARNN"),
  file_path = "05_results/acc_eps.rds"
)
