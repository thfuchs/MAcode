acc_mean_rank_save <- function(..., rank_str, type_old, type_new, file_path) {

  acc_split <- rbind(...)

  # Mean across splits
  acc <- acc_split[
    , lapply(.SD, mean), by = c("ticker", "type", "h"), .SDcols = rank_str
  ]

  # Ranks
  acc[
    , paste0("rank_", rank_str) := lapply(.SD, frank, ties.method = "average"),
    by = c("ticker", "h"),
    .SDcols = rank_str
  ]

  # Refactor and save
  if (is.null(type_old) || is.null(type_new)) {
    acc[, type := factor(type)]
  } else {
    acc[, type := factor(type, levels = type_old, labels = type_new)]
  }

  acc[, h := factor(h, levels = c("short", "medium", "long", "total"))]

  saveRDS(acc, file = file_path, compress = "xz")

  return(TRUE)
}

acc_rank_mean_save <- function(..., rank_str, type_old, type_new, file_path) {

  acc_split <- rbind(...)

  # Ranks
  acc_split[
    , paste0("rank_", acc_rank_str) := lapply(.SD, frank, ties.method = "average"),
    by = c("ticker", "split", "h"),
    .SDcols = acc_rank_str
  ]
  acc_rank_melt <- data.table::melt(
    acc_split,
    id.vars = c("ticker", "split", "type", "h"),
    measure.vars = c("rank_smape", "rank_mase", "rank_smis"),
    variable.name = "metric",
    value.name = "rank"
  )
  acc_rank_melt[, metric := factor(
    metric,
    levels = c("rank_smape", "rank_mase", "rank_smis"),
    labels = c("sMAPE (rk)", "MASE (rk)", "sMIS (rk)")
  )]

  # Mean
  acc_rank_avg <- acc_rank_melt[
    , .(rank_mean = mean(rank), rank_median = median(rank)),
    by = c("ticker", "type", "h", "metric")
  ]

  # Refactor and save
  if (is.null(type_old) || is.null(type_new)) {
    acc_rank_avg[, type := factor(type)]
  } else {
    acc_rank_avg[, type := factor(type, levels = type_old, labels = type_new)]
  }
  acc_rank_avg[, h := factor(h, levels = c("short", "medium", "long", "total"))]

  saveRDS(acc_rank_avg, file = file_path, compress = "xz")

  return(TRUE)
}
