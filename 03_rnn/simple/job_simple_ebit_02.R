############################ job_simple_ebit_02.R ##############################

################################################################################
### Training and forecasting on cross-validation splits with tuned parameters ##
################################################################################

### Settings -------------------------------------------------------------------
rm(list = ls())

source("utils.R")
source("settings.R")

data_ebit_test <- readRDS("data/data_ebit.rds")[ticker == "BA_UN", .(index, value)]
load("03_rnn/simple/fc_ebit_test_rnn_bayes.rda")

### Job ------------------------------------------------------------------------
fc_ebit_test_rnn_prediction <- tune_keras_rnn_predict(
  data = data_ebit_test,
  col_id = NULL, col_date = "index", col_value = "value",
  model_type = "simple",
  cv_setting = cv_setting_test,
  bayes_best_par = purrr::map(fc_ebit_test_rnn_bayes, "Best_Par"),
  iter_dropout = 500,
  save_model = NULL
  # save_model_id = "ebit"
)

save(fc_ebit_test_rnn_prediction, file = "03_rnn/simple/fc_ebit_test_rnn_prediction.rda")

# Success / Failure message
if (length(purrr::compact(fc_ebit_test_rnn_prediction)) > 0)
  toSlack("Simple RNN EBIT (Test) prediction finished") else
    toSlack("Error: Simple RNN EBIT (Test) prediction failed")
