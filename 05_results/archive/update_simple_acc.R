### Settings -------------------------------------------------------------------

library(data.table)
setDTthreads(percent = 100)
library(tsRNN)

### Read predictions -----------------------------------------------------------

ebit_simple_predict <- readRDS("03_rnn/simple/results/fc_ebit_rnn_predict.rds")

ebit_simple_new <- sapply(ebit_simple_predict, function(company) lapply(company, function(split) {
  index_predict <- unique(split[key == "predict", index])
  train <- split[key == "actual" & !index %in% index_predict, value]
  actual <- split[key == "actual" & index %in% index_predict, value]

  acc_new <- purrr::map_df(list(short = 1, medium = 1:4, long = 5:6, total = 1:6), function(h) {
    split[key == "predict", .(
      type = "simple",
      mape = tsRNN::mape(actual[h], value[h]),
      smape = tsRNN::smape(actual[h], value[h]),
      mase = tsRNN::mase(train, actual[h], value[h], m = 4),
      smis = tsRNN::mase(train, actual[h], value[h], m = 4),
      acd = tsRNN::acd(actual[h], lo95[h], hi95[h], level = 0.95)
    )]
  }, .id = "h")
  setcolorder(acc_new, c("type"))

  return(acc_new)
}), simplify = FALSE)

### Checks
ebit_simple <- readRDS("03_rnn/simple/results/fc_ebit_rnn_eval.rds")

library(tinytest)
# check forecasts
all(purrr::map2_lgl(
  ebit_simple,
  ebit_simple_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]]$forecast,
    .y[[split]]$forecast
  )))
))
# check accuracy (except mase and smis)
all(purrr::map2_lgl(
  ebit_simple,
  ebit_simple_new,
  ~ all(purrr::map_lgl(1:9, function(split) expect_identical(
    .x[[split]][, -c("mase", "smis")],
    .y[[split]][, -c("mase", "smis")]
  )))
))

ebit_simple_new_df <- purrr::map_df(ebit_simple_new, ~rbindlist(.x, idcol = "split"), .id = "ticker")
ebit_simple_new_df[!is.finite(smape)]
ebit_simple_new_df[!is.finite(mase)]
ebit_simple_new_df[!is.finite(smis)]

### Save (overwrite)
saveRDS(ebit_simple_new, file = "03_rnn/simple/results/fc_ebit_rnn_eval.rds", compress = "xz")
