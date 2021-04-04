library(data.table)
cols <- c("ticker", "split", "type", "optimizer_type", "lag_1_d", "lag_2_d", "lag_3_d", "lag_4_d")

### 1. EBIT
acc_ebit <- rbind(
  purrr::map_df(
    readRDS("03_rnn/simple/results/fc_ebit_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_ebit_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/gru/results/fc_ebit_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  )
)

bayes_ebit <- rbind(
  setDT(purrr::map_df(
    readRDS("03_rnn/simple/results/fc_ebit_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "simple"],
  setDT(purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_ebit_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "lstm"],
  setDT(purrr::map_df(
    readRDS("03_rnn/gru/results/fc_ebit_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "gru"]
)
# dummies for lag 1 to lag 4
bayes_ebit[, lag_1_d := fifelse(lag_1 == 1 | lag_2 == 1, TRUE, FALSE)]
bayes_ebit[, lag_2_d := between(2, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_ebit[, lag_3_d := between(3, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_ebit[, lag_4_d := fifelse(lag_1 == 4 | lag_2 == 4, TRUE, FALSE)]

ebit <- acc_ebit[h == "total"][bayes_ebit, on = c("ticker", "type", "split")]
ebit[, h := NULL]

# Convert to factor
ebit[, paste(cols) := lapply(.SD, as.factor), .SDcols = cols]

saveRDS(ebit, "05_results/acc_ebit_dl.rds", compress = "xz")

### 2. Net Income
acc_ni <- rbind(
  purrr::map_df(
    readRDS("03_rnn/simple/results/fc_ni_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_ni_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/gru/results/fc_ni_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  )
)

bayes_ni <- rbind(
  setDT(purrr::map_df(
    readRDS("03_rnn/simple/results/fc_ni_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "simple"],
  setDT(purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_ni_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "lstm"],
  setDT(purrr::map_df(
    readRDS("03_rnn/gru/results/fc_ni_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "gru"]
)
# dummies for lag 1 to lag 4
bayes_ni[, lag_1_d := fifelse(lag_1 == 1 | lag_2 == 1, TRUE, FALSE)]
bayes_ni[, lag_2_d := between(2, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_ni[, lag_3_d := between(3, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_ni[, lag_4_d := fifelse(lag_1 == 4 | lag_2 == 4, TRUE, FALSE)]

ni <- acc_ni[h == "total"][bayes_ni, on = c("ticker", "type", "split")]
ni[, h := NULL]

# Convert to factor
ni[, paste(cols) := lapply(.SD, as.factor), .SDcols = cols]

saveRDS(ni, "05_results/acc_ni_dl.rds", compress = "xz")

### 3. EPS
acc_eps <- rbind(
  purrr::map_df(
    readRDS("03_rnn/simple/results/fc_eps_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_eps_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  ),
  purrr::map_df(
    readRDS("03_rnn/gru/results/fc_eps_rnn_eval.rds"),
    ~ data.table::rbindlist(.x, idcol = "split")[, split := as.integer(gsub("Slice", "", split))],
    .id = "ticker"
  )
)

bayes_eps <- rbind(
  setDT(purrr::map_df(
    readRDS("03_rnn/simple/results/fc_eps_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "simple"],
  setDT(purrr::map_df(
    readRDS("03_rnn/lstm/results/fc_eps_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "lstm"],
  setDT(purrr::map_df(
    readRDS("03_rnn/gru/results/fc_eps_rnn_bayes.rds"),
    ~ purrr::map_df(.x, "Best_Par", .id = "split"),
    .id = "ticker"
  ))[, split := as.integer(gsub("^Slice", "", split))][, type := "gru"]
)
# dummies for lag 1 to lag 4
bayes_eps[, lag_1_d := fifelse(lag_1 == 1 | lag_2 == 1, TRUE, FALSE)]
bayes_eps[, lag_2_d := between(2, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_eps[, lag_3_d := between(3, pmin(lag_1, lag_2), pmax(lag_1, lag_2))]
bayes_eps[, lag_4_d := fifelse(lag_1 == 4 | lag_2 == 4, TRUE, FALSE)]

eps <- acc_eps[h == "total"][bayes_eps, on = c("ticker", "type", "split")]
eps[, h := NULL]

# Convert to factor
eps[, paste(cols) := lapply(.SD, as.factor), .SDcols = cols]

saveRDS(eps, "05_results/acc_eps_dl.rds", compress = "xz")
