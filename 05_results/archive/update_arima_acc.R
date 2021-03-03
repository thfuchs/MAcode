### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)
library(tsRNN)

### Read predictions -----------------------------------------------------------

ni_arima <- readRDS("02_arima/fc_arima_ni.rds")

ni_arima_new <- sapply(ni_arima, function(company) lapply(company, function(split) {
  data <- split$forecast
  index_predict <- unique(data[key == "predict", index])
  train <- data[key == "actual" & !index %in% index_predict, value]
  actual <- data[key == "actual" & index %in% index_predict, value]

  acc_new <- purrr::map_df(list(short = 1, medium = 1:4, long = 5:6, total = 1:6), function(h) {
    data[key == "predict", .(
      type = "ARIMA",
      mape = tsRNN::mape(actual[h], value[h]),
      smape = tsRNN::smape(actual[h], value[h]),
      mase = tsRNN::mase(train, actual[h], value[h], m = 4),
      smis = tsRNN::smis(train, actual[h], lo95[h], hi95[h], m = 4, level = 0.95),
      acd = tsRNN::acd(actual[h], lo95[h], hi95[h], level = 0.95)
    )]
  }, .id = "h")
  setcolorder(acc_new, c("type"))

  return(list(forecast = split$forecast, accuracy = acc_new))
}), simplify = FALSE)

### Checks
library(tinytest)
# check forecasts
all(purrr::map2_lgl(
  ni_arima,
  ni_arima_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]]$forecast,
    .y[[split]]$forecast
  )))
))
# check accuracy (except mase and smis)
all(purrr::map2_lgl(
  ni_arima,
  ni_arima_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]]$accuracy[, -c("smis")],
    .y[[split]]$accuracy[, -c("smis")]
  )))
))

ni_arima_new_df <- purrr::map_df(ni_arima_new, ~rbindlist(purrr::map(.x, "accuracy"), idcol = "split"), .id = "ticker")
ni_arima_new_df[!is.finite(smape)]
ni_arima_new_df[!is.finite(mase)]
ni_arima_new_df[!is.finite(smis)]

### Save (overwrite)
saveRDS(ni_arima_new, file = "02_arima/fc_arima_ni.rds", compress = "xz")
