######################### 02_transform_from_raw ################################

################################################################################
### Read 'data/rawdata/spx_sxxr_30y.csv' and transform to "tidy" data        ###
################################################################################

library(data.table)

### Companies
companies <- as.character(data.table::fread(
  file = "data/rawdata/spx_sxxr_30y.csv",
  na.strings = "#N/A N/A",
  header = FALSE,
  nrows = 1,
  drop = 1,
  sep = ";",
  dec = ",",
  stringsAsFactors = FALSE
))

# Quick checks (1)
if (nrow(data.table(x = companies)[, .N, by = x][N != 3]) != 0) rlang::abort(
  message = paste0(
    "Quick check (1) failed.\n",
    "Check that all companies have exactly 3 observations for \"EPS\", ",
    "\"EBIT\" and \"Net Income\"")
)

# Keep only single observation per company
companies <- unique(companies)

# Quick checks (2)
dummies <- readRDS("data/dummies.rds")
if (length(companies) != nrow(dummies)) rlang::abort(message = paste0(
  "Quick check (2a) failed.\n",
  "Check why the length of dummy tickers and company tickers is not identical")
)
if (!all(companies %in% dummies$ticker_full)) rlang::abort(message = paste0(
  "Quick check (2b) failed.\n",
  "Check which company tickers are missing in dummy tickers")
)

### type
data_type <- as.character(data.table::fread(
  file = "data/rawdata/spx_sxxr_30y.csv",
  na.strings = "#N/A N/A",
  header = FALSE,
  nrows = 1,
  skip = 1,
  drop = 1,
  sep = ";",
  dec = ",",
  stringsAsFactors = FALSE
))
data_type_length <- sapply(unique(data_type), function(x) sum(data_type == x))

# Quick checks (3)
if (length(unique(data_type_length)) > 1) rlang::abort(message = paste0(
  "Quick check (3a) failed.\n",
  "Check why the data types (EPS, EBIT, Net Income) are of different length")
)
if (length(companies) != unique(data_type_length)[1]) rlang::abort(message = paste0(
  "Quick check (3b) failed.\n",
  "Check why the length of unique company tickers is not identical to the ",
  "length of each data type (EPS, EBIT, Net Income)")
)
if (!all(sort(names(data_type_length)) == c("EBIT", "IS_EPS", "NET_INCOME")))
  rlang::abort(message = paste0(
    "Quick check (3c) failed.\n",
    "Check that the data solely contain type \"EBIT\", \"IS_EPS\" and \"NET_INCOME\""
  ))

# Keep only single observation per data type
data_type <- unique(data_type)

### data
setClass('myDate')
setAs("character", "myDate", function(from) as.Date(from, "%d.%m.%Y"))

raw <- data.table::fread(
  file = "data/rawdata/spx_sxxr_30y.csv",
  na.strings = c("#N/A N/A", "-"),
  skip = 1,
  colClasses = list(myDate = 1, numeric = 2:(length(companies) * length(data_type) + 1)),
  sep = ";",
  dec = ",",
  header = TRUE,
  strip.white = TRUE,
  check.names = FALSE,
  fill = TRUE,
  # encoding = "UTF-8",
  stringsAsFactors = FALSE
)

# Quick checks (4)
if (nrow(raw[, .SD, .SDcols = is.character]) > 0) rlang::abort(message = paste0(
  "Quick check (4) failed.\n",
  "Columns coerced to type \"character\" while only Date and numeric are valid")
)

data_per_cf_type <- sapply(data_type, function(filter_obj) {
  type <- raw[, c(1, which(names(raw) == filter_obj)), with = FALSE]
  data.table::setnames(type, new = c("date", companies))
}, simplify = FALSE, USE.NAMES = TRUE)

data_per_company <- data.table::rbindlist(data_per_cf_type, idcol = "type")

data_long <- data.table::melt(
  data_per_company,
  id.vars = c("type", "date"),
  variable.name = "company"
)
data <- data.table::dcast(data_long, company + date ~ type)

# Transformations
data <- janitor::clean_names(data)
setnames(data, "is_eps", "eps")
data <- data[dummies[, c("ticker", "ticker_full")], on = .(company = ticker_full)]

# Quick checks (5)
if (uniqueN(data$ticker) != uniqueN(data$company)) rlang::abort(message = paste0(
  "Quick check (5) failed.\n",
  "Check regular expression: Length of company and ticker differ")
)
data[, company := NULL]

# Save data
data.table::setcolorder(
  data,
  neworder = c("ticker", "date", "ebit", "net_income", "eps")
)
saveRDS(data, file = "data/data.rds", compress = "xz")
