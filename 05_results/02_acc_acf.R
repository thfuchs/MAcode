################################################################################
### Add mean autocorrelation function (acf) across splits per company to     ###
### acc_ebit, acc_ni and acc_eps                                             ###
################################################################################

source("settings.R")
n_initial <- cv_setting_test$periods_train + cv_setting_test$periods_val

### 1. EBIT
acc_ebit <- readRDS("05_results/acc_ebit.rds")
data_ebit <- readRDS("data/data_ebit.rds")

acf_ebit <- purrr::map_df(
  unique(acc_ebit$ticker),
  function(company) {
    rolling_origin_resamples <- rsample::rolling_origin(
      data_ebit[ticker == company, c("ticker", "index", "value")],
      initial = n_initial,
      assess = cv_setting_test$periods_test,
      cumulative = FALSE,
      skip = cv_setting_test$skip_span
    )
    dt_int <- setDT(purrr::map_df(rolling_origin_resamples$splits, function(split) {
      data_int <- setDT(rbind(rsample::analysis(split), rsample::assessment(split)))
      acf_int <- acf(data_int$value, lag.max = 4, plot = FALSE)$acf[2:5]
      names(acf_int) <- paste("acf", 1:4, sep = "_")
      acf_int
    }, .id = "split"))
    dt_int[, ticker := company]
  }
)

acc_ebit <- acc_ebit[acf_ebit[, lapply(.SD, mean), .SDcols = patterns("acf"), by = "ticker"], on = "ticker"]

saveRDS(acc_ebit, "05_results/acc_ebit.rds", compress = "xz")

### 2. NI
acc_ni <- readRDS("05_results/acc_ni.rds")
data_ni <- readRDS("data/data_ni.rds")

acf_ni <- purrr::map_df(
  unique(acc_ni$ticker),
  function(company) {
    rolling_origin_resamples <- rsample::rolling_origin(
      data_ni[ticker == company, c("ticker", "index", "value")],
      initial = n_initial,
      assess = cv_setting_test$periods_test,
      cumulative = FALSE,
      skip = cv_setting_test$skip_span
    )
    dt_int <- setDT(purrr::map_df(rolling_origin_resamples$splits, function(split) {
      data_int <- setDT(rbind(rsample::analysis(split), rsample::assessment(split)))
      acf_int <- acf(data_int$value, lag.max = 4, plot = FALSE)$acf[2:5]
      names(acf_int) <- paste("acf", 1:4, sep = "_")
      acf_int
    }, .id = "split"))
    dt_int[, ticker := company]
  }
)

acc_ni <- acc_ni[acf_ni[, lapply(.SD, mean), .SDcols = patterns("acf"), by = "ticker"], on = "ticker"]

saveRDS(acc_ni, "05_results/acc_ni.rds", compress = "xz")

### 3. EPS
acc_eps <- readRDS("05_results/acc_eps.rds")
data_eps <- readRDS("data/data_eps.rds")

acf_eps <- purrr::map_df(
  unique(acc_eps$ticker),
  function(company) {
    rolling_origin_resamples <- rsample::rolling_origin(
      data_eps[ticker == company, c("ticker", "index", "value")],
      initial = n_initial,
      assess = cv_setting_test$periods_test,
      cumulative = FALSE,
      skip = cv_setting_test$skip_span
    )
    dt_int <- setDT(purrr::map_df(rolling_origin_resamples$splits, function(split) {
      data_int <- setDT(rbind(rsample::analysis(split), rsample::assessment(split)))
      acf_int <- acf(data_int$value, lag.max = 4, plot = FALSE)$acf[2:5]
      names(acf_int) <- paste("acf", 1:4, sep = "_")
      acf_int
    }, .id = "split"))
    dt_int[, ticker := company]
  }
)

acc_eps <- acc_eps[acf_eps[, lapply(.SD, mean), .SDcols = patterns("acf"), by = "ticker"], on = "ticker"]

saveRDS(acc_eps, "05_results/acc_eps.rds", compress = "xz")
