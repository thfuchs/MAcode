######################### 01_baselines_estimate ################################

################################################################################
### Computation of cross-validated baseline forecasts and evaluation scores  ###
################################################################################

### Settings -------------------------------------------------------------------
source("settings.R")
source("utils.R")

fc_horizon <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### EBIT -----------------------------------------------------------------------
data_ebit <- readRDS("data/data_ebit.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    cv_baselines(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline EBIT estimation finished")

fc_baselines_ebit <- purrr::compact(purrr::set_names(forecast, dummies$ticker))
str(fc_baselines_ebit, max.level = 1)

saveRDS(fc_baselines_ebit, file = "01_baselines/fc_baselines_ebit.rds", compress = "xz")

### Net Income -----------------------------------------------------------------
data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    cv_baselines(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline Net Income estimation finished")

fc_baselines_ni <- purrr::compact(purrr::set_names(forecast, dummies$ticker))
str(fc_baselines_ni, max.level = 1)

saveRDS(fc_baselines_ni, file = "01_baselines/fc_baselines_ni.rds", compress = "xz")

### EPS ------------------------------------------------------------------------
data_eps <- readRDS("data/data_eps.rds")[, .(ticker, index, value)]

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    cv_baselines(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)
toSlack("Baseline EPS estimation finished")

fc_baselines_eps <- purrr::compact(purrr::set_names(forecast, dummies$ticker))
str(fc_baselines_eps, max.level = 1)

saveRDS(fc_baselines_eps, file = "01_baselines/fc_baselines_eps.rds", compress = "xz")
