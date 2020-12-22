######################### 01_baselines_estimate ################################

################################################################################
#### Computation of cross-validated ARIMA forecasts and evaluation scores ######
################################################################################

### Settings -------------------------------------------------------------------
library(data.table)
library(future)
library(furrr)
library(tsRNN)
plan(multisession)

source("utils.R")

dummies <- readRDS("data/dummies.rds")

cv_setting <- list(
  periods_train = 36,
  periods_val = 6,
  periods_test = 6,
  skip_span = 3
)

multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### EBIT -----------------------------------------------------------------------
data_ebit <- readRDS("data/data_ebit.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    predict_arima(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("ARIMA EBIT estimation finished")

fc_arima_ebit <- purrr::compact(forecast)
str(fc_arima_ebit, max.level = 1)

saveRDS(fc_arima_ebit, file = "arima/fc_arima_ebit.rds")

### Net Income -----------------------------------------------------------------
data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    predict_arima(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("ARIMA Net Income estimation finished")

fc_arima_ni <- purrr::compact(forecast)
str(fc_arima_ni, max.level = 1)

saveRDS(fc_arima_ni, file = "arima/fc_arima_ni.rds")

### EPS -----------------------------------------------------------------
data_eps <- readRDS("data/data_eps.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    predict_arima(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("ARIMA EPS estimation finished")

fc_arima_eps <- purrr::compact(forecast)
str(fc_arima_eps, max.level = 1)

saveRDS(fc_arima_eps, file = "arima/fc_arima_eps.rds")
