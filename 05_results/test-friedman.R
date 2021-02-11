# Friedman test

library(data.table)

# H1: ARIMA vs. Baselines
acc_ebit_h1 <- readRDS("05_results/acc_ebit_h1.rds")

friedman_ebit_h1_list <- sapply(levels(acc_ebit_h1$h), function(horizon) {
  mat <- as.matrix(data.table::dcast(
    acc_ebit_h1[h == horizon], company ~ type, value.var = "smape"
  )[, -"company"])
  stats::friedman.test(mat)
}, simplify = FALSE)

friedman_ebit_h1 <- purrr::map_df(friedman_ebit_h1_list, function(x) data.table(
  `chi-squared` = x[["statistic"]], `p-value` = x[["p.value"]]
), .id = "h")

# H2: RNN
acc_ebit_h2_rnn <- readRDS("05_results/acc_ebit_h2_rnn.rds")

friedman_ebit_h2_rnn_list <- sapply(levels(acc_ebit_h2_rnn$h), function(horizon) {
  mat <- as.matrix(data.table::dcast(
    acc_ebit_h1[h == horizon], company ~ type, value.var = "smape"
  )[, -"company"])
  stats::friedman.test(mat)
}, simplify = FALSE)

friedman_ebit_h2_rnn <- purrr::map_df(friedman_ebit_h2_rnn_list, function(x) data.table(
  `chi-squared` = x[["statistic"]], `p-value` = x[["p.value"]]
), .id = "h")

# H3: LSTM vs. GRU
acc_ebit_h3 <- readRDS("05_results/acc_ebit_h3.rds")

friedman_ebit_h3_list <- sapply(levels(acc_ebit_h3$h), function(horizon) {
  mat <- as.matrix(data.table::dcast(
    acc_ebit_h1[h == horizon], company ~ type, value.var = "smape"
  )[, -"company"])
  stats::friedman.test(mat)
}, simplify = FALSE)

friedman_ebit_h3 <- purrr::map_df(friedman_ebit_h3_list, function(x) data.table(
  `chi-squared` = x[["statistic"]], `p-value` = x[["p.value"]]
), .id = "h")
