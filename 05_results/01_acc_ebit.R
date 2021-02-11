### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)

acc_rank_str <- c("mape", "smape", "mase", "smis", "acd")

# Functions
source("05_results/00_fun_results.R")

### Read and compare accuracies ------------------------------------------------

acc_ebit_baselines <- purrr::map_df(
  readRDS("01_baselines/fc_baselines_ebit.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
acc_ebit_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ebit.rds"),
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
acc_ebit_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ebit_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "company"
)
acc_ebit_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ebit_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "company"
)
acc_ebit_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ebit_rnn_eval.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))],
  .id = "company"
)
acc_ebit_baselines_mean <- readRDS("04_hybrids/acc_ebit_baselines.rds")
acc_ebit_arnn <- readRDS("04_hybrids/acc_ebit_arnn_mean.rds")
acc_ebit_rnn <- readRDS("04_hybrids/acc_ebit_rnn_mean.rds")

### Accuracy -------------------------------------------------------------------

# All Models
acc_mean_rank_save(
  acc_ebit_baselines, acc_ebit_arima, acc_ebit_simple, acc_ebit_gru, acc_ebit_lstm, acc_ebit_arnn,
  rank_str = acc_rank_str,
  type_old = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "simple", "gru", "lstm", "arnn_mean"),
  type_new = c("Naive", "Snaive", "Drift", "Holt", "ARIMA", "Simple", "GRU", "LSTM", "ARNN"),
  file_path = "05_results/acc_ebit_01.rds"
)

# Mean Baselines + Others
acc_mean_rank_save(
  acc_ebit_baselines_mean, acc_ebit_arima, acc_ebit_simple, acc_ebit_gru, acc_ebit_lstm, acc_ebit_arnn,
  rank_str = acc_rank_str,
  type_old = c("Baselines", "ARIMA", "simple", "gru", "lstm", "arnn_mean"),
  type_new = c("Baselines", "ARIMA", "Simple", "GRU", "LSTM", "ARNN"),
  file_path = "05_results/acc_ebit_02.rds"
)

# Mean Baselines + ARIMA + Mean RNN + Hybrids
acc_mean_rank_save(
  acc_ebit_baselines_mean, acc_ebit_arima, acc_ebit_arnn, acc_ebit_rnn,
  rank_str = acc_rank_str,
  type_old = c("Baselines", "ARIMA", "arnn_mean", "rnn"),
  type_new = c("Baselines", "ARIMA", "ARNN", "RNN"),
  file_path = "05_results/acc_ebit_03.rds"
)

# H1: Baseline models vs. ARIMA
acc_mean_rank_save(
  acc_ebit_baselines, acc_ebit_arima,
  rank_str = acc_rank_str,
  type_old = NULL,
  type_new = NULL,
  file_path = "05_results/acc_ebit_h1.rds"
)
acc_rank_mean_save(
  acc_ebit_baselines, acc_ebit_arima,
  rank_str = acc_rank_str,
  type_old = NULL,
  type_new = NULL,
  file_path = "05_results/acc_ebit_h1_rankavg.rds"
)

# H2: Baseline models vs. LSTM / GRU
acc_mean_rank_save(
  acc_ebit_baselines, acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("Naive", "Snaive", "Drift", "Holt", "lstm", "gru"),
  type_new = c("Naive", "Snaive", "Drift", "Holt", "LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h2_baselines.rds"
)
acc_rank_mean_save(
  acc_ebit_baselines, acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("Naive", "Snaive", "Drift", "Holt", "lstm", "gru"),
  type_new = c("Naive", "Snaive", "Drift", "Holt", "LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h2_baselines_rankavg.rds"
)

# H2: ARIMA vs. LSTM / GRU
acc_mean_rank_save(
  acc_ebit_arima, acc_ebit_lstm,
  rank_str = acc_rank_str,
  type_old = c("ARIMA", "lstm"),
  type_new = c("ARIMA", "LSTM"),
  file_path = "05_results/acc_ebit_h2_arima_lstm.rds"
)
acc_rank_mean_save(
  acc_ebit_arima, acc_ebit_lstm,
  rank_str = acc_rank_str,
  type_old = c("ARIMA", "lstm"),
  type_new = c("ARIMA", "LSTM"),
  file_path = "05_results/acc_ebit_h2_arima_lstm_rankavg.rds"
)

acc_mean_rank_save(
  acc_ebit_arima, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("ARIMA", "gru"),
  type_new = c("ARIMA", "GRU"),
  file_path = "05_results/acc_ebit_h2_arima_gru.rds"
)
acc_rank_mean_save(
  acc_ebit_arima, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("ARIMA", "gru"),
  type_new = c("ARIMA", "GRU"),
  file_path = "05_results/acc_ebit_h2_arima_gru_rankavg.rds"
)

# H2: Simple RNN vs. LSTM / GRU
acc_mean_rank_save(
  acc_ebit_simple, acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("simple", "lstm", "gru"),
  type_new = c("Simple", "LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h2_rnn.rds"
)
acc_rank_mean_save(
  acc_ebit_simple, acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("simple", "lstm", "gru"),
  type_new = c("Simple", "LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h2_rnn_rankavg.rds"
)

acc_mean_rank_save(
  acc_ebit_simple, acc_ebit_lstm,
  rank_str = acc_rank_str,
  type_old = c("simple", "lstm"),
  type_new = c("lstm", "LSTM"),
  file_path = "05_results/acc_ebit_h2_simple_lstm.rds"
)
acc_rank_mean_save(
  acc_ebit_simple, acc_ebit_lstm,
  rank_str = acc_rank_str,
  type_old = c("simple", "lstm"),
  type_new = c("Simple", "LSTM"),
  file_path = "05_results/acc_ebit_h2_simple_lstm_rankavg.rds"
)

acc_mean_rank_save(
  acc_ebit_simple, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("simple", "gru"),
  type_new = c("Simple", "GRU"),
  file_path = "05_results/acc_ebit_h2_simple_gru.rds"
)
acc_rank_mean_save(
  acc_ebit_simple, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("simple", "gru"),
  type_new = c("Simple", "GRU"),
  file_path = "05_results/acc_ebit_h2_simple_gru_rankavg.rds"
)

# H3: LSTM vs. GRU
acc_mean_rank_save(
  acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("lstm", "gru"),
  type_new = c("LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h3.rds"
)
acc_rank_mean_save(
  acc_ebit_lstm, acc_ebit_gru,
  rank_str = acc_rank_str,
  type_old = c("lstm", "gru"),
  type_new = c("LSTM", "GRU"),
  file_path = "05_results/acc_ebit_h3_rankavg.rds"
)
