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
regex <- "(^[A-Z]+)\\s([A-Z]+)\\s(Equity)"
dummies[, ticker := gsub(regex, "\\1_\\2", ticker_full, perl = TRUE)]
dummies[, country_full_name := tools::toTitleCase(tolower(country_full_name))]

# Checks
dummies[, .N] == data.table::uniqueN(dummies, by = "ticker")

# Save data
saveRDS(dummies, file = "data/dummies.rds", compress = "xz")
