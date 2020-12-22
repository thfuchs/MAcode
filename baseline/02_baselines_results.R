# Evaluation of

### Settings -------------------------------------------------------------------
library(data.table)

# Accuracy Measures
str_point_acc <- c("smape", "mase")
str_dist_acc <- c("smis", "acd")

### EBIT -----------------------------------------------------------------------
fc_baselines_ebit <- readRDS("baseline/fc_baselines_ebit.rds")

samples <- purrr::map_df(
  fc_baselines_ebit,
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
# Point Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_point_acc
)

# Distribution Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_dist_acc
)

### Net Income -----------------------------------------------------------------
fc_baselines_ni <- readRDS("baseline/fc_baselines_ni.rds")

samples <- purrr::map_df(
  fc_baselines_ni,
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
# Point Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_point_acc
)

# Distribution Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_dist_acc
)

### EPS ------------------------------------------------------------------------
fc_baselines_eps <- readRDS("baseline/fc_baselines_eps.rds")

samples <- purrr::map_df(
  fc_baselines_eps,
  ~ purrr::map_df(.x, "accuracy", .id = "split"),
  .id = "company"
)
# Point Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_point_acc
)

# Distribution Accuracy Measure
data.table::dcast(
  samples,
  factor(type, levels = unique(type)) ~ factor(h, levels = unique(h)),
  fun = mean,
  value.var = str_dist_acc
)

