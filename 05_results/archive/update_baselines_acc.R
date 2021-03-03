### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)
library(tsRNN)

### Read predictions -----------------------------------------------------------

# Baselines
ebit_baselines <- readRDS("01_baselines/fc_baselines_ebit.rds")
x <- sapply(ebit_baselines, function(company) lapply(company, function(split) {
  split$accuracy[, type := factor(type, levels = c("Naive", "Snaive", "Drift", "Holt"))]
}), simplify = FALSE)
rm(x)

ebit_baselines_new <- sapply(ebit_baselines, function(company) lapply(company, function(split) {
  data <- split$forecast
  index_predict <- unique(data[key == "predict", index])
  train <- data[key == "actual" & !index %in% index_predict, value]
  actual <- data[key == "actual" & index %in% index_predict, value]

  acc_new <- purrr::map_df(list(short = 1, medium = 1:4, long = 5:6, total = 1:6), function(h) {
    data[key == "predict", .(
      mape = tsRNN::mape(actual[h], value[h]),
      smape = tsRNN::smape(actual[h], value[h]),
      mase = tsRNN::mase(train, actual[h], value[h], m = 4),
      smis = tsRNN::smis(train, actual[h], lo95[h], hi95[h], m = 4, level = 0.95),
      acd = tsRNN::acd(actual[h], lo95[h], hi95[h], level = 0.95)
    ), by = "type"]
  }, .id = "h")
  setcolorder(acc_new, c("type", "h"))
  acc_new[, type := factor(type, levels = c("Naive", "Snaive", "Drift", "Holt"))]
  setorder(acc_new, type)

  return(list(forecast = split$forecast, accuracy = acc_new))
}), simplify = FALSE)

### Checks
library(tinytest)
# check forecasts
all(purrr::map2_lgl(
  ebit_baselines,
  ebit_baselines_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]]$forecast,
    .y[[split]]$forecast
  )))
))
# check accuracy (except mase and smis)
all(purrr::map2_lgl(
  ebit_baselines,
  ebit_baselines_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]]$accuracy[, -c("smis")],
    .y[[split]]$accuracy[, -c("smis")]
  )))
))

ebit_baselines_new_df <- purrr::map_df(ebit_baselines_new, ~rbindlist(purrr::map(.x, "accuracy"), idcol = "split"), .id = "ticker")
ebit_baselines_new_df[!is.finite(smape)]
ebit_baselines_new_df[!is.finite(mase)]
ebit_baselines_new_df[!is.finite(smis)]

### Save (overwrite)
# saveRDS(ebit_baselines_new, file = "01_baselines/fc_baselines_ebit.rds", compress = "xz")
