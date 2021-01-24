############################ estimate_arima.R ##################################

################################################################################
### Computation of cross-validated ARIMA forecasts and evaluation scores     ###
################################################################################

### Settings -------------------------------------------------------------------
source("settings.R")
source("utils.R")

fc_horizon <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)
overall <- trunc(length(dummies$ticker) / cores)

### EBIT -----------------------------------------------------------------------
data_ebit <- readRDS("data/data_ebit.rds")[, .(ticker, index, value)]
stopifnot(all(dummies$ticker == unique(data_ebit$ticker)))

fc_ebit <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    current <- which(dummies$ticker == x)
    result <- cv_arima(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
    if (current <= overall) toSlack(paste0(
      "ARIMA EBIT Estimation: Finished ", x, "\n",
      round(current/overall * 100, 2), "% (", current, "/", overall, ")"
    ))
    return(result)
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)

fc_arima_ebit <- purrr::set_names(fc_ebit, dummies$ticker)
# fc_arima_ebit <- purrr::compact(forecast)
# str(fc_arima_ebit, max.level = 1)

saveRDS(fc_arima_ebit, file = "02_arima/fc_arima_ebit.rds", compress = "xz")
toSlack("ARIMA EBIT estimation finished")

### Net Income -----------------------------------------------------------------
data_ni <- readRDS("data/data_ni.rds")[, .(ticker, index, value)]
stopifnot(all(dummies$ticker == unique(data_ni$ticker)))

fc_ni <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ni[ticker == x]
    current <- which(dummies$ticker == x)
    result <- cv_arima(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
    if (current <= overall) toSlack(paste0(
      "ARIMA Net Income Estimation: Finished ", x, "\n",
      round(current/overall * 100, 2), "% (", current, "/", overall, ")"
    ))
    return(result)
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)

fc_arima_ni <- purrr::set_names(fc_ni, dummies$ticker)
# fc_arima_ni <- purrr::compact(forecast)
# str(fc_arima_ni, max.level = 1)

saveRDS(fc_arima_ni, file = "02_arima/fc_arima_ni.rds", compress = "xz")
toSlack("ARIMA Net Income estimation finished")

### EPS -----------------------------------------------------------------
data_eps <- readRDS("data/data_eps.rds")[, .(ticker, index, value)]
stopifnot(all(dummies$ticker == unique(data_eps$ticker)))

fc_eps <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_eps[ticker == x]
    current <- which(dummies$ticker == x)
    result <- cv_arima(
      data = d,
      cv_setting = cv_setting_test,
      col_id = "ticker",
      col_date = "index",
      col_value = "value",
      h = fc_horizon,
      frequency = 4
    )
    if (current <= overall) toSlack(paste0(
      "ARIMA EPS Estimation: Finished ", x, "\n",
      round(current/overall * 100, 2), "% (", current, "/", overall, ")"
    ))
    return(result)
  }, otherwise = NULL, quiet = FALSE),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)

fc_arima_eps <- purrr::set_names(fc_eps, dummies$ticker)
# fc_arima_eps <- purrr::compact(forecast)
# str(fc_arima_eps, max.level = 1)

saveRDS(fc_arima_eps, file = "02_arima/fc_arima_eps.rds", compress = "xz")
toSlack("ARIMA EPS estimation finsihed")
