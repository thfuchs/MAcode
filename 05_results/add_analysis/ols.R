library(data.table)
ebit <- readRDS("05_results/acc_ebit_dl.rds")
ni <- readRDS("05_results/acc_ni_dl.rds")
eps <- readRDS("05_results/acc_eps_dl.rds")

smape_f <- formula(log(smape) ~ n_units + n_epochs + dropout + recurrent_dropout + optimizer_type + log(learning_rate) + lag_1_d + lag_2_d + lag_3_d + lag_4_d + split + type)
mase_f <- formula(log(mase) ~ n_units + n_epochs + dropout + recurrent_dropout + optimizer_type + log(learning_rate) + lag_1_d + lag_2_d + lag_3_d + lag_4_d + split + type)
smis_f <- formula(log(smis) ~ n_units + n_epochs + dropout + recurrent_dropout + optimizer_type + log(learning_rate) + lag_1_d + lag_2_d + lag_3_d + lag_4_d + split + type)

reg_ebit_smape <- lm(smape_f, data = ebit)
reg_ebit_mase <- lm(mase_f, data = ebit)
reg_ebit_smis <- lm(smis_f, data = ebit)

reg_ni_smape <- lm(smape_f, data = ni)
reg_ni_mase <- lm(mase_f, data = ni)
reg_ni_smis <- lm(smis_f, data = ni)

reg_eps_smape <- lm(smape_f, data = eps)
reg_eps_mase <- lm(mase_f, data = eps)
reg_eps_smis <- lm(smis_f, data = eps)

### Output
texreg::texreg(
  list(reg_ebit_smape, reg_ebit_mase, reg_ebit_smis, reg_ni_smape, reg_ni_mase,
       reg_ni_smis, reg_eps_smape, reg_eps_mase, reg_eps_smis),
  table = TRUE,
  booktabs = TRUE,
  label = "tab:ols",
  caption.above = TRUE,
  caption = "OLS estimates for Hyperparameter on accuracy",
  dcolumn = FALSE,
  digits = 2,
  leading.zero = FALSE,
  custom.model.names = rep(c("sMAPE", "MASE", "sMIS"), 3),
  omit.coef = "^split|^type",
  custom.coef.names = c(
    "Intercept", "No. Units", "No. Epochs", "Dropout rate", "Recurrent dropout rate",
    "Optimizer (Adam)", "Optimizer (Adagrad)", "Learning rate", "Lag 1", "Lag 2", "Lag 3", "Lag 4"),
  custom.header = list("EBIT" = 1:3, "Net Income" = 4:6, "EPS" = 7:9)
)
