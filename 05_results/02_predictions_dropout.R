library(data.table)
library(aws.s3)
library(keras)

aws.s3::bucketlist()
aws.s3::bucket_exists(bucket = Sys.getenv("AWS_BUCKET"))

s3_fun <- function(model, data, company, split) {
  file <- file.path(model, "models", data, paste(data, model, company, paste0("Slice", split), "01.hdf5", sep = "_"))
  if (!isTRUE(aws.s3::object_exists(object = file, bucket = Sys.getenv("AWS_BUCKET")))) {
    message("No File")
    return(NULL)
  }

  path <- aws.s3::save_object(
    object = file,
    file = paste0(tempfile(), ".hdf5"),
    bucket = Sys.getenv("AWS_BUCKET")
  )
  k_model <- keras::load_model_hdf5(path)

  config <- k_model$get_config()
  dropout_layer <- config$layers[[3]]

  if (dropout_layer$class_name != "Dropout") {
    message("No dropout layer")
    return(NULL)
  }

  keras::k_clear_session()
  config$layers[[3]]$config$rate
}

### Let's go
dummies <- readRDS("data/dummies.rds")

rate_data <- data.table(
  ticker = rep(dummies$ticker, each = 3*3*9),
  id = rep(c("ebit", "ni", "eps"), 481, each = 3*9),
  type = rep(c("simple", "lstm", "gru"), 481*3, each = 9),
  split = rep(1:9, 481*3*3)
)

rate_data[, dropout := purrr::pmap(
  list(ticker, id, type, split),
  purrr::possibly(function(f_ticker, f_id, f_type, f_split) s3_fun(
    model = f_type,
    data = f_id,
    company = f_ticker,
    split = f_split
  ), otherwise = NA_real_, quiet = FALSE)
)]

rate_data[, dropout := as.numeric(dropout)]
rate_data[, id := factor(id, levels = c("ebit", "ni", "eps"), labels = c("EBIT", "Net Income", "EPS"))]
rate_data[, type := factor(type, levels = c("simple", "lstm", "gru"), labels = c("Simple", "LSTM", "GRU"))]

saveRDS(rate_data, "05_results/predictions_dropout.rds", compress = "xz")

# s3_fun(model = "simple", data = "ni", company = "RAND_NA", split = 3)
