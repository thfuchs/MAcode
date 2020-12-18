############################# 03_clean_data ####################################

################################################################################
### Impute missing values and clean data anomalies                           ###
################################################################################

### Intro ----------------------------------------------------------------------
library(data.table)
data <- readRDS("data/data.rds")

min_date <- min(data$date, na.rm = TRUE); min_date
max_date <- max(data$date, na.rm = TRUE); max_date

# Start Q1 2000, end Q4 2019 (in total more data points than starting with 1990)
data <- data[between(date, "2000-01-01", "2019-12-31", incbounds = TRUE)]

min_date <- min(data$date, na.rm = TRUE); min_date
max_date <- max(data$date, na.rm = TRUE); max_date
n <- round(as.numeric(difftime(max_date, min_date, units = "weeks")/52.25) * 4) + 1; n

### General data preparation ---------------------------------------------------

# Keep only ticker with >= 60% data points
data <- data[
  , .SD[sum(complete.cases(.SD)) >= n * 0.6],
  by = ticker, .SDcols = c("ebit", "net_income", "eps")
]

# Keep only ticker with gap size below 5 (a maximum of 4 gaps in a row)
data_na_rep <- data[, lapply(.SD, function(x) {
  na_reps <- rle(is.na(x))
  max(na_reps$length * na_reps$values)
}), .SDcols = c("ebit", "net_income", "eps"), by = "ticker"]
data_na_rep_ticker <- data_na_rep[, row_max := pmax(ebit, net_income, eps)][row_max < 5, ticker]

nrow(data[ticker %in% data_na_rep_ticker]) / nrow(data)
nrow(data[ticker %in% data_na_rep_ticker]) / nrow(readRDS("data/data.rds"))

data <- data[ticker %in% data_na_rep_ticker]

# Split data into "data_ebit", "data_ni", "data_eps" series
data_ebit <- data[, .(ticker, date, ebit)]
data.table::setnames(data_ebit, c("date", "ebit"), c("index", "value"))

data_ni <- data[, .(ticker, date, net_income)]
data.table::setnames(data_ni, c("date", "net_income"), c("index", "value"))

data_eps <- data[, .(ticker, date, eps)]
data.table::setnames(data_eps, c("date", "eps"), c("index", "value"))

### Detect and remove outlier and impute missing values ------------------------
clean_data <- function(value_col, date_col) {
  ts_obj <- stats::ts(
    value_col,
    frequency = 4,
    start = c(year(min(date_col)), quarter(min(date_col))),
    end = c(year(max(date_col)), quarter(max(date_col)))
  )
  # Remove outliers
  outliers <- forecast::tsoutliers(ts_obj, iterate = 3)
  ts_obj[outliers$index] <- outliers$replacements
  # Impute missing values
  forecast::na.interp(ts_obj)
}

data_ebit[, original := value][, value := clean_data(value, index), by = id_col]
data_ebit[, clean := data.table::fcase(
  is.na(original), "imputed", value != original, "yes", default = "no")]

data_ni[, original := value][, value := clean_data(value, index), by = id_col]
data_ni[, Outlier := data.table::fcase(
  is.na(original), "imputed", value != original, "yes", default = "no")]

data_eps[, original := value][, value := clean_data(value, index), by = id_col]
data_eps[, Outlier := data.table::fcase(
  is.na(original), "imputed", value != original, "yes", default = "no")]

# Quick check: Still any missing value?
if (nrow(data_ebit[!complete.cases(value), .N, by = "ticker"]) > 0) rlang::abort(
  message = "Quick check (1a) failed.\nCheck missing values in data_ebit")
if (nrow(data_ni[!complete.cases(value), .N, by = "ticker"]) > 0) rlang::abort(
  message = "Quick check (1b) failed.\nCheck missing values in data_ni")
if (nrow(data_eps[!complete.cases(value), .N, by = "ticker"]) > 0) rlang::abort(
  message = "Quick check (1c) failed.\nCheck missing values in data_eps")

### Save cleaned data ----------------------------------------------------------
saveRDS(data_ebit, file = "data/data_ebit.rds", compress = "xz")
saveRDS(data_ni, file = "data/data_ni.rds", compress = "xz")
saveRDS(data_eps, file = "data/data_eps.rds", compress = "xz")
