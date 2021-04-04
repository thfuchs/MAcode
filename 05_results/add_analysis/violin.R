library(ggplot2)
library(data.table)
ebit <- readRDS("05_results/acc_ebit_dl.rds")
ni <- readRDS("05_results/acc_ni_dl.rds")
eps <- readRDS("05_results/acc_eps_dl.rds")

ebit[, dropout_class := round(dropout, 1)]
ebit[, recurrent_dropout_class := round(recurrent_dropout, 1)]

ebit_optim <- rbindlist(list(
  smape = ebit[, c("smape", "optimizer_type")],
  mase = ebit[, c("mase", "optimizer_type")],
  smis = ebit[, c("smis", "optimizer_type")]
), use.names = FALSE, idcol = "metric")
ebit_optim[, metric := factor(metric, levels = c("smape", "mase", "smis"), labels = c("log(sMAPE)", "log(MASE)", "log(sMIS)"))]
setnames(ebit_optim, "smape", "accuracy")

dodge <- position_dodge(width = 0.9)
gg_violin_theme <- theme(
  plot.background = element_rect(fill = NA),
  panel.background = element_rect(fill = NA),
  panel.border = element_blank(),
  panel.grid.major = element_line(colour = "lightgrey"),
  panel.grid.major.x = element_blank(),
  legend.title = element_blank(),
  legend.position = "bottom",
  legend.key = element_blank(),
  panel.spacing = unit(0.5, "lines"),
  axis.title = element_blank(),
  axis.text.x = element_blank(),
  axis.ticks = element_blank()
)

# Optimizer Type
ggplot(ebit_optim, aes(x = optimizer_type, y = log(accuracy))) +
  geom_violin(aes(group = optimizer_type), position = dodge) +
  geom_boxplot(aes(fill = optimizer_type), width = 0.18, outlier.shape = NA, position = dodge) +
  facet_grid(~ metric, scales = "free") +
  scale_fill_brewer(palette = "Set1", labels = c("RMSprop", "Adam", "Adagrad")) +
  guides(fill = guide_legend(nrow = 1, reverse = FALSE)) +
  gg_violin_theme

ggplot(ebit, aes(x = optimizer_type, y = log(mase), group = optimizer_type)) +
  geom_violin()
ggplot(ebit, aes(x = optimizer_type, y = log(smape), group = optimizer_type)) +
  geom_violin()
ggplot(ebit, aes(x = optimizer_type, y = log(smis), group = optimizer_type)) +
  geom_violin()

# (Recurrent) Dropout
ggplot(ebit, aes(x = dropout_class, y = log(mase), group = dropout_class)) +
  geom_violin()
ggplot(ebit, aes(x = recurrent_dropout_class, y = log(mase), group = recurrent_dropout_class)) +
  geom_violin()

ggplot(ebit, aes(x = recurrent_dropout, y = smape, group = recurrent_dropout)) +
  geom_point(size = 0.2)

plot(log(smape) ~ log(learning_rate), data = ebit, cex = 0.5, pch = 20)
abline(lm(log(smape) ~ log(learning_rate), data = ebit), col = "red")
