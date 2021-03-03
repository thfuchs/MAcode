### Settings -------------------------------------------------------------------
library(data.table)
setDTthreads(percent = 100)

companies <- readRDS("data/dummies.rds")$ticker
companies_order <- data.table(ticker = companies, .r = order(companies))

### Function -------------------------------------------------------------------
averaging_acc <- function(data_list, method, name) {

  cols <- c("value", "lo95", "hi95")

  fc_all <- data.table::rbindlist(data_list)
  fc_actual <- unique(fc_all[key == "actual"], by = c("ticker", "split", "index"))

  # Averaging (by "mean" or "median")
  fc_pred <- fc_all[
    key == "predict",
    lapply(.SD, function(x) if (method == "median") median(x) else mean(x)),
    by = c("ticker", "split", "index", "key"), .SDcols = cols
  ][, type := name]

  fc_avg <- rbind(fc_actual, fc_pred)

  setorder(fc_avg[companies_order, on = "ticker"], .r, split, key, index)[, .r := NULL]
  fc_avg[, N := .N > 1 & key == "actual", by = c("ticker", "split", "index")]

  # Calculate accuracy measures for hybrid predictions
  acc_avg <- fc_avg[
    , purrr::map_df(
      list(short = 1, medium = 1:4, long = 5:6, total = 1:6),
      function(h) c(
        mape = tsRNN::mape(actual = .SD[(N), value][h], .SD[key == "predict", value][h]),
        smape = tsRNN::smape(actual = .SD[(N), value][h], .SD[key == "predict", value][h]),
        mase = tsRNN::mase(
          data = .SD[(!N) & key == "actual", value],
          actual = .SD[(N), value][h],
          forecast = .SD[key == "predict", value][h],
          m = 4
        ),
        smis = tsRNN::smis(
          data = .SD[(!N) & key == "actual", value],
          actual = .SD[(N), value][h],
          lower = .SD[key == "predict", lo95][h],
          upper = .SD[key == "predict", hi95][h],
          m = 4,
          level = 0.95
        ),
        acd = tsRNN::acd(
          actual = .SD[(N), value][h],
          lower = .SD[key == "predict", lo95][h],
          upper = .SD[key == "predict", hi95][h],
          level = 0.95
        )
      ), .id = "h"
    ), by = c("ticker", "split"), .SDcols = c("value", "lo95", "hi95")
  ]
  acc_avg[, type := name]

  return(acc_avg)
}

### EBIT -----------------------------------------------------------------------

# 0. Read forecast data
ebit_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ebit.rds"),
  ~ purrr::map_df(.x, ~ .x[["forecast"]], .id = "split")
)
ebit_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
ebit_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
ebit_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ebit_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

# 1. ARNN = ARIMA + RNN (Simple, GRU, LSTM)
acc_ebit_arnn_mean <- averaging_acc(
  data_list = list(ebit_arima, ebit_simple, ebit_gru, ebit_lstm),
  method = "mean",
  name = "arnn_mean"
)
saveRDS(acc_ebit_arnn_mean, "04_hybrids/acc_ebit_arnn_mean.rds", compress = "xz")

acc_ebit_arnn_med <- averaging_acc(
  data_list = list(ebit_arima, ebit_simple, ebit_gru, ebit_lstm),
  method = "median",
  name = "arnn_med"
)
saveRDS(acc_ebit_arnn_med, "04_hybrids/acc_ebit_arnn_med.rds", compress = "xz")

# 2. ARIMA + GRU (Mean)
acc_ebit_agru <- averaging_acc(
  data_list = list(ebit_arima, ebit_gru),
  method =  "mean",
  name = "agru"
)
saveRDS(acc_ebit_agru, "04_hybrids/acc_ebit_agru.rds", compress = "xz")

# 3. ARIMA + LSTM (Mean)
acc_ebit_alstm <- averaging_acc(
  data_list = list(ebit_arima, ebit_lstm),
  method =  "mean",
  name = "alstm"
)
saveRDS(acc_ebit_alstm, "04_hybrids/acc_ebit_alstm.rds", compress = "xz")

# 4. RNN
acc_ebit_rnn_mean <- averaging_acc(
  data_list = list(ebit_simple, ebit_gru, ebit_lstm),
  method = "mean",
  name = "rnn"
)
saveRDS(acc_ebit_rnn_mean, "04_hybrids/acc_ebit_rnn_mean.rds", compress = "xz")

acc_ebit_rnn_med <- averaging_acc(
  data_list = list(ebit_simple, ebit_gru, ebit_lstm),
  method = "median",
  name = "rnn"
)
saveRDS(acc_ebit_rnn_med, "04_hybrids/acc_ebit_rnn_med.rds", compress = "xz")


### Net Income -----------------------------------------------------------------

# 0. Read forecast data
ni_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_ni.rds"),
  ~ purrr::map_df(.x, ~ .x[["forecast"]], .id = "split"),
)
ni_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
ni_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
ni_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_ni_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

# 1. ARNN = ARIMA + RNN (Simple, GRU, LSTM)
acc_ni_arnn_mean <- averaging_acc(
  data_list = list(ni_arima, ni_simple, ni_gru, ni_lstm),
  method = "mean",
  name = "arnn_mean"
)
saveRDS(acc_ni_arnn_mean, "04_hybrids/acc_ni_arnn_mean.rds", compress = "xz")

acc_ni_arnn_med <- averaging_acc(
  data_list = list(ni_arima, ni_simple, ni_gru, ni_lstm),
  method = "median",
  name = "arnn_med"
)
saveRDS(acc_ni_arnn_med, "04_hybrids/acc_ni_arnn_med.rds", compress = "xz")

# 2. ARIMA + GRU (Mean)
acc_ni_agru <- averaging_acc(
  data_list = list(ni_arima, ni_gru),
  method =  "mean",
  name = "agru"
)
saveRDS(acc_ni_agru, "04_hybrids/acc_ni_agru.rds", compress = "xz")

# 3. ARIMA + LSTM (Mean)
acc_ni_alstm <- averaging_acc(
  data_list = list(ni_arima, ni_lstm),
  method =  "mean",
  name = "alstm"
)
saveRDS(acc_ni_alstm, "04_hybrids/acc_ni_alstm.rds", compress = "xz")

# 4. RNN
acc_ni_rnn_mean <- averaging_acc(
  data_list = list(ni_simple, ni_gru, ni_lstm),
  method = "mean",
  name = "rnn"
)
saveRDS(acc_ni_rnn_mean, "04_hybrids/acc_ni_rnn_mean.rds", compress = "xz")

acc_ni_rnn_med <- averaging_acc(
  data_list = list(ni_simple, ni_gru, ni_lstm),
  method = "median",
  name = "rnn"
)
saveRDS(acc_ni_rnn_med, "04_hybrids/acc_ni_rnn_med.rds", compress = "xz")


### EPS ------------------------------------------------------------------------

# 0. Read forecast data
eps_arima <- purrr::map_df(
  readRDS("02_arima/fc_arima_eps.rds"),
  ~ purrr::map_df(.x, ~ .x[["forecast"]], .id = "split")
)
eps_simple <- purrr::map_df(
  readRDS("03_rnn/simple/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
eps_gru <- purrr::map_df(
  readRDS("03_rnn/gru/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)
eps_lstm <- purrr::map_df(
  readRDS("03_rnn/lstm/results/fc_eps_rnn_predict.rds"),
  ~ data.table::rbindlist(.x, idcol = "split")[, split := as.numeric(gsub("Slice", "", split))]
)

# 1. ARNN = ARIMA + RNN (Simple, GRU, LSTM)
acc_eps_arnn_mean <- averaging_acc(
  data_list = list(eps_arima, eps_simple, eps_gru, eps_lstm),
  method = "mean",
  name = "arnn_mean"
)
saveRDS(acc_eps_arnn_mean, "04_hybrids/acc_eps_arnn_mean.rds", compress = "xz")

acc_eps_arnn_med <- averaging_acc(
  data_list = list(eps_arima, eps_simple, eps_gru, eps_lstm),
  method = "median",
  name = "arnn_med"
)
saveRDS(acc_eps_arnn_med, "04_hybrids/acc_eps_arnn_med.rds", compress = "xz")

# 2. ARIMA + GRU (Mean)
acc_eps_agru <- averaging_acc(
  data_list = list(eps_arima, eps_gru),
  method =  "mean",
  name = "agru"
)
saveRDS(acc_eps_agru, "04_hybrids/acc_eps_agru.rds", compress = "xz")

# 3. ARIMA + LSTM (Mean)
acc_eps_alstm <- averaging_acc(
  data_list = list(eps_arima, eps_lstm),
  method =  "mean",
  name = "alstm"
)
saveRDS(acc_eps_alstm, "04_hybrids/acc_eps_alstm.rds", compress = "xz")

# 4. RNN
acc_eps_rnn_mean <- averaging_acc(
  data_list = list(eps_simple, eps_gru, eps_lstm),
  method = "mean",
  name = "rnn"
)
saveRDS(acc_eps_rnn_mean, "04_hybrids/acc_eps_rnn_mean.rds", compress = "xz")

acc_eps_rnn_med <- averaging_acc(
  data_list = list(eps_simple, eps_gru, eps_lstm),
  method = "median",
  name = "rnn"
)
saveRDS(acc_eps_rnn_med, "04_hybrids/acc_eps_rnn_med.rds", compress = "xz")
