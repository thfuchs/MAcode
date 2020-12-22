# Forecasts and Evaluations for Baseline Models

### Settings -------------------------------------------------------------------
library(data.table)
library(future)
library(furrr)
library(tsRNN)

data_ebit <- readRDS("data/data_ebit.rds")[, .(ticker, index, value)]
dummies <- readRDS("data/dummies.rds")[ticker %in% unique(data_ebit$ticker)]

cv_setting <- list(
  periods_train = 36,
  periods_val = 6,
  periods_test = 6,
  skip_span = 3
)

multiple_h <- list(short = 1, medium = 1:4, long = 5:6, total = 1:6)

### EBIT -----------------------------------------------------------------------
plan(multisession)

forecast <- furrr::future_map(
  dummies$ticker,
  purrr::possibly(function(x) {
    d <- data_ebit[ticker == x]
    predict_baselines(d, cv_setting, multiple_h = multiple_h)
  }, otherwise = NULL),
  .options = furrr::furrr_options(seed = 123) # seed for bootstrapped based PI
)

message <- "Baseline estimation finished!"
content <- jsonlite::toJSON(list(list(
  type = "section",
  text = list(type = "mrkdwn", text = message)
)), auto_unbox = TRUE)

bin <- httr::POST(
  url = 'https://slack.com/api/chat.postMessage',
  body = list(token = Sys.getenv("SLACK_BOT"),
              channel = Sys.getenv("SLACK_CHANNEL"), `blocks` = paste(content))
)

fc_baselines_ebit <- purrr::compact(forecast)
str(fc_baselines_ebit, max.level = 1)

save(fc_baselines_ebit, file = "baseline/fc_baselines_ebit.rda")
load(file = "baseline/fc_baselines_ebit.rda")

# Accuracy Measures
str_point_acc <- c("smape", "mase")
str_dist_acc <- c("smis", "acd")

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

### EBITDA ---------------------------------------------------------------------


### Net Income -----------------------------------------------------------------

