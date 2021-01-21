library(data.table)
library(tsRNN)
library(keras)
library(future)
library(furrr)
cores <- future::availableCores()
plan(multisession, workers = cores)

dummies <- readRDS("data/dummies.rds")

cv_setting_tune <- list(
  periods_train = 36,
  periods_val = 6,
  periods_test = 6,
  skip_span = 3
)
cv_setting_test <- list(
  periods_train = 42,
  periods_val = 0,
  periods_test = 6,
  skip_span = 3
)
