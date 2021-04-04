### Intro ----------------------------------------------------------------------
library(ggplot2)
library(data.table)

gg_theme <- theme(
  plot.background = element_rect(fill = NA),
  panel.background = element_rect(fill = NA),
  panel.grid.major = element_blank(),
  panel.border = element_blank(),
  axis.ticks.y = element_blank(),
  legend.position = "bottom",
  legend.key = element_blank(),
  panel.spacing = unit(0.5, "lines")
)

dummies <- readRDS("data/dummies.rds")
acc_ebit <- readRDS("05_results/acc_ebit.rds")
acc_ni <- readRDS("05_results/acc_ni.rds")
acc_eps <- readRDS("05_results/acc_eps.rds")

acc <- rbindlist(
  list(ebit = acc_ebit, ni = acc_ni, eps = acc_eps),
  use.names = TRUE,
  idcol = "id"
)[dummies, on = "ticker"]
acc[, id := factor(id, levels = c("ebit", "ni", "eps"))]
# for stacked bar plots: Rank with ties.method "min", not "mean"
acc[
  , paste0("minrank_", c("smape", "mase", "smis")) := lapply(.SD, frank, ties.method = "min"),
  by = c("id", "ticker", "h"),
  .SDcols = c("smape", "mase", "smis")
]

acc_rank_melt <- data.table::melt(
  acc,
  id.vars = c("ticker", "type", "h"),
  measure.vars = c("minrank_mase", "minrank_smis"),
  variable.name = "metric",
  value.name = "rank"
)
acc_rank_melt[, metric := factor(
  metric,
  levels = c("minrank_mase", "minrank_smis"),
  labels = c("MASE (rk)", "sMIS (rk)")
)]
acc_rank_melt[, h := factor(
  h,
  levels = c("short", "medium", "long", "total"),
  labels = c("Quarter", "Year", "Long", "Total")
)]
# Re-Factor rank and type for "correct" ordering
acc_rank_melt[, rank := factor(rank, levels = sort(unique(rank), decreasing = TRUE))]
acc_rank_melt[, type := factor(type, levels = rev(levels(type)))]

# Barstack plot
ggplot(
  acc_rank_melt[metric %in% c("MASE (rk)") & type %in% c("ARIMA", "Simple", "GRU", "LSTM", "ARNN") & h == "Total"],
  mapping = aes(y = type, fill = rank)
) +
  geom_bar(position = "fill", width = 0.8) +
  facet_grid(~ metric) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  scale_fill_brewer(palette = "RdYlBu") +
  xlab(NULL) + ylab(NULL) +
  guides(fill = guide_legend(title = "Rank", reverse = TRUE)) +
  gg_theme

### Top 10% acf for 1 quarter --------------------------------------------------
acc_top <- acc[h == "total" & abs(acf_1) >= quantile(abs(acf_1), 0.9)] #acf_4

acc_top_rank_melt <- data.table::melt(
  acc_top,
  id.vars = c("ticker", "type", "h"),
  measure.vars = c("minrank_mase", "minrank_smis"),
  variable.name = "metric",
  value.name = "rank"
)
acc_top_rank_melt[, metric := factor(
  metric,
  levels = c("minrank_mase", "minrank_smis"),
  labels = c("MASE (rk)", "sMIS (rk)")
)]
acc_top_rank_melt[, h := factor(
  h,
  levels = c("short", "medium", "long", "total"),
  labels = c("Quarter", "Year", "Long", "Total")
)]
# Re-Factor rank and type for "correct" ordering
acc_top_rank_melt[, rank := factor(rank, levels = sort(unique(rank), decreasing = TRUE))]
acc_top_rank_melt[, type := factor(type, levels = rev(levels(type)))]

# Barstack plot
ggplot(
  acc_top_rank_melt[metric %in% c("MASE (rk)") & type %in% c("ARIMA", "Simple", "GRU", "LSTM", "ARNN") & h == "Total"],
  mapping = aes(y = type, fill = rank)
) +
  geom_bar(position = "fill", width = 0.8) +
  # facet_grid(~ metric) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  scale_fill_brewer(palette = "RdYlBu") +
  xlab(NULL) + ylab(NULL) +
  guides(fill = guide_legend(title = "Rank", reverse = TRUE)) +
  gg_theme

### Bottom 10% acf for 1 quarter -----------------------------------------------
acc_low <- acc[h == "total" & abs(acf_1) <= quantile(abs(acf_1), 0.1)]

acc_low_rank_melt <- data.table::melt(
  acc_low,
  id.vars = c("ticker", "type", "h"),
  measure.vars = c("minrank_mase", "minrank_smis"),
  variable.name = "metric",
  value.name = "rank"
)
acc_low_rank_melt[, metric := factor(
  metric,
  levels = c("minrank_mase", "minrank_smis"),
  labels = c("MASE (rk)", "sMIS (rk)")
)]
acc_low_rank_melt[, h := factor(
  h,
  levels = c("short", "medium", "long", "total"),
  labels = c("Quarter", "Year", "Long", "Total")
)]
# Re-Factor rank and type for "correct" ordering
acc_low_rank_melt[, rank := factor(rank, levels = sort(unique(rank), decreasing = TRUE))]
acc_low_rank_melt[, type := factor(type, levels = rev(levels(type)))]

# Barstack plot
ggplot(
  acc_low_rank_melt[metric %in% c("MASE (rk)") & type %in% c("ARIMA", "Simple", "GRU", "LSTM", "ARNN") & h == "Total"],
  mapping = aes(y = type, fill = rank)
) +
  geom_bar(position = "fill", width = 0.8) +
  # facet_grid(h ~ metric) +
  scale_x_discrete(expand = c(0, 0)) +
  scale_y_discrete(expand = c(0, 0)) +
  scale_fill_brewer(palette = "RdYlBu") +
  xlab(NULL) + ylab(NULL) +
  guides(fill = guide_legend(title = "Rank", reverse = TRUE)) +
  gg_theme


### Violin Plots for selected Models -------------------------------------------
library(vioplot)
vio_cols <- c("ARIMA", "Simple", "GRU", "LSTM", "ARNN")

acc_rank_melt_vio <- data.table::copy(acc_rank_melt)[type %in% vio_cols & metric == "MASE (rk)" & h == "Total"]
acc_rank_melt_vio[, rank := as.numeric(as.character(rank))]
acc_rank_melt_vio[, type := factor(type, levels = vio_cols)]

acc_top_rank_melt_vio <- data.table::copy(acc_top_rank_melt)[type %in% vio_cols & metric == "MASE (rk)" & h == "Total"]
acc_top_rank_melt_vio[, rank := as.numeric(as.character(rank))]
acc_top_rank_melt_vio[, type := factor(type, levels = vio_cols)]

# acc_low_rank_melt_vio <- data.table::copy(acc_low_rank_melt)[type %in% vio_cols & metric == "MASE (rk)" & h == "Total"]
# acc_low_rank_melt_vio[, rank := as.numeric(as.character(rank))]
# acc_low_rank_melt_vio[, type := factor(type, levels = vio_cols)]

vioplot(
  rank ~ type,
  acc_rank_melt_vio,
  col = "palevioletred",
  plotCentre = "line",
  side = "left",
  xlab = NULL,
  ylab = "MASE (rk)",
  frame.plot = FALSE
)
box(bty = "l")
vioplot(
  rank ~ type,
  data = acc_low_rank_melt_vio,
  col = "lightblue",
  plotCentre = "line",
  side = "right",
  add = TRUE,
  frame.plot = FALSE
)
points(
  1:5,
  acc_rank_melt_vio[, median(rank), by = type]$V1,
  pch = 21, col = "palevioletred4", bg = "palevioletred2"
)
points(
  1:5,
  acc_top_rank_melt_vio[, median(rank), by = type]$V1,
  pch = 21, col = "lightblue4", bg = "lightblue2"
)
