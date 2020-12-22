############################ 02_arima_results ##################################

################################################################################
######################### Evaluation of ARIMA results ##########################
################################################################################

### Settings -------------------------------------------------------------------
library(data.table)

# Accuracy Measures
str_point_acc <- c("smape", "mase")
str_dist_acc <- c("smis", "acd")

### EBIT -----------------------------------------------------------------------
readRDS(file = "arima/fc_arima_ebit.rds")

samples <- purrr::map_df(
  fc_arima_ebit,
  ~ purrr::map_df(.x, "accuracy")[
    , lapply(.SD, mean), by = type, .SDcols = c(str_point_acc, str_dist_acc)],
  .id = "id"
)
point_acc <- samples[, lapply(.SD, mean), .SDcols = str_point_acc, by = "type"]; point_acc
dist_acc <- samples[, lapply(.SD, mean), .SDcols = str_dist_acc, by = "type"]; dist_acc

# Accuracy Measures (per h)
acc <- purrr::map_df(
  fc_baselines_ebit,
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
# Point Accuracy Measure
data.table::dcast(
  acc,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_point_acc
)

# Distribution Accuracy Measure
data.table::dcast(
  acc,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_dist_acc
)

# Chart for single ticker (e.g. AAPL)
plot_prediction_samples(
  splits = purrr::map(fc_arima_ebit[[1]], "forecast"),
  title = "ARMIA Forecast including Prediction Interval for APPL",
  ncol = 3,
  scale = as.Date(c(min(data$index), max(data$index))),
  PI = TRUE
)

### EBITDA ---------------------------------------------------------------------


### Net Income -----------------------------------------------------------------

