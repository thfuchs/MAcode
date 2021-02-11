### Settings -------------------------------------------------------------------

library(ggplot2)

acc_ebit_03 <- readRDS("05_results/acc_ebit_03.rds")

### Data Vis: Predictions ------------------------------------------------------


### Data Vis: Accuracy ---------------------------------------------------------
# boxplot(mape ~ h, data = acc_ebit_03)
# boxplot(smape ~ h, data = acc_ebit_03)
# boxplot(mase ~ h, data = acc_ebit_03)
# boxplot(smis ~ h, data = acc_ebit_03)
# boxplot(acd ~ h, data = acc_ebit_03)

# ggplot(acc_ebit_03, aes(x = factor(h), y = mape)) +
#   geom_violin()

##
acc_ebit_03_melt <- data.table::melt(
  acc_ebit_03,
  id.vars = c("company", "split", "type", "h"),
  measure.vars = c("smape", "mase", "smis", "acd"),
  variable.name = "metric",
  value.name = "accuracy"
)
acc_ebit_03_melt[, type := factor(
  type,
  levels = c("Baselines", "ARIMA", "arnn_mean", "rnn"),
  labels = c("Baselines", "ARIMA", "ARNN", "RNN")
)]
acc_ebit_03_melt[, h := factor(
  h,
  levels = c("short", "medium", "long", "total"),
  labels = c("Q1", "Q1 - Q4", "Q5 - Q6", "Total")
)]
acc_ebit_03_melt[, metric := factor(
  metric,
  levels = c("smape", "mase", "smis", "acd"),
  labels = c("sMAPE", "MASE", "sMIS", "ACD")
)]

acc_ebit_03_melt_PF <- acc_ebit_03_melt[metric %in% c("sMAPE", "MASE")]
acc_ebit_03_melt_PF_split <- acc_ebit_03_melt_PF[, .(mean = mean(accuracy)), by = c("company", "type", "h", "metric")]

dodge <- position_dodge(width = 0.8)

# sMAPE & MASE
ggplot(acc_ebit_03_melt_PF_split, aes(x = h, y = mean)) +
  geom_violin(aes(group=interaction(type, h)), position = dodge) +
  geom_boxplot(aes(fill = type), width = 0.08, outlier.shape = NA, position = dodge) +
  facet_wrap(~ metric, scales = "free", ncol = 1) +
  xlab(NULL) + ylab(NULL) +
  theme(
    plot.background = element_rect(fill = NA),
    panel.background = element_rect(fill = NA, colour = "black"),
    panel.grid.major = element_line(colour = "lightgrey"),
    panel.grid.major.x = element_blank(),
    legend.title = element_blank(),
    legend.position = "bottom",
    legend.key = element_blank()
  )

# ggplot(acc_ebit_03_melt, aes(x = factor(h), y = accuracy, fill = factor(metric))) +
#   # geom_violin() +
#   geom_boxplot() +
#   facet_wrap(~ factor(type))


# sMAPE: Scaled single plots
ggplot(acc_ebit_03_melt[metric == "smape"], aes(
  x = factor(h,
             levels = c("short", "medium", "long", "total"),
             labels = c("Q1", "Q1 - Q4", "Q5 - Q6", "Total")),
  y = accuracy,
  fill = factor(type,
                levels = c("Baselines", "ARIMA", "arnn_mean", "rnn"),
                labels = c("Baselines", "ARIMA", "ARNN", "RNN"))
)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(ylim = c(0, 75)) +
  xlab(NULL) +
  theme(legend.title = element_blank(), legend.position = "bottom")

# MASE: Scaled single plots
ggplot(acc_ebit_03_melt[metric == "mase"], aes(
  x = factor(h,
             levels = c("short", "medium", "long", "total"),
             labels = c("Q1", "Q1 - Q4", "Q5 - Q6", "Total")),
  y = accuracy,
  fill = factor(type,
                levels = c("Baselines", "ARIMA", "arnn_mean", "rnn"),
                labels = c("Baselines", "ARIMA", "ARNN", "RNN"))
)) +
  geom_boxplot(outlier.shape = NA) +
  coord_cartesian(ylim = c(0, 4)) +
  xlab(NULL) +
  theme(legend.title = element_blank(), legend.position = "bottom")

# sMIS: scaled and without Baselines
dodge <- position_dodge(width = 0.8)
ggplot(acc_ebit_03_melt[metric == "smis" & !type %in% c("Baselines", "arnn_mean")], aes(
  x = factor(h,
             levels = c("short", "medium", "long", "total"),
             labels = c("Q1", "Q1 - Q4", "Q5 - Q6", "Total")),
  y = accuracy,
  fill = factor(type, levels = c("ARIMA", "rnn"), labels = c("ARIMA", "RNN"))
)) +
  geom_violin(position = dodge) +
  geom_boxplot(width = 0.08, outlier.shape = NA, position = dodge) +
  coord_cartesian(ylim = c(0, 8)) +
  xlab(NULL) +
  theme(legend.title = element_blank(), legend.position = "bottom")
