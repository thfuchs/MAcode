######################### 01_baselines_estimate ################################

################################################################################
### Computation of cross-validated baseline forecasts and evaluation scores ####
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
    predict_baselines(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline EBIT estimation finished!")

fc_baselines_ebit <- purrr::compact(forecast)
str(fc_baselines_ebit, max.level = 1)

saveRDS(fc_baselines_ebit, file = "baseline/fc_baselines_ebit.rds", compress = "xz")

### Net Income -----------------------------------------------------------------
data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    predict_baselines(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline Net Income estimation finished!")

fc_baselines_ni <- purrr::compact(forecast)
str(fc_baselines_ni, max.level = 1)

saveRDS(fc_baselines_ni, file = "baseline/fc_baselines_ni.rds", compress = "xz")

### EPS ------------------------------------------------------------------------
data_eps <- readRDS("data/data_eps.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    predict_baselines(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline EPS estimation finished!")

fc_baselines_eps <- purrr::compact(forecast)
str(fc_baselines_eps, max.level = 1)

saveRDS(fc_baselines_eps, file = "baseline/fc_baselines_eps.rds", compress = "xz")
