############################## 01_dummies.R ####################################

################################################################################
### Read 'data/rawdata/spx_sxxr_30y_dummies.csv', containing information per ###
### company: Index, company name, industry classification (GICS) and country ###
### Information used for graphics on ticker/company-level and data overview. ###
################################################################################

library(data.table)

# Read data
dummies <- data.table::fread(
  file = "data/rawdata/spx_sxxr_30y_dummies.csv",
  na.strings = "#N/A N/A",
  header = TRUE,
  sep = ";",
  dec = ",",
  stringsAsFactors = FALSE
)

# Transformations
dummies <- janitor::clean_names(dummies)
dummies[, ticker_full := ticker]
regex1 <- "[-!$%\\^&\\*\\(\\)_+\\|/~=`\\{\\}?,\\.]+"
dummies[, ticker := gsub(regex1, "_", ticker_full ,perl = TRUE)]
regex2 <- "(^[A-Z_0-9]+)\\s([A-Z]+)\\s(Equity)"
dummies[, ticker := gsub(regex2, "\\1_\\2", ticker, perl = TRUE)]
regex3 <- "(_)\\1*"
dummies[, ticker := gsub(regex3, "_", ticker, perl = TRUE)]
dummies[, country_full_name := tools::toTitleCase(tolower(country_full_name))]

# Checks
dummies[, .N] == data.table::uniqueN(dummies, by = "ticker")
nrow(dummies[grep("Equity|/__", ticker)]) == 0

# Save data
saveRDS(dummies, file = "data/dummies.rds", compress = "xz")
